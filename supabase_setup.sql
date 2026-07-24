-- ============================================================
-- 영양제 알람 - Supabase 데이터베이스 설정
-- Supabase 대시보드 → SQL Editor → 여기 내용 전체 붙여넣기 → Run
-- ============================================================

-- 사용자별 데이터 한 줄로 저장 (앱의 상태 전체를 JSON으로)
create table if not exists public.user_data (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- 잠금 켜기: 로그인한 사용자는 '자기 데이터'만 읽고 쓸 수 있음
alter table public.user_data enable row level security;

drop policy if exists "본인 데이터 조회" on public.user_data;
create policy "본인 데이터 조회" on public.user_data
  for select using (auth.uid() = user_id);

drop policy if exists "본인 데이터 추가" on public.user_data;
create policy "본인 데이터 추가" on public.user_data
  for insert with check (auth.uid() = user_id);

drop policy if exists "본인 데이터 수정" on public.user_data;
create policy "본인 데이터 수정" on public.user_data
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
