/**
 * Function trigger onUserCreated.
 *
 * Davi da Cruz Shieh - 24798076
 */

/**
 * IMPORTS
 */
import * as z from 'zod';
import {auth} from 'firebase-functions/v1';
import {addUser} from '../../db/users';
import {logger} from '../../utils/logger';


/**
 * TYPES
 */
import type {UserRecord} from 'firebase-admin/auth';


/**
 * CODE
 */

/**
 * I handle the onUserCreated trigger.
 *
 * @param user user data from the trigger
 *
 * :returns: nothing
 */
async function handleOnUserCreated(user: UserRecord)
{

    // try to add user
    logger.info(`Adding user "${user.uid}"...`, {data: user});
    try
    {
        const addedUser = await addUser(
            {
                created_at: new Date().toISOString(),
                email: user.email!,
                full_name: user.displayName ?? '',
                status: 'active',
                uid: user.uid,
                updated_at: null,
            },
        );
        logger.info(`User "${user.uid}" added successfully.`, {data: addedUser});
    }

    // on error: log error
    catch (error)
    {
        logger.error(`Failed to handle user "${user?.uid}" creation`);

        // error is a validation error: log error
        if (error instanceof z.ZodError)
        {
            logger.error(
                'Validation error',
                error,
                {
                    fieldErrors: z.flattenError(error).fieldErrors,
                    formErrors: z.flattenError(error).formErrors,
                },
            );
        }
    }
}


// export the function trigger
export const onUserCreated = auth.user().onCreate(handleOnUserCreated);
