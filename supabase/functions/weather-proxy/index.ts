import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';

// Supabase Edge Runtime global. Not always present (e.g. local `supabase functions serve`).
// deno-lint-ignore no-explicit-any
declare const EdgeRuntime: { waitUntil: (promise: Promise<unknown>) => void } | undefined;

type Provider = 'kma' | 'airKorea' | 'openWeather' | 'airNow';

const corsHeaders = {
  'access-control-allow-headers': 'authorization, apikey, content-type',
  'access-control-allow-methods': 'GET, OPTIONS',
  'access-control-allow-origin': '*',
  'access-control-expose-headers':
    'x-cache, x-cache-layer, x-cache-key, x-cache-age, x-cache-ttl, x-cache-error',
};

const providerConfig: Record<Provider, {
  baseUrl: string;
  keyName: string;
  secretName: string;
  allowedPaths: ReadonlySet<string>;
}> = {
  kma: {
    baseUrl: 'https://apihub.kma.go.kr',
    keyName: 'authKey',
    secretName: 'KMA_API_KEY',
    allowedPaths: new Set([
      '/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtNcst',
      '/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtFcst',
      '/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst',
      '/api/typ02/openApi/MidFcstInfoService/getMidLandFcst',
      '/api/typ01/url/fct_afs_wc.php',
    ]),
  },
  airKorea: {
    baseUrl: 'https://apis.data.go.kr',
    keyName: 'serviceKey',
    secretName: 'AIRKOREA_API_KEY',
    allowedPaths: new Set([
      '/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty',
      '/B552584/MsrstnInfoInqireSvc/getMsrstnList',
      '/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty',
    ]),
  },
  openWeather: {
    baseUrl: 'https://api.openweathermap.org/data/2.5',
    keyName: 'appid',
    secretName: 'OPENWEATHER_API_KEY',
    allowedPaths: new Set(['/weather', '/forecast', '/air_pollution']),
  },
  airNow: {
    baseUrl: 'https://www.airnowapi.org',
    keyName: 'API_KEY',
    secretName: 'AIRNOW_API_KEY',
    allowedPaths: new Set(['/aq/observation/latLong/current/']),
  },
};

// ---------------------------------------------------------------------------
// §3.4 TTL 상수 테이블 (초). 표에 없는 provider:path 는 캐시하지 않는다 (BYPASS, skip=E5).
// ---------------------------------------------------------------------------
const TTL_SECONDS: Record<string, number> = {
  'kma:/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtNcst': 3900,
  'kma:/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtFcst': 3900,
  'kma:/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst': 11400,
  'kma:/api/typ02/openApi/MidFcstInfoService/getMidLandFcst': 90000,
  'kma:/api/typ01/url/fct_afs_wc.php': 90000,
  'airKorea:/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty': 600,
  'airKorea:/B552584/MsrstnInfoInqireSvc/getMsrstnList': 86400,
  'airKorea:/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty': 600,
  'openWeather:/weather': 2100,
  'openWeather:/forecast': 3600,
  'openWeather:/air_pollution': 3600,
  'airNow:/aq/observation/latLong/current/': 1800,
};

// ---------------------------------------------------------------------------
// §2 캐시 키 정규화
// ---------------------------------------------------------------------------
const CONTROL_PARAMS = new Set(['provider', 'path', 'nocache']);

type SnapRule = { step: number; decimals: number };

// §2.3, §2.4 — kma/airKorea 는 정규화 없음(엔트리 없음 = 원값 그대로 사용).
const SNAP_CONFIG: Partial<Record<Provider, Record<string, Record<string, SnapRule>>>> = {
  openWeather: {
    '/weather': { lat: { step: 0.1, decimals: 1 }, lon: { step: 0.1, decimals: 1 } },
    '/forecast': { lat: { step: 0.1, decimals: 1 }, lon: { step: 0.1, decimals: 1 } },
    '/air_pollution': { lat: { step: 0.25, decimals: 2 }, lon: { step: 0.25, decimals: 2 } },
  },
  airNow: {
    '/aq/observation/latLong/current/': {
      latitude: { step: 0.1, decimals: 1 },
      longitude: { step: 0.1, decimals: 1 },
    },
  },
};

