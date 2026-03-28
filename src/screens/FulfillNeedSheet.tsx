import { useState } from 'react';
import type { Need } from '../types';
import { CATEGORY_LABELS } from '../types';
import { useCountdown } from '../hooks/useCountdown';
import { formatDistance, haversineDistance } from '../utils/geo';
import { EphemeralChat } from './EphemeralChat';
import { createChat, getActiveChat } from '../services/chatService';
import { markNeedFulfilled } from '../services/needsService';

interface FulfillNeedSheetProps {
  need: Need;
  userLat: number;
  userLng: number;
  aliasId: string;
  onClose: () => void;
  onRefresh: () => void;
}

export function FulfillNeedSheet({
  need,
  userLat,
  userLng,
  aliasId,
  onClose,
  onRefresh,
}: FulfillNeedSheetProps) {
  const timeLeft = useCountdown(need.expires_at);
  const distance = haversineDistance(userLat, userLng, need.lat, need.lng);
  const [chatMode, setChatMode] = useState(false);
  const [chatExpiresAt, setChatExpiresAt] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const posterAliasId = need.alias_id;
  const posterName = need.expand?.alias_id?.alias ?? 'Anonymous';
  const isOwnNeed = aliasId === posterAliasId;

  const handleHelp = async () => {
    setLoading(true);
    try {
      let chat = await getActiveChat(need.id);
      if (!chat) {
        chat = await createChat({
          need_id: need.id,
          poster_alias_id: posterAliasId,
          fulfiller_alias_id: aliasId,
        });
        await markNeedFulfilled(need.id);
        onRefresh();
      }
      setChatExpiresAt(chat.expires_at);
      setChatMode(true);
    } catch (err) {
      console.error('Failed to start chat:', err);
    } finally {
      setLoading(false);
    }
  };

  if (chatMode && chatExpiresAt) {
    return (
      <EphemeralChat
        needId={need.id}
        aliasId={aliasId}
        chatExpiresAt={chatExpiresAt}
        posterName={posterName}
        onClose={() => {
          setChatMode(false);
          onClose();
        }}
      />
    );
  }

  return (
    <div className="fixed inset-x-0 bottom-0 z-[1000]" role="dialog" aria-label="Need details">
      <div className="absolute inset-0 -top-screen" onClick={onClose} />
      <div className="relative bg-white rounded-t-2xl shadow-xl max-h-[60vh] overflow-y-auto">
        <div className="flex justify-center pt-3 pb-1">
          <div className="w-10 h-1 bg-chrome rounded-full" />
        </div>

        <div className="px-6 pb-6">
          <div className="flex items-center justify-between mb-3">
            <span className="inline-flex items-center gap-2 text-sm font-semibold text-navy">
              {CATEGORY_LABELS[need.category]}
            </span>
            <span
              className={`text-xs font-medium px-2 py-1 rounded-full ${
                timeLeft.expired
                  ? 'bg-red-100 text-red-600'
                  : timeLeft.hours < 1
                    ? 'bg-yellow-100 text-yellow-700'
                    : 'bg-green-100 text-green-700'
              }`}
            >
              {timeLeft.display}
            </span>
          </div>

          <p className="text-gray-700 mb-3">{need.description}</p>

          <div className="flex items-center gap-4 text-xs text-gray-400 mb-4">
            <span>Posted by {posterName}</span>
            <span>{formatDistance(distance)} away</span>
          </div>

          {timeLeft.expired ? (
            <p className="text-center text-gray-400 text-sm">This need has expired.</p>
          ) : isOwnNeed ? (
            <p className="text-center text-gray-400 text-sm">This is your posted need.</p>
          ) : (
            <button
              onClick={handleHelp}
              disabled={loading}
              className="w-full bg-navy text-white font-semibold py-3 rounded-lg hover:bg-navy/90 disabled:opacity-50 transition-colors"
            >
              {loading ? 'Starting chat...' : 'I Can Help'}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
