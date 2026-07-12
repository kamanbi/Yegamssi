import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

type Provider = 'kma' | 'airKorea' | 'openWeather' | 'airNow';

const corsHeaders = {
  'access-control-allow-headers': 'authorization, apikey, content-type',
  'access-control-allow-methods': 'GET, OPTIONS',
  'access-control-allow-origin': '*',
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

serve(async (request) => {
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
  if (!config.allowedPaths.has(path)) {
    return json(400, { error: 'unsupported_provider_path' });
  }

  const providerKey = Deno.env.get(config.secretName);
  if (!providerKey) {
    return json(503, { error: 'provider_not_configured' });
  }

  const upstreamUrl = new URL(`${config.baseUrl}${path}`);
  for (const [name, value] of requestUrl.searchParams) {
    if (name !== 'provider' && name !== 'path' && name !== config.keyName) {
      upstreamUrl.searchParams.append(name, value);
    }
  }
  upstreamUrl.searchParams.set(config.keyName, providerKey);

  const upstreamResponse = await fetch(upstreamUrl, {
    headers: provider === 'openWeather' ? { accept: 'application/json' } : undefined,
  });
  const contentType = upstreamResponse.headers.get('content-type') ?? 'application/json';
  const body = await upstreamResponse.text();
  return new Response(body, {
    status: upstreamResponse.status,
    headers: { ...corsHeaders, 'content-type': contentType },
  });
});
