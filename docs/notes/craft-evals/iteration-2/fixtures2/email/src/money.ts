export type Currency = 'EUR' | 'GBP';

const LOCALES: Record<Currency, string> = { EUR: 'de-DE', GBP: 'en-GB' };

export function formatMoney(cents: number, currency: Currency): string {
  return new Intl.NumberFormat(LOCALES[currency], { style: 'currency', currency }).format(cents / 100);
}
