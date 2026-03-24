-- Widows & Orphans Platform
-- Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
-- Proprietary and confidential.

CREATE TABLE IF NOT EXISTS partner_orgs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('CHURCH', 'MINISTRY', 'NONPROFIT', 'COMMUNITY')),
  location_zone TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_partner_orgs_location_zone ON partner_orgs(location_zone);
CREATE INDEX idx_partner_orgs_type ON partner_orgs(type);
