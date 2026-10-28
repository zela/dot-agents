export const CATEGORIES = ['shoes', 'bags', 'hats'] as const;
export type Category = (typeof CATEGORIES)[number];
export type Sort = 'price-asc' | 'price-desc' | 'newest';

export interface Product {
  id: string;
  category: Category;
  price: number;
  addedAt: string;
}

export interface Filters {
  category: Category | null;
  minPrice: number | null;
  maxPrice: number | null;
  sort: Sort;
}

export const DEFAULT_FILTERS: Filters = { category: null, minPrice: null, maxPrice: null, sort: 'newest' };

export function applyFilters(products: Product[], filters: Filters): Product[] {
  const kept = products.filter(
    (p) =>
      (filters.category === null || p.category === filters.category) &&
      (filters.minPrice === null || p.price >= filters.minPrice) &&
      (filters.maxPrice === null || p.price <= filters.maxPrice),
  );
  return kept.sort((a, b) => {
    if (filters.sort === 'price-asc') return a.price - b.price;
    if (filters.sort === 'price-desc') return b.price - a.price;
    return b.addedAt.localeCompare(a.addedAt);
  });
}
