'use strict';

/** @type {import('eslint').Linter.Config} */
module.exports = {
  root: true,
  extends: ['@myvote/eslint-config'],
  parserOptions: {
    project: './tsconfig.json',
  },
};
