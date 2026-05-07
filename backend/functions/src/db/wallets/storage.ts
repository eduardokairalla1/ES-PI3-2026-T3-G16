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
