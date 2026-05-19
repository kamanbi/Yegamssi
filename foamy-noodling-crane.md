# 예감씨 (Yegamssi) — 운세 기능 최종 구현 계획

---

## Context

lockey.md + 설계 검토 세션 기반 최종 확정안.
핵심 공식: **개인 사주 + 오늘 운 + 날씨 = 최종 운세**
언어팩(테이블 분리) + 코드 기반 주소 시스템 + 일 3회 캐시 + fallback 5계층 적용.

---

## 확정 설계 결정 사항

| 항목 | 결정 |
|------|------|
| 점수 구조 | 카테고리별 개별 점수 6개 (overall/money/love/work/health/decision) |
| 출생시간 미입력 | 정오(12시, 午時) 고정 → 항상 4기둥 계산 |
| 캐시 주기 | **일 3회** — am(00~11시) / pm(12~17시) / ev(18~23시) |
| slot 처리 | code에 포함 안 함. **seed 변수**로만 사용 (데이터 3배 절감) |
| 조건 처리 | 범용(NULL) 조각 없음. **모든 행에 완전한 code 필수** |
| 안전망 | **fallback 5계층** (코드 점진 축소 → 앱 내장 최종) |
| 언어 구조 | **테이블 분리 언어팩** (fortune_ko / fortune_en / fortune_ja / fortune_zh) |
| 멘트 데이터 | 사용자 제공 → 내가 INSERT SQL 변환 후 Supabase 등록 |
| 월주 계산 | 절기 테이블 하드코딩 적용 (단순 월 인덱스 오류 방지) |

---

## 현재 코드 vs 확정안 충돌 목록

| 파일 | 현재 | 변경 |
|------|------|------|
| `fortune_entity.dart` | message/luckyColor/luckyNumber/iconKey | **FortuneResult로 전면 교체** |
| `fortune_dto.dart` | 단일 message | **삭제 → fortune_response_dto.dart** |
| `fortune_data_source.dart` | date/birthDate 2개 파라미터 | **시그니처 변경** |
| `fortune_repository.dart` | 동일 누락 + typedef FortuneResult 충돌 | **FortuneQueryResult로 rename** |
| `fortune_repository_impl.dart` | 미구현 | **재작성** |
| `mingri_data_source.dart` | UnimplementedError | **전면 재작성** |
| `fortune_screen.dart` | placeholder | **6개 카테고리 카드 UI** |
| 사용자 생년월일 | 없음 | **신규 구현 (user/ feature)** |
| 온보딩 화면 | stub | **DatePicker + 출생시간 UI** |
| 설정 화면 | stub | **언어 선택 옵션 추가** |
| Supabase 테이블 | 없음 | **fortune_ko 등 언어팩 테이블 생성** |

---

## 구현 Phase (7단계)

---

### Phase 1 — 사용자 프로필 (생년월일 저장)

**신규 파일:**
- `lib/features/user/domain/entities/user_profile.dart`
  ```dart
  class UserProfile {
    final DateTime birthDate;
    final int birthHour;  // 모름=12(午時 고정), 0~23
  }
  ```
- `lib/features/user/data/user_profile_repository.dart`
  - SharedPreferences 저장: `user_birth_date`(ISO8601), `user_birth_hour`(int)
- `lib/features/user/presentation/user_profile_provider.dart`
  - `@riverpod Future<UserProfile?> userProfile(...)`
  - `@riverpod class UserProfileNotifier` — save/clear

**수정 파일:**
- `lib/features/onboarding/presentation/onboarding_screen.dart`
  - `showDatePicker` → 생년월일 선택
  - 출생시간: 드롭다운 0~23시 + "모름" (모름 선택 시 12 저장)
  - 완료 → `UserProfileNotifier.save()` → `context.go(AppRoutes.home)`
- `lib/core/router/app_router.dart`
  - redirect: `userProfileProvider == null` → `/onboarding` 강제

---

### Phase 2 — 언어 설정 (언어팩 기반)

**수정 파일:**
- `lib/core/locale/country_code.dart` — `AppLanguage` enum 추가
  ```dart
  enum AppLanguage {
    ko, en, ja, zh;

    // 설정 화면 표기 (자국어)
    String get displayName => switch (this) {
      AppLanguage.ko => '한국어',
      AppLanguage.en => 'English',
      AppLanguage.ja => '日本語',
      AppLanguage.zh => '中文',
    };

    // Supabase 테이블 접미사
    String get tableKey => name; // 'ko', 'en', 'ja', 'zh'

    // 언어팩 활성 여부 (미출시 언어 비활성)
    bool get isAvailable => this == AppLanguage.ko || this == AppLanguage.en;
  }
  ```
