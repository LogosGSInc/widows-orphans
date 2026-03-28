import { useState, useEffect, useRef, useCallback } from 'react';
import { useCountdown } from '../hooks/useCountdown';
import { sendMessage, getChatMessages, subscribeToMessages } from '../services/chatService';
import type { Message } from '../types';

interface EphemeralChatProps {
  needId: string;
  aliasId: string;
  chatExpiresAt: string;
  posterName: string;
  onClose: () => void;
}

export function EphemeralChat({
  needId,
  aliasId,
  chatExpiresAt,
  posterName,
  onClose,
}: EphemeralChatProps) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [sending, setSending] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const timeLeft = useCountdown(chatExpiresAt);

  const scrollToBottom = useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, []);

  useEffect(() => {
    getChatMessages(needId).then((msgs) => {
      setMessages(msgs);
      setTimeout(scrollToBottom, 100);
    });
  }, [needId, scrollToBottom]);

  useEffect(() => {
    const unsubscribe = subscribeToMessages(needId, (msg) => {
      setMessages((prev) => {
        if (prev.some((m) => m.id === msg.id)) return prev;
        return [...prev, msg];
      });
      setTimeout(scrollToBottom, 100);
    });
    return unsubscribe;
  }, [needId, scrollToBottom]);

  useEffect(() => {
    if (timeLeft.expired) {
      const timer = setTimeout(onClose, 5000);
      return () => clearTimeout(timer);
    }
  }, [timeLeft.expired, onClose]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    const body = input.trim();
    if (!body || sending || timeLeft.expired) return;

    setSending(true);
    try {
      await sendMessage({
        need_id: needId,
        sender_alias_id: aliasId,
        body,
        chat_expires_at: chatExpiresAt,
      });
      setInput('');
    } catch (err) {
      console.error('Failed to send message:', err);
    } finally {
      setSending(false);
    }
  };

  const getSenderName = (msg: Message): string => {
    if (msg.expand?.sender_alias_id?.alias) return msg.expand.sender_alias_id.alias;
    if (msg.sender_alias_id === aliasId) return 'You';
    return posterName;
  };

  return (
    <div className="fixed inset-0 z-[1000] flex flex-col bg-white" role="dialog" aria-label="Ephemeral chat">
      {/* Header */}
      <div className="bg-navy text-white px-4 py-3 flex items-center justify-between">
        <button onClick={onClose} className="text-white p-1" aria-label="Close chat">
          <svg xmlns="http://www.w3.org/2000/svg" className="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M19 12H5M12 19l-7-7 7-7" />
          </svg>
        </button>
        <span className="font-semibold">Chat with {posterName}</span>
        <span
          className={`text-xs font-mono px-2 py-1 rounded ${
            timeLeft.expired
              ? 'bg-red-500'
              : timeLeft.minutes < 5
                ? 'bg-yellow-500 text-navy'
                : 'bg-white/20'
          }`}
          aria-live="polite"
        >
          {timeLeft.expired ? 'Expired' : `${String(timeLeft.minutes).padStart(2, '0')}:${String(timeLeft.seconds).padStart(2, '0')}`}
        </span>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {messages.map((msg) => {
          const isMine = msg.sender_alias_id === aliasId;
          return (
            <div key={msg.id} className={`flex ${isMine ? 'justify-end' : 'justify-start'}`}>
              <div
                className={`max-w-[75%] rounded-2xl px-4 py-2 ${
                  isMine ? 'bg-navy text-white rounded-br-md' : 'bg-gray-100 text-navy rounded-bl-md'
                }`}
              >
                <p className="text-xs font-medium opacity-70 mb-0.5">{getSenderName(msg)}</p>
                <p className="text-sm">{msg.body}</p>
              </div>
            </div>
          );
        })}
        <div ref={messagesEndRef} />

        {timeLeft.expired && (
          <div className="text-center text-gray-400 text-sm py-4" role="alert">
            Chat expired. Closing in 5 seconds...
          </div>
        )}
      </div>

      {/* Input */}
      <form onSubmit={handleSend} className="border-t border-chrome p-3 flex gap-2">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder={timeLeft.expired ? 'Chat expired' : 'Type a message...'}
          disabled={timeLeft.expired}
          maxLength={500}
          className="flex-1 border border-chrome rounded-full px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-navy/30 disabled:opacity-50"
          aria-label="Message input"
        />
        <button
          type="submit"
          disabled={sending || !input.trim() || timeLeft.expired}
          className="bg-navy text-white p-2 rounded-full disabled:opacity-50 transition-colors hover:bg-navy/90"
          aria-label="Send message"
        >
          <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
            <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z" />
          </svg>
        </button>
      </form>
    </div>
  );
}
