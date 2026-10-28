import { test, expect } from 'vitest';
import { applyFilters, DEFAULT_FILTERS, type Product } from '../src/catalog.ts';

const products: Product[] = [
  { id: 'a', category: 'shoes', price: 80, addedAt: '2026-01-02' },
  { id: 'b', category: 'bags', price: 120, addedAt: '2026-03-01' },
  { id: 'c', category: 'shoes', price: 40, addedAt: '2026-02-01' },
];

test('default filters keep everything, newest first', () => {
  expect(applyFilters(products, DEFAULT_FILTERS).map((p) => p.id)).toEqual(['b', 'c', 'a']);
});

test('category and price range', () => {
  const result = applyFilters(products, { ...DEFAULT_FILTERS, category: 'shoes', minPrice: 50, sort: 'price-asc' });
  expect(result.map((p) => p.id)).toEqual(['a']);
});
