export interface Customer {
  id: string;
  isVip: boolean;
}

export interface LineItem {
  sku: string;
  unitPrice: number;
  quantity: number;
}

export interface Order {
  customer: Customer;
  items: LineItem[];
  promoCode?: string;
}

const PROMO_CODES: Record<string, number> = { SPRING10: 0.1, WELCOME5: 0.05 };
const SHIPPING_FLAT = 12;
const FREE_SHIPPING_THRESHOLD = 150;

const round2 = (n: number) => Math.round(n * 100) / 100;

export function subtotal(order: Order): number {
  return order.items.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);
}

export function discount(order: Order): number {
  let rate = 0;
  if (order.customer.isVip) rate += 0.1;
  if (order.promoCode && PROMO_CODES[order.promoCode]) rate += PROMO_CODES[order.promoCode];
  return round2(subtotal(order) * rate);
}

export function shipping(order: Order): number {
  if (order.customer.isVip) return 0;
  return subtotal(order) >= FREE_SHIPPING_THRESHOLD ? 0 : SHIPPING_FLAT;
}

export function total(order: Order): number {
  return round2(subtotal(order) - discount(order) + shipping(order));
}
