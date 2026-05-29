/**
 * Seed script — creates historical buy orders for a specific user.
 *
 * Run AFTER seed-startups (startups must exist):
 *   npm run seed:orders -- --uid=<firebase-auth-uid>
 *
 * Each purchase:
 *   1. Creates an order document (status: completed, past date)
 *   2. Decrements available_tokens on the startup
 *   3. Recalculates token_price via bonding curve
 *   4. Records a price snapshot with the matching past date
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import {initializeApp} from 'firebase-admin/app';
import {FieldValue, getFirestore}  from 'firebase-admin/firestore';

import type {StartupDocument}       from '../src/db/startups/model';
import type {OrderDocument}         from '../src/db/orders/model';
import type {InvestmentDocument}    from '../src/db/investments/model';
import type {PriceSnapshotDocument} from '../src/db/price_history/model';
import type {TransactionDocument}   from '../src/db/transactions/model';
import {calcTokenPrice}             from '../src/utils/pricing';


/**
 * CODE
 */

const app = initializeApp({projectId: 'mesclainvest-eda16'});
const db  = getFirestore(app);


// --- ARG PARSING ---

const uidArg = process.argv.find(a => a.startsWith('--uid='));
if (!uidArg)
{
    console.error('Usage: npm run seed:orders -- --uid=<firebase-auth-uid>');
    process.exit(1);
}
const USER_UID = uidArg.replace('--uid=', '').trim();


// --- HELPERS ---

function daysBack(from: Date, days: number): Date
{
    return new Date(from.getTime() - days * 24 * 60 * 60 * 1000);
}


// --- PURCHASE SIMULATION ---

/**
 * I simulate a single past purchase directly in Firestore.
 * Mutates [startup] in-place to keep state for subsequent purchases.
 */
async function simulatePurchase(
    startup: StartupDocument,
    quantity: number,
    daysAgo: number,
    now: Date,
): Promise<void>
{
    const purchaseDate  = daysBack(now, daysAgo);
    const unitPrice     = startup.token_price;
    const totalAmount   = unitPrice * quantity;
    const newAvailable  = startup.available_tokens - quantity;
    const newPrice      = calcTokenPrice(
        startup.base_price,
        startup.total_tokens,
        newAvailable,
        startup.appreciation_factor,
    );
    const tokensSold = startup.total_tokens - newAvailable;

    const batch = db.batch();

    // order document
    const orderRef              = db.collection('orders').doc();
    const order: OrderDocument  = {
        id:              orderRef.id,
        uid:             USER_UID,
        startup_id:      startup.id,
        type:            'buy',
        status:          'completed',
        quantity,
        unit_price:      unitPrice,
        total_amount:    totalAmount,
        created_at:      purchaseDate,
        completed_at:    purchaseDate,
        failure_reason:  null,
        filled_quantity: quantity,
        cancelled_at:    null,
        avg_fill_price:  unitPrice,
    };
    batch.set(orderRef, order);

    // startup: decrement available_tokens + new price
    batch.update(db.collection('startups').doc(startup.id), {
        available_tokens: newAvailable,
        token_price:      newPrice,
        updated_at:       purchaseDate,
    });

    // price snapshot
    const snapRef                        = db.collection('price_history').doc(startup.id).collection('snapshots').doc();
    const snapshot: PriceSnapshotDocument = {
        id:          snapRef.id,
        startup_id:  startup.id,
        price:       newPrice,
        tokens_sold: tokensSold,
        recorded_at: purchaseDate,
    };
    batch.set(snapRef, snapshot);

    // transaction record
    const txRef = db.collection('users').doc(USER_UID).collection('transactions').doc();
    const transaction: Omit<TransactionDocument, 'id'> = {
        amount:      totalAmount,
        created_at:  purchaseDate,
        description: `Compra de ${quantity} tokens ${startup.token_name} (${startup.name})`,
        status:      'completed',
        type:        'buy',
    };
    batch.set(txRef, transaction);

    // wallet debit
    batch.update(db.collection('wallets').doc(USER_UID), {
        balance:    FieldValue.increment(-totalAmount),
        updated_at: purchaseDate,
    });

    await batch.commit();

    // update in-memory state for next purchase
    startup.available_tokens = newAvailable;
    startup.token_price      = newPrice;
}