function snap(raw: string, step: number, decimals: number): string {
  const v = Number(raw);
  if (!Number.isFinite(v)) return raw; // 파싱 실패 시 원본 유지
  let snapped = Math.round(v / step) * step;
  if (Object.is(snapped, -0)) snapped = 0; // '-0.0' 문자열 방지
  return snapped.toFixed(decimals);
}

function normalizeParam(provider: Provider, path: string, name: string, value: string): string {
  const rule = SNAP_CONFIG[provider]?.[path]?.[name];
  if (!rule) return value;
  return snap(value, rule.step, rule.decimals);
}

function canonicalize(
  provider: Provider,
  path: string,
  sp: URLSearchParams,
): { pairs: [string, string][]; query: string } {
  const keyName = providerConfig[provider].keyName;
  const pairs: [string, string][] = [];
  for (const [name, value] of sp) {
    if (CONTROL_PARAMS.has(name) || name === keyName) continue;
    pairs.push([name, normalizeParam(provider, path, name, value)]);
  }
  pairs.sort((a, b) => {
    if (a[0] === b[0]) return a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0;
    return a[0] < b[0] ? -1 : 1;
  });
  const query = pairs.map(([n, v]) => `${encodeURIComponent(n)}=${encodeURIComponent(v)}`).join('&');
  return { pairs, query };
}

async function sha256Hex(input: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(input));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, '0')).join('');
}

function byteLength(s: string): number {
  return new TextEncoder().encode(s).length;
}

// ---------------------------------------------------------------------------
// §4 캐시 제외 조건 (애플리케이션 계층 성공 판정 포함)
// ---------------------------------------------------------------------------
function determineSkipReason(
  provider: Provider,
  path: string,
  status: number,
  body: string,
): string | null {
  if (status !== 200) return 'E1'; // 200 만 캐시
  const bytes = byteLength(body);
  if (bytes > 1_048_576) return 'E3';
  if (body.trim().length === 0) return 'E4';

  try {
    // kma/airKorea 공통: XML/HTML 오류 엔벨로프 차단 (E6). fct_afs_wc.php 분기보다
    // 먼저 실행해야 한다 — 그 분기는 plain text 전용 판정이라 HTML 오류 본문도
    // "데이터 라인 있음"으로 오판해 통과시킨 적이 있었다(검증 리포트 F-1).
    if ((provider === 'kma' || provider === 'airKorea') && body.trimStart().startsWith('<')) {
      return 'E6';
    }

    if (provider === 'kma' && path === '/api/typ01/url/fct_afs_wc.php') {
      // plain text — kma_data_source.dart:_parseTaWcText와 동일 기준(토큰 8개 이상인
      // 데이터 라인이 1줄이라도 있어야 함)으로 판정해 파서와 캐시 조건을 일치시킨다.
      const hasDataLine = body.split('\n').some((line) => {
        const t = line.trim();
        if (t.length === 0 || t.startsWith('#')) return false;
        return t.split(/\s+/).length >= 8;
      });
      return hasDataLine ? null : 'E8';
    }

    if (provider === 'kma' || provider === 'airKorea') {
      const parsed = JSON.parse(body);
      const resultCode = parsed?.response?.header?.resultCode;
      return resultCode === '00' ? null : 'E7';
    }

    if (provider === 'openWeather') {
      const parsed = JSON.parse(body);
      if (parsed && Object.prototype.hasOwnProperty.call(parsed, 'cod') && Number(parsed.cod) !== 200) {
        return 'E9';
      }
      return null;
    }

    if (provider === 'airNow') {
      const parsed = JSON.parse(body);
      return Array.isArray(parsed) && parsed.length > 0 ? null : 'E10';
    }

    return null;
  } catch {
    return 'E11';
  }
}

