/**
 * Order document type definitions for Firestore.
 * Adjust fields as needed based on the actual order schema used in the project.
 */
export interface OrderDocument {
  /** Unique identifier of the order (Firestore document ID) */
  id: string;
  /** UID of the user who placed the order */
  userId: string;
  /** UID of the startup involved in the order */
  startupId: string;
  /** Amount of tokens purchased */
  tokenQuantity: number;
  /** Price per token at the time of the order */
  tokenPrice: number;
  /** Timestamp when the order was created */
  createdAt: FirebaseFirestore.Timestamp;
}