- `lib/core/locale/locale_provider.dart`
  - `@riverpod class AppLanguageNotifier` — SharedPreferences 저장/로드
  - 언어 변경 시 `ref.invalidate(dailyFortuneProvider)` → 캐시 자동 무효화
- `lib/features/settings/presentation/settings_screen.dart`
  - 언어 선택 UI 구현
  ```
  ● 한국어
  ○ English
  ○ 日本語  (비활성 — 준비 중)
  ○ 中文    (비활성 — 준비 중)
  ```

---

### Phase 3 — 오행(五行) 도메인 모델

**신규 파일:**
- `lib/features/fortune/domain/entities/oheng.dart`
  ```dart
  enum Oheng { mok, hwa, to, geum, su }
  enum OhengStrength { ex, df }   // excess(과다) / deficient(부족)
  enum FortuneCategory { overall, money, love, work, health, decision }
  enum HeavenlyStem { gap, eul, byeong, jeong, mu, gi, gyeong, shin, im, gye } // 甲~癸
  enum EarthlyBranch { ja, chuk, in_, myo, jin, sa, o, mi, sin, yu, sul, hae } // 子~亥
  ```
- `lib/features/fortune/domain/entities/saju.dart`
  ```dart
  class Saju {
    final HeavenlyStem yearStem;  final EarthlyBranch yearBranch;
    final HeavenlyStem monthStem; final EarthlyBranch monthBranch;
    final HeavenlyStem dayStem;   final EarthlyBranch dayBranch;
    final HeavenlyStem hourStem;  final EarthlyBranch hourBranch; // 모름=午時
    final Map<Oheng, int> ohengCount; // 기둥별 오행 카운트 (0~8)
    Oheng get dominant;            // 가장 많은 오행
    OhengStrength get dominantStrength; // count>=3: ex, <=1: df
  }
  ```
- `lib/features/fortune/domain/entities/fortune_result.dart`
  ```dart
  class FortuneResult {
    final Map<FortuneCategory, int>    scores;    // 카테고리별 점수 0~100
    final Map<FortuneCategory, String> messages;  // 카테고리별 조합 멘트
    final Map<Oheng, double>           ohengRatio; // 오행 비율 (UI 게이지용)
    final DateTime date;
    final TimeSlot slot;
  }
  enum TimeSlot { am, pm, ev }
  ```

**교체:**
- `fortune_entity.dart` → `FortuneResult` 참조로 내용 교체
- `fortune_dto.dart` → 삭제 후 `fortune_response_dto.dart` 신규

---

### Phase 4 — 명리 계산 엔진 (순수 Dart, 오프라인)

**신규 파일:**

`lib/features/fortune/domain/calculators/saju_calculator.dart`
- 천간 오행: 甲乙→木 / 丙丁→火 / 戊己→土 / 庚辛→金 / 壬癸→水
- 지지 오행: 子亥→水 / 寅卯→木 / 巳午→火 / 申酉→金 / 丑辰未戌→土
- 년주: `(year-4)%10` → 천간, `(year-4)%12` → 지지
- 일주: 기준일 1900-01-01(甲子)로부터 일수 차이 `%60`
- **월주: 절기 테이블 하드코딩** (단순 월 인덱스 사용 금지 — 최대 20% 오류)
  ```dart
  // 연도별 절기 시작일 배열로 정확한 월주 산출
  static const _solarTerms = { 1900: [6,4,6,5,...], 1901: [...], ... };
  ```
- 시주: `birthHour`(12 고정 or 실제 입력값) → 2시간 단위 지지 배정
- 반환: `Saju` (4기둥 + ohengCount + dominant + dominantStrength)

`lib/features/fortune/domain/calculators/ganji_calculator.dart`
- `todayGanji(DateTime) → ({HeavenlyStem stem, EarthlyBranch branch})`
- 일주 계산과 동일 방법

`lib/features/fortune/domain/calculators/fortune_score_calculator.dart`
- 오행 관계표:
  ```
  상생(+20): 木→火, 火→土, 土→金, 金→水, 水→木
  동일(+10): 같은 오행
  중립(  0): 간접 관계
  상극(-20): 木→土, 土→水, 水→火, 火→金, 金→木
  충돌(-40): 일주天干 ↔ 오늘天干 충(冲) 관계
  ```