// ---------------------------------------------------------------------------
// L1 인메모리 캐시 (§1.6)
// ---------------------------------------------------------------------------
interface CacheEntry {
  status: number;
  contentType: string;
  body: string;
  byteSize: number;
  storedAt: number; // epoch ms
  expiresAt: number; // epoch ms
}

const L1_MAX_ENTRIES = 150;
const L1_MAX_TOTAL_BYTES = 8 * 1024 * 1024;
const L1_MAX_ENTRY_BYTES = 512 * 1024;

const l1Cache = new Map<string, CacheEntry>();
let l1TotalBytes = 0;

function l1Get(key: string): CacheEntry | null {
  const entry = l1Cache.get(key);
  if (!entry) return null;
  if (Date.now() >= entry.expiresAt) {
    l1Cache.delete(key);
    l1TotalBytes -= entry.byteSize;
    return null;
  }
  return entry;
}

function l1Set(key: string, entry: CacheEntry): void {
  if (entry.byteSize > L1_MAX_ENTRY_BYTES) return; // L2에만 저장, L1은 스킵
  const existing = l1Cache.get(key);
  if (existing) {
    l1TotalBytes -= existing.byteSize;
    l1Cache.delete(key);
  }
  l1Cache.set(key, entry);
  l1TotalBytes += entry.byteSize;
  // FIFO 축출 (Map 은 삽입 순서를 보존한다)
  while ((l1Cache.size > L1_MAX_ENTRIES || l1TotalBytes > L1_MAX_TOTAL_BYTES) && l1Cache.size > 0) {
    const oldestKey = l1Cache.keys().next().value as string;
    const oldest = l1Cache.get(oldestKey)!;
    l1Cache.delete(oldestKey);
    l1TotalBytes -= oldest.byteSize;
  }
}

// single-flight: 동일 캐시 키에 대한 동시 upstream 호출을 1건으로 합친다.
interface UpstreamResult {
  status: number;
  contentType: string;
  body: string;
  ms: number;
}

const inflight = new Map<string, Promise<UpstreamResult>>();

async function singleFlight(key: string, fn: () => Promise<UpstreamResult>): Promise<UpstreamResult> {
  const existing = inflight.get(key);
  if (existing) return existing;
  const promise = fn().finally(() => inflight.delete(key));
  inflight.set(key, promise);
  return promise;
}

// ---------------------------------------------------------------------------
// L2 Postgres 캐시 (§1.5)
// ---------------------------------------------------------------------------
const supabaseUrl = Deno.env.get('SUPABASE_URL');
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
const supabase = supabaseUrl && supabaseServiceKey
  ? createClient(supabaseUrl, supabaseServiceKey, { auth: { persistSession: false } })
  : null;

interface L2Row {
  status: number;
  content_type: string;
  body: string;
  byte_size: number;
  stored_at: string;
  expires_at: string;
}

const L2_SELECT_TIMEOUT_MS = 250;

async function l2Select(cacheKey: string): Promise<L2Row | null> {
  if (!supabase) throw new Error('l2_unavailable');
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), L2_SELECT_TIMEOUT_MS);
  try {
    const { data, error } = await supabase
      .from('weather_proxy_cache')
      .select('status, content_type, body, byte_size, stored_at, expires_at')
      .eq('cache_key', cacheKey)
      .abortSignal(controller.signal)
      .maybeSingle();
    if (error) throw error;
    return (data as L2Row | null) ?? null;
  } catch (err) {
    if (controller.signal.aborted) throw new Error('l2_timeout');
    throw new Error('l2_unavailable');
  } finally {
    clearTimeout(timer);
  }
}

async function l2Upsert(
  cacheKey: string,
  provider: Provider,
  path: string,
  entry: CacheEntry,
): Promise<void> {
  if (!supabase) return;
  await supabase.from('weather_proxy_cache').upsert(
    {
      cache_key: cacheKey,
      provider,
      path,
      status: entry.status,
      content_type: entry.contentType,
      body: entry.body,
      byte_size: entry.byteSize,
      stored_at: new Date(entry.storedAt).toISOString(),
      expires_at: new Date(entry.expiresAt).toISOString(),
    },
    { onConflict: 'cache_key' },
  );
}

