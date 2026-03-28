import pb from './pocketbase';
import type { Chat, Message } from '../types';

export async function createChat(data: {
  need_id: string;
  poster_alias_id: string;
  fulfiller_alias_id: string;
}): Promise<Chat> {
  const now = new Date();
  const expiresAt = new Date(now.getTime() + 60 * 60 * 1000);

  return pb.collection('chats').create<Chat>({
    ...data,
    started_at: now.toISOString(),
    expires_at: expiresAt.toISOString(),
    status: 'active',
  });
}

export async function getActiveChat(needId: string): Promise<Chat | null> {
  try {
    const records = await pb.collection('chats').getFullList<Chat>({
      filter: `need_id = "${needId}" && status = "active"`,
      sort: '-created',
    });
    return records[0] ?? null;
  } catch {
    return null;
  }
}

export async function sendMessage(data: {
  need_id: string;
  sender_alias_id: string;
  body: string;
  chat_expires_at: string;
}): Promise<Message> {
  return pb.collection('messages').create<Message>({
    need_id: data.need_id,
    sender_alias_id: data.sender_alias_id,
    body: data.body,
    expires_at: data.chat_expires_at,
  });
}

export async function getChatMessages(needId: string): Promise<Message[]> {
  return pb.collection('messages').getFullList<Message>({
    filter: `need_id = "${needId}"`,
    sort: 'created',
    expand: 'sender_alias_id',
  });
}

export function subscribeToMessages(
  needId: string,
  callback: (message: Message) => void,
): () => void {
  pb.collection('messages').subscribe<Message>('*', (e) => {
    if (e.record.need_id === needId) {
      callback(e.record);
    }
  });

  return () => {
    pb.collection('messages').unsubscribe('*');
  };
}