- **반환: `Map<FortuneCategory, int>`** (카테고리별 개별 점수)
  ```
  overall: 일주天干 ↔ 오늘天干 관계 + 날씨 보정
  money:   金 강도 기반 (과다→高, 부족→低)
  love:    火+水 균형 지수
  work:    木+金 조합 강도
  health:  오행 균형도 (편차 낮을수록 고점)
  decision:일주 천간 상생 관계 강도
  ```
- 정규화: `((rawScore+80)/160*100).clamp(0,100)`

`lib/features/fortune/domain/services/weather_oheng_mapper.dart`
```
sunny        → Oheng.hwa  (火)
partlyCloudy → Oheng.to   (土)
cloudy       → Oheng.to   (土)
foggy        → Oheng.to   (土)
rainy        → Oheng.su   (水)
heavyRain    → Oheng.su   (水)
snowy        → Oheng.su   (水)
stormy       → Oheng.mok  (木)
unknown      → null (날씨 보정 없음)
```

날씨 보정 점수:
```
ohengCount[weatherOheng] = 0 → +20
                          = 1 → +10
                          = 2 →   0
                          = 3 → -10
                         >= 4 → -20
```

---

### Phase 5 — Supabase 언어팩 + 코드 기반 조회

**Supabase SQL (직접 실행):**

```sql
-- 언어팩 공통 생성 함수 (fortune_ko, fortune_en 동일 구조)
CREATE TABLE fortune_ko (
  id       BIGSERIAL PRIMARY KEY,
  code     TEXT NOT NULL,
  type     TEXT NOT NULL CHECK (type IN ('intro','state','effect','action')),
  text     TEXT NOT NULL,
  weight   SMALLINT NOT NULL DEFAULT 1 CHECK (weight BETWEEN 1 AND 10)
);
CREATE INDEX idx_fko ON fortune_ko (code, type);
ALTER TABLE fortune_ko ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read" ON fortune_ko FOR SELECT TO anon USING (true);

-- en 팩 (동일 구조)
CREATE TABLE fortune_en (LIKE fortune_ko INCLUDING ALL);
ALTER TABLE fortune_en ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read" ON fortune_en FOR SELECT TO anon USING (true);
```

**코드 형식:**
```
{category}_{tier}_{oheng}_{strength}_{weather}

tier:     A(75~100) / B(50~74) / C(25~49) / D(0~24)
oheng:    mok / hwa / to / geum / su
strength: ex(과다, count≥3) / df(부족, count≤1)
weather:  fire(맑음) / earth(흐림) / water(비/눈) / wood(폭풍)

예: money_A_su_ex_water
    love_C_hwa_df_fire
    overall_B_to_ex_earth
```

**코드 생성 (Dart):**
```dart
String buildCode({
  required FortuneCategory category,
  required int score,
  required Oheng dominantOheng,
  required OhengStrength strength,
  required Oheng? weatherOheng,
}) {
  final tier = score >= 75 ? 'A' : score >= 50 ? 'B' : score >= 25 ? 'C' : 'D';
  final wx = switch (weatherOheng) {
    Oheng.hwa  => 'fire',
    Oheng.to   => 'earth',
    Oheng.su   => 'water',
    Oheng.mok  => 'wood',
    _          => 'earth',  // null → earth 기본
  };
  return '${category.name}_${tier}_${dominantOheng.name}_${strength.name}_$wx';
}
```

**Supabase 조회 (1회 IN 쿼리):**
```dart
final tableName = 'fortune_${selectedLang}';  // fortune_ko / fortune_en

final codes = FortuneCategory.values
  .map((cat) => buildCode(category: cat, score: scores[cat]!, ...))
  .toList();

final rows = await supabase
  .from(tableName)
  .select('code, type, text, weight')
  .inFilter('code', codes);  // 6개 코드 1회 조회
```

**Fallback 5계층 (데이터 공백 방지):**
```dart
Future<List<Row>> fetchWithFallback(FortuneCategory cat, String baseCode) async {
  // 1단계: 완전 코드    money_A_su_ex_water
  var rows = await _fetch(baseCode);
  if (rows.isNotEmpty) return rows;

  // 2단계: weather 제거  money_A_su_ex
  rows = await _fetch(_removeWeather(baseCode));
  if (rows.isNotEmpty) return rows;

  // 3단계: strength 제거 money_A_su
  rows = await _fetch(_removeStrength(baseCode));
  if (rows.isNotEmpty) return rows;

  // 4단계: oheng 제거   money_A
  rows = await _fetch(_removeOheng(baseCode));
  if (rows.isNotEmpty) return rows;

  // 5단계: 앱 내장 하드코딩 기본 멘트
  return _hardcoded[cat]!;
}
```

