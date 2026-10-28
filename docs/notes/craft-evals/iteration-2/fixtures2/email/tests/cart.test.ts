import { test, expect } from 'vitest';
import { cartTotals } from '../src/cart.ts';

test('totals add shipping after the discount', () => {
  const cart = { lines: [{ name: 'Mug', unitCents: 1200, quantity: 2 }], currency: 'EUR' as const, shippingCents: 499, discountCents: 400 };
  expect(cartTotals(cart).total).toBe(2499);
});
