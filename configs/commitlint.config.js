module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // A new feature
        'fix',      // A bug fix
        'docs',     // Documentation only changes
        'style',    // Formatting, missing semi colons, etc; no code change
        'refactor', // Refactoring production code
        'test',     // Adding tests, refactoring test; no production code change
        'chore',    // Updating build tasks, package manager configs, etc
        'perf',     // Performance improvements
        'build',    // Changes to build system or external dependencies
        'ci',       // Changes to CI configuration files and scripts
        'revert',   // Reverts a previous commit
        'release'   // Release commits
      ]
    ],
    'scope-enum': [
      2,
      'always',
      [
        'api',
        'ui',
        'core',
        'auth',
        'db',
        'config',
        'deps',
        'ci',
        'docs',
        'test',
        'security',
        'performance',
        'workflow',
        'action',
        'template'
      ]
    ],
    'scope-case': [2, 'always', 'lower-case'],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100],
    'body-max-line-length': [2, 'always', 120],
    'footer-max-line-length': [2, 'always', 120]
  }
};