**멘트 조합 (seed-random, 일 3회 변화):**
```dart
TimeSlot getTimeSlot() {
  final h = DateTime.now().hour;
  if (h < 12) return TimeSlot.am;
  if (h < 18) return TimeSlot.pm;
  return TimeSlot.ev;
}

// slot을 seed에 반영 → 같은 코드에서 다른 variant 선택
final seed = profile.birthDate.millisecondsSinceEpoch
           ^ (date.year * 10000 + date.month * 100 + date.day)
           ^ (slot.index * 997)
           ^ (category.index * 31);
final rng = Random(seed);
```

**캐시 키:**
```dart
// 하루 최대 3개 키 생성
// fortune_ko_20260415_am
// fortune_ko_20260415_pm
// fortune_ko_20260415_ev
final cacheKey = 'fortune_${lang}_${yyyyMMdd}_${slot.name}';
```

**신규 파일:**
- `lib/features/fortune/data/models/fortune_fragment_dto.dart`
- `lib/features/fortune/domain/services/fragment_composer.dart`
  - `compose(List<FragmentDto>, Random) → String`
  - intro + state + effect + action 조합
  - weight 기반 가중 랜덤 선택

**수정 파일:**
- `fortune_data_source.dart` — 시그니처 변경
- `mingri_data_source.dart` — 전면 재작성
- `fortune_repository.dart` — FortuneQueryResult로 rename, 시그니처 변경
- `fortune_repository_impl.dart` — 재작성

---

### Phase 6 — Riverpod Provider

**신규 파일:**
- `lib/features/fortune/presentation/fortune_provider.dart`
  ```dart
  @riverpod
  Future<FortuneResult> dailyFortune(DailyFortuneRef ref) async {
    // 캐시 확인
    final cacheKey = 'fortune_${lang}_${date}_${slot.name}';
    final cached = localStore.getJson(cacheKey);
    if (cached != null) return FortuneResult.fromJson(cached);

    // 데이터 계산
    final profile = await ref.watch(userProfileProvider.future);
    if (profile == null) throw const FortuneNoProfileException();

    final weather  = await ref.watch(currentWeatherProvider.future);
    final lang     = ref.watch(appLanguageProvider).tableKey;
    final saju     = SajuCalculator.calculate(profile.birthDate, profile.birthHour);
    final ganji    = GanjiCalculator.todayGanji(DateTime.now());
    final wxOheng  = WeatherOhengMapper.toOheng(weather.condition);
    final scores   = FortuneScoreCalculator.calculate(saju, ganji, wxOheng);
    final result   = await repo.getDailyFortune(saju, scores, wxOheng, lang);

    // 캐시 저장
    localStore.setJson(cacheKey, result.toJson());
    return result;
  }

  @riverpod
  FortuneRepository fortuneRepository(FortuneRepositoryRef ref) =>
      FortuneRepositoryImpl(const MingriDataSource());
  ```
- `app_exception.dart` — `FortuneNoProfileException` 추가

---

### Phase 7 — UI 전면 재구성

**수정 파일:**
- `lib/features/fortune/presentation/fortune_screen.dart` — 전면 재작성
  - **loading**: CircularProgressIndicator + "오늘의 운세를 계산하는 중..."
  - **error(NoProfile)**: "생년월일을 입력해주세요" + 온보딩 이동 버튼
  - **data**: 아래 레이아웃
    ```
    헤더: "오늘의 운세" + 날짜 + 시간대(아침/점심/저녁)
    [종합운세 카드] — GlassCard 골드, 점수 게이지, overall 멘트
    [오행 분석 카드] — ohengRatio 기반 5개 진행률 바
    [카테고리 그리드 2열]
      [재물운 카드] 점수 + 멘트
      [연애운 카드] 점수 + 멘트
      [직장운 카드] 점수 + 멘트
      [건강운 카드] 점수 + 멘트
      [결정운 카드] 점수 + 멘트 (전체폭)
    ```

**신규 파일:**
- `lib/features/fortune/presentation/widgets/fortune_category_card.dart`
  - 카테고리별 아이콘/색상 매핑 포함
- `lib/features/fortune/presentation/widgets/fortune_score_gauge.dart`
  - 선형 게이지 (score_gauge.dart 참고)

**연동:**
- `lib/features/home/presentation/home_tab_screen.dart`
  - `_FortuneSummaryCard` → `dailyFortuneProvider` 실제 데이터 연결
  - overall 점수 + overall 멘트 앞부분 표시

---

