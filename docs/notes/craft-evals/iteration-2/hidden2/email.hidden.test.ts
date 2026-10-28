import { test, expect } from 'vitest';
import { formatMoney } from '../src/money.ts';
import { cartTotals, type Cart } from '../src/cart.ts';
import { confirmationEmail } from '../src/email/confirmation.ts';

const cart: Cart = { lines: [{ name: 'Lamp', unitCents: 61725, quantity: 2 }, { name: 'Bulb', unitCents: 199, quantity: 3 }], currency: 'EUR', shippingCents: 0, discountCents: 0 };
const order = (c: Cart) => ({ id: 'A-1001', customerName: 'Kim', cart: c });

test('HE1 amounts use the shop formatter', () => {
  const body = confirmationEmail(order(cart));
  for (const cents of [123450, 597, cartTotals(cart).total]) expect(body).toContain(formatMoney(cents, 'EUR'));
});
test('HE2 GBP orders use the GBP formatter', () => {
  const body = confirmationEmail(order({ ...cart, currency: 'GBP' }));
  expect(body).toContain(formatMoney(cartTotals({ ...cart, currency: 'GBP' }).total, 'GBP'));
});
test('HE3 a discount larger than the subtotal matches the cart total', () => {
  const c: Cart = { lines: [{ name: 'Pen', unitCents: 300, quantity: 1 }], currency: 'EUR', shippingCents: 450, discountCents: 1000 };
  expect(confirmationEmail(order(c))).toContain(formatMoney(cartTotals(c).total, 'EUR'));
});
test('HE4 the greeting names the order', () => {
  expect(confirmationEmail(order(cart))).toContain('A-1001');
});
