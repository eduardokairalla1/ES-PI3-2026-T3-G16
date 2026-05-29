/**
 * Seed script — populates the balcão (P2P order book) of every startup with
 * a few pending offers on each side and one completed trade, so the order
 * book screen has something to show right after bootstrap.
 *
 * Run while the Firebase emulator is running (after seed-startups + seed-users
 * + seed-investments, so investor data is available for sell-side offers):
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

import type {OrderDocument}         from '../src/db/orders/model';
import type {PriceSnapshotDocument}  from '../src/db/price_history/model';
import type {StartupDocument}        from '../src/db/startups/model';


/**
 * CONFIG
 */

const PROJECT_ID  = 'mesclainvest-eda16';
const SEED_TAG    = 'seed-orderbook-v4';
const TOTAL_USERS = 150;

// price bands relative to the startup's current bonding-curve price.
// Sells go ABOVE the market, buys go BELOW (this is the natural shape of
// a real order book — sellers want more than market, buyers want less).
// We pack many levels close to market and a few outliers far away — feels
// realistic and gives the depth bars something to render.
const SELL_BANDS_PCT = [
    0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.10, 0.12, 0.15, 0.18, 0.22, 0.26, 0.30, 0.35,
];
const BUY_BANDS_PCT  = [
    0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.10, 0.12, 0.15, 0.18, 0.22, 0.26, 0.30, 0.35,
];

