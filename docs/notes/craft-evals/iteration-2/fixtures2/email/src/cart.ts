import { formatMoney, type Currency } from './money.ts';

export interface CartLine {
  name: string;
  unitCents: number;
  quantity: number;
}

export interface Cart {
  lines: CartLine[];
  currency: Currency;
  shippingCents: number;
  discountCents: number;
}

export function lineTotal(line: CartLine): number {
  return line.unitCents * line.quantity;
}

export function cartTotals(cart: Cart) {
  const subtotal = cart.lines.reduce((sum, line) => sum + lineTotal(line), 0);
  const discount = Math.min(cart.discountCents, subtotal);
  return { subtotal, discount, shipping: cart.shippingCents, total: subtotal - discount + cart.shippingCents };
}

// The lines the cart page renders under the item list.
export function cartSummary(cart: Cart): string[] {
  const totals = cartTotals(cart);
  const lines = cart.lines.map((l) => `${l.quantity} × ${l.name}  ${formatMoney(lineTotal(l), cart.currency)}`);
  lines.push(`Subtotal  ${formatMoney(totals.subtotal, cart.currency)}`);
  if (totals.discount > 0) lines.push(`Discount  -${formatMoney(totals.discount, cart.currency)}`);
  lines.push(`Shipping  ${totals.shipping === 0 ? 'free' : formatMoney(totals.shipping, cart.currency)}`);
  lines.push(`Total  ${formatMoney(totals.total, cart.currency)}`);
  return lines;
}