## Supabase 멘트 데이터 전달 방법

### 코드 구조 이해

데이터를 채울 때 코드 형식은:
```
{카테고리}_{등급}_{오행}_{강도}_{날씨}

카테고리: overall / money / love / work / health / decision
등급:     A(75-100) / B(50-74) / C(25-49) / D(0-24)
오행:     mok(목) / hwa(화) / to(토) / geum(금) / su(수)
강도:     ex(과다) / df(부족)
날씨:     fire(맑음) / earth(흐림) / water(비/눈) / wood(폭풍)

예시:
money_A_su_ex_water → 재물운, 75점이상, 수 과다 사주, 비
love_C_hwa_df_fire  → 연애운, 25-49점, 화 부족 사주, 맑음
```

### 데이터 전달 형식 (CSV — 가장 단순)

아래 형식의 CSV 파일을 전달하면 INSERT SQL로 변환:

```csv
code,type,text,weight
money_A_su_ex_water,intro,오늘 재물의 기운이 충만합니다,1
money_A_su_ex_water,state,수기가 강한 당신에게 물의 흐름처럼,1
money_A_su_ex_water,effect,뜻밖의 수익이 들어올 수 있으며,1
money_A_su_ex_water,action,오늘 중요한 금전 결정을 내려도 좋습니다,1
love_C_hwa_df_fire,intro,연애운이 다소 주춤하는 하루입니다,1
love_C_hwa_df_fire,state,화기가 부족한 지금은 감정이 냉랭할 수 있으나,1
...
```

**type 별 멘트 작성 기준:**
| type | 역할 | 글자 수 | 예시 |
|------|------|---------|------|
| intro | 도입 (오늘의 상황) | 15~25자 | "오늘 재물의 기운이 충만합니다" |
| state | 상태 (사주 상황) | 20~35자 | "수기가 강한 당신에게 물의 흐름처럼" |
| effect | 결과 (어떤 일이) | 20~35자 | "뜻밖의 수익이 들어올 수 있으며" |
| action | 행동 (오늘 할 일) | 20~35자 | "중요한 금전 결정을 내려도 좋습니다" |

**최종 문장 조합 예시:**
```
intro + state + effect + action =
"오늘 재물의 기운이 충만합니다. 수기가 강한 당신에게 물의 흐름처럼 뜻밖의 수익이 들어올 수 있으며, 중요한 금전 결정을 내려도 좋습니다."
```

### 우선 채워야 할 코드 (MVP 최소 세트)

전체 2,880개 코드 중 **가장 흔한 조합 우선**:

```
1순위 (출시 필수): tier B+C × oheng 5개 × strength 2개 × weather 4개
  = 2 × 5 × 2 × 4 = 80 코드 × 6 카테고리 = 480 코드
  × 4 type = 1,920행

2순위 (출시 후): tier A+D (극단값) 추가
  = 480 코드 × 4 type = 1,920행 추가

3순위 (운영 중): weight 2~3으로 variant 추가
```

### 전달 절차

```
1. 사용자가 CSV 파일 작성 (코드/type/text/weight)
         ↓
2. Claude에게 전달
         ↓
3. Claude가 INSERT SQL 생성 후 확인 요청
         ↓
4. 사용자가 Supabase SQL Editor에서 실행
         ↓
5. 앱에서 테스트 확인
```

---

## 전체 데이터 흐름 (최종)

```
[설정: 언어 선택]
  한국어 → fortune_ko
  English → fortune_en
        ↓
[캐시 확인]
  키: fortune_{lang}_{date}_{slot}
  유효 → UI 즉시 렌더링
  없음 →
        ↓
[사주 계산 (Dart, 오프라인)]
  생년월일+출생시간(모름=12시) → Saju → dominant+strength
        ↓
[날씨 조회]
  currentWeatherProvider → WeatherOheng
        ↓
[카테고리별 점수 계산]
  FortuneScoreCalculator → Map<FortuneCategory, int>
        ↓
[코드 6개 생성]
  buildCode × 6 카테고리
        ↓
[Supabase 1회 IN 쿼리]
  FROM fortune_{lang} WHERE code IN (6개 코드)
        ↓ 코드 없으면
[Fallback 5계층]
  weather 제거 → strength 제거 → oheng 제거 → tier 제거 → 앱 내장
        ↓
[seed-random 조합]
  seed = birthDate ^ date ^ slot ^ category
  intro + state + effect + action 조합
        ↓
[캐시 저장]
  fortune_{lang}_{date}_{slot}
        ↓
[UI 렌더링]
  종합운세 + 오행 게이지 + 5개 카테고리 카드
```

