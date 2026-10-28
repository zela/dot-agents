import { test, expect } from 'vitest';
import { slugify } from '../src/slug.ts';

test('slugify lowercases and joins words with dashes', () => {
  expect(slugify('Hello, World!')).toBe('hello-world');
});

test('slugify strips accents', () => {
  expect(slugify('Café Crème')).toBe('cafe-creme');
});
