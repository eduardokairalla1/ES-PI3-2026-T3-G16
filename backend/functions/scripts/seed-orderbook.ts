/**
 * Seed script — populates the balcão (P2P order book) of every startup with
 * a few pending offers on each side and one completed trade, so the order
 * book screen has something to show right after bootstrap.
 *
 * Run while the Firebase emulator is running (after seed-startups + seed-users):
 *   npm run seed:orderbook
 *
 * Idempotent: looks for existing seed-orderbook docs (marked with a `seed_tag`
 * field) and skips startups that already have them.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 */

/**
 * IMPORTS
 */

// point Admin SDK at local emulators before importing it
process.env.FIRESTORE_EMULATOR_HOST ??= 'localhost:8080';

import {initializeApp}   from 'firebase-admin/app';
import {getFirestore}    from 'firebase-admin/firestore';

import type {OrderDocument}  from '../src/db/orders/model';
import type {StartupDocument} from '../src/db/startups/model';


/**
 * CONFIG
 */

const PROJECT_ID  = 'mesclainvest-eda16';
const SEED_TAG    = 'seed-orderbook-v2';
const TOTAL_USERS = 30;

// price bands relative to the startup's current bonding-curve price.
// Sells go ABOVE the market, buys go BELOW (this is the natural shape of
// a real order book — sellers want more than market, buyers want less).
// We pack many levels close to market and a few outliers far away — feels
// realistic and gives the depth bars something to render.
const SELL_BANDS_PCT = [
    0.01, 0.02, 0.03, 0.05, 0.07, 0.10, 0.13, 0.16, 0.20, 0.25,
];
const BUY_BANDS_PCT  = [
    0.01, 0.02, 0.03, 0.05, 0.07, 0.10, 0.13, 0.16, 0.20, 0.25,
];

// historical trades to seed (so the book has a price history, not just
// the current state). Each entry is hours ago + price drift % from market.
const TRADE_HISTORY: Array<{hoursAgo: number; driftPct: number}> = [
    {hoursAgo: 168, driftPct: -0.08},  // a week ago, lower
    {hoursAgo: 120, driftPct: -0.05},
    {hoursAgo: 72,  driftPct: -0.02},
    {hoursAgo: 36,  driftPct:  0.00},
    {hoursAgo: 18,  driftPct:  0.02},
    {hoursAgo: 6,   driftPct:  0.01},
    {hoursAgo: 2,   driftPct:  0.005},
    {hoursAgo: 0.25, driftPct: 0.003}, // 15 min ago
];

/**
 * I produce a deterministic quantity between 50 and 499 tokens from `seed`,
 * used so neighbouring offer slots don't all carry the same amount.
 *
 * @param seed any positive integer; same input → same output
 *
 * @returns token quantity in the [50, 499] range
 */
function deterministicQty(seed: number): number
{
    // 50 to 499 tokens, varies per slot
    return 50 + (seed * 73) % 450;
}

/**
 * I pick a seed-user UID, rotating across the {@link TOTAL_USERS} pool so
 * neighbouring startups don't all share the same author.
 *
 * @param slot offer slot index (any integer)
 *
 * @returns UID in the form `seed-user-NN`
 */
function pickUid(slot: number): string
{
    const n = (slot % TOTAL_USERS) + 1;
    return `seed-user-${String(n).padStart(2, '0')}`;
}

/**
 * I round a BRL value to two decimal places (cents).
 *
 * @param value raw number
 *
 * @returns value rounded to 2 decimals
 */
function round2(value: number): number
{
    return Math.round(value * 100) / 100;
}


/**
 * SEED
 */

/**
 * I seed the order book of every startup in Firestore with pending buy/sell
 * offers and a short history of completed trades. Idempotent — startups
 * already seeded with the current {@link SEED_TAG} are skipped, and docs from
 * older seed versions are purged before reseeding.
 */