---

---

## ChatGPT 멘트 생성 가이드 (데이터 생성 전용 문서)

---

### 1. 역할 정의

당신은 한국 명리학 기반 운세 앱 **예감씨**의 운세 멘트를 생성합니다.
생성된 멘트는 CSV 형식으로 출력하여 Supabase 데이터베이스에 등록됩니다.

---

### 2. 코드 시스템 완전 이해

모든 멘트에는 **코드(code)**가 부여됩니다. 코드는 5개 요소의 조합입니다.

```
형식: {카테고리}_{등급}_{오행}_{강도}_{날씨}
예시: money_A_su_ex_water
```

#### 요소 1 — 카테고리 (category)

| 코드값 | 한국어 | 의미 |
|--------|--------|------|
| overall | 종합운세 | 오늘 하루 전반적인 운세 |
| money | 재물운 | 금전, 수입, 투자, 소비 |
| love | 연애운 | 연인, 이성, 감정, 관계 |
| work | 직장운 | 업무, 커리어, 동료, 성과 |
| health | 건강운 | 컨디션, 체력, 심신 상태 |
| decision | 결정운 | 선택, 판단, 계획, 결단 |

#### 요소 2 — 등급 (tier): 점수 범위

| 코드값 | 점수 | 운세 수준 | 멘트 톤 |
|--------|------|----------|---------|
| A | 75~100점 | 매우 좋음 | 자신감 있고 긍정적. "길한 기운", "좋은 흐름" |
| B | 50~74점 | 보통 이상 | 온화하게 긍정적. "순탄한", "무난한" |
| C | 25~49점 | 주의 필요 | 조심스럽고 신중하게. "서두르지 말고", "신중하게" |
| D | 0~24점 | 어려운 날 | 위로하며 인내 강조. "힘든 하루지만", "쉬어가는 것도" |

#### 요소 3 — 오행 (oheng): 사주의 주도 오행

| 코드값 | 오행 | 자연 상징 | 성격/에너지 |
|--------|------|----------|------------|
| mok | 木 (목) | 나무, 봄, 동쪽 | 성장, 창의, 시작, 유연 |
| hwa | 火 (화) | 불, 여름, 남쪽 | 열정, 변화, 표현, 과열 |
| to | 土 (토) | 흙, 환절기, 중앙 | 안정, 포용, 중립, 답답함 |
| geum | 金 (금) | 쇠, 가을, 서쪽 | 결단, 정밀, 냉정, 날카로움 |
| su | 水 (수) | 물, 겨울, 북쪽 | 지혜, 유연, 흐름, 방향상실 |

#### 요소 4 — 강도 (strength): 해당 오행이 사주에서 얼마나 강한지

| 코드값 | 의미 | 설명 | 작성 방향 |
|--------|------|------|----------|
| ex | 과다 (excess) | 사주 4기둥 중 3개 이상이 해당 오행 | 그 오행의 특성이 과도하게 발현. 장점이 지나쳐 단점이 될 수 있음 |
| df | 부족 (deficient) | 사주 4기둥 중 1개 이하가 해당 오행 | 그 오행의 에너지가 필요한 상태. 보충이 필요한 날 |

**오행별 과다/부족 특성:**
```
수(su) 과다(ex): 지나친 유연함으로 방향을 잃을 수 있음. 감정 과잉.
수(su) 부족(df): 지혜와 유연성이 필요. 고집보다 흐름을 따를 것.

화(hwa) 과다(ex): 열정이 넘쳐 과열될 수 있음. 감정 조절 필요.
화(hwa) 부족(df): 동기와 활력이 부족. 불씨를 지필 자극이 필요.

목(mok) 과다(ex): 성장 에너지가 과해 무리할 수 있음. 속도 조절 필요.
목(mok) 부족(df): 새로운 시작과 창의성이 필요. 변화를 두려워 말 것.

금(geum) 과다(ex): 지나치게 날카롭고 냉정할 수 있음. 부드러움 필요.
금(geum) 부족(df): 결단과 정리가 필요한 시기. 우유부단함 주의.

토(to) 과다(ex): 안정을 추구하다 변화를 두려워할 수 있음. 새로움 필요.
토(to) 부족(df): 중심이 흔들리는 시기. 안정과 기초에 집중할 것.
```

#### 요소 5 — 날씨 (weather): 오늘의 날씨가 오행에 미치는 영향

