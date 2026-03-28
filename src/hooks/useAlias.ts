import { useState, useEffect } from 'react';
import { getOrCreateAlias, getStoredAliasName, getStoredAliasId } from '../services/aliasService';
import type { Alias } from '../types';

interface AliasState {
  alias: Alias | null;
  aliasName: string | null;
  aliasId: string | null;
  loading: boolean;
  error: string | null;
}

export function useAlias(): AliasState {
  const [state, setState] = useState<AliasState>({
    alias: null,
    aliasName: getStoredAliasName(),
    aliasId: getStoredAliasId(),
    loading: true,
    error: null,
  });

  useEffect(() => {
    let cancelled = false;

    getOrCreateAlias()
      .then((alias) => {
        if (!cancelled) {
          setState({
            alias,
            aliasName: alias.alias,
            aliasId: alias.id,
            loading: false,
            error: null,
          });
        }
      })
      .catch((err) => {
        if (!cancelled) {
          setState((prev) => ({
            ...prev,
            loading: false,
            error: err instanceof Error ? err.message : 'Failed to create alias',
          }));
        }
      });

    return () => {
      cancelled = true;
    };
  }, []);

  return state;
}
