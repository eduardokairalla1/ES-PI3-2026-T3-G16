/**
 * Order database operations.
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
import type {OrderDocument, OrderStatus} from './model';


/**
 * CODE
 */

/**
 * I create a new order document and return it.
 *
 * @param data order fields (without id)
 *
 * @returns the created order document
 */
export async function createOrder(
    data: Omit<OrderDocument, 'id'>,
): Promise<OrderDocument>
{
    const ref = db.collection('orders').doc();
    const order: OrderDocument = {id: ref.id, ...data};
    await ref.set(order);
    return order;
}


/**
 * I return all orders for a user filtered by type and status.
 *
 * @param uid    the user's Firebase Auth uid
 * @param type   order type to filter by
 * @param status order status to filter by
 *
 * @returns list of matching order documents
 */
export async function getOrdersByTypeAndStatus(
    uid: string,
    type: OrderDocument['type'],
    status: OrderDocument['status'],
): Promise<OrderDocument[]>
{
    const snap = await db
        .collection('orders')
        .where('uid', '==', uid)
        .where('type', '==', type)
        .where('status', '==', status)
        .get();

    return snap.docs.map(doc => doc.data() as OrderDocument);
}


/**
 * I update the status (and optional extra fields) of an existing order.
 *
 * @param orderId       Firestore document ID of the order
 * @param status        new status
 * @param extraFields   optional extra fields to merge (e.g. completed_at, failure_reason)
 */
export async function updateOrderStatus(
    orderId: string,
    status: OrderStatus,
    extraFields: Partial<OrderDocument> = {},
): Promise<void>
{
    await db.collection('orders').doc(orderId).update({status, ...extraFields});
}


/**
 * I return all completed orders (buy and sell) for a user.
 *
 * @param uid the user's Firebase Auth uid
 *
 * @returns list of completed order documents
 */
export async function getAllCompletedOrdersByUid(uid: string): Promise<OrderDocument[]>
{
    const snap = await db
        .collection('orders')
        .where('uid', '==', uid)
        .where('status', '==', 'completed')
        .get();

    return snap.docs.map(doc => doc.data() as OrderDocument);
}


// --- ORDER BOOK QUERIES ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// The order book screen and the matching engine both need to read the open
// (pending) orders of a startup, sorted by best price. The functions below
// expose those reads. They're split from the existing per-user queries to
// keep call sites obvious.

/**
 * I get a reference to an order document, useful for transactions.
 *
 * @param orderId Firestore document ID of the order
 *
 * @returns DocumentReference for the order
 */
export function getOrderRef(orderId: string): FirebaseFirestore.DocumentReference
{
    return db.collection('orders').doc(orderId);
}


/**
 * I get an order by id.
 *
 * @param orderId Firestore document ID
 *
 * @returns the order document, or null if not found
 */
export async function getOrder(orderId: string): Promise<OrderDocument | null>
{
    const snap = await db.collection('orders').doc(orderId).get();

    if (!snap.exists) return null;

    return snap.data() as OrderDocument;
}


/**
 * I get the top N open orders of a given type for a startup, ordered by best
 * price first. "Best" depends on the type: lowest price first for sell offers
 * (cheaper is better for the buyer), highest first for buy offers.
 *
 * Used by both the matching engine (to find counterparties to cross with) and
 * the order book screen (to render the public list).
 *
 * @param startupId Firestore document ID of the startup
 * @param type      'buy' or 'sell' — the side to query
 * @param limit     max number of orders to return
 *
 * @returns list of open orders, best price first
 */
export async function getOpenOrdersForStartup(
    startupId: string,
    type: OrderDocument['type'],
    limit: number,
): Promise<OrderDocument[]>
{
    // sells are ranked low → high (cheapest first)
    // buys  are ranked high → low (richest first)
    const direction: 'asc' | 'desc' = type === 'sell' ? 'asc' : 'desc';

    const snap = await db
        .collection('orders')
        .where('startup_id', '==', startupId)
        .where('type', '==', type)
        .where('status', '==', 'pending')
        .orderBy('unit_price', direction)
        .limit(limit)
        .get();

    return snap.docs.map(doc => doc.data() as OrderDocument);
}


/**
 * I get the most recent completed order for a startup. Used as the "last trade
 * price" indicator on the order book screen.
 *
 * @param startupId Firestore document ID of the startup
 *
 * @returns the most recent completed order, or null if none
 */
export async function getLastCompletedOrderForStartup(
    startupId: string,
): Promise<OrderDocument | null>
{
    const snap = await db
        .collection('orders')
        .where('startup_id', '==', startupId)
        .where('status', '==', 'completed')
        .orderBy('completed_at', 'desc')
        .limit(1)
        .get();

    if (snap.empty) return null;

    return snap.docs[0].data() as OrderDocument;
}


/**
 * I get all orders authored by a user (any startup, any status), newest first.
 * Used by the "Minhas ordens" tab in the balcão hub.
 *
 * @param uid   Firebase Auth UID
 * @param limit max number of orders to return
 *
 * @returns list of orders, newest first
 */
export async function getOrdersByUid(uid: string, limit = 100): Promise<OrderDocument[]>
{
    const snap = await db
        .collection('orders')
        .where('uid', '==', uid)
        .orderBy('created_at', 'desc')
        .limit(limit)
        .get();

    return snap.docs.map(doc => doc.data() as OrderDocument);
}


/**
 * I get all orders of a user for a specific startup, any status, any type.
 * Used by the matching engine to validate "tokens available to sell" — caller
 * filters by type/status in memory.
 *
 * @param uid       Firebase Auth UID of the user
 * @param startupId Firestore document ID of the startup
 *
 * @returns list of order documents
 */
export async function getOrdersByUidAndStartup(
    uid: string,
    startupId: string,
): Promise<OrderDocument[]>
{
    const snap = await db
        .collection('orders')
        .where('uid', '==', uid)
        .where('startup_id', '==', startupId)
        .get();

    return snap.docs.map(doc => doc.data() as OrderDocument);
}


/**
 * I count distinct users that have ever completed at least one order
 * (buy or sell). Used as the "active investors" metric on the dashboard.
 *
 * Firestore doesn't support DISTINCT, so we pull the uid field of every
 * completed order and de-dupe in memory. Fine for academic scale; for a
 * production system this would live in a denormalized counter.
 *
 * @returns number of unique users with at least one completed order
 */
export async function countActiveInvestors(): Promise<number>
{
    const snap = await db
        .collection('orders')
        .where('status', '==', 'completed')
        .select('uid')
        .get();

    const uniqueUids = new Set<string>();
    for (const doc of snap.docs)
    {
        uniqueUids.add(doc.get('uid') as string);
    }
    return uniqueUids.size;
}
