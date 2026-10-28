import { test, expect } from 'vitest';
import { shippingCost } from '../src/shipping.ts';

const base = { weightKg: 1, country: 'GB', postcode: 'SW1A 1AA', express: false, subtotal: 20 };

test('light GB parcel', () => {
  expect(shippingCost(base)).toBe(4.5);
});

test('light DE parcel', () => {
  expect(shippingCost({ ...base, country: 'DE', postcode: '10115' })).toBe(9);
});
