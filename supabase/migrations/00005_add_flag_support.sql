-- Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
-- Proprietary and confidential.
--
-- Migration: 00005_add_flag_support
-- Adds the need_flags table for flagging needs for moderator review.

CREATE TABLE IF NOT EXISTS need_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  need_id UUID REFERENCES need_requests(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES users(id),
  reason TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE need_flags ENABLE ROW LEVEL SECURITY;

-- Authenticated users can insert flags
CREATE POLICY need_flags_insert ON need_flags
  FOR INSERT WITH CHECK (reporter_id = auth.uid());

-- Moderators and org admins can read flags
CREATE POLICY need_flags_select_moderator ON need_flags
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('MODERATOR', 'ORG_ADMIN')
    )
  );
