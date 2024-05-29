import globals from 'globals';
import pluginVue from 'eslint-plugin-vue';
// import pluginImport from "eslint-plugin-import"; // not yet support eslint 9 https://github.com/import-js/eslint-plugin-import/pull/2996
import babelParser from '@babel/eslint-parser';
import path from 'path';
import { fileURLToPath } from 'url';
import { FlatCompat } from '@eslint/eslintrc';
import pluginJs from '@eslint/js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: pluginJs.configs.recommended
});

export default [
  ...compat.extends('standard'),
  ...pluginVue.configs['flat/recommended'],
  {
    languageOptions: {
      globals: {
        ...globals.browser,
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
          configFile: './babel.config.js'
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
      'operator-linebreak': ['error', 'after', {
        overrides: {
          '|>': 'before'
        }
      }],
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
      'import/order': 'off'
    }
  },
  {
    files: ['*.vue', '**/*.vue'],
    languageOptions: {
      ...pluginVue.configs['flat/recommended'][1].languageOptions,
      parserOptions: {
        parser: '@babel/eslint-parser',
        ecmaVersion: 2021,
        sourceType: 'module',
        requireConfigFile: false,
        babelOptions: {
          configFile: './babel.config.js'
        }
      }
    },
    rules: {
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
