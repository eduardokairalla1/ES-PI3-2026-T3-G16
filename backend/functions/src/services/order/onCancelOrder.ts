import {HttpsError, CallableRequest} from 'firebase-functions/v2/https';
import db from '../../configs';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';
import {OrderDocument} from '../../db/orders/model';
import {getUserDocId} from '../../db/users/storage';

export async function handleOnCancelOrder(request: CallableRequest) {
    try {
        const uid = verifyAuth(request);
        const orderId = request.data?.orderId;

        if (!orderId || typeof orderId !== 'string') {
            throw new HttpsError('invalid-argument', 'O ID da ordem é obrigatório.');
        }

        await db.runTransaction(async (tx) => {
            const orderRef = db.collection('orders').doc(orderId);
            const orderSnap = await tx.get(orderRef);

            if (!orderSnap.exists) {
                throw new HttpsError('not-found', 'Ordem não encontrada.');
            }

            const order = orderSnap.data() as OrderDocument;

            if (order.uid !== uid) {
                throw new HttpsError('permission-denied', 'Você não pode cancelar esta ordem.');
            }

            if (order.status !== 'pending') {
                throw new HttpsError('failed-precondition', 'Apenas ordens abertas podem ser canceladas.');
            }

            const now = new Date();

            // Refund assets
            if (order.type === 'buy') {
                const refundAmount = order.quantity * order.unit_price;
                const walletRef = db.collection('wallets').doc(uid);
                const walletSnap = await tx.get(walletRef);
                if (walletSnap.exists) {
                    tx.update(walletRef, {
                        balance: (walletSnap.data()!.balance as number) + refundAmount,
                        updated_at: now
                    });
                }
            } else if (order.type === 'sell') {
                const userDocId = await getUserDocId(uid);
                if (userDocId) {
                    const investmentRef = db.collection('users').doc(userDocId).collection('investments').doc(order.startup_id);
                    const invSnap = await tx.get(investmentRef);
                    if (invSnap.exists) {
                        tx.update(investmentRef, {
                            token_quantity: (invSnap.data()!.token_quantity as number) + order.quantity,
                            updated_at: now
                        });
                    }
                }
            }

            // Update order status
            tx.update(orderRef, {
                status: 'cancelled',
                completed_at: now,
            });
        });

        logger.info(`Order ${orderId} cancelled by user ${uid}.`);
        return { success: true };

    } catch (e: any) {
        if (e instanceof HttpsError) throw e;
        logger.error(`Error cancelling order`, e);
        throw new HttpsError('internal', 'Erro interno ao cancelar a ordem.');
    }
}
