/**
 * Function callable onGetMyOrders.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 *
 * Returns every order the calling user has authored, across all startups,
 * newest first. Comes with denormalized startup name/logo/token_name so the
 * "Minhas ordens" tab does not have to do per-row lookups.
 */

// --- IMPORTS ---
import {HttpsError} from 'firebase-functions/v2/https';
import {getOrdersByUid} from '../../db/orders/storage';
import {getStartup} from '../../db/startups/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';


// --- ERRORS ---
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';


// --- TYPES ---
import type {CallableRequest} from 'firebase-functions/v2/https';


// --- CONSTANTS ---

// hard cap to keep the response payload small
const MAX_ORDERS = 100;


// --- CODE ---

/**
 * I handle the onGetMyOrders callable.
 * Returns every order the calling user has authored, newest first, capped at
 * {@link MAX_ORDERS}. Each entry comes denormalized with the startup name,
 * logo and token symbol so the "Minhas ordens" tab can render without
 * per-row lookups.
 *
 * @param request callable request (no body params, uses auth context)
 *
 * @returns `{orders: OrderModel[]}` shaped for the Flutter OrderModel
 *
 * @throws HttpsError('unauthenticated') if the caller is not signed in
 */
export async function handleOnGetMyOrders(request: CallableRequest)
{
    try
    {
        const uid = verifyAuth(request);

        logger.info(`Fetching all orders for user "${uid}"...`);

        const orders = await getOrdersByUid(uid, MAX_ORDERS);

        // collect unique startup IDs so we fetch each startup doc only once
        const startupIds = Array.from(new Set(orders.map(o => o.startup_id)));

        const startupEntries = await Promise.all(
            startupIds.map(async (sid) =>
            {
                const s = await getStartup(sid);
                return {sid, startup: s};
            }),
        );

        const startupById = new Map<string, {name: string; logoUrl: string | null; tokenName: string}>();
        for (const entry of startupEntries)
        {
            if (entry.startup !== null)
            {
                startupById.set(entry.sid, {
                    name:      entry.startup.name,
                    logoUrl:   entry.startup.logo_url,
                    tokenName: entry.startup.token_name ?? entry.startup.name.slice(0, 4).toUpperCase(),
                });
            }
        }

        // map orders to the shape the frontend OrderModel expects
        const enriched = orders.map((o) =>
        {
            const s = startupById.get(o.startup_id);
            return {
                orderId:         o.id,
                startupId:       o.startup_id,
                startupName:     s?.name      ?? 'Startup desconhecida',
                startupLogoUrl:  s?.logoUrl   ?? null,
                tokenName:       s?.tokenName ?? '',
                type:            o.type,
                status:          o.status,
                quantity:        o.quantity,
                filledQuantity:  o.filled_quantity ?? 0,
                unitPrice:       o.unit_price,
                avgFillPrice:    o.avg_fill_price ?? null,
                createdAt:       o.created_at,
                completedAt:     o.completed_at,
                cancelledAt:     o.cancelled_at ?? null,
            };
        });

        return {orders: enriched};
    }

    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }

        const internal = new InternalError('Failed to fetch user orders.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
