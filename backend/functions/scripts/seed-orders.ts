/**
 * Seed script — populates Firestore emulator with 30 sample buy/sell orders.
 * Run while the Firebase emulator is running:
 *   npm run seed:orders
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
process.env.FIRESTORE_EMULATOR_HOST     ??= 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= 'localhost:9099';

import {initializeApp} from 'firebase-admin/app';
import {getFirestore}  from 'firebase-admin/firestore';
import {getAuth}       from 'firebase-admin/auth';

import type {StartupDocument} from '../src/db/startups/model';
import type {OrderDocument}   from '../src/db/orders/model';

/**
 * CODE
 */

const app  = initializeApp({projectId: 'mesclainvest-eda16'});
const db   = getFirestore(app);
const auth = getAuth(app);

const TOTAL_ORDERS = 30;

/**
 * HELPER: I get the user document ID based on the UID.
 */
async function getUserDocId(uid: string): Promise<string | null>
{
    const snapshot = await db.collection('users').where('uid', '==', uid).limit(1).get();
    if (snapshot.empty) return null;
    return snapshot.docs[0].id;
}

/**
 * SEED
 */
async function seed(): Promise<void>
{
    console.log(`Seeding ${TOTAL_ORDERS} orders into Firestore emulator...`);
    console.log(`  Firestore: ${process.env.FIRESTORE_EMULATOR_HOST}\n`);

    // 1. Fetch demo users from Auth
    const listResult = await auth.listUsers(50);
    const users = listResult.users.filter(u => u.uid.startsWith('seed-user-'));

    if (users.length === 0)
    {
        console.error('No seed users found in the auth emulator. Please run seed:users first.');
        process.exit(1);
    }

    // 2. Fetch existing startups
    const startupsSnapshot = await db.collection('startups').orderBy('name').get();
    if (startupsSnapshot.empty)
    {
        console.error('No startups found. Run seed:startups first.');
        process.exit(1);
    }

    const startups = startupsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
    } as StartupDocument));

    let created = 0;

    // 3. Create 30 orders
    for (let i = 0; i < TOTAL_ORDERS; i++)
    {
        // Pick user and startup deterministically/cyclically
        const user = users[i % users.length];
        const startup = startups[i % startups.length];
        const userDocId = await getUserDocId(user.uid);

        if (!userDocId) {
            console.warn(`[Skip] User doc not found for UID "${user.uid}"`);
            continue;
        }

        // Alternate between buy and sell
        const type: 'buy' | 'sell' = i % 2 === 0 ? 'buy' : 'sell';
        
        // Base quantity
        const quantity = 100 * ((i % 5) + 1); // 100, 200, 300, 400, 500

        // Calculate realistic price offset so orders stay pending
        // Buy orders: 5% to 15% below market price
        // Sell orders: 5% to 15% above market price
        const basePrice = startup.token_price || 0.50;
        const pctOffset = 0.05 + ((i % 3) * 0.05); // 5%, 10%, 15%
        
        let unitPrice = type === 'buy' 
            ? basePrice * (1 - pctOffset) 
            : basePrice * (1 + pctOffset);
        
        unitPrice = Number(unitPrice.toFixed(2));
        const totalAmount = Number((quantity * unitPrice).toFixed(2));

        // Execute transaction to maintain balance/token integrity
        await db.runTransaction(async (tx) =>
        {
            const walletRef = db.collection('wallets').doc(user.uid);
            const investmentRef = db.collection('users').doc(userDocId).collection('investments').doc(startup.id);

            const [walletSnap, investmentSnap] = await Promise.all([
                tx.get(walletRef),
                tx.get(investmentRef),
            ]);

            const now = new Date();

            if (type === 'buy')
            {
                const balance = walletSnap.exists ? (walletSnap.data()!.balance as number) : 0;
                if (balance >= totalAmount) {
                    tx.update(walletRef, { balance: balance - totalAmount, updated_at: now });
                } else {
                    // If demo user ran out of balance, give them a top-up for demo purposes
                    tx.update(walletRef, { balance: 10000 - totalAmount, updated_at: now });
                }
            }
            else if (type === 'sell')
            {
                const tokenData = investmentSnap.exists ? investmentSnap.data() : null;
                const currentTokens = tokenData ? (tokenData.token_quantity as number) : 0;

                if (currentTokens >= quantity) {
                    tx.update(investmentRef, { token_quantity: currentTokens - quantity, updated_at: now });
                } else {
                    // Provision tokens so the sell order is valid
                    const initialTokens = quantity + 5000;
                    if (investmentSnap.exists) {
                        tx.update(investmentRef, { token_quantity: initialTokens - quantity, updated_at: now });
                    } else {
                        tx.set(investmentRef, {
                            startup_id: startup.id,
                            startup_name: startup.name,
                            startup_logo_url: startup.logo_url,
                            token_quantity: initialTokens - quantity,
                            avg_purchase_price: basePrice,
                            created_at: now,
                            updated_at: now,
                        });
                    }
                }
            }

            // Create pending order
            const orderRef = db.collection('orders').doc();
            const orderDoc: OrderDocument = {
                id: orderRef.id,
                uid: user.uid,
                startup_id: startup.id,
                type,
                status: 'pending',
                quantity,
                unit_price: unitPrice,
                total_amount: totalAmount,
                created_at: now,
                completed_at: null,
                failure_reason: null,
            };

            tx.set(orderRef, orderDoc);
        });

        const typeLabel = type === 'buy' ? 'COMPRA' : 'VENDA ';
        console.log(`✓ [${typeLabel}] ${user.email?.padEnd(22)} | ${startup.name.padEnd(15)} | ${quantity} STX a R$ ${unitPrice.toFixed(2)} (Total: R$ ${totalAmount.toFixed(2)})`);
        created++;
    }

    console.log(`\nSeed complete: ${created} orders successfully created as "pending".\n`);
}

seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
