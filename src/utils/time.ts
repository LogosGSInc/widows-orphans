export function getTimeRemaining(expiresAt: string): {
  expired: boolean;
  hours: number;
  minutes: number;
  seconds: number;
  display: string;
} {
  const now = Date.now();
  const expiry = new Date(expiresAt).getTime();
  const diff = expiry - now;

  if (diff <= 0) {
    return { expired: true, hours: 0, minutes: 0, seconds: 0, display: 'Expired' };
  }

  const hours = Math.floor(diff / (1000 * 60 * 60));
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((diff % (1000 * 60)) / 1000);

  let display: string;
  if (hours > 0) {
    display = `${hours}h ${minutes}m remaining`;
  } else if (minutes > 0) {
    display = `${minutes}m ${seconds}s remaining`;
  } else {
    display = `${seconds}s remaining`;
  }

  return { expired: false, hours, minutes, seconds, display };
}