| 코드값 | 날씨 | 오행 | 사주 과다일 때 (보정 약함) | 사주 부족일 때 (보정 강함) |
|--------|------|------|--------------------------|--------------------------|
| fire | 맑음 | 火 | 화기가 더 강해져 과열 주의 | 양기 충만, 활동적인 날 |
| earth | 흐림 | 土 | 더 답답하고 무거운 기운 | 차분하고 안정적인 날 |
| water | 비/눈 | 水 | 수기 과잉, 감정 흘러넘칠 수 있음 | 성찰과 내면 강화의 날 |
| wood | 폭풍 | 木 | 변화가 너무 급격할 수 있음 | 역동적 변화, 새로운 시작 |

---

### 3. 코드 해석 실전 예시

**예시 1: `money_A_su_ex_water`**
```
카테고리: 재물운
등급: A (75-100점, 매우 좋음)
오행: 수(水) 과다 사주
날씨: 비 (수 오행 → 수기가 더 강해짐)

해석: 수기가 이미 강한 사람에게 비까지 더해져 수기 과잉 상태.
     그러나 재물운 자체는 A등급.
     "물이 넘쳐흐르듯 재물이 들어오나, 방향을 잘 잡아야 한다"는 뉘앙스.
```

**예시 2: `love_C_hwa_df_fire`**
```
카테고리: 연애운
등급: C (25-49점, 주의 필요)
오행: 화(火) 부족 사주
날씨: 맑음 (화 오행 → 부족한 화기를 보충)

해석: 평소 감정 표현이 서툰 사람에게 맑은 날이 도움을 줌.
     그래도 연애운 전체는 C등급으로 조심 필요.
     "맑은 날씨가 감정을 녹여주지만, 서두르면 역효과" 뉘앙스.
```

**예시 3: `health_B_to_ex_water`**
```
카테고리: 건강운
등급: B (50-74점, 보통 이상)
오행: 토(土) 과다 사주
날씨: 비 (수 오행 → 토 과다에 수가 들어오면 泥 = 진흙, 정체)

해석: 안정적이지만 느린 사람에게 비가 와 더 무겁고 축축한 느낌.
     건강은 무난하나 활동성이 떨어질 수 있음.
     "몸이 무겁게 느껴질 수 있으나, 충분한 휴식으로 회복" 뉘앙스.
```

---

### 4. 멘트 조각 4가지 (type)

모든 멘트는 4개 조각의 조합으로 완성됩니다:

```
최종 문장 = intro + state + effect + action
```

| type | 역할 | 글자 수 | 끝맺음 | 예시 |
|------|------|---------|--------|------|
| intro | 도입 — 오늘의 전반 분위기 | 15~25자 | 서술형 마침 | "오늘 재물의 흐름이 원활합니다" |
| state | 상태 — 오행/날씨 상황 묘사 | 20~35자 | 연결형으로 이어짐 | "수기가 강한 흐름 속에서" |
| effect | 결과 — 일어날 수 있는 일 | 20~35자 | "~하며" 또는 "~지만"으로 이어짐 | "뜻밖의 기회가 찾아올 수 있으며" |
| action | 행동 — 오늘 취할 자세 | 20~35자 | 마침표로 완결 | "적극적인 행동보다 관찰을 권합니다." |

**조합 예시:**
```
intro:  "오늘 재물의 흐름이 원활합니다."
state:  "강한 수기가 돈의 흐름을 도와주며"
effect: "예상치 못한 수입이 생길 수 있으며"
action: "단, 충동적 소비보다 저축을 우선하세요."

→ 최종: "오늘 재물의 흐름이 원활합니다. 강한 수기가 돈의 흐름을 도와주며 예상치 못한 수입이 생길 수 있으며, 단 충동적 소비보다 저축을 우선하세요."
```

**작성 시 주의사항:**
- 각 조각은 독립적으로 작성 (다른 조각 없이도 의미 파악 가능해야 함)
- state는 오행/날씨를 **직접 언급하지 않아도 됨** (분위기로 표현)
- effect는 단정 표현 금지 → "~할 수 있으며", "~을 경험할 수 있으며"
- action은 항상 **권유형**으로 마무리 ("~하세요", "~을 권합니다", "~이 좋습니다")
- 미신적이거나 지나치게 점술적인 표현 지양 (앱 신뢰도 목적)

---

### 5. CSV 출력 형식

```csv
code,type,text,weight
money_A_su_ex_water,intro,오늘 재물의 흐름이 원활합니다,1
money_A_su_ex_water,state,강한 수기가 돈의 흐름을 자연스럽게 이끌며,1
money_A_su_ex_water,effect,예상치 못한 수입이나 좋은 거래가 성사될 수 있으며,1
money_A_su_ex_water,action,단 충동적인 소비보다 안정적인 저축을 우선하세요,1
```

