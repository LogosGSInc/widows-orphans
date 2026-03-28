import { useState, useCallback } from 'react';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import { createNeed } from '../services/needsService';
import type { NeedCategory } from '../types';
import { CATEGORY_LABELS } from '../types';

interface PostNeedModalProps {
  lat: number;
  lng: number;
  aliasId: string;
  onClose: () => void;
  onSuccess: () => void;
}

const CATEGORIES: NeedCategory[] = ['food', 'shelter', 'transportation', 'clothing', 'medical', 'other'];

function DraggableMarker({
  position,
  onMove,
}: {
  position: [number, number];
  onMove: (lat: number, lng: number) => void;
}) {
  useMapEvents({
    click(e) {
      onMove(e.latlng.lat, e.latlng.lng);
    },
  });

  return <Marker position={position} />;
}

export function PostNeedModal({ lat, lng, aliasId, onClose, onSuccess }: PostNeedModalProps) {
  const [category, setCategory] = useState<NeedCategory>('food');
  const [description, setDescription] = useState('');
  const [pinLat, setPinLat] = useState(lat);
  const [pinLng, setPinLng] = useState(lng);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleMove = useCallback((newLat: number, newLng: number) => {
    setPinLat(newLat);
    setPinLng(newLng);
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (description.length < 10 || description.length > 280) return;

    setSubmitting(true);
    setError(null);
    try {
      await createNeed({
        alias_id: aliasId,
        category,
        description,
        lat: pinLat,
        lng: pinLng,
      });
      onSuccess();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to post need');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-[1000] flex items-end sm:items-center justify-center"
      role="dialog"
      aria-modal="true"
      aria-label="Post a Need"
    >
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={onClose} />
      <div className="relative bg-white rounded-t-2xl sm:rounded-2xl w-full sm:max-w-lg max-h-[90vh] overflow-y-auto shadow-xl">
        <div className="p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-bold text-navy">Post a Need</h2>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 p-1"
              aria-label="Close modal"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M18 6L6 18M6 6l12 12" />
              </svg>
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label htmlFor="category" className="block text-sm font-medium text-gray-700 mb-1">
                Category
              </label>
              <select
                id="category"
                value={category}
                onChange={(e) => setCategory(e.target.value as NeedCategory)}
                className="w-full border border-chrome rounded-lg px-3 py-2 text-navy focus:outline-none focus:ring-2 focus:ring-navy/30"
              >
                {CATEGORIES.map((cat) => (
                  <option key={cat} value={cat}>
                    {CATEGORY_LABELS[cat]}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
                Description
              </label>
              <textarea
                id="description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                maxLength={280}
                rows={3}
                placeholder="Describe what you need (10-280 characters)"
                className="w-full border border-chrome rounded-lg px-3 py-2 text-navy resize-none focus:outline-none focus:ring-2 focus:ring-navy/30"
                required
              />
              <p className="text-xs text-gray-400 mt-1 text-right">
                {description.length}/280
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Location <span className="text-xs text-gray-400">(tap map to adjust)</span>
              </label>
              <div className="h-40 rounded-lg overflow-hidden border border-chrome">
                <MapContainer
                  center={[pinLat, pinLng]}
                  zoom={14}
                  style={{ height: '100%', width: '100%' }}
                  zoomControl={false}
                >
                  <TileLayer
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                  />
                  <DraggableMarker position={[pinLat, pinLng]} onMove={handleMove} />
                </MapContainer>
              </div>
            </div>

            {error && (
              <p className="text-red-500 text-sm" role="alert">{error}</p>
            )}

            <button
              type="submit"
              disabled={submitting || description.length < 10}
              className="w-full bg-navy text-white font-semibold py-3 rounded-lg hover:bg-navy/90 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {submitting ? 'Posting...' : 'Post Need'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
