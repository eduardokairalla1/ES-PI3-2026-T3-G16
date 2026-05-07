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