async function seed(): Promise<void>
{
    const app = initializeApp({projectId: PROJECT_ID});
    const db  = getFirestore(app);

    console.log(`Seeding orderbook into Firestore emulator...`);
    console.log(`  Firestore: ${process.env.FIRESTORE_EMULATOR_HOST}\n`);

    // pull every startup we'll seed against
    const startupsSnap = await db.collection('startups').get();
    if (startupsSnap.empty)
    {
        console.error('No startups found. Run seed-startups first.');
        process.exit(1);
    }

    let createdOffers = 0;
    let createdTrades = 0;
    let skippedStartups = 0;
    let processedStartups = 0;
    let purgedOld = 0;

    for (const doc of startupsSnap.docs)
    {
        const startup = {id: doc.id, ...doc.data()} as StartupDocument;

        // purge any docs from previous versions of this seed (v1, v2, …) so
        // the order book matches exactly what this version is supposed to create
        const stale = await db
            .collection('orders')
            .where('startup_id', '==', startup.id)
            .get();

        const staleSeedDocs = stale.docs.filter((d) =>
        {
            const tag = d.data().seed_tag as string | undefined;
            return tag !== undefined && tag.startsWith('seed-orderbook-');
        });

        if (staleSeedDocs.length > 0)
        {
            const isCurrentVersion = staleSeedDocs.every(
                (d) => d.data().seed_tag === SEED_TAG,
            );
            if (isCurrentVersion)
            {
                console.log(`- Skip "${startup.name}" (already seeded with ${SEED_TAG})`);
                skippedStartups++;
                continue;
            }

            // wipe old seed docs from previous versions
            for (const d of staleSeedDocs)
            {
                await d.ref.delete();
                purgedOld++;
            }
        }

        const price = startup.token_price;
        if (!price || price <= 0)
        {
            console.log(`- Skip "${startup.name}" (no token_price set)`);
            skippedStartups++;
            continue;
        }

        const startupSeed = Math.abs(hashCode(startup.id));
        const now = new Date();

        // ----- pending sell offers (above market) -----
        for (let i = 0; i < SELL_BANDS_PCT.length; i++)
        {
            const slotSeed = startupSeed + i * 11;
            const order: OrderDocument & {seed_tag: string} = {
                id:              '',
                uid:             pickUid(slotSeed),
                startup_id:      startup.id,
                type:            'sell',
                status:          'pending',
                quantity:        deterministicQty(slotSeed),
                unit_price:      round2(price * (1 + SELL_BANDS_PCT[i])),
                total_amount:    0,  // set below
                created_at:      new Date(now.getTime() - i * 60_000),
                completed_at:    null,
                failure_reason:  null,
                filled_quantity: 0,
                cancelled_at:    null,
                avg_fill_price:  null,
                seed_tag:        SEED_TAG,
            };
            order.total_amount = order.quantity * order.unit_price;

            const ref = await db.collection('orders').add(order);
            await ref.update({id: ref.id});
            createdOffers++;
        }

        // ----- pending buy offers (below market) -----
        for (let i = 0; i < BUY_BANDS_PCT.length; i++)
        {
            const slotSeed = startupSeed + 100 + i * 7;
            const order: OrderDocument & {seed_tag: string} = {
                id:              '',
                uid:             pickUid(slotSeed),
                startup_id:      startup.id,
                type:            'buy',
                status:          'pending',
                quantity:        deterministicQty(slotSeed),
                unit_price:      round2(price * (1 - BUY_BANDS_PCT[i])),
                total_amount:    0,
                created_at:      new Date(now.getTime() - i * 60_000),
                completed_at:    null,
                failure_reason:  null,
                filled_quantity: 0,
                cancelled_at:    null,
                avg_fill_price:  null,
                seed_tag:        SEED_TAG,
            };
            order.total_amount = order.quantity * order.unit_price;

            const ref = await db.collection('orders').add(order);
            await ref.update({id: ref.id});
            createdOffers++;
        }

        // ----- historical completed trades (so lastTradePrice + history are populated) -----
        // Each entry is one synthetic trade that already happened. The trades
        // drift from below to around the current market price over the week.
        for (let i = 0; i < TRADE_HISTORY.length; i++)
        {
            const slot = TRADE_HISTORY[i];
            const tradeQty   = deterministicQty(startupSeed + 500 + i * 17);
            const tradePrice = round2(price * (1 + slot.driftPct));
            const ts = new Date(now.getTime() - slot.hoursAgo * 60 * 60 * 1000);

            const trade: OrderDocument & {seed_tag: string} = {
                id:              '',
                uid:             pickUid(startupSeed + 50 + i * 3),
                startup_id:      startup.id,
                type:            i % 2 === 0 ? 'buy' : 'sell',
                status:          'completed',
                quantity:        tradeQty,
                unit_price:      tradePrice,
                total_amount:    tradeQty * tradePrice,
                created_at:      ts,
                completed_at:    ts,
                failure_reason:  null,
                filled_quantity: tradeQty,
                cancelled_at:    null,
                avg_fill_price:  tradePrice,
                seed_tag:        SEED_TAG,
            };
            const tradeRef = await db.collection('orders').add(trade);
            await tradeRef.update({id: tradeRef.id});
            createdTrades++;
        }

        const sellCount = SELL_BANDS_PCT.length;
        const buyCount  = BUY_BANDS_PCT.length;
        console.log(
            `✓ "${startup.name}" — ${sellCount} sells, ${buyCount} buys, ${TRADE_HISTORY.length} trades`,
        );
        processedStartups++;
    }

    console.log(
        `\nSeed complete: ${processedStartups} startups populated, ${skippedStartups} skipped.`,
    );
    if (purgedOld > 0)
    {
        console.log(`  Purged ${purgedOld} stale docs from previous seed versions.`);
    }
    console.log(`  ${createdOffers} pending offers + ${createdTrades} completed trades.`);
}


/**
 * I'm a tiny stable string hash — used to vary which seed-user a startup's
 * offers come from so the same UIDs don't always land on the same startups.
 *
 * @param s input string
 *
 * @returns 32-bit signed integer hash (may be negative; callers Math.abs it)
 */
function hashCode(s: string): number
{
    let h = 0;
    for (let i = 0; i < s.length; i++)
    {
        h = ((h << 5) - h) + s.charCodeAt(i);
        h |= 0;
    }
    return h;
}


seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
