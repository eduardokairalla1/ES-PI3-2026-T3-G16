/**
 * In-app notification types and schema.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 *
 * Documents live in users/{uid}/notifications/{notifId}. There is no
 * read/unread flag — opening or dismissing a notification deletes it.
 */


/**
 * TYPES
 */

export type NotificationType =
    | 'welcome'              // post sign-up welcome
    | 'deposit_confirmed'    // deposit settled into the wallet
    | 'order_executed'       // the user's own order matched (full or partial)
    | 'order_counter_match'  // the user was the counter-party of a match
    | 'order_cancelled'      // the user's pending order was cancelled
    | 'question_answered';   // a founder answered the user's question


/**
 * Structured payload used to build the navigation target when the user
 * taps the tile. Each type only fills the fields that make sense.
 */
export interface NotificationPayload
{
    startupId?:  string;
    startupName?: string;
    orderId?:    string;
    questionId?: string;
}


/**
 * One notification document. `id` is the Firestore doc ID, filled in by
 * the storage helpers — never persisted inside the body.
 */
export interface NotificationDocument
{
    id:         string;
    type:       NotificationType;
    title:      string;
    body:       string;
    payload:    NotificationPayload;
    created_at: Date;
}
