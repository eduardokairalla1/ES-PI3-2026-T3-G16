// --- Function callable onGetPatrimonyHistory ---
//
// Alex Gabriel Soares Sousa - 24802449
// Serviço responsável por compilar o histórico de evolução patrimonial real do usuário.

// --- IMPORTS ---
import {HttpsError} from 'firebase-functions/v2/https';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';
import db from '../../configs';
import {parseRequest} from '../../utils/validation';
import {GetPatrimonyHistoryRequest} from '../../types/responders/dashboard';
import {getUserDocId} from '../../db/users/storage';
import {getWallet} from '../../db/wallets/storage';
import {getStartups} from '../../db/startups/storage';
import {getPriceSnapshots} from '../../db/price_history/storage';
import {toJsDate} from '../../utils/walletUtils';

// --- ERRORS ---
import {AuthError} from '../../errors/authError';
import {ValidationError} from '../../errors/validationError';
import {InternalError} from '../../errors/internalError';

// --- TYPES ---
import type {CallableRequest} from 'firebase-functions/v2/https';
import type {OrderDocument} from '../../db/orders/model';

// --- CONSTANTS ---

const PERIOD_TO_DAYS: Record<string, number> = {
    d7: 7,
    m1: 30,
    m3: 90,
    m6: 180,
    y1: 365,
};

// --- CODE ---

/**
 * Manipula a requisição da Cloud Function Callable 'onGetPatrimonyHistory'.
 * Reconstrói de forma retroativa e diária o valor do patrimônio do usuário.
 *
 * @param request Objeto da requisição contendo o período solicitado.
 * @returns Lista contendo os pontos do histórico do patrimônio (timestamp e valor).
 */
