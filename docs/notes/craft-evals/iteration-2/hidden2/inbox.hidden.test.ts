import { test, expect } from 'vitest';
import { Inbox } from '../src/inbox.ts';

function deferredApi() {
  const calls: string[][] = [];
  let release: () => void = () => {};
  let fail: (e: Error) => void = () => {};
  const api = {
    markRead: (ids: string[]) => {
      calls.push([...ids]);
      return new Promise<void>((res, rej) => { release = res; fail = rej; });
    },
  };
  return { api, calls, release: () => release(), fail: (e: Error) => fail(e) };
}
const n = (id: string) => ({ id, text: id });

test('HI1 markAllRead sends every unread id in one call and clears the badge', async () => {
  const d = deferredApi();
  const inbox = new Inbox(d.api);
  inbox.receive(n('a')); inbox.receive(n('b'));
  const done = inbox.markAllRead();
  d.release(); await done;
  expect(d.calls.length).toBe(1);
  expect([...d.calls[0]].sort()).toEqual(['a', 'b']);
  expect(inbox.unreadCount).toBe(0);
  expect(inbox.list()).toEqual([]);
});
test('HI2 a notification that arrives during markAllRead stays unread', async () => {
  const d = deferredApi();
  const inbox = new Inbox(d.api);
  inbox.receive(n('a'));
  const done = inbox.markAllRead();
  inbox.receive(n('late'));
  d.release(); await done;
  expect(inbox.list().map((x) => x.id)).toEqual(['late']);
  expect(inbox.unreadCount).toBe(1);
});
test('HI3 a failed API call clears nothing', async () => {
  const d = deferredApi();
  const inbox = new Inbox(d.api);
  inbox.receive(n('a')); inbox.receive(n('b'));
  const done = inbox.markAllRead();
  d.fail(new Error('503'));
  await expect(done).rejects.toThrow();
  expect(inbox.unreadCount).toBe(2);
  expect(inbox.list()).toHaveLength(2);
});
test('HI4 existing markRead: a notification that arrives during the call is still counted', async () => {
  const d = deferredApi();
  const inbox = new Inbox(d.api);
  inbox.receive(n('a')); inbox.receive(n('b'));
  const done = inbox.markRead('a');
  inbox.receive(n('c'));
  d.release(); await done;
  expect(inbox.unreadCount).toBe(2);
  expect(inbox.unreadCount).toBe(inbox.list().length);
});
