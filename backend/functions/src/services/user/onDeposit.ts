/**
 * Alex Gabriel Soares Sousa - 24802449
 *
 * Function callable onDeposit.
 * Updated to use Firestore transaction with idempotency and server timestamps.
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getWallet} from '../../db/wallets/storage';
import {getUserDocId} from '../../db/users/storage';
import {logger} from '../../utils/logger';
import {FieldValue} from 'firebase-admin/firestore';
import {AuthError} from '../../errors/authError';
import type {CallableRequest} from 'firebase-functions/v2/https';
import {default as db} from '../../configs';
import {IdempotentDeposit} from '../../db/idempotency/model';

export async function handleOnDeposit(request: CallableRequest) {
  try {
    // verify authentication
    if (!request.auth) {
      throw new AuthError('User must be authenticated.');
    }
    const {uid} = request.auth;
    let {amount, idempotencyKey} = request.data;
    // basic validation
    if (typeof amount !== 'number' || amount <= 0) {
      throw new HttpsError('invalid-argument', 'Amount must be a positive number.');
    }
    if (amount > 100000) {
      throw new HttpsError('out-of-range', 'Maximum deposit amount is R$ 100.000,00.');
    }
    // ensure two decimal places
    amount = Math.round(amount * 100) / 100;
    // generate fallback idempotency key if missing
    if (typeof idempotencyKey !== 'string' || !idempotencyKey.trim()) {
      const crypto = require('crypto');
      idempotencyKey = crypto.randomUUID();
    }
    logger.info(`Processing deposit of R$ ${amount} for user "${uid}" with idempotencyKey=${idempotencyKey}...`);
    // run atomic transaction
    const result = await db.runTransaction(async (t) => {
      const idempRef = db.collection('idempotentDeposits').doc(idempotencyKey);
      const idempSnap = await t.get(idempRef);
      if (idempSnap.exists) {
        const data = idempSnap.data() as IdempotentDeposit;
        return {existing: true, transactionId: data.transactionId};
      }
      // use wallets collection (root level) - consistent with getWallet() and createWallet()
      const walletRef = db.collection('wallets').doc(uid);
      // update balance
      t.update(walletRef, {balance: FieldValue.increment(amount)});
      // locate user's document for transactions subcollection
      const userDocId = await getUserDocId(uid);
      if (!userDocId) throw new HttpsError('not-found', 'User document not found');
      // create transaction document
      const txnRef = db.collection('users').doc(userDocId).collection('transactions').doc();
      const transaction = {
        amount,
        description: 'Depósito em conta',
        status: 'completed' as const,
        type: 'deposit' as const,
        created_at: FieldValue.serverTimestamp(),
      };
      t.set(txnRef, transaction);
      // store idempotency record linking to this transaction
      t.set(idempRef, {transactionId: txnRef.id, created_at: FieldValue.serverTimestamp()});
      return {existing: false, transactionId: txnRef.id, transaction};
    });
    // fetch updated balance
    const updatedWallet = await getWallet(uid);
    const newBalance = updatedWallet?.balance ?? 0;
    if (result.existing) {
      const userDocId = await getUserDocId(uid);
      const txnSnap = await db.collection('users').doc(userDocId!).collection('transactions').doc(result.transactionId).get();
      const txnData = txnSnap.data() as any;
      return {message: 'Deposit already processed.', newBalance, transaction: {id: result.transactionId, ...txnData}};
    }
    return {message: 'Deposit successful.', newBalance, transaction: {id: result.transactionId, ...result.transaction}};
  } catch (error: unknown) {
    if (error instanceof AuthError) {
      throw new HttpsError('unauthenticated', error.message);
    }
    if (error instanceof HttpsError) throw error;
    logger.error('Deposit failed:', error);
    throw new HttpsError('internal', 'Failed to process deposit.');
  }
}

