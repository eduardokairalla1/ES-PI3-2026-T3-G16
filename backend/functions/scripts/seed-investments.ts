/**
 * Seed script — populates Firestore emulator with sample investments.
 * Run while the Firebase emulator is running:
 *   npm run seed:investments
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/**
 * IMPORTS
 */
import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';

import type {InvestmentDocument} from '../src/db/investments/model';


/**
 * CODE
 */

// initialize Firebase Admin pointing at the local emulator
const app = initializeApp({projectId: 'mesclainvest-eda16'});
const db = getFirestore(app);
const auth = getAuth(app);



/**
 * I process a transaction from the "Balcão" (trading desk).
 *
 * TO THE DEVELOPER: Implement the business logic for token trading here.
 * This should handle creating the investment record, updating user balance,
 * creating transaction logs, etc.
 *
 * @param userDocId Firestore ID of the user
 * @param startup   Startup document data
 * @param quantity  Amount of tokens bought
 * @param price     Price per token
 */
async function processBalcaoTransaction(
    userDocId: string,
    startup: {id: string, name: string, logo_url: string},
    quantity: number,
    price: number,
): Promise<void>
{
    // --- PREPARED GROUND: INSERT LOGIC BELOW ---
    // Example: updating the user's investments sub-collection
    const invCol = db.collection('users').doc(userDocId).collection('investments');

    const investment: Omit<InvestmentDocument, 'id'> = {
        'avg_purchase_price': price,
        'created_at': new Date(),
        'startup_id': startup.id,
        'startup_logo_url': startup.logo_url,
        'startup_name': startup.name,
        'token_quantity': quantity,
        'updated_at': null,
    };

    const ref = await invCol.add(investment);
    console.log(`✓ [Balcão] Registered ${quantity} tokens of "${startup.name}" for user ${userDocId} (ID: ${ref.id})`);
}


async function seed(): Promise<void>
{
    console.log('Seeding investments (using Balcão logic)...\n');

    // 1. Find the first user in the auth emulator
    const listResult = await auth.listUsers(1);
    if (listResult.users.length === 0)
    {
        console.error('No users found in the auth emulator. Please create a user first.');
        process.exit(1);
    }

    const uid = listResult.users[0].uid;
    const userDocId = await getUserDocId(uid);

    if (userDocId === null)
    {
        console.error('User document not found in Firestore. Please run the app and register first.');
        process.exit(1);
    }

    console.log(`Target User UID: ${uid} (Doc: ${userDocId})\n`);

    // 2. Get existing startups to reference them
    const startupsSnapshot = await db.collection('startups').orderBy('name').get();
    if (startupsSnapshot.empty)
    {
        console.error('No startups found. Run seed-startups first.');
        process.exit(1);
    }

    const startups = startupsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
    })) as any[];

    // 3. Simulate transactions using the Balcão function
    // We'll take the first few startups and simulate a purchase for each
    // This removes the hardcoded array and uses the "ground" we prepared.
    const sampleSize = Math.min(startups.length, 3);

    for (let i = 0; i < sampleSize; i++)
    {
        const startup = startups[i];
        // Dynamic values based on startup data instead of hardcoded fixed list
        const quantity = 1000 * (i + 1);
        const price = startup.token_price || 0.5;

        await processBalcaoTransaction(userDocId, startup, quantity, price);
    }

    console.log('\nInvestments seed complete.');
}

seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});

