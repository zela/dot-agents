import { test, expect } from 'vitest';
import { InMemoryDb, type Post } from '../src/db.ts';
import { backfillSlugs } from '../src/backfill.ts';

const slugs = (db: InMemoryDb) => [...db.posts.values()].map((p) => p.slug);
const unique = (xs: unknown[]) => new Set(xs).size === xs.length;

test('HB1 fills null slugs and keeps existing ones', async () => {
  const db = new InMemoryDb([{ id: 1, title: 'Old Post', slug: null }, { id: 2, title: 'New', slug: 'kept-slug' }]);
  await backfillSlugs(db);
  expect(db.posts.get(1)!.slug).toBe('old-post');
  expect(db.posts.get(2)!.slug).toBe('kept-slug');
});
test('HB2 avoids a slug that an existing post already has', async () => {
  const db = new InMemoryDb([{ id: 1, title: 'Hello World', slug: 'hello-world' }, { id: 2, title: 'Hello World', slug: null }]);
  await backfillSlugs(db);
  expect(db.posts.get(1)!.slug).toBe('hello-world');
  expect(db.posts.get(2)!.slug).toMatch(/^hello-world.+/);
});
test('HB3 duplicate titles among null posts get unique slugs', async () => {
  const db = new InMemoryDb([1, 2, 3].map((id) => ({ id, title: 'Same Title', slug: null })));
  await backfillSlugs(db);
  expect(unique(slugs(db))).toBe(true);
});
test('HB4 a second run changes nothing', async () => {
  const db = new InMemoryDb([{ id: 1, title: 'A', slug: null }, { id: 2, title: 'A', slug: null }, { id: 3, title: 'B', slug: 'a' }]);
  await backfillSlugs(db);
  const first = slugs(db);
  await backfillSlugs(db);
  expect(slugs(db)).toEqual(first);
});
test('HB5 a rerun after a crash halfway completes without changing finished posts', async () => {
  const posts: Post[] = [1, 2, 3, 4].map((id) => ({ id, title: 'Crash Test', slug: null }));
  const db = new InMemoryDb(posts);
  const real = db.updatePost.bind(db);
  let calls = 0;
  db.updatePost = async (id, patch) => {
    calls++;
    if (calls === 3) throw new Error('connection reset');
    return real(id, patch);
  };
  await expect(backfillSlugs(db)).rejects.toThrow();
  const afterCrash = new Map([...db.posts.values()].filter((p) => p.slug !== null).map((p) => [p.id, p.slug]));
  db.updatePost = real;
  await backfillSlugs(db);
  expect(slugs(db).every((s) => typeof s === 'string' && s.length > 0)).toBe(true);
  expect(unique(slugs(db))).toBe(true);
  for (const [id, slug] of afterCrash) expect(db.posts.get(id)!.slug).toBe(slug);
});
test('HB6 a title with no letters or digits still gets a non-empty unique slug', async () => {
  const db = new InMemoryDb([{ id: 1, title: '!!!', slug: null }, { id: 2, title: '???', slug: null }]);
  await backfillSlugs(db);
  expect(slugs(db).every((s) => typeof s === 'string' && s.length > 0)).toBe(true);
  expect(unique(slugs(db))).toBe(true);
});
