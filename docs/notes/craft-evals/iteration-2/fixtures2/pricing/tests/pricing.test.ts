import { test, expect } from 'vitest';
import { total, shipping, discount } from '../src/pricing.ts';
import { checkoutSummary } from '../src/checkout.ts';

const items = [{ sku: 'A', unitPrice: 50, quantity: 2 }];

test('regular customer pays shipping under the threshold', () => {
  const order = { customer: { id: 'c1', isVip: false }, items };
  expect(shipping(order)).toBe(12);
  expect(total(order)).toBe(112);
});

test('vip gets 10% off and free shipping', () => {
  const order = { customer: { id: 'c2', isVip: true }, items };
  expect(discount(order)).toBe(10);
  expect(total(order)).toBe(90);
});

test('promo code stacks with vip', () => {
  const order = { customer: { id: 'c3', isVip: true }, items, promoCode: 'SPRING10' };
  expect(discount(order)).toBe(20);
});

test('summary shows the vip badge', () => {
  const order = { customer: { id: 'c2', isVip: true }, items };
  expect(checkoutSummary(order)).toBe('Customer c2 (VIP): 90.00');
});
