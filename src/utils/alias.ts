const ADJECTIVES = [
  'Kind', 'Brave', 'Gentle', 'Warm', 'Bright', 'Swift', 'Calm', 'Bold',
  'Fair', 'True', 'Noble', 'Wise', 'Happy', 'Lucky', 'Eager', 'Quiet',
  'Keen', 'Pure', 'Free', 'Glad', 'Merry', 'Vivid', 'Solid', 'Steady',
];

const NOUNS = [
  'Sparrow', 'Robin', 'Falcon', 'Dove', 'Finch', 'Wren', 'Lark', 'Crane',
  'Heron', 'Eagle', 'Hawk', 'Owl', 'Fox', 'Bear', 'Wolf', 'Deer',
  'Otter', 'Lynx', 'Maple', 'Cedar', 'Birch', 'Pine', 'River', 'Stone',
];

function randomItem<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

export function generateAlias(): string {
  const adj = randomItem(ADJECTIVES);
  const noun = randomItem(NOUNS);
  const num = Math.floor(Math.random() * 100);
  return `${adj} ${noun} ${num}`;
}

export async function hashToken(token: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(token);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, '0')).join('');
}

export function generateToken(): string {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return Array.from(array)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}
