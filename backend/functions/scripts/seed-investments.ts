/**
 * Seed script — populates the Firestore emulator with investments for every user.
 *
 * Each simulated investment atomically:
 *   1. Creates a completed buy order in the orders collection
 *   2. Creates an investment record in users/{uid}/investments
 *   3. Debits wallets/{uid}.balance
 *   4. Creates a transaction record in users/{uid}/transactions
 *   5. Records a price snapshot in price_history/{startupId}/snapshots
 *   6. Decrements startups/{id}.available_tokens and recalculates token_price
 *
 * Orders and snapshots are created with past timestamps (30–90 days ago) so
 * onGetPatrimonyHistory can reconstruct meaningful chart data for every user.
 *
 * Run AFTER seed:users and seed:startups:
 *   npm run seed:investments
 *
 * Idempotent: users who already have at least one investment are skipped.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
process.env.FIRESTORE_EMULATOR_HOST ??= 'localhost:8080';

import {initializeApp} from 'firebase-admin/app';
import {FieldValue, getFirestore} from 'firebase-admin/firestore';

import type {InvestmentDocument}    from '../src/db/investments/model';
import type {OrderDocument}         from '../src/db/orders/model';
import type {PriceSnapshotDocument} from '../src/db/price_history/model';
import type {StartupDocument}       from '../src/db/startups/model';
import type {TransactionDocument}   from '../src/db/transactions/model';
import {calcTokenPrice}             from '../src/utils/pricing';


/**
 * CODE
 */

const app = initializeApp({projectId: 'mesclainvest-eda16'});
const db  = getFirestore(app);


/**
 * A simple stable string hash to generate deterministic random-like values.
 */
function hashCode(s: string): number
{
    let h = 0;
    for (let i = 0; i < s.length; i++)
    {
        h = ((h << 5) - h) + s.charCodeAt(i);
        h |= 0;
    }
    return Math.abs(h);
}


/**
 * I simulate one investment atomically, writing 6 documents in a single batch:
 *   1. Completed buy order       → orders/{id}
 *   2. Investment custody record → users/{uid}/investments/{id}
 *   3. Wallet debit              → wallets/{uid}
 *   4. Transaction record        → users/{uid}/transactions/{id}
 *   5. Price snapshot            → price_history/{startupId}/snapshots/{id}
 *   6. Startup token/price update→ startups/{id}
 *
 * All timestamps are set to [purchaseDate] so the patrimony chart can
 * reconstruct historical portfolio value correctly.
 *
 * Mutates [startup] in-place so subsequent calls see the updated price/supply.
 * Mutates [walletBalance.value] so the caller tracks remaining funds.
 *
 * Returns false (with a warning) if the investment is skipped due to
 * insufficient tokens or insufficient wallet balance.
 */
async function processInvestment(
    uid: string,
    startup: StartupDocument,
    requestedQty: number,
    walletBalance: {value: number},
    purchaseDate: Date,
): Promise<boolean>
{
    const quantity = Math.min(requestedQty, startup.available_tokens);
    if (quantity <= 0)
    {
        console.log(`  ⚠ Tokens esgotados em "${startup.name}" — pulando`);
        return false;
    }

    const unitPrice = startup.token_price;
    const amount    = Math.round(unitPrice * quantity * 100) / 100;

    if (walletBalance.value < amount)
    {
        console.log(
            `  ⚠ Saldo insuficiente para "${startup.name}" ` +
            `(necessário R$${amount.toFixed(2)}, disponível R$${walletBalance.value.toFixed(2)}) — pulando`,
        );
        return false;
    }

    const newAvailable = startup.available_tokens - quantity;
    const tokensSold   = startup.total_tokens - newAvailable;
    const newPrice     = calcTokenPrice(
        startup.base_price,
        startup.total_tokens,
        newAvailable,
        startup.appreciation_factor,
    );

    const batch = db.batch();

    // 1. completed buy order — required by onGetPatrimonyHistory to reconstruct
    //    portfolio value over time
    const orderRef = db.collection('orders').doc();
    const order: OrderDocument = {
        id:              orderRef.id,
        uid,
        startup_id:      startup.id,
        type:            'buy',
        status:          'completed',
        quantity,
        unit_price:      unitPrice,
        total_amount:    amount,
        created_at:      purchaseDate,
        completed_at:    purchaseDate,
        failure_reason:  null,
        filled_quantity: quantity,
        cancelled_at:    null,
        avg_fill_price:  unitPrice,
    };
    batch.set(orderRef, order);

    // 2. investment custody record
    const invRef                                  = db.collection('users').doc(uid).collection('investments').doc();
    const investment: Omit<InvestmentDocument, 'id'> = {
        avg_purchase_price: unitPrice,
        created_at:         purchaseDate,
        startup_id:         startup.id,
        startup_logo_url:   startup.logo_url ?? '',
        startup_name:       startup.name,
        token_quantity:     quantity,
        updated_at:         null,
    };
    batch.set(invRef, investment);

    // 3. wallet debit
    batch.update(db.collection('wallets').doc(uid), {
        balance:    FieldValue.increment(-amount),
        updated_at: purchaseDate,
    });

    // 4. transaction record
    const txRef                                    = db.collection('users').doc(uid).collection('transactions').doc();
    const transaction: Omit<TransactionDocument, 'id'> = {
        amount,
        created_at:  purchaseDate,
        description: `Compra de ${quantity} tokens ${startup.token_name} (${startup.name})`,
        status:      'completed',
        type:        'buy',
    };
    batch.set(txRef, transaction);

    // 5. price snapshot — required by onGetPatrimonyHistory to look up historical prices
    const snapRef                                       = db.collection('price_history').doc(startup.id).collection('snapshots').doc();
    const snapshot: PriceSnapshotDocument = {
        id:          snapRef.id,
        startup_id:  startup.id,
        price:       newPrice,
        tokens_sold: tokensSold,
        recorded_at: purchaseDate,
    };
    batch.set(snapRef, snapshot);

    // 6. startup: decrement available tokens + recalculate bonding-curve price
    batch.update(db.collection('startups').doc(startup.id), {
        available_tokens: newAvailable,
        token_price:      newPrice,
        updated_at:       purchaseDate,
    });

    await batch.commit();

    // update in-memory state for subsequent calls
    startup.available_tokens = newAvailable;
    startup.token_price      = newPrice;
    walletBalance.value      = Math.round((walletBalance.value - amount) * 100) / 100;

    console.log(
        `  ✓ ${quantity} ${startup.token_name} @ R$${unitPrice.toFixed(4)} ` +
        `= R$${amount.toFixed(2)} | ${Math.round((Date.now() - purchaseDate.getTime()) / 86_400_000)}d atrás` +
        ` | saldo R$${walletBalance.value.toFixed(2)}`,
    );
    return true;
}


