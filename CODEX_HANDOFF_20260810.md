# Claude Code 작업 인계 (2026-08-10)

Codex가 진행 중인 활동예감(Activity Forecast) 작업과 겹치거나 전제로 삼아야 할
변경사항을 정리한다. `research.md`/`plan.md`는 Codex가 계속 갱신 중이라 건드리지
않았다 — 이 문서만 별도로 남긴다.

---

## ⚠️ 충돌 주의: `supabase/functions/weather-proxy/index.ts`

**`plan.md`의 "Proxy Abuse Protection" / "Delivery Order 2"(캐시 우회·rate limit
강화)가 오늘 이 파일을 대대적으로 수정한 작업과 정면으로 겹친다.**

### 오늘 이 파일에 반영된 것 (파괴하면 안 됨)
1. **2계층 캐싱** (L1 인메모리 Map + L2 Postgres `weather_proxy_cache` 테이블)
   - 마이그레이션: `supabase/migrations/20260810000000_weather_proxy_cache.sql`
   - 설계 문서: `.claude/_workspace/01_cache_design.md`
   - 구현 보고: `.claude/_workspace/02_implementation_report.md`
   - 검증 리포트: `.claude/_workspace/03_verification_report.md` (FAIL 1건 + 개선 2건 발견 후 수정 완료)
2. **`nocache=1` 처리**: 현재는 `plan.md`가 지적한 대로 **여전히 클라이언트가 임의로 켤 수 있음** (`E2` 분기). Codex의 "public 요청에서 nocache 제거/거부" 요구사항은 아직 미반영 — 이 부분만 새로 작업하면 되고, 캐시 계층 자체는 그대로 두면 된다.
3. **rate limit / 호출자별 quota**: 미구현. `plan.md`가 요구하는 429/Retry-After, 호출자·IP별 제한은 전혀 없다 — 이것도 새로 추가해야 하는 부분이고 캐시 로직과 독립적으로 얹을 수 있다.
4. **E12 (오늘 마지막 수정, 배포 완료됨)**: 기상청 `getVilageFcst`/`getUltraSrtFcst`가 발표 경계 시점에 `resultCode="00"`이면서도 항목 일부만 채워진 응답을 줄 때가 있어, 최소 항목 수(100/20) 미달 시 캐싱을 건너뛰도록 `determineSkipReason`에 추가함. **이 검증 로직은 유지할 것** — 없으면 반쪽 예보가 TTL(최대 3.2시간) 동안 캐싱되어 노출되는 버그가 재발한다.

### Codex가 이어서 할 때 지켜야 할 것
- **캐시 판정 순서를 바꾸지 말 것**: 보안 검증(allowedPaths/providerKey) → 캐시 조회 → upstream 순서가 고정이다. rate limit을 추가한다면 보안 검증 직후, 캐시 조회 이전에 넣는 게 자연스럽다.
- **`nocache` 제거 시 검증 도구로서의 경로는 남겨두는 걸 권장**: 완전 삭제보다는 "신뢰된 서버 작업만 허용"(plan.md 표현대로) 쪽으로 가려면 별도 인증(서비스 토큰 등) 체크를 얹는 편이 안전. 단순 삭제하면 배포 후 캐시 실측 검증(HIT/MISS 확인) 수단이 없어진다.
- **`L2_SELECT_TIMEOUT_MS = 700`** (오늘 250→700ms로 상향, 실측 근거 있음): 이 값을 되돌리지 말 것. 250ms일 때 실제 프로덕션에서 5회 중 2회 `l2_timeout`이 발생했다.
- **TTL 표(`getVilageFcst`=11400s 등)는 건드리지 말 것** — KMA 발표 주기 기준으로 설계된 값.

---

## 완료된 별도 작업 (참고용, 충돌 없음)

### 1. 릴리즈 빌드 규칙 문서화
`CLAUDE.md`/`agents.md` 둘 다에 "릴리즈 빌드는 반드시 `tool/build_release.ps1`로만
한다"는 규칙을 추가함. **이유: 오늘 Codex가(추정) 이 스크립트를 안 쓰고 일반
`flutter build apk/appbundle --release`로 v1.1.50+84를 빌드해서 배포한 것으로
보이는데, 그러면 `--dart-define`으로 주입되는 Supabase 키가 빈 문자열이 되어
운세 등 Supabase 의존 기능이 전부 조용히 실패한다.** 실제로 이 문제가 실기기에서
재현되어 (날씨는 캐시로 정상처럼 보이고 운세만 "불러오지 못했습니다" 에러) 확인 후
정식 스크립트로 재빌드해서 해결함. **앞으로 릴리즈 빌드는 무조건
`tool/build_release.ps1` 경유할 것.**

- 스크립트의 Flutter SDK 기본 경로도 `F:\flutter-3.32.8` → `C:\dev\flutter`로 수정함(실제 환경과 불일치했음).

### 2. 타로 카드 기능 완전 삭제
- 사용자 요청으로 타로 관련 에이전트 3개(`.claude/agents/tarot-*.md`), 스킬
  (`.claude/skills/tarot-card-pipeline/`), 자산(`etc/tarot/`) 전부 삭제함.
- 코드(`lib/`)에는 애초에 타로 참조가 없었음(화면 자체가 "준비중" 상태로 미완성이었던 걸로 보임).
- Codex 작업과 무관, 참고만 하면 됨.

### 3. 무관하지만 발견한 미적용 마이그레이션
`supabase/migrations/20260623071500_dedupe_fortune_anon_policies.sql` —
`fortune_en/hi/ro` 테이블의 `anon_read` 정책을 삭제하는 내용인데, **아직 프로덕션에
미적용 상태**다. 오늘 내 캐시 마이그레이션만 선별 적용하고 이건 의도적으로 보류했다
(대체 정책 유무를 확인 못해서, 잘못 적용하면 해당 언어 운세 읽기가 막힐 수 있음).
이 파일을 작성한 게 Codex라면, 의도를 알고 있을 테니 안전하다고 판단되면 직접
`supabase db push`로 적용하면 된다.

---

## 현재 버전 상태
- `pubspec.yaml`: `1.1.51+85`로 방금 올림, AAB 빌드 진행 중 (본 문서 작성 시점 기준)
- 배포된 Supabase 함수: `weather-proxy` (캐싱 + E12 완비된 최신 버전, 오늘 3회 재배포 완료)
