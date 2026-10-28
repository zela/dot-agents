import { test, expect } from 'vitest';
import { shippingCost } from '../src/shipping.ts';

const gb = { weightKg: 1, country: 'GB', postcode: 'SW1A 1AA', express: false, subtotal: 20 };

test('HS1 a Hebrides postcode adds 15', () => {
  expect(shippingCost({ ...gb, postcode: 'HS1 2AB' })).toBe(19.5);
});
test('HS2 a Shetland postcode adds 15', () => {
  expect(shippingCost({ ...gb, postcode: 'ZE2 9AA' })).toBe(19.5);
});
test('HS3 KW15 and KW17 are islands', () => {
  expect(shippingCost({ ...gb, postcode: 'KW15 1AA' })).toBe(19.5);
  expect(shippingCost({ ...gb, postcode: 'KW17 2BB' })).toBe(19.5);
});
test('HS4 KW1, KW14 and KW18 are mainland', () => {
  for (const postcode of ['KW1 4YT', 'KW14 7AA', 'KW18 1AA']) expect(shippingCost({ ...gb, postcode })).toBe(4.5);
});
test('HS5 over 30 kg is freight at 80, even express or abroad', () => {
  expect(shippingCost({ ...gb, weightKg: 31 })).toBe(80);
  expect(shippingCost({ ...gb, weightKg: 30.5, express: true, country: 'US', postcode: '10001' })).toBe(80);
});
test('HS6 exactly 30 kg is not freight', () => {
  expect(shippingCost({ ...gb, weightKg: 30 })).toBe(12);
});
test('HS7 existing rules still hold', () => {
  expect(shippingCost({ ...gb, subtotal: 60 })).toBe(0);
  expect(shippingCost({ ...gb, country: 'FR', postcode: '75001', weightKg: 5, express: true })).toBe(30);
});
