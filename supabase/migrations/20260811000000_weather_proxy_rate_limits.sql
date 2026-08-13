create table if not exists public.weather_proxy_rate_limit_buckets (
  bucket_key text primary key,
  window_started_at timestamptz not null,
  request_count integer not null,
  updated_at timestamptz not null default now()
);

alter table public.weather_proxy_rate_limit_buckets enable row level security;

create or replace function public.consume_weather_proxy_rate_limit(
  p_bucket_key text,
  p_window_seconds integer,
  p_request_limit integer
)
returns table (allowed boolean, retry_after_seconds integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  current_window timestamptz;
  next_count integer;
begin
  if p_window_seconds <= 0 or p_request_limit <= 0 then
    raise exception 'invalid rate limit configuration';
  end if;

  current_window := to_timestamp(
    floor(extract(epoch from clock_timestamp()) / p_window_seconds) * p_window_seconds
  );

  perform pg_advisory_xact_lock(hashtextextended(p_bucket_key, 0));

  insert into public.weather_proxy_rate_limit_buckets (
    bucket_key,
    window_started_at,
    request_count,
    updated_at
  ) values (
    p_bucket_key,
    current_window,
    1,
    clock_timestamp()
  )
  on conflict (bucket_key) do update
    set window_started_at = case
          when weather_proxy_rate_limit_buckets.window_started_at = current_window
            then weather_proxy_rate_limit_buckets.window_started_at
          else current_window
        end,
        request_count = case
          when weather_proxy_rate_limit_buckets.window_started_at = current_window
            then weather_proxy_rate_limit_buckets.request_count + 1
          else 1
        end,
        updated_at = clock_timestamp()
  returning request_count into next_count;

  return query select
    next_count <= p_request_limit,
    greatest(
      1,
      ceil(extract(epoch from current_window + make_interval(secs => p_window_seconds) - clock_timestamp()))::integer
    );
end;
$$;

revoke all on function public.consume_weather_proxy_rate_limit(text, integer, integer)
  from public, anon, authenticated;
grant execute on function public.consume_weather_proxy_rate_limit(text, integer, integer)
  to service_role;

create index if not exists weather_proxy_rate_limit_updated_at_idx
  on public.weather_proxy_rate_limit_buckets (updated_at);
