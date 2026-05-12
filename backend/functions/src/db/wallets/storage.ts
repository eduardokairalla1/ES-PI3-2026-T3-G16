/**
 * Wallet database operations.
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

import {FieldValue} from 'firebase-admin/firestore';

/**
 * I add balance to a user's wallet.
 * If the wallet doesn't exist, it will be created with the initial amount.
 *
 * @param uid    Firebase Auth UID
 * @param amount amount to add
 */
export async function deposit(uid: string, amount: number): Promise<void>
{
    const walletRef = db.collection('wallets').doc(uid);
    
    // use FieldValue.increment to ensure atomicity
    // use set with merge: true to automatically create the document if it doesn't exist
    await walletRef.set({
        uid,
        balance: FieldValue.increment(amount),
        updated_at: new Date(),
    }, {merge: true});
}
