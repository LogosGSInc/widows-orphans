export type NeedCategory = 'food' | 'shelter' | 'transportation' | 'clothing' | 'medical' | 'other';

export type NeedStatus = 'open' | 'fulfilled' | 'expired';

export type ChatStatus = 'active' | 'expired';

export interface Alias {
  id: string;
  alias: string;
  device_hash: string;
  created: string;
}

export interface Need {
  id: string;
  alias_id: string;
  category: NeedCategory;
  description: string;
  lat: number;
  lng: number;
  expires_at: string;
  status: NeedStatus;
  created: string;
  expand?: {
    alias_id?: Alias;
  };
}

export interface Chat {
  id: string;
  need_id: string;
  poster_alias_id: string;
  fulfiller_alias_id: string;
  started_at: string;
  expires_at: string;
  status: ChatStatus;
}

export interface Message {
  id: string;
  need_id: string;
  sender_alias_id: string;
  body: string;
  expires_at: string;
  created: string;
  expand?: {
    sender_alias_id?: Alias;
  };
}

export const CATEGORY_LABELS: Record<NeedCategory, string> = {
  food: 'Food',
  shelter: 'Shelter',
  transportation: 'Transportation',
  clothing: 'Clothing',
  medical: 'Medical',
  other: 'Other',
};

export const CATEGORY_COLORS: Record<NeedCategory, string> = {
  food: '#E07A5F',
  shelter: '#3D405B',
  transportation: '#81B29A',
  clothing: '#F2CC8F',
  medical: '#D62828',
  other: '#C0C7D4',
};
