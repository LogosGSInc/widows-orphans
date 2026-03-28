import { useState, useEffect, useCallback } from 'react';
import { fetchNearbyNeeds } from '../services/needsService';
import type { Need } from '../types';

const REFRESH_INTERVAL = 30000;

export function useNeeds(lat: number | null, lng: number | null) {
  const [needs, setNeeds] = useState<Need[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    if (lat === null || lng === null) return;
    setLoading(true);
    try {
      const data = await fetchNearbyNeeds(lat, lng);
      setNeeds(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch needs');
    } finally {
      setLoading(false);
    }
  }, [lat, lng]);

  useEffect(() => {
    refresh();
    const interval = setInterval(refresh, REFRESH_INTERVAL);
    return () => clearInterval(interval);
  }, [refresh]);

  return { needs, loading, error, refresh };
}
