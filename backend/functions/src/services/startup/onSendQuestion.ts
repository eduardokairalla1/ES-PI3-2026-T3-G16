/**
 * Function callable onSendQuestion.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import {HttpsError} from 'firebase-functions/v2/https';
import {addQuestion, getStartup} from '../../db/startups/storage';
import {isUserInvestorInStartup} from '../../db/investments/storage';
import {getUser} from '../../db/users/storage';
import {verifyAuth} from '../../utils/auth';
import {logger} from '../../utils/logger';


/**
 * ERRORS
 */
import {AuthError} from '../../errors/authError';
import {InternalError} from '../../errors/internalError';
import {NotFoundError} from '../../errors/notFoundError';
import {PermissionError} from '../../errors/permissionError';
import {ValidationError} from '../../errors/validationError';


/**
 * TYPES
 */
import type {CallableRequest} from 'firebase-functions/v2/https';
import {SendQuestionRequest} from '../../types/responders/startups';
import {parseRequest} from '../../utils/validation';


/**
 * CODE
 */

/**
 * I handle the onSendQuestion callable.
 * Adds a question to a startup's questions subcollection.
 *
 * @param request callable request with startupId, text and isPrivate
 *
 * @returns the created question
 */
export async function handleOnSendQuestion(request: CallableRequest)
{
    try
    {
        // verify authentication and extract uid
        const uid = verifyAuth(request);

        // validate request data
        const parsed = parseRequest(SendQuestionRequest, request.data);

        // fetch startup and user profile in parallel
        const [startup, user] = await Promise.all([
            getStartup(parsed.startupId),
            getUser(uid),
        ]);

        if (startup === null)
        {
            throw new NotFoundError(`Startup "${parsed.startupId}" not found.`);
        }
        if (user === null)
        {
            throw new AuthError(`User profile not found for uid "${uid}".`);
        }

        // private questions are restricted to investors of the startup
        if (parsed.isPrivate)
        {
            const isInvestor = await isUserInvestorInStartup(uid, parsed.startupId);
            if (!isInvestor)
            {
                throw new PermissionError(
                    `User "${uid}" is not an investor in startup "${parsed.startupId}" and cannot send private questions.`,
                );
            }
        }

        // add the question
        logger.info(`User "${uid}" sending question to startup "${parsed.startupId}"...`);
        const question = await addQuestion(
            parsed.startupId,
            uid,
            user.full_name,
            parsed.text,
            parsed.isPrivate,
        );
        logger.info(`Question "${question.id}" added to startup "${parsed.startupId}".`);

        return {
            answer: question.answer,
            answeredAt: question.answered_at,
            authorName: question.author_name,
            createdAt: question.created_at,
            id: question.id,
            isPrivate: question.is_private,
            startupId: question.startup_id,
            text: question.text,
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
        if (error instanceof PermissionError)
        {
            logger.error(error.message);
            throw new HttpsError('permission-denied', error.message);
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

        const internal = new InternalError('Failed to send question.', error);
        logger.error(internal.message, internal.cause);
        throw new HttpsError('internal', internal.message);
    }
}
