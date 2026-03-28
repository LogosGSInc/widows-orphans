import pb from './pocketbase';
import { getBoundingBox, haversineDistance } from '../utils/geo';
import type { Need } from '../types';

export async function fetchNearbyNeeds(
  lat: number,
  lng: number,
  radiusMiles: number = 10,
): Promise<Need[]> {
  const bbox = getBoundingBox(lat, lng, radiusMiles);
  const now = new Date().toISOString();

  const records = await pb.collection('needs').getFullList<Need>({
    filter: `lat >= ${bbox.minLat} && lat <= ${bbox.maxLat} && lng >= ${bbox.minLng} && lng <= ${bbox.maxLng} && status = "open" && expires_at > "${now}"`,
    sort: '-created',
    expand: 'alias_id',
  });

  return records.filter(
    (need) => haversineDistance(lat, lng, need.lat, need.lng) <= radiusMiles,
  );
}

export async function createNeed(data: {
  alias_id: string;
  category: string;
  description: string;
  lat: number;
  lng: number;
}): Promise<Need> {
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();

  return pb.collection('needs').create<Need>({
    ...data,
    expires_at: expiresAt,
    status: 'open',
  });
}

export async function markNeedFulfilled(needId: string): Promise<void> {
  await pb.collection('needs').update(needId, { status: 'fulfilled' });
}
