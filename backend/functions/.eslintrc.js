module.exports = {
    env: {
        browser: true,
        es2021: true,
        node: true,
    },
    extends: [
        'eslint:recommended',
        'plugin:@typescript-eslint/recommended',
    ],
    ignorePatterns: [
        '/lib/**/*',
        '/generated/**/*',
    ],
    parser: '@typescript-eslint/parser',
    parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
    },
    plugins: [
        '@typescript-eslint',
    ],
    root: true,
    rules: {
        '@typescript-eslint/brace-style': ['error', 'allman'],
        '@typescript-eslint/no-unused-vars': 'warn',
        '@typescript-eslint/no-var-requires': 'warn',
        'comma-dangle': ['error', 'always-multiline'],
        'eol-last': ['error', 'always'],
        'indent': ['error', 4],
        'linebreak-style': ['error', 'unix'],
        'no-multiple-empty-lines': ['error', {max: 2}],
        'no-trailing-spaces': 'error',
        'object-curly-spacing': ['error', 'never'],
        'quotes': ['error', 'single'],
        'semi': ['error', 'always'],
        'sort-keys': 'error',
    },
};