// §1.5 pg_cron 폴백 — 200회 중 1회, 만료 1시간 이상 지난 행 정리
async function l2PurgeFallback(): Promise<void> {
  if (!supabase) return;
  const cutoff = new Date(Date.now() - 3600_000).toISOString();
  await supabase.from('weather_proxy_cache').delete().lt('expires_at', cutoff);
}

function runBackground(promise: Promise<unknown>): void {
  const settled = promise.catch(() => {
    // 캐시 쓰기 실패는 삼킨다 — 요청 실패로 이어지면 안 된다.
  });
  if (typeof EdgeRuntime !== 'undefined' && EdgeRuntime && 'waitUntil' in EdgeRuntime) {
    EdgeRuntime.waitUntil(settled);
  }
  // waitUntil 이 없는 로컬 환경(`supabase functions serve`)에서는 fire-and-forget.
  // 이미 시작된 promise 이므로 await 하지 않아도 실행은 계속된다.
}

// ---------------------------------------------------------------------------
// 유틸
// ---------------------------------------------------------------------------
function json(status: number, body: Record<string, string>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'content-type': 'application/json' },
  });
}

function resolveProvider(value: string | null): Provider | null {
  if (value === 'kma' || value === 'airKorea' || value === 'openWeather' || value === 'airNow') {
    return value;
  }
  return null;
}

function logLine(fields: Record<string, unknown>): void {
  console.log(JSON.stringify({ evt: 'wxproxy', ...fields }));
}

