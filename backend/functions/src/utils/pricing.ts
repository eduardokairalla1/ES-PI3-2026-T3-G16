/**
 * Token pricing utilities — bonding curve model.
 *
 * Formula: price = base_price × (1 + k × tokens_sold / total_tokens)
 *
 * k (appreciation_factor) is fixed per startup and controls how much the
 * price grows as tokens are sold. When all tokens are sold the price reaches:
 *   base_price × (1 + k)
 *
 * Davi da Cruz Shieh - 24798076
 */


/**
 * I calculate the current token price based on the bonding curve.
 *
 * @param basePrice    original token price defined at startup creation
 * @param totalTokens  total token supply
 * @param availableTokens tokens not yet sold
 * @param k            appreciation factor (appreciation_factor on StartupDocument)
 *
 * @returns current token price
 */
export function calcTokenPrice(
    basePrice: number,
    totalTokens: number,
    availableTokens: number,
    k: number,
): number
{
    const tokensSold = totalTokens - availableTokens;
    return basePrice * (1 + k * (tokensSold / totalTokens));
}
