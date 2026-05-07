/**
 * Function callable onGetStartups.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getStartups} from '../../db/startups/storage';
import {logger} from '../../utils/logger';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {ValidationError} from '../../errors/validationError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';
import {GetStartupsRequest} from '../../types/responders/startups';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

/**
 * I handle the onGetStartups callable.
 * Returns all startups, optionally filtered by stage.
 *
 * @param request callable request with optional stage filter
 *
 * @returns list of startups
 */
export async function handleOnGetStartups(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        // validate request data
        const parsed = parseRequest(GetStartupsRequest, request.data);

        // fetch startups from Firestore
        logger.info('Fetching startups...', {data: {stage: parsed.stage}});
        const startups = await getStartups(parsed.stage);
        logger.info(`Fetched ${startups.length} startups.`);

        return {
            startups: startups.map(s => (
                {
                    advisors: s.advisors,
                    capitalRaised: s.capital_raised,
                    createdAt: s.created_at,
                    description: s.description,
                    executiveSummary: s.executive_summary,
                    id: s.id,
                    logoUrl: s.logo_url,
                    name: s.name,
                    partners: s.partners,
                    stage: s.stage,
                    tagline: s.tagline,
                    tokenPrice: s.token_price,
                    totalTokens: s.total_tokens,
                    updatedAt: s.updated_at,
                    videoUrl: s.video_url,
                }
            )),
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
        if (error instanceof ValidationError)
        {
            logger.error(error.message);
            throw new HttpsError('invalid-argument', error.message);
        }

        const internal = new InternalError('Failed to fetch startups.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
