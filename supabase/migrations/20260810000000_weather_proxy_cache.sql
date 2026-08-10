-- weather-proxy L2 캐시 테이블 (.claude/_workspace/01_cache_design.md §1.5)
create table if not exists public.weather_proxy_cache (
  cache_key    text        primary key,
  provider     text        not null,
  path         text        not null,
  status       smallint    not null,
  content_type text        not null,
  body         text        not null,
  byte_size    integer     not null,
  stored_at    timestamptz not null default now(),
  expires_at   timestamptz not null
);

create index if not exists weather_proxy_cache_expires_at_idx
  on public.weather_proxy_cache (expires_at);

alter table public.weather_proxy_cache enable row level security;
-- 정책을 만들지 않는다. service_role만 RLS를 우회해 접근한다.
-- anon/authenticated는 어떤 경로로도 이 테이블을 읽을 수 없다.

-- 만료 행 정리: pg_cron 우선. 익스텐션이 없으면 무시되며,
-- index.ts의 폴백(미스 처리 경로에서 0.5% 확률로 delete 실행)이 대신한다.
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule(
      'weather_proxy_cache_purge',
      '*/15 * * * *',
      $cron$delete from public.weather_proxy_cache where expires_at < now() - interval '1 hour'$cron$
    );
  end if;
end;
$$;
