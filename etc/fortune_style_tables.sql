-- ============================================================
-- 예감씨 운세 스타일별 테이블 생성 및 Data API 권한 설정
-- Supabase SQL Editor에서 실행
-- ============================================================

CREATE TABLE IF NOT EXISTS public.fortune_ko_humor
  (LIKE public.fortune_ko INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING IDENTITY);
CREATE TABLE IF NOT EXISTS public.fortune_ko_tsundere
  (LIKE public.fortune_ko INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING IDENTITY);
CREATE TABLE IF NOT EXISTS public.fortune_ko_cynical
  (LIKE public.fortune_ko INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING IDENTITY);
CREATE TABLE IF NOT EXISTS public.fortune_ko_emotional
  (LIKE public.fortune_ko INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING IDENTITY);
CREATE TABLE IF NOT EXISTS public.fortune_ko_historical
  (LIKE public.fortune_ko INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING IDENTITY);
CREATE TABLE IF NOT EXISTS public.fortune_ko_ai
  (LIKE public.fortune_ko INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING IDENTITY);

CREATE INDEX IF NOT EXISTS idx_fortune_ko_humor_code_type
  ON public.fortune_ko_humor (code, type);
CREATE INDEX IF NOT EXISTS idx_fortune_ko_tsundere_code_type
  ON public.fortune_ko_tsundere (code, type);
CREATE INDEX IF NOT EXISTS idx_fortune_ko_cynical_code_type
  ON public.fortune_ko_cynical (code, type);
CREATE INDEX IF NOT EXISTS idx_fortune_ko_emotional_code_type
  ON public.fortune_ko_emotional (code, type);
CREATE INDEX IF NOT EXISTS idx_fortune_ko_historical_code_type
  ON public.fortune_ko_historical (code, type);
CREATE INDEX IF NOT EXISTS idx_fortune_ko_ai_code_type
  ON public.fortune_ko_ai (code, type);

ALTER TABLE public.fortune_ko_humor ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fortune_ko_tsundere ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fortune_ko_cynical ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fortune_ko_emotional ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fortune_ko_historical ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fortune_ko_ai ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_fortune_ko_humor" ON public.fortune_ko_humor;
DROP POLICY IF EXISTS "anon_read_fortune_ko_tsundere" ON public.fortune_ko_tsundere;
DROP POLICY IF EXISTS "anon_read_fortune_ko_cynical" ON public.fortune_ko_cynical;
DROP POLICY IF EXISTS "anon_read_fortune_ko_emotional" ON public.fortune_ko_emotional;
DROP POLICY IF EXISTS "anon_read_fortune_ko_historical" ON public.fortune_ko_historical;
DROP POLICY IF EXISTS "anon_read_fortune_ko_ai" ON public.fortune_ko_ai;

CREATE POLICY "anon_read_fortune_ko_humor"
  ON public.fortune_ko_humor FOR SELECT TO anon USING (true);
CREATE POLICY "anon_read_fortune_ko_tsundere"
  ON public.fortune_ko_tsundere FOR SELECT TO anon USING (true);
CREATE POLICY "anon_read_fortune_ko_cynical"
  ON public.fortune_ko_cynical FOR SELECT TO anon USING (true);
CREATE POLICY "anon_read_fortune_ko_emotional"
  ON public.fortune_ko_emotional FOR SELECT TO anon USING (true);
CREATE POLICY "anon_read_fortune_ko_historical"
  ON public.fortune_ko_historical FOR SELECT TO anon USING (true);
CREATE POLICY "anon_read_fortune_ko_ai"
  ON public.fortune_ko_ai FOR SELECT TO anon USING (true);

GRANT SELECT ON TABLE
  public.fortune_ko_humor,
  public.fortune_ko_tsundere,
  public.fortune_ko_cynical,
  public.fortune_ko_emotional,
  public.fortune_ko_historical,
  public.fortune_ko_ai
TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
  public.fortune_ko_humor,
  public.fortune_ko_tsundere,
  public.fortune_ko_cynical,
  public.fortune_ko_emotional,
  public.fortune_ko_historical,
  public.fortune_ko_ai
TO service_role;

GRANT USAGE, SELECT
  ON ALL SEQUENCES IN SCHEMA public
  TO service_role;

NOTIFY pgrst, 'reload schema';