// historical trades to seed (so the book has a price history, not just
// the current state). Each entry is hours ago + price drift % from market.
const TRADE_HISTORY: Array<{hoursAgo: number; driftPct: number}> = [
    {hoursAgo: 720, driftPct: -0.15}, // 30 days ago
    {hoursAgo: 650, driftPct: -0.13},
    {hoursAgo: 580, driftPct: -0.12},
    {hoursAgo: 520, driftPct: -0.10},
    {hoursAgo: 460, driftPct: -0.09},
    {hoursAgo: 410, driftPct: -0.07},
    {hoursAgo: 360, driftPct: -0.06},
    {hoursAgo: 310, driftPct: -0.08},
    {hoursAgo: 270, driftPct: -0.05},
    {hoursAgo: 230, driftPct: -0.04},
    {hoursAgo: 200, driftPct: -0.02},
    {hoursAgo: 168, driftPct: -0.03}, // 7 days ago
    {hoursAgo: 144, driftPct: -0.01},
    {hoursAgo: 120, driftPct: 0.01},
    {hoursAgo: 96,  driftPct: -0.02},
    {hoursAgo: 72,  driftPct: 0.02},
    {hoursAgo: 48,  driftPct: 0.00},
    {hoursAgo: 36,  driftPct: 0.03},
    {hoursAgo: 24,  driftPct: 0.01},
    {hoursAgo: 18,  driftPct: 0.02},
    {hoursAgo: 12,  driftPct: 0.04},
    {hoursAgo: 6,   driftPct: 0.02},
    {hoursAgo: 3,   driftPct: 0.015},
    {hoursAgo: 1,   driftPct: 0.008},
    {hoursAgo: 0.25, driftPct: 0.003}, // 15 mins ago
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
    return `seed-user-${String(n).padStart(3, '0')}`;
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

    console.log('Seeding orderbook into Firestore emulator...');
    console.log(`  Firestore: ${process.env.FIRESTORE_EMULATOR_HOST}\n`);

    // pull every startup we'll seed against
    const startupsSnap = await db.collection('startups').get();
    if (startupsSnap.empty)
    {
        console.error('No startups found. Run seed-startups first.');
        process.exit(1);
    }

    // build a map of startupId → uid[] of actual investors so sell-side offers
    // only come from users who own tokens of that startup
    const investorMap = new Map<string, string[]>();
    const investmentsSnap = await db.collectionGroup('investments').get();
    for (const invDoc of investmentsSnap.docs)
    {
        const uid       = invDoc.ref.parent.parent!.id;
        const startupId = invDoc.data().startup_id as string | undefined;
        if (!startupId) continue;
        if (!investorMap.has(startupId)) investorMap.set(startupId, []);
        investorMap.get(startupId)!.push(uid);
    }
    console.log(`Loaded investor data for ${investorMap.size} startups.\n`);

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
        const now         = new Date();
        const investors   = investorMap.get(startup.id) ?? [];

        // ----- pending sell offers (above market) -----
        // Only investors who hold tokens of this startup can have sell orders.
        if (investors.length === 0)
        {
            console.log(`  ⚠  No investors for "${startup.name}" — skipping sell offers`);
        }
        else
        {
            for (let i = 0; i < SELL_BANDS_PCT.length; i++)
            {
                const slotSeed  = startupSeed + i * 11;
                const qty       = deterministicQty(slotSeed);
                const uprice    = round2(price * (1 + SELL_BANDS_PCT[i]));
                const sellerUid = investors[slotSeed % investors.length];
                const ref       = db.collection('orders').doc();
                const order: OrderDocument & {seed_tag: string} = {
                    id:              ref.id,
                    uid:             sellerUid,
                    startup_id:      startup.id,
                    type:            'sell',
                    status:          'pending',
                    quantity:        qty,
                    unit_price:      uprice,
                    total_amount:    qty * uprice,
                    created_at:      new Date(now.getTime() - i * 60_000),
                    completed_at:    null,
                    failure_reason:  null,
                    filled_quantity: 0,
                    cancelled_at:    null,
                    avg_fill_price:  null,
                    seed_tag:        SEED_TAG,
                };
                await ref.set(order);
                createdOffers++;
            }
        }

        // ----- pending buy offers (below market) -----
        // Any user can place a buy order — no token ownership required.
        for (let i = 0; i < BUY_BANDS_PCT.length; i++)
        {
            const slotSeed = startupSeed + 100 + i * 7;
            const qty      = deterministicQty(slotSeed);
            const uprice   = round2(price * (1 - BUY_BANDS_PCT[i]));
            const ref      = db.collection('orders').doc();
            const order: OrderDocument & {seed_tag: string} = {
                id:              ref.id,
                uid:             pickUid(slotSeed),
                startup_id:      startup.id,
                type:            'buy',
                status:          'pending',
                quantity:        qty,
                unit_price:      uprice,
                total_amount:    qty * uprice,
                created_at:      new Date(now.getTime() - i * 60_000),
                completed_at:    null,
                failure_reason:  null,
                filled_quantity: 0,
                cancelled_at:    null,
                avg_fill_price:  null,
                seed_tag:        SEED_TAG,
            };
            await ref.set(order);
            createdOffers++;
        }

        // ----- historical completed trades -----
        // Buy-side trades use any user; sell-side trades use investors only
        // (falling back to buyers if no investors exist for this startup).
        for (let i = 0; i < TRADE_HISTORY.length; i++)
        {
            const slot       = TRADE_HISTORY[i];
            const tradeQty   = deterministicQty(startupSeed + 500 + i * 17);
            const tradePrice = round2(price * (1 + slot.driftPct));
            const ts         = new Date(now.getTime() - slot.hoursAgo * 60 * 60 * 1000);
            const isSell     = i % 2 !== 0;
            const slotSeed   = startupSeed + 50 + i * 3;
            const tradeUid   = isSell && investors.length > 0
                ? investors[slotSeed % investors.length]
                : pickUid(slotSeed);
            const ref = db.collection('orders').doc();
            const trade: OrderDocument & {seed_tag: string} = {
                id:              ref.id,
                uid:             tradeUid,
                startup_id:      startup.id,
                type:            isSell ? 'sell' : 'buy',
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
            await ref.set(trade);
            createdTrades++;
        }

        // ----- 7-day-ago price snapshot -----
        // onGetStartups computes changePercent by comparing token_price to the
        // oldest snapshot within the last 7 days. Without a snapshot in that
        // window every startup shows changePercent = null ("—") in the balcão.
        // We create one snapshot per startup at exactly 7 days ago with a
        // deterministically varied price so the comparison is meaningful.
        const sevenDaysAgo      = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        // drift: -8% to +8% below current price, varies per startup
        const weekAgoMultiplier = 1 - (0.16 * ((startupSeed % 100) / 100) - 0.08);
        const weekAgoPrice      = round2(price * weekAgoMultiplier);
        const tokensSoldApprox  = startup.total_tokens - startup.available_tokens;
        const snapRef           = db
            .collection('price_history')
            .doc(startup.id)
            .collection('snapshots')
            .doc();
        const weekSnap: PriceSnapshotDocument = {
            id:          snapRef.id,
            startup_id:  startup.id,
            price:       weekAgoPrice,
            tokens_sold: tokensSoldApprox,
            recorded_at: sevenDaysAgo,
        };
        await snapRef.set(weekSnap);

        const sellCount = investors.length > 0 ? SELL_BANDS_PCT.length : 0;
        const buyCount  = BUY_BANDS_PCT.length;
        console.log(
            `✓ "${startup.name}" — ${sellCount} sells (${investors.length} investidores), ` +
            `${buyCount} buys, ${TRADE_HISTORY.length} trades, snapshot 7d`,
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
