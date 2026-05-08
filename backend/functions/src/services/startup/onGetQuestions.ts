/**
 * Function callable onGetQuestions.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {getPublicQuestions, getStartup, getUserPrivateQuestions} from '../../db/startups/storage';
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
import {GetQuestionsRequest} from '../../types/responders/startups';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

/**
 * I handle the onGetQuestions callable.
 * Returns public questions for a given startup.
 *
 * @param request callable request with startupId
 *
 * @returns list of public questions
 */
export async function handleOnGetQuestions(request: CallableRequest)
{
    try
    {
        // verify authentication
        if (request.auth === null || request.auth === undefined)
        {
            throw new AuthError('User must be authenticated.');
        }

        // validate request data
        const parsed = parseRequest(GetQuestionsRequest, request.data);

        // ensure the startup exists
        const startup = await getStartup(parsed.startupId);
        if (startup === null)
        {
            throw new NotFoundError(`Startup "${parsed.startupId}" not found.`);
        }

        // fetch public questions + caller's own private questions in parallel
        logger.info(`Fetching questions for startup "${parsed.startupId}"...`);
        const [publicQs, privateQs] = await Promise.all([
            getPublicQuestions(parsed.startupId),
            getUserPrivateQuestions(parsed.startupId, request.auth.uid),
        ]);

        const toMs = (d: any) => d?.toMillis ? d.toMillis() : new Date(d).getTime();
        const questions = [...publicQs, ...privateQs]
            .sort((a, b) => toMs(b.created_at) - toMs(a.created_at));

        logger.info(`Fetched ${questions.length} questions for startup "${parsed.startupId}".`);

        return {
            questions: questions.map(q => (
                {
                    answer: q.answer,
                    answeredAt: q.answered_at,
                    authorName: q.author_name,
                    createdAt: q.created_at,
                    id: q.id,
                    isPrivate: q.is_private,
                    startupId: q.startup_id,
                    text: q.text,
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

        const internal = new InternalError('Failed to fetch questions.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
