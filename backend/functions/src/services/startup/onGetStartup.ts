/**
 * Function callable onGetStartup.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getStartup} from '../../db/startups/storage';
import {logger} from '../../utils/logger';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {NotFoundError} from '../../errors/notFoundError';
import {ValidationError} from '../../errors/validationError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';
import {GetStartupRequest} from '../../types/responders/startups';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

/**
 * I handle the onGetStartup callable.
 * Returns the full details of a single startup by its ID.
 *
 * @param request callable request with startup ID
 *
 * @returns startup details
 */
export async function handleOnGetStartup(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        // validate request data
        const parsed = parseRequest(GetStartupRequest, request.data);

        // fetch startup from Firestore
        logger.info(`Fetching startup "${parsed.id}"...`, {data: {id: parsed.id}});
        const startup = await getStartup(parsed.id);

        // startup not found
        if (startup === null)
        {
            throw new NotFoundError(`Startup "${parsed.id}" not found.`);
        }

        logger.info(`Startup "${parsed.id}" fetched successfully.`);

        return {
            advisors: startup.advisors,
            capitalRaised: startup.capital_raised,
            createdAt: startup.created_at,
            description: startup.description,
            executiveSummary: startup.executive_summary,
            id: startup.id,
            logoUrl: startup.logo_url,
            name: startup.name,
            partners: startup.partners,
            stage: startup.stage,
            tagline: startup.tagline,
            tokenPrice: startup.token_price,
            totalTokens: startup.total_tokens,
            updatedAt: startup.updated_at,
            videoUrl: startup.video_url,
        };
    }

    // handle errors
    catch (error: unknown)
    {
        if (error instanceof AuthError)
        {
            logger.error(error.message);
            throw new HttpsError('unauthenticated', error.message);
        }
        if (error instanceof NotFoundError)
        {
            logger.error(error.message);
            throw new HttpsError('not-found', error.message);
        }
        if (error instanceof ValidationError)
        {
            logger.error(error.message);
            throw new HttpsError('invalid-argument', error.message);
        }

        const internal = new InternalError('Failed to fetch startup.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
