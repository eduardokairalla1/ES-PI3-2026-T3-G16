# Backend

Firebase project using Cloud Functions (TypeScript) and Firestore.

## Requirements

- [Node.js LTS](https://nodejs.org/)
- [Firebase CLI](https://firebase.google.com/docs/cli) — `npm install -g firebase-tools`
- Java (required by the Firestore emulator) — `sudo apt install default-jre -y`

## Setup

```bash
npm install
npm --prefix functions install
```

## Commands

| Command | Description |
|---|---|
| `npm run dev` | Install deps, compile, start file watcher and all Firebase emulators |
| `npm run build:functions` | Compile TypeScript functions once |
| `npm run watch:functions` | Compile TypeScript functions in watch mode |
| `npm run deploy` | Deploy everything to Firebase |

### Seed scripts

Run after starting the emulators (`npm run dev`) in a separate terminal:

| Command | Description |
|---|---|
| `npm run seed:all` | Seed all collections in dependency order |
| `npm run seed:startups` | Seed startups and storage assets |
| `npm run seed:users` | Seed users in Auth and Firestore |
| `npm run seed:investments` | Seed investment records |
| `npm run seed:orderbook` | Seed order book entries |
| `npm run seed:questions` | Seed Q&A questions |
| `npm run seed:notifications` | Seed notifications |

## Tests

| Command | Description |
|---|---|
| `npm run lint:functions` | Run ESLint and report errors |
| `npm run lint:fix:functions` | Run ESLint and auto-fix errors |

## Emulators

Started with `npm run dev`. Available at:

| Service | URL |
|---|---|
| Emulator UI | http://localhost:4000 |
| Firestore | http://localhost:8080 |
| Functions | http://localhost:5001 |
| Auth | http://localhost:9099 |
| Storage | http://localhost:9199 |

## Project structure

```
backend/
├── firebase.json           # Firebase project configuration
├── firestore.rules         # Firestore security rules
├── firestore.indexes.json  # Firestore indexes
└── functions/
    └── src/
        └── index.ts        # Cloud Functions entry point
```

## Docs

- [Cloud Functions](https://firebase.google.com/docs/functions)
- [Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
