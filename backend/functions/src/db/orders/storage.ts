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