export async function handleOnGetPatrimonyHistory(request: CallableRequest)
{
    try
    {
        // 1. Valida se a requisição provém de um usuário autenticado
        const uid = verifyAuth(request);
        const {period} = parseRequest(GetPatrimonyHistoryRequest, request.data);

        const days = PERIOD_TO_DAYS[period] ?? 30;
        logger.info(`Calculando histórico patrimonial para o usuário "${uid}" no período "${period}" (${days} dias)...`);

        const userDocId = await getUserDocId(uid);
        if (!userDocId)
        {
            throw new ValidationError(`Usuário com UID "${uid}" não foi localizado.`);
        }

        // 2. Define a data de início da janela de busca
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - (days - 1));
        startDate.setHours(0, 0, 0, 0);

        // 3. Executa consultas no Firestore em paralelo
        const [wallet, ordersSnap, txSnap, startups] = await Promise.all([
            getWallet(uid),
            db.collection('orders').where('uid', '==', uid).get(),
            db.collection('users')
                .doc(userDocId)
                .collection('transactions')
                .where('created_at', '>=', startDate)
                .get(),
            getStartups(),
        ]);

        if (wallet === null)
        {
            throw new ValidationError(`Carteira não encontrada para o usuário "${uid}".`);
        }

        const currentBalance = wallet.balance;

        // 4. Formata e ordena as transações decrescentemente pelo tempo de criação
        const transactions = txSnap.docs.map(doc =>
        {
            const data = doc.data();
            const createdAt = data.created_at?.toDate ? data.created_at.toDate() : new Date(data.created_at);
            return {
                amount: data.amount as number,
                type: data.type as 'deposit' | 'buy' | 'sell' | 'withdrawal',
                createdAt,
            };
        }).sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

        // 5. Separa ordens de compra e venda por filled_quantity independentemente do status
        const allOrders = ordersSnap.docs.map(doc => doc.data() as OrderDocument);
        const buyOrders = allOrders
            .filter(o => o.type === 'buy' && (o.filled_quantity ?? 0) > 0)
            .map(o => ({
                startupId: o.startup_id,
                quantity: o.filled_quantity ?? 0,
                date: o.completed_at ? toJsDate(o.completed_at) : toJsDate(o.created_at),
            }));

        const sellOrders = allOrders
            .filter(o => o.type === 'sell' && (o.filled_quantity ?? 0) > 0)
            .map(o => ({
                startupId: o.startup_id,
                filledQuantity: o.filled_quantity ?? 0,
                date: o.completed_at ? toJsDate(o.completed_at) : toJsDate(o.created_at),
            }));

        // 6. Obtém o conjunto de startups investidas para buscar os históricos de preços correspondentes
        const startupIds = new Set<string>([
            ...buyOrders.map(o => o.startupId),
            ...sellOrders.map(o => o.startupId),
        ]);

        const startupPrices = new Map<string, number>();
        const startupSnapshots = new Map<string, any[]>();

        for (const s of startups)
        {
            startupPrices.set(s.id, s.token_price);
            if (startupIds.has(s.id))
            {
                // Busca o histórico de preços completo para esta startup
                const snaps = await getPriceSnapshots(s.id, new Date(0));
                startupSnapshots.set(s.id, snaps);
            }
        }

        // 7. Gera os timestamps alvo para o fim de cada dia no período (de startDate até hoje)
        const targetTimes: number[] = [];
        for (let i = 0; i < days; i++)
        {
            const targetDate = new Date();
            targetDate.setDate(targetDate.getDate() - (days - 1 - i));
            targetDate.setHours(23, 59, 59, 999);
            targetTimes.push(targetDate.getTime());
        }

        // 8. Calcula o patrimônio para cada data alvo
        const history = targetTimes.map(T =>
        {
            // a. Calcula o saldo da carteira em T revertendo transações posteriores
            let balance = currentBalance;
            for (const tx of transactions)
            {
                if (tx.createdAt.getTime() > T)
                {
                    if (tx.type === 'deposit' || tx.type === 'sell')
                    {
                        balance -= tx.amount;
                    }
                    else if (tx.type === 'buy' || tx.type === 'withdrawal')
                    {
                        balance += tx.amount;
                    }
                }
                else
                {
                    // Como as transações estão ordenadas de forma decrescente,
                    // ao encontrar a primeira transação que ocorreu antes ou em T,
                    // todas as seguintes também ocorreram antes ou em T. Paramos o loop.
                    break;
                }
            }

            // b. Calcula a custódia de tokens e seu respectivo valor em T
            let assetsValue = 0;
            for (const startupId of startupIds)
            {
                let quantity = 0;
                for (const order of buyOrders)
                {
                    if (order.startupId === startupId && order.date.getTime() <= T)
                    {
                        quantity += order.quantity;
                    }
                }
                for (const order of sellOrders)
                {
                    if (order.startupId === startupId && order.date.getTime() <= T)
                    {
                        quantity -= order.filledQuantity;
                    }
                }

                if (quantity > 0)
                {
                    // Determina o preço da startup em T
                    let price = startupPrices.get(startupId) ?? 0;
                    const snaps = startupSnapshots.get(startupId) ?? [];

                    // snaps estão ordenados de forma crescente pelo tempo de registro
                    let foundPrice = false;
                    for (let j = snaps.length - 1; j >= 0; j--)
                    {
                        const snapDate = snaps[j].recorded_at.toDate
                            ? snaps[j].recorded_at.toDate()
                            : new Date(snaps[j].recorded_at);

                        if (snapDate.getTime() <= T)
                        {
                            price = snaps[j].price;
                            foundPrice = true;
                            break;
                        }
                    }

                    // Se não houver snapshot registrado antes ou em T, usa o preço do primeiro snapshot
                    if (!foundPrice && snaps.length > 0)
                    {
                        price = snaps[0].price;
                    }

                    assetsValue += quantity * price;
                }
            }

            return {
                timestamp: T,
                patrimony: Math.max(0, Math.round((balance + assetsValue) * 100) / 100),
            };
        });

        logger.info(`Histórico calculado com sucesso contendo ${history.length} pontos.`);

        return {history};
    }
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(`Erro de autenticação: ${error.message}`);
            throw new HttpsError('unauthenticated', error.message);
        }
        if (error instanceof ValidationError)
        {
            logger.error(`Erro de validação: ${error.message}`);
            throw new HttpsError('invalid-argument', error.message);
        }

        const internal = new InternalError('Falha interna ao calcular histórico de evolução patrimonial.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
