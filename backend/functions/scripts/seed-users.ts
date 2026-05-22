/**
 * Seed script — populates the Auth + Firestore emulators with 30 demo users.
 * Each user lands in Firebase Auth, in `users/` and in `wallets/` with a starting
 * balance, so the trading desk has buyers ready to go.
 *
 * Run while the Firebase emulator is running:
 *   npm run seed:users
 *
 * Idempotent: UIDs are deterministic (seed-user-01..30) and existing users are skipped.
 *
 * Pedro Henrique Medeiros dos Reis - 24801656
 */

/**
 * IMPORTS
 */

// point the Admin SDK at local emulators before importing it — these defaults
// can be overridden by exporting the env vars before invoking the script
process.env.FIRESTORE_EMULATOR_HOST     ??= 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= 'localhost:9099';

import {initializeApp}  from 'firebase-admin/app';
import {getAuth}        from 'firebase-admin/auth';
import {getFirestore}   from 'firebase-admin/firestore';

import type {userDocument}   from '../src/db/users/model';
import type {walletDocument} from '../src/db/wallets/model';


/**
 * CONFIG
 */

const PROJECT_ID       = 'mesclainvest-eda16';
const TOTAL_USERS      = 150;
const COMMON_PASSWORD  = 'Mescla@2026';
const STARTING_BALANCE = 10000;            // BRL 10k per wallet for trading tests
const EMAIL_DOMAIN     = 'mescla.test';


// 30 first names + 30 last names — combined by index → unique full names
const FIRST_NAMES = [
    'Ana',     'Bruno',    'Carla',    'Daniel',  'Elisa',
    'Felipe',  'Gabriela', 'Henrique', 'Isabela', 'João',
    'Karina',  'Lucas',    'Mariana',  'Nicolas', 'Olívia',
    'Pedro',   'Raquel',   'Rafael',   'Sofia',   'Thiago',
    'Vitória', 'Vinícius', 'Amanda',   'Bernardo', 'Camila',
    'Diego',   'Eduarda',  'Fernando', 'Giovanna', 'Hugo',
];

const LAST_NAMES = [
    'Silva',     'Santos',     'Oliveira',   'Souza',      'Lima',
    'Pereira',   'Costa',      'Ferreira',   'Almeida',    'Carvalho',
    'Gomes',     'Martins',    'Araújo',     'Ribeiro',    'Rodrigues',
    'Barbosa',   'Cardoso',    'Pinto',      'Moreira',    'Nascimento',
    'Mendes',    'Castro',     'Campos',     'Cavalcanti', 'Dias',
    'Freitas',   'Teixeira',   'Marques',    'Vieira',     'Rocha',
];


/**
 * HELPERS
 */

/**
 * I compute one CPF check digit using the Mod11 algorithm, with the weight
 * running from `startWeight` down to 2.
 *
 * @param digits      base digits of the CPF (either 9 for d1, or 10 for d2)
 * @param startWeight starting weight (10 for the first digit, 11 for the second)
 *
 * @returns the resulting check digit (0..9)
 */
function checkDigit(digits: number[], startWeight: number): number
{
    let sum = 0;
    for (let i = 0; i < digits.length; i++)
    {
        sum += digits[i] * (startWeight - i);
    }
    const rest = sum % 11;
    return rest < 2 ? 0 : 11 - rest;
}


/**
 * I produce a Mod11-valid 11-digit CPF deterministically from `seed`. Spread
 * across the digit space so the 30 outputs don't collide and don't look like
 * obvious test sequences (e.g. 11111111111 which is rejected by real validators).
 *
 * @param seed any positive integer; same input → same CPF
 *
 * @returns 11-digit numeric string with valid check digits
 */
function generateCpf(seed: number): string
{
    const base   = (seed * 1234567) % 1000000000;
    const digits = base.toString().padStart(9, '0').split('').map(Number);

    const d1 = checkDigit(digits, 10);
    const d2 = checkDigit([...digits, d1], 11);

    return [...digits, d1, d2].join('');
}


/**
 * I produce a Brazilian-format mobile phone number deterministically from `seed`.
 *
 * @param seed any positive integer; same input → same phone
 *
 * @returns string in the form `(DDD) 9XXXX-XXXX`
 */
