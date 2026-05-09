create table if not exists public.proof_records (
  id text primary key,
  event_id text not null,
  user_id text not null,
  mission_id text not null,
  proof_type text not null,
  proof_timestamp timestamptz not null,
  location text not null,
  xp_earned integer not null,
  validator text not null,
  status text not null,
  evidence_label text not null,
  storage jsonb not null,
  media_storage jsonb,
  badge_id text,
  created_at timestamptz not null default now()
);

create index if not exists proof_records_user_id_idx on public.proof_records (user_id);
create index if not exists proof_records_event_id_idx on public.proof_records (event_id);
create index if not exists proof_records_mission_id_idx on public.proof_records (mission_id);
create index if not exists proof_records_created_at_idx on public.proof_records (created_at desc);

alter table public.proof_records enable row level security;

create policy "Public can read proof receipts"
  on public.proof_records
  for select
  using (true);
