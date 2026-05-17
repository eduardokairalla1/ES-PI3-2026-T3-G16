import {onDocumentCreated} from 'firebase-functions/v2/firestore';
import db from '../../configs';
import {logger} from '../../utils/logger';
import {OrderDocument} from '../../db/orders/model';
import {getUserDocId} from '../../db/users/storage';

/**
 * Match Engine triggered when a new order is added to the order book.
 * It searches for opposite pending orders and executes trades if prices cross.
 */
export const onMatchOrders = onDocumentCreated('orders/{orderId}', async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        return;
    }

    const newOrder = snapshot.data() as OrderDocument;

    // Only process new OPEN/pending orders
    if (newOrder.status !== 'pending') {
        return;
    }

    const startupId = newOrder.startup_id;

    try {
        await db.runTransaction(async (tx) => {
            // Re-fetch order
            const orderRef = db.collection('orders').doc(newOrder.id);
            const currentOrderSnap = await tx.get(orderRef);
            if (!currentOrderSnap.exists) return;
            const currentOrder = currentOrderSnap.data() as OrderDocument;

            if (currentOrder.status !== 'pending' || currentOrder.quantity <= 0) return;

            // Fetch opposite orders
            const oppositeType = currentOrder.type === 'buy' ? 'sell' : 'buy';
            const query = db.collection('orders')
                .where('startup_id', '==', startupId)
                .where('status', '==', 'pending')
                .where('type', '==', oppositeType);

            const oppositeOrdersSnap = await tx.get(query);
            let oppositeOrders = oppositeOrdersSnap.docs.map(doc => ({id: doc.id, ...doc.data()} as OrderDocument));

            // Filter and sort in memory
            if (currentOrder.type === 'buy') {
                oppositeOrders = oppositeOrders
                    .filter(o => o.unit_price <= currentOrder.unit_price)
                    .sort((a, b) => a.unit_price - b.unit_price || a.created_at.getTime() - b.created_at.getTime());
            } else {
                oppositeOrders = oppositeOrders
                    .filter(o => o.unit_price >= currentOrder.unit_price)
                    .sort((a, b) => b.unit_price - a.unit_price || a.created_at.getTime() - b.created_at.getTime());
            }

            let remainingQuantity = currentOrder.quantity;
            let lastTradePrice = 0;

            for (const matchOrder of oppositeOrders) {
                if (remainingQuantity <= 0) break;

                const matchRef = db.collection('orders').doc(matchOrder.id);
                const freshMatchSnap = await tx.get(matchRef);
                const freshMatch = freshMatchSnap.data() as OrderDocument;
                
                if (freshMatch.status !== 'pending' || freshMatch.quantity <= 0) continue;

                const tradeQuantity = Math.min(remainingQuantity, freshMatch.quantity);
                const tradePrice = freshMatch.unit_price; // Maker's price

                remainingQuantity -= tradeQuantity;
                const matchRemaining = freshMatch.quantity - tradeQuantity;
                const now = new Date();

                if (remainingQuantity === 0) {
                    tx.update(orderRef, {status: 'completed', quantity: 0, completed_at: now});
                } else {
                    tx.update(orderRef, {quantity: remainingQuantity});
                }

                if (matchRemaining === 0) {
                    tx.update(matchRef, {status: 'completed', quantity: 0, completed_at: now});
                } else {
                    tx.update(matchRef, {quantity: matchRemaining});
                }

                const buyerUid = currentOrder.type === 'buy' ? currentOrder.uid : freshMatch.uid;
                const sellerUid = currentOrder.type === 'sell' ? currentOrder.uid : freshMatch.uid;

                const buyerDocId = await getUserDocId(buyerUid);
                const sellerDocId = await getUserDocId(sellerUid);

                if (!buyerDocId || !sellerDocId) continue;

                const buyerInvestmentRef = db.collection('users').doc(buyerDocId).collection('investments').doc(startupId);
                const sellerWalletRef = db.collection('wallets').doc(sellerUid);

                // Add tokens to buyer
                const buyerInvSnap = await tx.get(buyerInvestmentRef);
                const buyerTokens = buyerInvSnap.exists ? (buyerInvSnap.data()!.token_quantity as number) : 0;
                
                if (!buyerInvSnap.exists) {
                    const startupSnap = await tx.get(db.collection('startups').doc(startupId));
                    tx.set(buyerInvestmentRef, {
                        id: startupId,
                        startup_id: startupId,
                        startup_name: startupSnap.data()!.name,
                        startup_logo_url: startupSnap.data()!.logo_url || '',
                        token_quantity: tradeQuantity,
                        avg_purchase_price: tradePrice,
                        created_at: now,
                        updated_at: now,
                    });
                } else {
                    tx.update(buyerInvestmentRef, {
                        token_quantity: buyerTokens + tradeQuantity,
                        updated_at: now,
                    });
                }

                // Add money to seller
                const sellerWalletSnap = await tx.get(sellerWalletRef);
                const sellerBalance = sellerWalletSnap.exists ? (sellerWalletSnap.data()!.balance as number) : 0;
                tx.update(sellerWalletRef, {
                    balance: sellerBalance + (tradeQuantity * tradePrice),
                    updated_at: now
                });

                // Refund buyer if their limit price was higher than executed maker price
                if (currentOrder.type === 'buy' && currentOrder.unit_price > tradePrice) {
                    const refundAmount = (currentOrder.unit_price - tradePrice) * tradeQuantity;
                    const buyerWalletRef = db.collection('wallets').doc(buyerUid);
                    const buyerWalletSnap = await tx.get(buyerWalletRef);
                    if (buyerWalletSnap.exists) {
                        tx.update(buyerWalletRef, {
                            balance: (buyerWalletSnap.data()!.balance as number) + refundAmount,
                            updated_at: now
                        });
                    }
                }

                // Transaction Record
                const txRecordRef = db.collection('transactions').doc();
                tx.set(txRecordRef, {
                    id: txRecordRef.id,
                    startup_id: startupId,
                    buyer_id: buyerUid,
                    seller_id: sellerUid,
                    price: tradePrice,
                    quantity: tradeQuantity,
                    total_value: tradeQuantity * tradePrice,
                    executed_at: now
                });

                lastTradePrice = tradePrice;
            }

            if (lastTradePrice > 0) {
                const now = new Date();
                const snapRef = db.collection('price_history').doc(startupId).collection('snapshots').doc();
                tx.set(snapRef, {
                    id: snapRef.id,
                    startup_id: startupId,
                    price: lastTradePrice,
                    tokens_sold: 0,
                    recorded_at: now,
                });

                tx.update(db.collection('startups').doc(startupId), {
                    token_price: lastTradePrice,
                    updated_at: now
                });
            }
        });

        logger.info(`MatchEngine finished for order ${newOrder.id}`);
    } catch (e) {
        logger.error(`Error matching order ${newOrder.id}`, e);
    }
});
