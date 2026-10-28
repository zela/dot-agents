export interface Notification {
  id: string;
  text: string;
}

export interface InboxApi {
  markRead(ids: string[]): Promise<void>;
}

export class Inbox {
  private api: InboxApi;
  private unread = new Map<string, Notification>();
  unreadCount = 0;

  constructor(api: InboxApi) {
    this.api = api;
  }

  // The websocket client calls this for every pushed notification.
  receive(notification: Notification): void {
    if (this.unread.has(notification.id)) return;
    this.unread.set(notification.id, notification);
    this.unreadCount++;
  }

  list(): Notification[] {
    return [...this.unread.values()];
  }

  async markRead(id: string): Promise<void> {
    if (!this.unread.has(id)) return;
    const count = this.unreadCount;
    await this.api.markRead([id]);
    this.unread.delete(id);
    this.unreadCount = count - 1;
  }
}
