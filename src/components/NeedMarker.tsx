import { Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import type { Need } from '../types';
import { CATEGORY_COLORS, CATEGORY_LABELS } from '../types';
import { useCountdown } from '../hooks/useCountdown';

interface NeedMarkerProps {
  need: Need;
  onSelect: (need: Need) => void;
}

function createCategoryIcon(category: Need['category']): L.DivIcon {
  const color = CATEGORY_COLORS[category];
  return L.divIcon({
    className: 'custom-marker',
    html: `<div style="
      background-color: ${color};
      width: 32px;
      height: 32px;
      border-radius: 50% 50% 50% 0;
      transform: rotate(-45deg);
      border: 2px solid white;
      box-shadow: 0 2px 6px rgba(0,0,0,0.3);
    "></div>`,
    iconSize: [32, 32],
    iconAnchor: [16, 32],
    popupAnchor: [0, -32],
  });
}

export function NeedMarker({ need, onSelect }: NeedMarkerProps) {
  const timeLeft = useCountdown(need.expires_at);
  const icon = createCategoryIcon(need.category);

  if (timeLeft.expired) return null;

  return (
    <Marker
      position={[need.lat, need.lng]}
      icon={icon}
      eventHandlers={{
        click: () => onSelect(need),
      }}
    >
      <Popup>
        <div className="text-sm">
          <strong>{CATEGORY_LABELS[need.category]}</strong>
          <p className="mt-1 text-gray-600">{need.description}</p>
          <p className="mt-1 text-xs text-gray-400">{timeLeft.display}</p>
        </div>
      </Popup>
    </Marker>
  );
}
