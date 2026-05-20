/**
 * Wallet database operations.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import db from '../../configs';
import {FieldValue} from 'firebase-admin/firestore';


/**
 * TYPES
 */
import type {walletDocument} from './model';


/**
 * CODE
 */

/**
 * I get a wallet by uid.
 *
 * @param uid the user's Firebase Auth uid
 *
 * @returns the wallet document, or null if not found
 */
export async function getWallet(uid: string): Promise<walletDocument | null>
{
    const snap = await db.collection('wallets').doc(uid).get();

    if (!snap.exists) return null;

    return snap.data() as walletDocument;
}


/**
 * I create a wallet for a user with zero balance.
 *
 * @param uid the user's Firebase Auth uid
 */
export async function createWallet(uid: string): Promise<void>
{
    const wallet: walletDocument = {
        uid,
        balance:    0,
        created_at: new Date(),
        updated_at: null,
    };

    await db.collection('wallets').doc(uid).set(wallet);
}


/**
 * I increment the wallet balance for a user.
 *
 * @param uid    Firebase Auth UID
 * @param amount positive amount to add
 */
export async function depositToWallet(uid: string, amount: number): Promise<void>
{
    const ref  = db.collection('wallets').doc(uid);
    const snap = await ref.get();

    if (!snap.exists)
    {
        throw new Error(`Wallet not found for user "${uid}".`);
    }

    await ref.update({
        'balance':    FieldValue.increment(amount),
        'updated_at': new Date(),
    });
}


/**
 * I return the current wallet balance for a user.
 *
 * @param uid Firebase Auth UID
 *
 * @returns current balance
 */
export async function getWalletBalance(uid: string): Promise<number>
{
    const snap = await db.collection('wallets').doc(uid).get();
    if (!snap.exists) throw new Error(`Wallet not found for user "${uid}".`);
    return (snap.data()!.balance as number) ?? 0;
}


// --- ORDER BOOK HELPERS ---
// Pedro Henrique Medeiros dos Reis - 24801656

/**
 * I get a reference to a wallet document, for use inside a transaction.
 *
 * @param uid Firebase Auth UID
 *
 * @returns Firestore DocumentReference for the wallet
 */
export function getWalletRef(uid: string): FirebaseFirestore.DocumentReference
{
    return db.collection('wallets').doc(uid);
}


/**
 * I debit a wallet by the given amount, inside a transaction.
 * The caller is responsible for reading the current balance via tx.get first
 * and passing it in, so the math stays consistent with what the tx saw.
 *
 * @param tx             Firestore transaction
 * @param walletRef      Firestore DocumentReference of the wallet
 * @param currentBalance the balance value read inside the same transaction
 * @param amount         positive amount to debit
 */
export function txDebitWallet(
    tx: FirebaseFirestore.Transaction,
    walletRef: FirebaseFirestore.DocumentReference,
    currentBalance: number,
    amount: number,
): void
{
    tx.update(walletRef, {
        balance:    currentBalance - amount,
        updated_at: new Date(),
    });
}


/**
 * I credit a wallet by the given amount, inside a transaction.
 * Same contract as txDebitWallet — caller must pass the value read in the tx.
 *
 * @param tx             Firestore transaction
 * @param walletRef      Firestore DocumentReference of the wallet
 * @param currentBalance the balance value read inside the same transaction
 * @param amount         positive amount to credit
 */
export function txCreditWallet(
    tx: FirebaseFirestore.Transaction,
    walletRef: FirebaseFirestore.DocumentReference,
    currentBalance: number,
    amount: number,
): void
{
    tx.update(walletRef, {
        balance:    currentBalance + amount,
        updated_at: new Date(),
    });
}
