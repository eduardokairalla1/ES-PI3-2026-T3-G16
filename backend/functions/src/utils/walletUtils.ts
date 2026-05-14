/**
 * Shared wallet utility functions.
 *
 * Davi da Cruz Shieh - 24798076
 */

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
