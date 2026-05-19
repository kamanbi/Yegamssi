-- ============================================================
-- 예감씨 앱 업데이트 정책 테이블 생성 및 Data API 권한 설정
-- Supabase SQL Editor에서 실행
-- ============================================================

CREATE TABLE IF NOT EXISTS public.app_version_policies (
  id BIGSERIAL PRIMARY KEY,
  platform TEXT NOT NULL UNIQUE,
  latest_version TEXT NOT NULL,
  minimum_version TEXT NOT NULL,
  latest_build_number INTEGER,
  minimum_build_number INTEGER,
  store_url TEXT NOT NULL DEFAULT '',
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.app_version_policies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_app_version_policies"
  ON public.app_version_policies;

CREATE POLICY "anon_read_app_version_policies"
  ON public.app_version_policies
  FOR SELECT
  TO anon
  USING (enabled = TRUE);

GRANT SELECT
  ON TABLE public.app_version_policies
  TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.app_version_policies
  TO service_role;

GRANT USAGE, SELECT
  ON SEQUENCE public.app_version_policies_id_seq
  TO service_role;

INSERT INTO public.app_version_policies (
  platform,
  latest_version,
  minimum_version,
  latest_build_number,
  minimum_build_number,
  store_url,
  enabled
)
VALUES (
  'android',
  '1.1.4+36',
  '1.1.1+33',
  36,
  33,
  'https://play.google.com/store/apps/details?id=com.yegamssi.yegamssi',
  TRUE
)
ON CONFLICT (platform) DO UPDATE SET
  latest_version = EXCLUDED.latest_version,
  minimum_version = EXCLUDED.minimum_version,
  latest_build_number = EXCLUDED.latest_build_number,
  minimum_build_number = EXCLUDED.minimum_build_number,
  store_url = EXCLUDED.store_url,
  enabled = EXCLUDED.enabled,
  updated_at = NOW();
