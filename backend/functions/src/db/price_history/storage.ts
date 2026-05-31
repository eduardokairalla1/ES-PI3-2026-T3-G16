/**
 * Price history database operations.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import db from '../../configs';


/**
 * TYPES
 */
import type {PriceSnapshotDocument} from './model';


/**
 * CODE
 */

/**
 * I record a price snapshot for a startup inside a batch.
 *
 * @param batch     Firestore WriteBatch to include the write in
 * @param startupId Firestore document ID of the startup
 * @param price     token price at the time of the snapshot
 * @param tokensSold cumulative tokens sold at the time of the snapshot
 */
export function batchAddPriceSnapshot(
    batch: FirebaseFirestore.WriteBatch,
    startupId: string,
    price: number,
    tokensSold: number,
): void
{
    const ref = db
        .collection('price_history')
        .doc(startupId)
        .collection('snapshots')
        .doc();

    const snapshot: PriceSnapshotDocument = {
        id:          ref.id,
        startup_id:  startupId,
        price,
        tokens_sold: tokensSold,
        recorded_at: new Date(),
    };

    batch.set(ref, snapshot);
}


/**
 * I fetch the oldest price snapshot for a startup since a given date.
 * Returns null if no snapshot exists in the period.
 *
 * @param startupId Firestore document ID of the startup
 * @param since     start of the period
 *
 * @returns the oldest snapshot in the period, or null
 */
export async function getOldestSnapshotSince(
    startupId: string,
    since: Date,
): Promise<PriceSnapshotDocument | null>
{
    const snapshot = await db
        .collection('price_history')
        .doc(startupId)
        .collection('snapshots')
        .where('recorded_at', '>=', since)
        .orderBy('recorded_at', 'asc')
        .limit(1)
        .get();

    if (snapshot.empty) return null;
    return snapshot.docs[0].data() as PriceSnapshotDocument;
}


/**
 * I fetch the latest price snapshot for a startup before or equal to a given date.
 * Returns null if no snapshot exists before that date.
 *
 * @param startupId Firestore document ID of the startup
 * @param before    end of the period
 *
 * @returns the latest snapshot before the date, or null
 */
export async function getLatestSnapshotBefore(
    startupId: string,
    before: Date,
): Promise<PriceSnapshotDocument | null>
{
    const snapshot = await db
        .collection('price_history')
        .doc(startupId)
        .collection('snapshots')
        .where('recorded_at', '<=', before)
        .orderBy('recorded_at', 'desc')
        .limit(1)
        .get();

    if (snapshot.empty) return null;
    return snapshot.docs[0].data() as PriceSnapshotDocument;
}


/**
 * I fetch price snapshots for a startup within a date range.
 *
 * @param startupId Firestore document ID of the startup
 * @param since     start of the period
 *
 * @returns list of price snapshots ordered by recorded_at ascending
 */
export async function getPriceSnapshots(
    startupId: string,
    since: Date,
): Promise<PriceSnapshotDocument[]>
{
    const snapshot = await db
        .collection('price_history')
        .doc(startupId)
        .collection('snapshots')
        .where('recorded_at', '>=', since)
        .orderBy('recorded_at', 'asc')
        .get();

    return snapshot.docs.map(doc => doc.data() as PriceSnapshotDocument);
}


/**
 * I get the price of a startup at a specific date.
 * If no snapshot exists before that date, it falls back to the startup's base price
 * (if any snapshot exists after the date) or the current token price.
 *
 * @param startupId   Firestore document ID of the startup
 * @param date        target date
 * @param basePrice   startup's initial base price
 * @param currentPrice startup's current token price
 *
 * @returns the resolved historical price
 */
export async function getHistoricalPrice(
    startupId: string,
    date: Date,
    basePrice: number,
    currentPrice: number,
): Promise<number>
{
    const [latestBefore, firstSnapshot] = await Promise.all([
        getLatestSnapshotBefore(startupId, date),
        db.collection('price_history')
            .doc(startupId)
            .collection('snapshots')
            .orderBy('recorded_at', 'asc')
            .limit(1)
            .get(),
    ]);

    if (latestBefore !== null)
    {
        return latestBefore.price;
    }

    if (firstSnapshot.empty)
    {
        return currentPrice;
    }

    return basePrice;
}