/**
 * I create or update the investment record for USER_UID in a given startup,
 * reflecting the accumulated token quantity and weighted average price across
 * all purchases for that startup.
 */
async function upsertInvestment(
    startup: StartupDocument,
    totalQty: number,
    weightedAvgPrice: number,
): Promise<void>
{
    const invCol = db.collection('users').doc(USER_UID).collection('investments');
    const existing = await invCol.where('startup_id', '==', startup.id).limit(1).get();

    if (existing.empty)
    {
        const investment: Omit<InvestmentDocument, 'id'> = {
            avg_purchase_price: weightedAvgPrice,
            created_at:         new Date(),
            startup_id:         startup.id,
            startup_logo_url:   startup.logo_url ?? '',
            startup_name:       startup.name,
            token_quantity:     totalQty,
            updated_at:         null,
        };
        await invCol.add(investment);
    }
    else
    {
        await existing.docs[0].ref.update({
            token_quantity:     FieldValue.increment(totalQty),
            avg_purchase_price: weightedAvgPrice,
            updated_at:         new Date(),
        });
    }
}


// --- PURCHASE SCHEDULE PER STARTUP ---
// daysAgo is relative to today — sorted oldest-first automatically.

interface StartupPurchases
{
    name:      string;
    purchases: Array<{quantity: number; daysAgo: number}>;
}

const SCHEDULE: StartupPurchases[] = [
    {
        name: 'TheraCare',
        purchases: [
            {quantity: 10_000, daysAgo: 60},
            {quantity: 5_000,  daysAgo: 30},
            {quantity: 8_000,  daysAgo: 10},
        ],
    },
    {
        name: 'AgroLink',
        purchases: [
            {quantity: 50_000,  daysAgo: 90},
            {quantity: 30_000,  daysAgo: 45},
            {quantity: 20_000,  daysAgo: 15},
        ],
    },
    {
        name: 'UrbanMob',
        purchases: [
            {quantity: 100_000, daysAgo: 120},
            {quantity: 80_000,  daysAgo: 60},
            {quantity: 50_000,  daysAgo: 20},
        ],
    },
];


// --- MAIN ---

async function seed(): Promise<void>
{
    const now = new Date();

    console.log(`Seeding orders for user "${USER_UID}"...\n`);

    for (const {name, purchases} of SCHEDULE)
    {
        const snap = await db
            .collection('startups')
            .where('name', '==', name)
            .limit(1)
            .get();

        if (snap.empty)
        {
            console.warn(`⚠  Startup "${name}" not found — run seed-startups first.`);
            continue;
        }

        const startup = {id: snap.docs[0].id, ...snap.docs[0].data()} as StartupDocument;
        console.log(`→ "${name}" (${startup.id})`);

        // oldest first so the bonding curve progresses correctly
        const sorted = [...purchases].sort((a, b) => b.daysAgo - a.daysAgo);

        let totalQty        = 0;
        let weightedPriceSum = 0;

        for (const {quantity, daysAgo} of sorted)
        {
            const priceAtPurchase = startup.token_price;
            await simulatePurchase(startup, quantity, daysAgo, now);
            console.log(`  ✓ ${quantity.toLocaleString()} tokens — ${daysAgo}d ago @ R$${priceAtPurchase.toFixed(4)}`);
            totalQty         += quantity;
            weightedPriceSum += priceAtPurchase * quantity;
        }

        // create / update the investment custody record for this startup
        const weightedAvgPrice = totalQty > 0 ? weightedPriceSum / totalQty : 0;
        await upsertInvestment(startup, totalQty, weightedAvgPrice);
        console.log(`  ✓ investment record: ${totalQty.toLocaleString()} tokens @ avg R$${weightedAvgPrice.toFixed(4)}\n`);
    }

    console.log('Done.');
}

seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
