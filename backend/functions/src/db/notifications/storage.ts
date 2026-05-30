/**
 * Notification inbox storage helpers.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 */


/**
 * IMPORTS
 */
import db from '../../configs';


/**
 * TYPES
 */
import type {
    NotificationDocument,
    NotificationPayload,
    NotificationType,
} from './model';


/**
 * CONSTANTS
 */

// Cap on the inbox size returned by the callable.
const MAX_INBOX_SIZE = 50;


/**
 * CODE
 */

function notificationsCol(uid: string): FirebaseFirestore.CollectionReference
{
    return db.collection('users').doc(uid).collection('notifications');
}


/**
 * Create a notification. Best-effort: never throws — a failure here must
 * not roll back the business flow that triggered it (deposit, match, etc).
 *
 * @returns the created document, or null on failure
 */
export async function createNotification(
    uid:     string,
    type:    NotificationType,
    title:   string,
    body:    string,
    payload: NotificationPayload = {},
): Promise<NotificationDocument | null>
{
    try
    {
        const now = new Date();

        const doc: Omit<NotificationDocument, 'id'> = {
            'body':       body,
            'created_at': now,
            'payload':    payload,
            'title':      title,
            'type':       type,
        };

        const ref = await notificationsCol(uid).add(doc);
        return {id: ref.id, ...doc};
    }
    catch (e)
    {
        return null;
    }
}


/**
 * Return the user's pending notifications, newest first.
 */
export async function getRecentNotifications(
    uid: string,
): Promise<NotificationDocument[]>
{
    const snapshot = await notificationsCol(uid)
        .orderBy('created_at', 'desc')
        .limit(MAX_INBOX_SIZE)
        .get();

    return snapshot.docs.map(doc => ({
        id: doc.id,
        ...(doc.data() as Omit<NotificationDocument, 'id'>),
    }));
}


/**
 * Delete a single notification (idempotent).
 */
export async function deleteNotification(
    uid:     string,
    notifId: string,
): Promise<void>
{
    await notificationsCol(uid).doc(notifId).delete();
}


/**
 * Wipe the entire inbox. Chunks into 400-doc batches to stay under
 * Firestore's 500-write limit.
 *
 * @returns number of notifications deleted
 */
export async function deleteAllNotifications(uid: string): Promise<number>
{
    const snapshot = await notificationsCol(uid).get();
    if (snapshot.empty) return 0;

    const docs = snapshot.docs;
    let written = 0;

    for (let i = 0; i < docs.length; i += 400)
    {
        const batch = db.batch();
        const slice = docs.slice(i, i + 400);
        for (const d of slice) batch.delete(d.ref);
        await batch.commit();
        written += slice.length;
    }

    return written;
}