serve(async (request) => {
  const startTime = Date.now();

  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  if (request.method !== 'GET') {
    return json(405, { error: 'method_not_allowed' });
  }

  const requestUrl = new URL(request.url);
  const provider = resolveProvider(requestUrl.searchParams.get('provider'));
  const path = requestUrl.searchParams.get('path');
  if (!provider || !path) {
    return json(400, { error: 'invalid_proxy_request' });
  }

  const config = providerConfig[provider];
  // 보안 검증(허용목록) — 캐시 조회보다 반드시 먼저 수행한다.
  if (!config.allowedPaths.has(path)) {
    return json(400, { error: 'unsupported_provider_path' });
  }

  const providerKey = Deno.env.get(config.secretName);
  if (!providerKey) {
    return json(503, { error: 'provider_not_configured' });
  }

  // ---- 여기부터 캐시 계층. 보안 검증은 위에서 이미 끝났다. ----

  const nocache = requestUrl.searchParams.get('nocache') === '1';
  const canonical = canonicalize(provider, path, requestUrl.searchParams);
  const cacheKey = await sha256Hex(`${provider}\n${path}\n${canonical.query}`);
  const cacheKeyShort = cacheKey.slice(0, 16);
  const ttlSeconds = TTL_SECONDS[`${provider}:${path}`];

  // §2.3 근거: 좌표 스냅은 캐시 키뿐 아니라 upstream 요청 자체에도 반영해야 결정적 응답이 된다.
  const upstreamUrl = new URL(`${config.baseUrl}${path}`);
  for (const [name, value] of canonical.pairs) {
    upstreamUrl.searchParams.append(name, value);
  }
  upstreamUrl.searchParams.set(config.keyName, providerKey);

  const callUpstream = async (): Promise<UpstreamResult> => {
    const t0 = Date.now();
    const upstreamResponse = await fetch(upstreamUrl, {
      headers: provider === 'openWeather' ? { accept: 'application/json' } : undefined,
    });
    const contentType = upstreamResponse.headers.get('content-type') ?? 'application/json';
    const body = await upstreamResponse.text();
    return { status: upstreamResponse.status, contentType, body, ms: Date.now() - t0 };
  };

  const respond = (result: UpstreamResult, extraHeaders: Record<string, string>) =>
    new Response(result.body, {
      status: result.status,
      headers: { ...corsHeaders, 'content-type': result.contentType, ...extraHeaders },
    });

  // E2: nocache=1 — 캐시를 완전히 우회한다. 키에서도, upstream 요청에서도 이미 제외되어 있다.
  // single-flight 키는 일반 캐시 키와 분리한다 — 같은 키를 쓰면 검증용 nocache 요청이
  // 동시 도착한 일반 MISS 요청과 하나의 upstream 호출로 합쳐져, "nocache는 매번 실호출"이라는
  // 전제가 깨지고 캐시 절감률 측정이 오염된다(검증 리포트 공백4).
  if (nocache) {
    const result = await singleFlight(`nocache:${cacheKey}`, callUpstream);
    logLine({
      cache: 'BYPASS',
      layer: 'none',
      provider,
      path,
      key: cacheKeyShort,
      ttl_s: ttlSeconds ?? 0,
      age_s: 0,
      upstream_ms: result.ms,
      l2_ms: 0,
      total_ms: Date.now() - startTime,
      status: result.status,
      bytes: byteLength(result.body),
      stored: false,
      skip: 'E2',
    });
    return respond(result, {
      'x-cache': 'BYPASS',
      'x-cache-layer': 'none',
      'x-cache-key': cacheKeyShort,
      'x-cache-age': '0',
      'x-cache-ttl': String(ttlSeconds ?? 0),
    });
  }

  // E5: TTL 화이트리스트에 없는 경로 — 캐시 대상이 아니다.
  if (ttlSeconds === undefined) {
    const result = await singleFlight(cacheKey, callUpstream);
    logLine({
      cache: 'BYPASS',
      layer: 'none',
      provider,
      path,
      key: cacheKeyShort,
      ttl_s: 0,
      age_s: 0,
      upstream_ms: result.ms,
      l2_ms: 0,
      total_ms: Date.now() - startTime,
      status: result.status,
      bytes: byteLength(result.body),
      stored: false,
      skip: 'E5',
    });
    return respond(result, {
      'x-cache': 'BYPASS',
      'x-cache-layer': 'none',
      'x-cache-key': cacheKeyShort,
      'x-cache-age': '0',
      'x-cache-ttl': '0',
    });
  }

  // L1 조회
  const l1Hit = l1Get(cacheKey);
  if (l1Hit) {
    const ageS = Math.floor((Date.now() - l1Hit.storedAt) / 1000);
    logLine({
      cache: 'HIT',
      layer: 'l1',
      provider,
      path,
      key: cacheKeyShort,
      ttl_s: ttlSeconds,
      age_s: ageS,
      upstream_ms: 0,
      l2_ms: 0,
      total_ms: Date.now() - startTime,
      status: l1Hit.status,
      bytes: l1Hit.byteSize,
      stored: false,
      skip: null,
    });
    return respond(
      { status: l1Hit.status, contentType: l1Hit.contentType, body: l1Hit.body, ms: 0 },
      {
        'x-cache': 'HIT',
        'x-cache-layer': 'l1',
        'x-cache-key': cacheKeyShort,
        'x-cache-age': String(ageS),
        'x-cache-ttl': String(ttlSeconds),
      },
    );
  }

  // L2 조회 (250ms 타임아웃, 실패 시 캐시 전체를 우회하고 upstream 그대로 호출)
  let l2Row: L2Row | null = null;
  let l2Error: string | null = null;
  const l2Start = Date.now();
  try {
    l2Row = await l2Select(cacheKey);
  } catch (err) {
    l2Error = err instanceof Error ? err.message : 'l2_unavailable';
  }
  const l2Ms = Date.now() - l2Start;

  if (l2Error) {
    const result = await singleFlight(cacheKey, callUpstream);
    // L2(Postgres)가 죽어도 L1은 순수 인메모리라 정상 동작한다. 여기서 L1에 안 채우면
    // L2 장애가 지속되는 동안 L1도 영원히 비어 히트율이 0%로 떨어져 캐시 도입 전 호출량으로
    // 되돌아간다 — 헤더/로그를 보지 않으면 드러나지 않는 조용한 비용 회귀다(검증 리포트 공백1).
    const skip = determineSkipReason(provider, path, result.status, result.body);
    let stored = false;
    if (!skip) {
      const now = Date.now();
      l1Set(cacheKey, {
        status: result.status,
        contentType: result.contentType,
        body: result.body,
        byteSize: byteLength(result.body),
        storedAt: now,
        expiresAt: now + ttlSeconds * 1000,
      });
      stored = true;
    }
    logLine({
      cache: 'BYPASS',
      layer: 'none',
      provider,
      path,
      key: cacheKeyShort,
      ttl_s: ttlSeconds,
      age_s: 0,
      upstream_ms: result.ms,
      l2_ms: l2Ms,
      total_ms: Date.now() - startTime,
      status: result.status,
      bytes: byteLength(result.body),
      stored,
      skip,
      cache_error: l2Error,
    });
    return respond(result, {
      'x-cache': 'BYPASS',
      'x-cache-layer': 'none',
      'x-cache-key': cacheKeyShort,
      'x-cache-age': '0',
      'x-cache-ttl': String(ttlSeconds),
      'x-cache-error': l2Error,
    });
  }

  if (l2Row && Date.parse(l2Row.expires_at) > Date.now()) {
    const storedAtMs = Date.parse(l2Row.stored_at);
    const expiresAtMs = Date.parse(l2Row.expires_at);
    const ageS = Math.floor((Date.now() - storedAtMs) / 1000);
    l1Set(cacheKey, {
      status: l2Row.status,
      contentType: l2Row.content_type,
      body: l2Row.body,
      byteSize: l2Row.byte_size,
      storedAt: storedAtMs,
      expiresAt: expiresAtMs,
    });
    logLine({
      cache: 'HIT',
      layer: 'l2',
      provider,
      path,
      key: cacheKeyShort,
      ttl_s: ttlSeconds,
      age_s: ageS,
      upstream_ms: 0,
      l2_ms: l2Ms,
      total_ms: Date.now() - startTime,
      status: l2Row.status,
      bytes: l2Row.byte_size,
      stored: false,
      skip: null,
    });
    return respond(
      { status: l2Row.status, contentType: l2Row.content_type, body: l2Row.body, ms: 0 },
      {
        'x-cache': 'HIT',
        'x-cache-layer': 'l2',
        'x-cache-key': cacheKeyShort,
        'x-cache-age': String(ageS),
        'x-cache-ttl': String(ttlSeconds),
      },
    );
  }

  // MISS: upstream 호출 후 적격이면 저장
  const result = await singleFlight(cacheKey, callUpstream);
  const skip = determineSkipReason(provider, path, result.status, result.body);
  let stored = false;

  if (!skip) {
    const now = Date.now();
    const entry: CacheEntry = {
      status: result.status,
      contentType: result.contentType,
      body: result.body,
      byteSize: byteLength(result.body),
      storedAt: now,
      expiresAt: now + ttlSeconds * 1000,
    };
    l1Set(cacheKey, entry);
    stored = true;
    runBackground(l2Upsert(cacheKey, provider, path, entry));
  }

  // §1.5 pg_cron 폴백 — 200회 중 1회 확률로 만료 행 정리
  if (Math.random() < 0.005) {
    runBackground(l2PurgeFallback());
  }

  logLine({
    cache: 'MISS',
    layer: 'none',
    provider,
    path,
    key: cacheKeyShort,
    ttl_s: ttlSeconds,
    age_s: 0,
    upstream_ms: result.ms,
    l2_ms: l2Ms,
    total_ms: Date.now() - startTime,
    status: result.status,
    bytes: byteLength(result.body),
    stored,
    skip,
  });
  return respond(result, {
    'x-cache': 'MISS',
    'x-cache-layer': 'none',
    'x-cache-key': cacheKeyShort,
    'x-cache-age': '0',
    'x-cache-ttl': String(ttlSeconds),
  });
});
