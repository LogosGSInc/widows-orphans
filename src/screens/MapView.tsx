import { useState, useCallback } from 'react';
import { MapContainer, TileLayer, Circle, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import { Header } from '../components/Header';
import { NeedMarker } from '../components/NeedMarker';
import { Toast } from '../components/Toast';
import { PostNeedModal } from './PostNeedModal';
import { FulfillNeedSheet } from './FulfillNeedSheet';
import { useGeolocation } from '../hooks/useGeolocation';
import { useAlias } from '../hooks/useAlias';
import { useNeeds } from '../hooks/useNeeds';
import type { Need } from '../types';

const MILES_TO_METERS = 1609.34;
const RADIUS_MILES = 10;

function RecenterMap({ lat, lng }: { lat: number; lng: number }) {
  const map = useMap();
  map.setView([lat, lng], 12);
  return null;
}

export function MapView() {
  const geo = useGeolocation();
  const alias = useAlias();
  const { needs, refresh } = useNeeds(geo.lat, geo.lng);
  const [showPostModal, setShowPostModal] = useState(false);
  const [selectedNeed, setSelectedNeed] = useState<Need | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  const handleNeedPosted = useCallback(() => {
    setShowPostModal(false);
    setToast('Need posted. It will be visible for 24 hours.');
    refresh();
  }, [refresh]);

  if (geo.loading) {
    return (
      <div className="h-screen flex items-center justify-center bg-navy text-white">
        <div className="text-center">
          <div className="animate-spin w-8 h-8 border-2 border-white border-t-transparent rounded-full mx-auto mb-4" />
          <p>Getting your location...</p>
        </div>
      </div>
    );
  }

  if (geo.error || geo.lat === null || geo.lng === null) {
    return (
      <div className="h-screen flex items-center justify-center bg-navy text-white p-6">
        <div className="text-center max-w-md">
          <h2 className="text-xl font-bold mb-2">Location Required</h2>
          <p className="text-chrome mb-4">
            Widows &amp; Orphans needs access to your location to show nearby needs.
            Please enable location services and reload.
          </p>
          <button
            onClick={() => window.location.reload()}
            className="bg-white text-navy font-semibold px-6 py-2 rounded-lg"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen flex flex-col">
      <Header aliasName={alias.aliasName} />

      <div className="flex-1 relative">
        <MapContainer
          center={[geo.lat, geo.lng]}
          zoom={12}
          className="h-full w-full"
          zoomControl={false}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <RecenterMap lat={geo.lat} lng={geo.lng} />
          <Circle
            center={[geo.lat, geo.lng]}
            radius={RADIUS_MILES * MILES_TO_METERS}
            pathOptions={{
              color: '#0A1628',
              fillColor: '#0A1628',
              fillOpacity: 0.05,
              weight: 1,
            }}
          />
          {needs.map((need) => (
            <NeedMarker key={need.id} need={need} onSelect={setSelectedNeed} />
          ))}
        </MapContainer>

        {/* FAB */}
        <button
          onClick={() => setShowPostModal(true)}
          className="absolute bottom-6 right-6 z-[999] bg-navy text-white w-14 h-14 rounded-full shadow-lg flex items-center justify-center hover:bg-navy/90 transition-colors"
          aria-label="Post a need"
        >
          <svg xmlns="http://www.w3.org/2000/svg" className="w-7 h-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
            <path d="M12 5v14M5 12h14" />
          </svg>
        </button>
      </div>

      {showPostModal && alias.aliasId && (
        <PostNeedModal
          lat={geo.lat}
          lng={geo.lng}
          aliasId={alias.aliasId}
          onClose={() => setShowPostModal(false)}
          onSuccess={handleNeedPosted}
        />
      )}

      {selectedNeed && alias.aliasId && (
        <FulfillNeedSheet
          need={selectedNeed}
          userLat={geo.lat}
          userLng={geo.lng}
          aliasId={alias.aliasId}
          onClose={() => setSelectedNeed(null)}
          onRefresh={refresh}
        />
      )}

      {toast && <Toast message={toast} onClose={() => setToast(null)} />}
    </div>
  );
}
