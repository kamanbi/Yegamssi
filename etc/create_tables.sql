-- ============================================================
-- 예감씨 운세 데이터 테이블 생성 및 Data API 권한 설정
-- Supabase SQL Editor에서 실행
-- ============================================================

-- fortune_ko: 한국어 운세 문구
CREATE TABLE IF NOT EXISTS public.fortune_ko (
  id BIGSERIAL PRIMARY KEY,
  code TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('intro', 'state', 'effect', 'action')),
  text TEXT NOT NULL,
  weight SMALLINT NOT NULL DEFAULT 1 CHECK (weight BETWEEN 1 AND 10)
);

CREATE INDEX IF NOT EXISTS idx_fortune_ko_code_type
  ON public.fortune_ko (code, type);

ALTER TABLE public.fortune_ko ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_fortune_ko"
  ON public.fortune_ko;

CREATE POLICY "anon_read_fortune_ko"
  ON public.fortune_ko
  FOR SELECT
  TO anon
  USING (true);

GRANT SELECT
  ON TABLE public.fortune_ko
  TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.fortune_ko
  TO service_role;

GRANT USAGE, SELECT
  ON SEQUENCE public.fortune_ko_id_seq
  TO service_role;

-- fortune_en: 영어 운세 문구 보관용
CREATE TABLE IF NOT EXISTS public.fortune_en (
  id BIGSERIAL PRIMARY KEY,
  code TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('intro', 'state', 'effect', 'action')),
  text TEXT NOT NULL,
  weight SMALLINT NOT NULL DEFAULT 1 CHECK (weight BETWEEN 1 AND 10)
);

CREATE INDEX IF NOT EXISTS idx_fortune_en_code_type
  ON public.fortune_en (code, type);

ALTER TABLE public.fortune_en ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_fortune_en"
  ON public.fortune_en;

CREATE POLICY "anon_read_fortune_en"
  ON public.fortune_en
  FOR SELECT
  TO anon
  USING (true);

GRANT SELECT
  ON TABLE public.fortune_en
  TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.fortune_en
  TO service_role;

GRANT USAGE, SELECT
  ON SEQUENCE public.fortune_en_id_seq
  TO service_role;
