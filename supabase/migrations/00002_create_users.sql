-- Widows & Orphans Platform
-- Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
-- Proprietary and confidential.

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('REQUESTER', 'HELPER', 'ORG_ADMIN', 'MODERATOR', 'SPONSOR_ADMIN')),
  trust_tier TEXT NOT NULL DEFAULT 'UNVERIFIED' CHECK (trust_tier IN ('UNVERIFIED', 'BASIC', 'TRUSTED', 'VERIFIED_PARTNER')),
  org_id UUID REFERENCES partner_orgs(id) ON DELETE SET NULL,
  location_zone TEXT,
  fulfillment_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_org_id ON users(org_id);
CREATE INDEX idx_users_location_zone ON users(location_zone);
