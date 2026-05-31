/**
 * Shared wallet utility functions.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import db from '../configs';
import {getHistoricalPrice} from '../db/price_history/storage';

/**
 * TYPES
 */
import type {OrderDocument} from '../db/orders/model';


/**
 * I group total token quantities by startup from a list of completed orders.
 *
 * @param orders list of completed buy orders
 *
 * @returns map of startupId → total quantity held
 */
export function mapTotalTokensByStartup(orders: OrderDocument[]): Record<string, number>
{
    const totalTokensByStartup: Record<string, number> = {};

    for (const {startup_id, quantity} of orders)
    {
        totalTokensByStartup[startup_id] = (totalTokensByStartup[startup_id] ?? 0) + quantity;
    }

    return totalTokensByStartup;
}


/**
 * I compute weekly return in BRL and percentage from current and past position values.
 *
 * @param values list of { currentValue, pastValue } per startup
 *
 * @returns weeklyReturn (BRL) and weeklyReturnPct (%)
 */
export function calcWeeklyReturn(
    values: {currentValue: number; pastValue: number}[],
): {weeklyReturn: number; weeklyReturnPct: number}
{
    const totalCurrent = values.reduce((s, v) => s + v.currentValue, 0);
    const totalPast = values.reduce((s, v) => s + v.pastValue, 0);
    const weeklyReturn = totalCurrent - totalPast;
    const weeklyReturnPct = totalPast > 0 ? (weeklyReturn / totalPast) * 100 : 0;
    return {weeklyReturn, weeklyReturnPct};
}


/**
 * Helper to safely convert Firestore Timestamp or string to JS Date
 */
export function toJsDate(val: any): Date
{
    if (!val) return new Date(0);
    if (typeof val.toDate === 'function')
    {
        return val.toDate();
    }
    return new Date(val);
}

/**
 * Helper to determine the effective event date of an order (completed or cancelled)
 */
export function getOrderEventDate(order: OrderDocument): Date
{
    if (order.status === 'completed' && order.completed_at)
    {
        return toJsDate(order.completed_at);
    }
    if (order.status === 'cancelled' && order.cancelled_at)
    {
        return toJsDate(order.cancelled_at);
    }
    return toJsDate(order.created_at);
}

/**
 * I compute the wallet custody and cash-flow adjusted weekly yield.
 *
 * @param uid             Firebase Auth UID
 * @param startupPriceMap Map of startupId to current token price
 *
 * @returns portfolio holdings map and the adjusted weeklyReturn & weeklyReturnPct
 */