/**
 * Main seed function.
 */
async function seed(): Promise<void>
{
    console.log('Iniciando seed de investimentos...\n');
    console.log(`  Firestore: ${process.env.FIRESTORE_EMULATOR_HOST}\n`);

    // 1. load all startups into a mutable map so price/supply updates propagate
    //    across users who invest in the same startup
    const startupsSnap = await db.collection('startups').orderBy('name').get();
    if (startupsSnap.empty)
    {
        console.error('Nenhuma startup encontrada. Execute seed:startups primeiro.');
        process.exit(1);
    }
    const startupMap = new Map<string, StartupDocument>(
        startupsSnap.docs.map(doc => [doc.id, {id: doc.id, ...doc.data()} as StartupDocument]),
    );
    const startupList = [...startupMap.values()];

    // 2. load all users
    const usersSnap = await db.collection('users').get();
    if (usersSnap.empty)
    {
        console.error('Nenhum usuário encontrado. Execute seed:users primeiro.');
        process.exit(1);
    }

    console.log(`Populando investimentos para ${usersSnap.size} usuários...\n`);

    let totalPortfolios  = 0;
    let totalInvestments = 0;
    let skipped          = 0;

    for (const userDoc of usersSnap.docs)
    {
        // since seed-users writes users/{uid}, the doc ID is the uid
        const uid = userDoc.id;

        // idempotency: skip users who already have investment records
        const existingInv = await db
            .collection('users').doc(uid)
            .collection('investments')
            .limit(1).get();

        if (!existingInv.empty)
        {
            skipped++;
            continue;
        }

        // read current wallet balance for this user
        const walletSnap = await db.collection('wallets').doc(uid).get();
        if (!walletSnap.exists)
        {
            console.log(`⚠ Carteira não encontrada para ${uid} — pulando`);
            skipped++;
            continue;
        }
        const walletBalance = {value: walletSnap.data()!.balance as number};

        const seedVal     = hashCode(uid);
        const portfolioSz = 2 + (seedVal % 4);   // 2–5 startups per user

        console.log(`→ ${uid}  (${portfolioSz} startups, saldo R$${walletBalance.value.toFixed(2)})`);

        let created = 0;
        for (let s = 0; s < portfolioSz; s++)
        {
            const startupIdx = (seedVal + s) % startupList.length;
            const startup    = startupList[startupIdx];

            // 500–4500 tokens, deterministic
            const quantity = 100 * (5 + (seedVal * (s + 1)) % 45);

            // purchase date: 30–90 days ago, deterministic per user+slot
            const daysAgo     = 30 + ((seedVal * (s + 1) * 7) % 61);
            const purchaseDate = new Date(Date.now() - daysAgo * 86_400_000);
            purchaseDate.setHours(12, 0, 0, 0);

            const ok = await processInvestment(uid, startup, quantity, walletBalance, purchaseDate);
            if (ok)
            {
                created++;
                totalInvestments++;
            }
        }

        if (created > 0) totalPortfolios++;
    }

    console.log('\nSeed de investimentos concluído.');
    console.log(`  Portfólios criados : ${totalPortfolios}`);
    console.log(`  Investimentos      : ${totalInvestments}`);
    console.log(`  Usuários pulados   : ${skipped}`);
}


seed().catch(err =>
{
    console.error('Falha no seed de investimentos:', err);
    process.exit(1);
});
