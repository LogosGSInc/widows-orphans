-- Widows & Orphans Platform
-- Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
-- Proprietary and confidential.
--
-- Row Level Security Policies
-- Enforces data access at the database layer per Architecture Rule #6.

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_orgs ENABLE ROW LEVEL SECURITY;
ALTER TABLE need_requests ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- USERS TABLE POLICIES
-- ============================================================

-- Users can read their own row
CREATE POLICY users_select_own ON users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own row
CREATE POLICY users_update_own ON users
  FOR UPDATE USING (auth.uid() = id);

-- ============================================================
-- PARTNER_ORGS TABLE POLICIES
-- ============================================================

-- Org members can read their own org
CREATE POLICY partner_orgs_select_member ON partner_orgs
  FOR SELECT USING (
    id IN (SELECT org_id FROM users WHERE users.id = auth.uid())
  );

-- ============================================================
-- NEED_REQUESTS TABLE POLICIES
-- ============================================================

-- Requesters: SELECT own rows only
CREATE POLICY need_requests_select_requester ON need_requests
  FOR SELECT USING (
    requester_id = auth.uid()
  );

-- Requesters: UPDATE own rows only
CREATE POLICY need_requests_update_requester ON need_requests
  FOR UPDATE USING (
    requester_id = auth.uid()
  );

-- Requesters: INSERT own rows
CREATE POLICY need_requests_insert_requester ON need_requests
  FOR INSERT WITH CHECK (
    requester_id = auth.uid()
  );

-- Helpers: SELECT need_requests where they are the advocate (matched helper)
CREATE POLICY need_requests_select_helper ON need_requests
  FOR SELECT USING (
    advocate_id = auth.uid()
  );

-- ORG_ADMIN: SELECT need_requests within their org
CREATE POLICY need_requests_select_org_admin ON need_requests
  FOR SELECT USING (
    org_id IN (
      SELECT org_id FROM users
      WHERE users.id = auth.uid() AND users.role = 'ORG_ADMIN'
    )
  );

-- ORG_ADMIN: UPDATE need_requests within their org
CREATE POLICY need_requests_update_org_admin ON need_requests
  FOR UPDATE USING (
    org_id IN (
      SELECT org_id FROM users
      WHERE users.id = auth.uid() AND users.role = 'ORG_ADMIN'
    )
  );

-- MODERATOR: SELECT escalated or under-review need_requests
CREATE POLICY need_requests_select_moderator ON need_requests
  FOR SELECT USING (
    status IN ('ESCALATED', 'UNDER_REVIEW')
    AND EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.role = 'MODERATOR'
    )
  );

-- SPONSOR_ADMIN: No direct access to need_requests rows.
-- Sponsor admins access aggregate stats only via backend API functions.
-- This is enforced by NOT having a SELECT policy for SPONSOR_ADMIN on need_requests.
-- Aggregate stats are provided via Postgres functions with SECURITY DEFINER.

-- ============================================================
-- AGGREGATE FUNCTION FOR SPONSOR_ADMIN
-- ============================================================

CREATE OR REPLACE FUNCTION get_sponsor_stats(p_org_id UUID DEFAULT NULL)
RETURNS TABLE (
  total_requests BIGINT,
  open_requests BIGINT,
  fulfilled_requests BIGINT,
  avg_fulfillment_hours NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verify caller is SPONSOR_ADMIN
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'SPONSOR_ADMIN'
  ) THEN
    RAISE EXCEPTION 'Access denied: SPONSOR_ADMIN role required';
  END IF;

  RETURN QUERY
  SELECT
    COUNT(*)::BIGINT AS total_requests,
    COUNT(*) FILTER (WHERE nr.status = 'OPEN')::BIGINT AS open_requests,
    COUNT(*) FILTER (WHERE nr.status = 'FULFILLED')::BIGINT AS fulfilled_requests,
    ROUND(AVG(
      EXTRACT(EPOCH FROM (nr.fulfilled_at - nr.created_at)) / 3600
    ) FILTER (WHERE nr.fulfilled_at IS NOT NULL), 2) AS avg_fulfillment_hours
  FROM need_requests nr
  WHERE (p_org_id IS NULL OR nr.org_id = p_org_id);
END;
$$;
