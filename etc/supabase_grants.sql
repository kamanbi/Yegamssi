-- ============================================================
-- Supabase Data API 명시적 권한 보정 SQL
-- 기존 테이블에 바로 실행
-- ============================================================

GRANT SELECT
  ON TABLE public.fortune_ko
  TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.fortune_ko
  TO service_role;

GRANT USAGE, SELECT
  ON SEQUENCE public.fortune_ko_id_seq
  TO service_role;

GRANT SELECT
  ON TABLE public.fortune_en
  TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.fortune_en
  TO service_role;

GRANT USAGE, SELECT
  ON SEQUENCE public.fortune_en_id_seq
  TO service_role;

GRANT SELECT
  ON TABLE public.app_version_policies
  TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.app_version_policies
  TO service_role;

GRANT USAGE, SELECT
  ON SEQUENCE public.app_version_policies_id_seq
  TO service_role;
