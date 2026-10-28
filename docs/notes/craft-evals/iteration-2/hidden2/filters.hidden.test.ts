import { test, expect } from 'vitest';
import { applyFilters, DEFAULT_FILTERS, type Filters, type Product } from '../src/catalog.ts';
import { filtersFromQuery, filtersToQuery } from '../src/filtersUrl.ts';

const products: Product[] = [
  { id: 'a', category: 'shoes', price: 80, addedAt: '2026-01-02' },
  { id: 'b', category: 'bags', price: 120, addedAt: '2026-03-01' },
];

test('HU1 round trip of a full filter', () => {
  const f: Filters = { category: 'bags', minPrice: 10, maxPrice: 99.5, sort: 'price-desc' };
  expect(filtersFromQuery(filtersToQuery(f))).toEqual(f);
});
test('HU2 round trip of the defaults', () => {
  expect(filtersFromQuery(filtersToQuery(DEFAULT_FILTERS))).toEqual(DEFAULT_FILTERS);
});
test('HU3 junk values fall back to defaults', () => {
  expect(filtersFromQuery('?minPrice=abc&sort=DROP&category=nope')).toEqual(DEFAULT_FILTERS);
});
test('HU4 empty numbers are null, not 0', () => {
  const f = filtersFromQuery('?minPrice=&maxPrice=');
  expect([f.minPrice, f.maxPrice]).toEqual([null, null]);
});
test('HU5 a junk maxPrice does not hide every product', () => {
  expect(applyFilters(products, filtersFromQuery('?maxPrice=abc'))).toHaveLength(2);
});
test('HU6 an inherited object key is not a category', () => {
  expect(filtersFromQuery('?category=constructor').category).toBeNull();
});
