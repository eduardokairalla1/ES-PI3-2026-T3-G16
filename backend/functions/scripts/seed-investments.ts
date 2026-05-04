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


async function seed(): Promise<void>
{
    console.log('Seeding investments...\n');

    // find the first user in the auth emulator
    const listResult = await auth.listUsers(1);
    if (listResult.users.length === 0)
    {
        console.error('No users found in the auth emulator. Please create a user first.');
        process.exit(1);
    }

    const uid = listResult.users[0].uid;
    console.log(`Using user UID: ${uid}\n`);

    // find the user document in Firestore to get the doc ID
    const userSnapshot = await db.collection('users')
        .where('uid', '==', uid)
        .limit(1)
        .get();

    if (userSnapshot.empty)
    {
        console.error('User document not found in Firestore. Please run the app and register first.');
        process.exit(1);
    }

    const userDocId = userSnapshot.docs[0].id;

    // get existing startups to reference them
    const startupsSnapshot = await db.collection('startups').orderBy('name').get();
    if (startupsSnapshot.empty)
    {
        console.error('No startups found. Run seed-startups first.');
        process.exit(1);
    }

    const startups = startupsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
    }));

    // investments to seed — one per startup with varied quantities
    const investments: Omit<InvestmentDocument, 'id'>[] = [
        {
            'avg_purchase_price': 0.08,
            'created_at': new Date('2026-02-15'),
            'startup_id': startups[0].id,
            'startup_logo_url': (startups[0] as Record<string, unknown>)['logo_url'] as string,
            'startup_name': (startups[0] as Record<string, unknown>)['name'] as string,
            'token_quantity': 5000,
            'updated_at': null,
        },
        {
            'avg_purchase_price': 0.30,
            'created_at': new Date('2026-03-01'),
            'startup_id': startups[1].id,
            'startup_logo_url': (startups[1] as Record<string, unknown>)['logo_url'] as string,
            'startup_name': (startups[1] as Record<string, unknown>)['name'] as string,
            'token_quantity': 2000,
            'updated_at': new Date('2026-03-20'),
        },
        {
            'avg_purchase_price': 0.85,
            'created_at': new Date('2026-01-10'),
            'startup_id': startups[2].id,
            'startup_logo_url': (startups[2] as Record<string, unknown>)['logo_url'] as string,
            'startup_name': (startups[2] as Record<string, unknown>)['name'] as string,
            'token_quantity': 1000,
            'updated_at': null,
        },
    ];

    const invCol = db.collection('users').doc(userDocId).collection('investments');

    for (const inv of investments)
    {
        const ref = await invCol.add(inv);
        console.log(`✓ Created investment in "${inv.startup_name}" (${inv.token_quantity} tokens) with ID: ${ref.id}`);
    }

    console.log('\nInvestments seed complete.');
}

seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