export async function computeWalletState(
    uid: string,
    startupPriceMap: Map<string, number>,
    startupBasePriceMap: Map<string, number>,
): Promise<{
    holdingsByStartup: Map<string, {quantity: number; buyQuantity: number; totalCost: number}>;
    weeklyReturn: number;
    weeklyReturnPct: number;
}>
{
    // 1. Fetch buy and sell orders (all by user, filter in memory)
    const [buyOrdersSnap, sellOrdersSnap] = await Promise.all([
        db.collection('orders').where('uid', '==', uid).where('type', '==', 'buy').get(),
        db.collection('orders').where('uid', '==', uid).where('type', '==', 'sell').get(),
    ]);

    const buyOrders = buyOrdersSnap.docs.map(doc => doc.data() as OrderDocument);
    const sellOrders = sellOrdersSnap.docs.map(doc => doc.data() as OrderDocument);

    // 2. Define timeframe (7 days ago)
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    // 3. Compute current holdings
    const holdingsByStartup = new Map<string, {quantity: number; buyQuantity: number; totalCost: number}>();

    for (const order of buyOrders)
    {
        const filled = order.filled_quantity ?? 0;
        if (filled <= 0) continue;

        const existing = holdingsByStartup.get(order.startup_id);
        if (existing)
        {
            existing.quantity    += filled;
            existing.buyQuantity += filled;
            existing.totalCost   += (order.avg_fill_price ?? order.unit_price) * filled;
        }
        else
        {
            holdingsByStartup.set(order.startup_id, {
                buyQuantity: filled,
                quantity:    filled,
                totalCost:   (order.avg_fill_price ?? order.unit_price) * filled,
            });
        }
    }

    for (const order of sellOrders)
    {
        const filled = order.filled_quantity ?? 0;
        if (filled <= 0) continue;

        const existing = holdingsByStartup.get(order.startup_id);
        if (existing)
        {
            existing.quantity -= filled;
        }
    }

    // Clean up fully liquidated assets from current holdings map
    for (const [sid, holding] of Array.from(holdingsByStartup.entries()))
    {
        if (holding.quantity <= 0)
        {
            holdingsByStartup.delete(sid);
        }
    }

    // 4. Compute past holdings (7 days ago)
    const pastHoldingsByStartup = new Map<string, {quantity: number}>();

    for (const order of buyOrders)
    {
        const filled = order.filled_quantity ?? 0;
        if (filled <= 0) continue;

        const orderDate = getOrderEventDate(order);
        if (orderDate < weekAgo)
        {
            const existing = pastHoldingsByStartup.get(order.startup_id);
            if (existing)
            {
                existing.quantity += filled;
            }
            else
            {
                pastHoldingsByStartup.set(order.startup_id, {quantity: filled});
            }
        }
    }

    for (const order of sellOrders)
    {
        const filled = order.filled_quantity ?? 0;
        if (filled <= 0) continue;

        const orderDate = getOrderEventDate(order);
        if (orderDate < weekAgo)
        {
            const existing = pastHoldingsByStartup.get(order.startup_id);
            if (existing)
            {
                existing.quantity -= filled;
            }
            else
            {
                pastHoldingsByStartup.set(order.startup_id, {quantity: -filled});
            }
        }
    }

    // 5. Compute weekly transaction cash-flows (buys cost and sales proceeds)
    const weeklyBuysCostByStartup = new Map<string, number>();
    const weeklySalesProceedsByStartup = new Map<string, number>();

    for (const order of buyOrders)
    {
        const filled = order.filled_quantity ?? 0;
        if (filled <= 0) continue;

        const orderDate = getOrderEventDate(order);
        if (orderDate >= weekAgo)
        {
            const price = order.avg_fill_price ?? order.unit_price;
            const amount = price * filled;
            weeklyBuysCostByStartup.set(
                order.startup_id,
                (weeklyBuysCostByStartup.get(order.startup_id) ?? 0) + amount,
            );
        }
    }

    for (const order of sellOrders)
    {
        const filled = order.filled_quantity ?? 0;
        if (filled <= 0) continue;

        const orderDate = getOrderEventDate(order);
        if (orderDate >= weekAgo)
        {
            const price = order.avg_fill_price ?? order.unit_price;
            const amount = price * filled;
            weeklySalesProceedsByStartup.set(
                order.startup_id,
                (weeklySalesProceedsByStartup.get(order.startup_id) ?? 0) + amount,
            );
        }
    }

    // 6. Union of all startup IDs in current or past holdings
    const allStartupIds = new Set([
        ...Array.from(holdingsByStartup.keys()),
        ...Array.from(pastHoldingsByStartup.keys()),
    ]);

    // 7. Calculate weekly values for each startup in the union
    const weeklyValues = await Promise.all(
        Array.from(allStartupIds).map(async (startupId) =>
        {
            const currentPrice = startupPriceMap.get(startupId) ?? 0;
            const currentQty = holdingsByStartup.get(startupId)?.quantity ?? 0;
            const pastQty = pastHoldingsByStartup.get(startupId)?.quantity ?? 0;
            const weeklyBuysCost = weeklyBuysCostByStartup.get(startupId) ?? 0;
            const weeklySalesProceeds = weeklySalesProceedsByStartup.get(startupId) ?? 0;

            const basePrice = startupBasePriceMap.get(startupId) ?? currentPrice;
            const pastPrice = await getHistoricalPrice(startupId, weekAgo, basePrice, currentPrice);

            return {
                currentValue: (currentQty * currentPrice) + weeklySalesProceeds,
                pastValue:    (pastQty * pastPrice) + weeklyBuysCost,
            };
        }),
    );

    // 8. Compute weekly return and percent
    const totalCurrent = weeklyValues.reduce((s, v) => s + v.currentValue, 0);
    const totalPast = weeklyValues.reduce((s, v) => s + v.pastValue, 0);
    const weeklyReturn = totalCurrent - totalPast;
    const weeklyReturnPct = totalPast > 0 ? (weeklyReturn / totalPast) * 100 : 0;

    return {
        holdingsByStartup,
        weeklyReturn,
        weeklyReturnPct,
    };
}
