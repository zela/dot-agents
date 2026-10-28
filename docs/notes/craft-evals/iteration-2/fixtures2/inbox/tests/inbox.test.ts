import { test, expect } from 'vitest';
import { Inbox } from '../src/inbox.ts';

const api = { markRead: async (_ids: string[]) => {} };

test('receive counts each notification once', () => {
  const inbox = new Inbox(api);
  inbox.receive({ id: 'n1', text: 'hi' });
  inbox.receive({ id: 'n1', text: 'hi' });
  inbox.receive({ id: 'n2', text: 'yo' });
  expect(inbox.unreadCount).toBe(2);
});

test('markRead removes the notification', async () => {
  const inbox = new Inbox(api);
  inbox.receive({ id: 'n1', text: 'hi' });
  await inbox.markRead('n1');
  expect(inbox.unreadCount).toBe(0);
  expect(inbox.list()).toEqual([]);
});
