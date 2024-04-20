import globals from 'globals';
import pluginVue from 'eslint-plugin-vue';
// import pluginImport from "eslint-plugin-import"; // not yet support eslint 9 https://github.com/import-js/eslint-plugin-import/pull/2996
import babelParser from '@babel/eslint-parser';

import path from 'path';
import { fileURLToPath } from 'url';
import { FlatCompat } from '@eslint/eslintrc';
import pluginJs from '@eslint/js';

// mimic CommonJS variables -- not needed if using CommonJS
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({ baseDirectory: __dirname, recommendedConfig: pluginJs.configs.recommended });

// console.log(pluginImport);

export default [
  {
    languageOptions: {
      globals: globals.browser
    }
  },
  ...compat.extends('standard'),
  ...pluginVue.configs['flat/recommended'],
  // pluginImport,
  {
    languageOptions: {
      globals: {
        pageLoad: 'readonly',
        pageUnload: 'readonly',
        $: 'readonly',
        gon: 'readonly'
      },
      parser: babelParser,
      parserOptions: {
        ecmaVersion: 2021,
        sourceType: 'module',
        requireConfigFile: false,
        babelOptions: {
          configFile: './babel.config.js' // path to your Babel config file
        }
      }
    },
    ignores: [
      'app/packs/javascripts/vendor/*'
    ],
    settings: {
      'import/resolver': {
        node: {
          extensions: ['.js', '.vue']
        },
        webpack: {
          config: './config/webpack/development.js'
        }
      }
    },
    rules: {
      quotes: ['error', 'single'],
      'object-curly-spacing': ['error', 'always'],
      semi: ['error', 'always'],
      'object-curly-newline': 'off',
      'arrow-body-style': ['error', 'as-needed'],
      'arrow-parens': ['error', 'as-needed'],
      'no-console': 'warn',
      'no-alert': 'off',
      'no-debugger': 'warn',
      'no-trailing-spaces': 'error',
      'no-return-assign': 'off',
      'no-param-reassign': ['error', { props: false }],
      'no-underscore-dangle': 'off',
      'no-unused-vars': 'off', // Temporarily disabled
      'no-use-before-define': 'off',
      'no-mixed-operators': 'off',
      'no-new': 'off',
      'no-nested-ternary': 'off',
      'function-paren-newline': 'off',
      'comma-dangle': ['warn', 'never'],
      'max-len': ['warn', 100, {
        ignoreComments: true,
        ignoreUrls: true,
        ignorePattern: '\\s*(<|@)'
      }],
      indent: ['error', 2, {
        SwitchCase: 1,
        ignoreComments: true
      }],
      'space-before-function-paren': ['error', {
        anonymous: 'never', // Requires a space for anonymous functions
        named: 'never', // Disallows space for named functions
        asyncArrow: 'always' // Requires a space for async arrow functions
      }],
      'linebreak-style': ['error', 'unix'],
      'func-names': 'off',
      'implicit-arrow-linebreak': 'off',
      'prefer-template': 'off',
      'class-methods-use-this': 'off',
      radix: 'off',
      'operator-linebreak': ['error', 'after'],
      'keyword-spacing': ['error', {
        before: true,
        after: true
      }],
      'lines-between-class-members': 'off',
      'import/no-extraneous-dependencies': 'off',
      'import/no-unresolved': 'error',
      'import/no-webpack-loader-syntax': 'off',
      'import/prefer-default-export': 'off',
      'import/no-named-as-default': 'off',
      'import/extensions': ['error', 'always', {
        js: 'never',
        coffee: 'never',
        vue: 'never'
      }],
      'import/first': 'off',
      'import/order': 'off',
      'vue/max-attributes-per-line': ['error', {
        singleline: 3,
        multiline: 1
      }],
      'vue/singleline-html-element-content-newline': 'off',
      'vue/html-quotes': 'off',
      'vue/component-name-in-template-casing': ['error', 'PascalCase', {
        ignores: ['router-view', 'router-link']
      }],
      'vue/no-v-html': 'off',
      'vue/multi-word-component-names': 'off'
    }
  }
];

// ---
// root: true
//
// env:
//   node: true
//   es6: true
//   jquery: true
//
// parser: vue-eslint-parser
//
// extends:
//   - plugin:vue/vue3-recommended
//   - eslint:recommended
//   - plugin:import/errors
//   - plugin:import/warnings
//
// plugins:
//   - vue
//
// globals:
//   I18n: true
//   gon: true
//   p: true
//   pageLoad: true
//   pageUnload: true
//
// parserOptions:
//   ecmaVersion: 2018
//   sourceType: module
//   parser: babel-eslint
//
// rules:
//   quotes:
//     - error
//     - single
//   object-curly-spacing:
//     - error
//     - always
//   semi:
//     - error
//     - always
//   space-before-function-paren:
//     - error
//     - anonymous: never
//       named: never
//       asyncArrow: always
//   object-curly-newline: 0
//   arrow-body-style:
//     - 2
//     - as-needed
//   arrow-parens:
//     - 2
//     - as-needed
//   no-console: 1
//   no-alert: 0
//   no-debugger: 1
//   no-trailing-spaces:
//     - error
//   no-return-assign: 0
//   no-param-reassign:
//     - 2
//     - props: false
//   no-underscore-dangle: 0
//   no-unused-vars: 0 # temporarily disabled because it does not work with vue-3 script setup syntax
//     # - error
//     # - argsIgnorePattern: ^_
//     #   varsIgnorePattern: ^_
//   no-use-before-define: 0
//   no-mixed-operators: 0
//   no-new: 0
//   no-shadow:
//     - 2
//     - allow:
//       - '_'
//   function-paren-newline: 0
//   comma-dangle:
//     - warn
//     - never
//   max-len:
//     - warn
//     - 100
//     - ignoreComments: true
//       ignoreUrls: true
//       ignorePattern: "\\s*<"
//   indent:
//     - error
//     - 2
//     - ignoreComments: true
//       SwitchCase: 1
//   linebreak-style:
//     - error
//     - unix
//   func-names: 0
//   implicit-arrow-linebreak: 0
//   prefer-template: 0
//   class-methods-use-this: 0
//   radix: 0
//   operator-linebreak:
//     - 2
//     - after
//     - overrides:
//         '|>': 'before'
//   keyword-spacing:
//     - error
//     - after: true
//       before: true
//   lines-between-class-members: 0
//   default-case: 0
//   import/no-extraneous-dependencies: 0
//   import/no-unresolved: 2
//   import/no-webpack-loader-syntax: 0
//   import/prefer-default-export: 0
//   import/extensions:
//     - error
//     - always
//     - js: never
//       coffee: never
//       vue: never
//   import/first: 0
//   import/order: 0
//   vue/max-attributes-per-line:
//     - error
//     - singleline: 3
//       # multiline:
//       #   max: 1
//       #   allowFirstLine: false
//   vue/singleline-html-element-content-newline: 0
//   vue/html-quotes: 0
//     # - 1
//     # - single
//   vue/component-name-in-template-casing:
//     - 2
//     - PascalCase
//     - ignores:
//       - router-view
//       - router-link
//
// settings:
//   import/resolver:
//     webpack:
//       config: './config/webpack/development.js'
//     node:
//       extensions:
//         - '.js'
//         - '.vue'
