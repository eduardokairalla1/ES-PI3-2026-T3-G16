/**
 * Startup database operations.
 *
 * Eduardo Kairalla - 24024241
 */

/**
 * IMPORTS
 */
import {FieldValue} from 'firebase-admin/firestore';
import db from '../../configs';


/**
 * TYPES
 */
import type {QuestionDocument, StartupDocument, StartupStage} from './model';


/**
 * CODE
 */

/**
 * I get all startups, optionally filtered by stage.
 *
 * @param stage optional stage filter
 *
 * @returns list of startup documents
 */
export async function getStartups(stage?: StartupStage): Promise<StartupDocument[]>
{

    // get reference to startups collection
    const col = db.collection('startups');

    // if stage filter provided, query startups by stage; otherwise get all startups
    const snapshot = stage !== undefined
        ? await col.where('stage', '==', stage).orderBy('name').get()
        : await col.orderBy('name').get();

    // map documents to StartupDocument objects
    return snapshot.docs.map(doc => ({id: doc.id, ...doc.data()} as StartupDocument));
}


/**
 * I get a startup by its Firestore document ID.
 *
 * @param id Firestore document ID
 *
 * @returns the startup document, or null if not found
 */
export async function getStartup(id: string): Promise<StartupDocument | null>
{

    // get document reference and snapshot
    const doc = await db.collection('startups').doc(id).get();

    // if document doesn't exist, return null; otherwise map to StartupDocument object
    if (!doc.exists) return null;

    // map document to StartupDocument and return
    return {id: doc.id, ...doc.data()} as StartupDocument;
}


/**
 * I add a question to a startup's questions subcollection.
 *
 * @param startupId  Firestore document ID of the startup
 * @param authorUid  Firebase Auth UID of the question author
 * @param authorName full name of the question author
 * @param text       question text
 * @param isPrivate  whether the question is private (investor-only)
 *
 * @returns the created question document
 */
export async function addQuestion(
    startupId: string,
    authorUid: string,
    authorName: string,
    text: string,
    isPrivate: boolean,
): Promise<QuestionDocument>
{
    // create question object (without ID)
    const question: Omit<QuestionDocument, 'id'> = {
        'answer': null,
        'answered_at': null,
        'author_name': authorName,
        'author_uid': authorUid,
        'created_at': new Date(),
        'is_private': isPrivate,
        'startup_id': startupId,
        'text': text,
    };

    // add question to Firestore and get reference to new document
    const ref = await db
        .collection('startups')
        .doc(startupId)
        .collection('questions')
        .add(question);

    // return question document with ID included
    return {id: ref.id, ...question};
}


/**
 * I decrement the available_tokens of a startup by the given quantity.
 * Must be called inside a batch or transaction that already validates stock.
 *
 * @param batch     Firestore WriteBatch to include the update in
 * @param startupId Firestore document ID of the startup
 * @param quantity  number of tokens to reserve
 */
export function batchDecrementAvailableTokens(
    batch: FirebaseFirestore.WriteBatch,
    startupId: string,
    quantity: number,
): void
{
    // get reference to startup document
    const ref = db.collection('startups').doc(startupId);

    // decrement available_tokens by quantity and update updated_at timestamp
    batch.update(ref, {
        available_tokens: FieldValue.increment(-quantity),
        updated_at:       new Date(),
    });
}


/**
 * I get the public questions for a startup.
 *
 * @param startupId Firestore document ID of the startup
 *
 * @returns list of public question documents, newest first
 */
export async function getPublicQuestions(startupId: string): Promise<QuestionDocument[]>
{
    const snapshot = await db
        .collection('startups')
        .doc(startupId)
        .collection('questions')
        .where('is_private', '==', false)
        .orderBy('created_at', 'desc')
        .get();

    return snapshot.docs.map(doc => ({id: doc.id, ...doc.data()} as QuestionDocument));
}


/**
 * I get the private questions authored by a specific user for a startup.
 *
 * @param startupId Firestore document ID of the startup
 * @param authorUid Firebase Auth UID of the question author
 *
 * @returns list of private question documents authored by the user, newest first
 */
export async function getUserPrivateQuestions(
    startupId: string,
    authorUid: string,
): Promise<QuestionDocument[]>
{
    const snapshot = await db
        .collection('startups')
        .doc(startupId)
        .collection('questions')
        .where('is_private', '==', true)
        .where('author_uid', '==', authorUid)
        .orderBy('created_at', 'desc')
        .get();

    return snapshot.docs.map(doc => ({id: doc.id, ...doc.data()} as QuestionDocument));
}
