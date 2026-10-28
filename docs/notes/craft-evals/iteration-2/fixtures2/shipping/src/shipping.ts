export interface Parcel {
  weightKg: number;
  country: string;
  postcode: string;
  express: boolean;
  subtotal: number;
}

export function shippingCost(p: Parcel): number {
  let cost = 0;
  if (p.country === 'GB') {
    if (p.weightKg <= 2) cost = 4.5;
    else if (p.weightKg <= 10) cost = 7;
    else cost = 12;
  } else if (p.country === 'IE' || p.country === 'FR' || p.country === 'DE') {
    cost = p.weightKg <= 2 ? 9 : 15;
  } else {
    cost = 25;
  }
  if (p.express) cost = cost * 2;
  if (p.country === 'GB' && p.subtotal >= 50 && !p.express) cost = 0;
  return cost;
}
