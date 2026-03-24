-- Widows & Orphans Platform
-- Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
-- Proprietary and confidential.

CREATE TABLE IF NOT EXISTS need_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID REFERENCES users(id),
  advocate_id UUID REFERENCES users(id),
  org_id UUID REFERENCES partner_orgs(id),
  category TEXT NOT NULL CHECK (category IN ('FOOD', 'TRANSPORT', 'HOUSEHOLD', 'MEDICAL', 'FAMILY', 'PRAYER', 'EMERGENCY', 'CUSTOM')),
  status TEXT NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'UNDER_REVIEW', 'MATCHED', 'IN_PROGRESS', 'FULFILLED', 'CLOSED', 'ESCALATED')),
  urgency TEXT NOT NULL DEFAULT 'MEDIUM' CHECK (urgency IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  location_zone TEXT NOT NULL,
  description TEXT,
  is_anonymous BOOLEAN DEFAULT FALSE,
  sponsor_backed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  fulfilled_at TIMESTAMPTZ
);

CREATE INDEX idx_need_requests_requester_id ON need_requests(requester_id);
CREATE INDEX idx_need_requests_advocate_id ON need_requests(advocate_id);
CREATE INDEX idx_need_requests_org_id ON need_requests(org_id);
CREATE INDEX idx_need_requests_status ON need_requests(status);
CREATE INDEX idx_need_requests_category ON need_requests(category);
CREATE INDEX idx_need_requests_urgency ON need_requests(urgency);
CREATE INDEX idx_need_requests_location_zone ON need_requests(location_zone);
