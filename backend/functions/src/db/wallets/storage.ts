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
