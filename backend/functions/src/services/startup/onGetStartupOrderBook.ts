/**
 * Function callable onGetStartupOrderBook.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 *
 * Returns the open offers of a startup as individual orders (not aggregated
 * by price), so the UI can render one card per order with the seller's price
 * and the variance vs the current market price. Also returns the last trade
 * and the current bonding-curve price (used as the market reference).
 */

// --- IMPORTS ---
import {HttpsError} from 'firebase-functions/v2/https';
import {
    getOpenOrdersForStartup,
    getLastCompletedOrderForStartup,
} from '../../db/orders/storage';
import {getStartup} from '../../db/startups/storage';
import {logger} from '../../utils/logger';


// --- ERRORS ---
import {ValidationError} from '../../errors/validationError';
import {NotFoundError} from '../../errors/notFoundError';
import {InternalError} from '../../errors/internalError';


// --- TYPES ---
import type {CallableRequest} from 'firebase-functions/v2/https';
import type {OrderDocument} from '../../db/orders/model';
import {GetStartupOrderBookRequest} from '../../types/responders/investment';
import {parseRequest} from '../../utils/validation';


// --- CONSTANTS ---

// keep the response small. depth is per side (buy/sell).
const MAX_DEPTH     = 50;
const DEFAULT_DEPTH = 30;


// --- CODE ---

/**
 * I map a Firestore order doc to the slim shape the UI needs (price + remaining).
 *
 * @param o raw order document
 *
 * @returns serialized open order entry
 */
function toEntry(o: OrderDocument)
{
    const filled = o.filled_quantity ?? 0;
    return {
        orderId:    o.id,
        uid:        o.uid,
        price:      o.unit_price,
        quantity:   o.quantity,
        remaining:  o.quantity - filled,
        createdAt:  o.created_at,
    };
}


/**
 * I handle the onGetStartupOrderBook callable.
 * Returns the open offers of a startup as individual orders (one entry per
 * order, not aggregated by price), so the UI can render one card per offer
 * with its price and the variance vs the market reference. Also returns the
 * last completed trade and the current bonding-curve price.
 *
 * No auth required — the order book is public.
 *
 * @param request callable request with `startupId` and optional `depth`
 *   (default {@link DEFAULT_DEPTH}, capped at {@link MAX_DEPTH})
 *
 * @returns `{buyOrders, sellOrders, lastTradePrice, lastTradeAt, currentMarketPrice}`
 *
 * @throws HttpsError('invalid-argument') if `depth` exceeds {@link MAX_DEPTH}
 * @throws HttpsError('not-found')        if the startup does not exist
 */
export async function handleOnGetStartupOrderBook(request: CallableRequest)
{
    try
    {
        // validate input (no auth required — order book is public)
        const {startupId, depth} = parseRequest(GetStartupOrderBookRequest, request.data);

        const requested = depth ?? DEFAULT_DEPTH;
        if (requested > MAX_DEPTH)
        {
            throw new ValidationError(`Depth cannot exceed ${MAX_DEPTH}.`);
        }

        logger.info(`Fetching order book for startup "${startupId}" (depth=${requested})...`);

        const [startup, buyOrders, sellOrders, lastTrade] = await Promise.all([
            getStartup(startupId),
            getOpenOrdersForStartup(startupId, 'buy',  requested),
            getOpenOrdersForStartup(startupId, 'sell', requested),
            getLastCompletedOrderForStartup(startupId),
        ]);

        if (startup === null)
        {
            throw new NotFoundError(`Startup "${startupId}" not found.`);
        }

        return {
            // raw individual orders, best price first (already sorted by storage)
            buyOrders:  buyOrders.map(toEntry),
            sellOrders: sellOrders.map(toEntry),
            // last completed trade — drives the "last price" header
            lastTradePrice: lastTrade?.avg_fill_price ?? lastTrade?.unit_price ?? null,
            lastTradeAt:    lastTrade?.completed_at   ?? null,
            // current bonding-curve price — used as the market reference so the
            // UI can render the % variance for each offer
            currentMarketPrice: startup.token_price,
        };
    }

    catch (error: unknown)
    {
        if (error instanceof ValidationError)
        {
            logger.error(error.message);
            throw new HttpsError('invalid-argument', error.message);
        }
        if (error instanceof NotFoundError)
        {
            logger.error(error.message);
            throw new HttpsError('not-found', error.message);
        }

        const internal = new InternalError('Failed to fetch order book.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