function generatePhone(seed: number): string
{
    const ddds = [11, 21, 19, 31, 41, 51, 61, 71, 81, 85];
    const ddd  = ddds[seed % ddds.length];

    const part1 = String(90000 + (seed * 137)  % 10000).slice(-4);
    const part2 = String(10000 + (seed * 4231) % 10000).slice(-4);

    return `(${ddd}) 9${part1}-${part2}`;
}


/**
 * I produce a birth date (YYYY-MM-DD) deterministically from `seed`, always 18+
 * relative to the project timeline (years in 1985..2005).
 *
 * @param seed any positive integer; same input → same date
 *
 * @returns ISO-style date string `YYYY-MM-DD`
 */
function generateBirthDate(seed: number): string
{
    const year  = 1985 + (seed % 21);              // 1985..2005
    const month = String(1 + (seed % 12)).padStart(2, '0');
    const day   = String(1 + (seed % 28)).padStart(2, '0');
    return `${year}-${month}-${day}`;
}


/**
 * SEED
 */

/**
 * I seed {@link TOTAL_USERS} demo users into the Auth + Firestore emulators,
 * each with a Firestore `users/` document and a `wallets/` doc pre-funded
 * with {@link STARTING_BALANCE}. Idempotent — UIDs are deterministic and
 * existing users are skipped on rerun.
 */
async function seed(): Promise<void>
{
    const app  = initializeApp({projectId: PROJECT_ID});
    const auth = getAuth(app);
    const db   = getFirestore(app);

    console.log(`Seeding ${TOTAL_USERS} users into Auth + Firestore emulators...`);
    console.log(`  Auth:      ${process.env.FIREBASE_AUTH_EMULATOR_HOST}`);
    console.log(`  Firestore: ${process.env.FIRESTORE_EMULATOR_HOST}\n`);

    let created = 0;
    let skipped = 0;

    for (let i = 0; i < TOTAL_USERS; i++)
    {
        const n         = i + 1;
        const padded    = String(n).padStart(3, '0');
        const uid       = `seed-user-${padded}`;
        const email     = `aluno${padded}@${EMAIL_DOMAIN}`;
        const firstName = FIRST_NAMES[i % FIRST_NAMES.length];
        const lastName  = LAST_NAMES[(i + Math.floor(i / FIRST_NAMES.length)) % LAST_NAMES.length];
        const fullName  = `${firstName} ${lastName}`;
        const cpf       = generateCpf(n);
        const phone     = generatePhone(n);
        const birthDate = generateBirthDate(n);

        // skip if already provisioned (so the script can be rerun safely)
        try
        {
            await auth.getUser(uid);
            console.log(`- Skip ${email} (already exists)`);
            skipped++;
            continue;
        }
        catch
        {
            // user does not exist yet — fall through to creation
        }

        // 1. create the auth user
        await auth.createUser({
            uid,
            email,
            password:      COMMON_PASSWORD,
            displayName:   fullName,
            emailVerified: true,
        });

        // 2. create the Firestore user document
        const userDoc: userDocument = {
            'birth_date':     birthDate,
            'cpf':            cpf,
            'created_at':     new Date(),
            'email':          email,
            'favorite_ids':   [],
            'full_name':      fullName,
            'phone':          phone,
            'photo_url':      null,
            'status':         'active',
            'two_fa_enabled': false,
            'uid':            uid,
            'updated_at':     null,
        };
        await db.collection('users').add(userDoc);

        // 3. create the wallet (doc ID === uid, matching createWallet in storage.ts)
        const walletDoc: walletDocument = {
            'uid':        uid,
            'balance':    STARTING_BALANCE,
            'created_at': new Date(),
            'updated_at': null,
        };
        await db.collection('wallets').doc(uid).set(walletDoc);

        console.log(`✓ ${email}  —  ${fullName.padEnd(28)}  CPF ${cpf}`);
        created++;
    }

    console.log(`\nSeed complete: ${created} created, ${skipped} skipped.\n`);
    console.log('Login credentials:');
    console.log(`  Emails:  aluno001@${EMAIL_DOMAIN} … aluno${String(TOTAL_USERS).padStart(3, '0')}@${EMAIL_DOMAIN}`);
    console.log(`  Senha:   ${COMMON_PASSWORD}`);
    console.log(`  Saldo:   R$ ${STARTING_BALANCE.toLocaleString('pt-BR')} em cada carteira`);
}


seed().catch(err =>
{
    console.error('Seed failed:', err);
    process.exit(1);
});
