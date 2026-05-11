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
import {getFirestore}  from 'firebase-admin/firestore';

import type {StartupDocument}       from '../db/startups/model';
import type {OrderDocument}         from '../db/orders/model';
import type {PriceSnapshotDocument} from '../db/price_history/model';
import {calcTokenPrice}             from '../utils/pricing';


/**
 * CODE
 */

const app = initializeApp({projectId: 'demo-mesclainvest'});
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
        id:             orderRef.id,
        uid:            USER_UID,
        startup_id:     startup.id,
        type:           'buy',
        status:         'completed',
        quantity,
        unit_price:     unitPrice,
        total_amount:   totalAmount,
        created_at:     purchaseDate,
        completed_at:   purchaseDate,
        failure_reason: null,
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

    await batch.commit();

    // update in-memory state for next purchase
    startup.available_tokens = newAvailable;
    startup.token_price      = newPrice;
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

        for (const {quantity, daysAgo} of sorted)
        {
            await simulatePurchase(startup, quantity, daysAgo, now);
            console.log(`  ✓ ${quantity.toLocaleString()} tokens — ${daysAgo}d ago @ R$${startup.token_price.toFixed(4)}`);
        }

        console.log();
    }

    console.log('Done.');
}

seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