**규칙:**
- 헤더 행 1줄 고정: `code,type,text,weight`
- text에 쉼표(,) 포함 시 큰따옴표로 감쌀 것: `"텍스트, 내용"`
- weight: 기본 1, 더 선호되는 멘트는 2 (동일 코드+type에 여러 variant 있을 때)

---

### 6. 생성 우선순위 (MVP 순서)

**1순위 (출시 필수 — 1,920행)**
```
tier: B, C  (가장 흔한 점수대)
oheng: mok, hwa, to, geum, su (전체)
strength: ex, df (전체)
weather: fire, earth, water, wood (전체)
category: overall, money, love, work, health, decision (전체)

= 2 × 5 × 2 × 4 × 6 = 480 코드 × 4 type = 1,920행
```

**2순위 (출시 후 — 1,920행 추가)**
```
tier: A, D (극단값) 추가
= 480 코드 × 4 type = 1,920행
```

**3순위 (운영 중 — 품질 강화)**
```
동일 코드에 weight=2 variant 추가 (다양성 확보)
```

---

### 7. ChatGPT에게 요청하는 방법

**한 번에 한 카테고리씩 요청 권장 (응답 품질 유지):**

```
[요청 예시]

아래 조건에 맞는 운세 멘트를 CSV 형식으로 생성해주세요.

카테고리: money (재물운)
등급: B (50~74점, 보통 이상, 온화하게 긍정적인 톤)
오행: su (수, 水 — 물, 지혜, 유연함, 흐름)
강도: ex (과다 — 수기가 사주에 3개 이상, 지나친 유연함으로 방향을 잃을 수 있음)
날씨: water (비 — 수 오행이 더 강해짐, 수기 과잉 상태)

코드: money_B_su_ex_water
필요한 type: intro, state, effect, action 각 1개

출력 형식:
code,type,text,weight
money_B_su_ex_water,intro,...,1
money_B_su_ex_water,state,...,1
money_B_su_ex_water,effect,...,1
money_B_su_ex_water,action,...,1
```

**한 번에 여러 코드 요청 시 (배치 생성):**
```
아래 코드 목록에 해당하는 멘트를 모두 생성해주세요.
각 코드당 intro/state/effect/action 4개씩 생성.

코드 목록:
money_B_su_ex_water
money_B_su_ex_fire
money_B_su_df_water
money_B_su_df_fire
...
```

---

### 8. 전체 코드 목록 (1순위 480개)

tier B+C, 카테고리별 정리:

```
생성 공식:
for tier in [B, C]:
  for oheng in [mok, hwa, to, geum, su]:
    for strength in [ex, df]:
      for weather in [fire, earth, water, wood]:
        for category in [overall, money, love, work, health, decision]:
          code = f"{category}_{tier}_{oheng}_{strength}_{weather}"
```

전체 코드는 요청 시 목록으로 제공 가능.

---

## 검증 방법

1. `flutter analyze` — 오류 0개
2. `dart run build_runner build` — g.dart 재생성
3. Supabase SQL Editor — fortune_ko 테이블 생성 + 샘플 데이터 INSERT
4. 온보딩 생년월일 입력 → 홈 이동 확인
5. 설정에서 언어 변경 → 운세 캐시 초기화 + 재조회 확인
6. 운세 탭 6개 카테고리 카드 + 점수 표시 확인
7. 캐시 동작 확인: 같은 시간대 재실행 → 동일 결과
8. 시간대 변경 시뮬레이션 → am/pm/ev 다른 결과 확인

---

## 파일 의존 순서

```
Phase 1: user_profile → user_profile_repository → user_profile_provider
              → onboarding_screen(수정) + app_router(수정)

Phase 2: AppLanguage(추가) → locale_provider(수정) → settings_screen(수정)

Phase 3: oheng.dart → saju.dart → fortune_result.dart
              → fortune_entity.dart(교체) + fortune_dto.dart(교체)

Phase 4: saju_calculator → ganji_calculator → fortune_score_calculator
              → weather_oheng_mapper

Phase 5: fortune_fragment_dto → fragment_composer
              → fortune_data_source(수정) → mingri_data_source(재작성)
              → fortune_repository(수정) → fortune_repository_impl(재작성)

Phase 6: fortune_provider(신규) → app_exception(추가)

Phase 7: fortune_category_card → fortune_score_gauge
              → fortune_screen(재작성) → home_tab_screen(연동)
```
