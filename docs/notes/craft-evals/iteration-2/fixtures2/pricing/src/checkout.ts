import { total, type Order } from './pricing.ts';

export function checkoutSummary(order: Order): string {
  const badge = order.customer.isVip ? ' (VIP)' : '';
  return `Customer ${order.customer.id}${badge}: ${total(order).toFixed(2)}`;
}
