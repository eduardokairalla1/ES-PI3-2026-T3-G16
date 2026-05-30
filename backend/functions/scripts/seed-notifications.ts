/**
 * Seed script — populates the demo users' inbox with sample notifications.
 *
 * Run with the emulators up:
 *   npm run seed:notifications
 *
 * Idempotent: wipes before re-inserting.
 * Requires seed:users and seed:startups to have run first.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 */


/**
 * IMPORTS
 */

process.env.FIRESTORE_EMULATOR_HOST ??= 'localhost:8080';

import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';

import type {NotificationDocument, NotificationType} from '../src/db/notifications/model';


/**
 * CONFIG
 */

const PROJECT_ID = 'mesclainvest-eda16';

// First N users (aluno001..aluno005) get a populated inbox on first login.
const TARGET_USER_COUNT = 5;


/**
 * TEMPLATES
 *
 * `minutesAgo` spreads the dates across the modal's four date buckets
 * (Hoje, Ontem, Esta semana, Mais antigas).
 * `startupSlot`: 'first' = first startup alphabetically; 'random' = varies
 * per item; absent = template doesn't reference any startup.
 */
interface NotificationTemplate
{
    type:        NotificationType;
    title:       string;
    body:        string;
    minutesAgo:  number;
    startupSlot?: 'first' | 'random';
}

const TEMPLATES: NotificationTemplate[] = [
    {
        body:        '10 {startup} por R$ 125,00.',
        minutesAgo:  3,
        startupSlot: 'first',
        title:       'Sua compra foi executada',
        type:        'order_executed',
    },
    {
        body:        'R$ 500,00 foi adicionado à sua carteira.',
        minutesAgo:  60,
        title:       'Depósito confirmado',
        type:        'deposit_confirmed',
    },
    {
        body:        '"Acreditamos no break-even em 16 a 18 meses após esta rodada."',
        minutesAgo:  240,
        startupSlot: 'random',
        title:       '{startup} respondeu sua pergunta',
        type:        'question_answered',
    },
    {
        body:        '5 {startup} por R$ 62,50.',
        minutesAgo:  60 * 26,                                  // yesterday
        startupSlot: 'random',
        title:       'Sua venda no balcão foi casada',
        type:        'order_counter_match',
    },
    {
        body:        '30 de 50 {startup} negociados por R$ 360,00. O restante segue no balcão.',
        minutesAgo:  60 * 30,                                  // yesterday
        startupSlot: 'random',
        title:       'Sua compra foi parcialmente executada',
        type:        'order_executed',
    },
    {
        body:        'Faça seu primeiro depósito e comece a investir nas startups do ecossistema.',
        minutesAgo:  60 * 24 * 3,                              // 3 days
        title:       'Bem-vindo ao MesclaInvest!',
        type:        'welcome',
    },
    {
        body:        'R$ 1.000,00 foi adicionado à sua carteira.',
        minutesAgo:  60 * 24 * 5,                              // 5 days
        title:       'Depósito confirmado',
        type:        'deposit_confirmed',
    },
    {
        body:        '15 {startup} por R$ 195,00.',
        minutesAgo:  60 * 24 * 10,                             // 10 days
        startupSlot: 'random',
        title:       'Sua compra foi executada',
        type:        'order_executed',
    },
];


/**
 * HELPERS
 */

function minutesAgo(minutes: number): Date
{
    const d = new Date();
    d.setMinutes(d.getMinutes() - minutes);
    return d;
}


function fillStartup(raw: string, startupName: string): string
{
    return raw.replace(/\{startup\}/g, startupName);
}


/**
 * SEED
 */

async function seed(): Promise<void>
{
    const app = initializeApp({projectId: PROJECT_ID});
    const db  = getFirestore(app);

    console.log(`Seeding notifications inbox for the first ${TARGET_USER_COUNT} demo users...`);
    console.log(`  Firestore: ${process.env.FIRESTORE_EMULATOR_HOST}\n`);

    const startupsSnap = await db.collection('startups').orderBy('name').get();
    if (startupsSnap.empty)
    {
        console.error('✗ No startups found. Run "npm run seed:startups" first.');
        process.exit(1);
    }
    const startupNames = startupsSnap.docs.map(d => d.data().name as string);

    let createdTotal = 0;
    let wipedTotal   = 0;

    for (let i = 0; i < TARGET_USER_COUNT; i++)
    {
        const padded = String(i + 1).padStart(3, '0');
        const uid    = `seed-user-${padded}`;

        const notifRef = db.collection('users').doc(uid).collection('notifications');

        // Wipe before re-inserting so re-runs yield a deterministic state.
        const existing = await notifRef.get();
        if (!existing.empty)
        {
            const batch = db.batch();
            for (const d of existing.docs) batch.delete(d.ref);
            await batch.commit();
            wipedTotal += existing.size;
        }

        const batch = db.batch();
        let createdHere = 0;
        for (let t = 0; t < TEMPLATES.length; t++)
        {
            const template    = TEMPLATES[t];
            const startupName = template.startupSlot === 'first'
                ? startupNames[0]
                : template.startupSlot === 'random'
                    ? startupNames[(t + i) % startupNames.length]
                    : '';

            const title = fillStartup(template.title, startupName);
            const body  = fillStartup(template.body,  startupName);

            const doc: Omit<NotificationDocument, 'id'> = {
                'body':       body,
                'created_at': minutesAgo(template.minutesAgo),
                'payload':    startupName !== '' ? {'startupName': startupName} : {},
                'title':      title,
                'type':       template.type,
            };
            batch.set(notifRef.doc(), doc);
            createdHere++;
        }
        await batch.commit();

        createdTotal += createdHere;
        console.log(`✓ ${uid} — ${createdHere} notifications created`);
    }

    console.log('\nDone.');
    console.log(`  Wiped:    ${wipedTotal}`);
    console.log(`  Created:  ${createdTotal}`);
    console.log(`\nLogin as aluno001..aluno${String(TARGET_USER_COUNT).padStart(3, '0')}@mescla.test`);
    console.log('Password: Mescla@2026\n');
}


seed().catch((err) =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
