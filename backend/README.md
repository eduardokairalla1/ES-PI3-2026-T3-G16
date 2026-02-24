# Backend

Firebase project using Cloud Functions (TypeScript) and Firestore.

## Requirements

- [Node.js LTS](https://nodejs.org/)
- [Firebase CLI](https://firebase.google.com/docs/cli) — `npm install -g firebase-tools`

## Setup

```bash
npm install
npm --prefix functions install
```

## Commands

| Command | Description |
|---|---|
| `npm run dev` | Start all Firebase emulators |
| `npm run build:functions` | Compile TypeScript functions once |
| `npm run watch:functions` | Compile TypeScript functions in watch mode |
| `npm run deploy` | Deploy everything to Firebase |

## Emulators

Started with `npm run dev`. Available at:

| Service | URL |
|---|---|
| Emulator UI | http://localhost:4000 |
| Firestore | http://localhost:8080 |
| Functions | http://localhost:5001 |
| Auth | http://localhost:9099 |

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
