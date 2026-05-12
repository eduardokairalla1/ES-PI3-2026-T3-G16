/**
 * Idempotency record for deposit operations.
 * Stores the transaction that was created for a given idempotency key.
 */
export interface IdempotentDeposit {
  /** The Firestore document ID of the transaction created for this deposit */
  transactionId: string;
  /** Server timestamp of when the deposit was first processed */
  created_at: FirebaseFirestore.Timestamp;
}
