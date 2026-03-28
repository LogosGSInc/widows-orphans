import pb from './pocketbase';
import { generateAlias, generateToken, hashToken } from '../utils/alias';
import type { Alias } from '../types';

const STORAGE_KEY_ALIAS_ID = 'wo_alias_id';
const STORAGE_KEY_ALIAS_NAME = 'wo_alias_name';
const STORAGE_KEY_TOKEN = 'wo_token';

export async function getOrCreateAlias(): Promise<Alias> {
  const storedId = localStorage.getItem(STORAGE_KEY_ALIAS_ID);
  const storedToken = localStorage.getItem(STORAGE_KEY_TOKEN);

  if (storedId && storedToken) {
    try {
      const alias = await pb.collection('aliases').getOne<Alias>(storedId);
      return alias;
    } catch {
      // Alias not found in PocketBase — create a new one
    }
  }

  const token = generateToken();
  const aliasName = generateAlias();
  const deviceHash = await hashToken(token);

  const alias = await pb.collection('aliases').create<Alias>({
    alias: aliasName,
    device_hash: deviceHash,
  });

  localStorage.setItem(STORAGE_KEY_ALIAS_ID, alias.id);
  localStorage.setItem(STORAGE_KEY_ALIAS_NAME, alias.alias);
  localStorage.setItem(STORAGE_KEY_TOKEN, token);

  return alias;
}

export function getStoredAliasName(): string | null {
  return localStorage.getItem(STORAGE_KEY_ALIAS_NAME);
}

export function getStoredAliasId(): string | null {
  return localStorage.getItem(STORAGE_KEY_ALIAS_ID);
}
