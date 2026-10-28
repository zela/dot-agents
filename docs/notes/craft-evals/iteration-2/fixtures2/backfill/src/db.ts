export interface Post {
  id: number;
  title: string;
  slug: string | null;
}

export interface Db {
  listPosts(): Promise<Post[]>;
  updatePost(id: number, patch: Partial<Omit<Post, 'id'>>): Promise<void>;
}

// Test double for the Postgres adapter. Like production, it enforces the unique index on slug.
export class InMemoryDb implements Db {
  posts = new Map<number, Post>();

  constructor(posts: Post[] = []) {
    for (const post of posts) this.posts.set(post.id, { ...post });
  }

  async listPosts(): Promise<Post[]> {
    return [...this.posts.values()].map((post) => ({ ...post }));
  }

  async updatePost(id: number, patch: Partial<Omit<Post, 'id'>>): Promise<void> {
    const post = this.posts.get(id);
    if (!post) throw new Error(`No post ${id}`);
    if (patch.slug != null) {
      for (const other of this.posts.values()) {
        if (other.id !== id && other.slug === patch.slug) {
          throw new Error(`duplicate key value violates unique constraint "posts_slug_key": ${patch.slug}`);
        }
      }
    }
    this.posts.set(id, { ...post, ...patch });
  }
}
