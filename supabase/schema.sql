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
  chain_anchor jsonb,
  badge_id text,
  created_at timestamptz not null default now()
);

alter table public.proof_records
  add column if not exists chain_anchor jsonb;

create index if not exists proof_records_user_id_idx on public.proof_records (user_id);
create index if not exists proof_records_event_id_idx on public.proof_records (event_id);
create index if not exists proof_records_mission_id_idx on public.proof_records (mission_id);
create index if not exists proof_records_created_at_idx on public.proof_records (created_at desc);

alter table public.proof_records enable row level security;

drop policy if exists "Public can read proof receipts" on public.proof_records;

create policy "Public can read proof receipts"
  on public.proof_records
  for select
  using (true);

create table if not exists public.user_profiles (
  id text primary key,
  privy_user_id text,
  wallet_address text,
  handle text unique not null,
  display_name text not null,
  user_tag text unique not null,
  bio text,
  avatar text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists user_profiles_wallet_address_idx on public.user_profiles (wallet_address);
create index if not exists user_profiles_user_tag_idx on public.user_profiles (user_tag);

alter table public.user_profiles enable row level security;

drop policy if exists "Public can read user profiles" on public.user_profiles;

create policy "Public can read user profiles"
  on public.user_profiles
  for select
  using (true);

create table if not exists public.community_events (
  id text primary key,
  slug text unique not null,
  title text not null,
  description text not null,
  location text not null,
  start_date date not null,
  end_date date not null,
  organizer_id text not null,
  organizer_name text not null,
  category text not null,
  max_attendees integer not null default 100,
  color text not null default 'var(--color-pastel-purple)',
  emoji text not null default '🎟️',
  status text not null default 'published',
  missions jsonb not null default '[]'::jsonb,
  share_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists community_events_slug_idx on public.community_events (slug);
create index if not exists community_events_start_date_idx on public.community_events (start_date);
create index if not exists community_events_status_idx on public.community_events (status);

alter table public.community_events enable row level security;

drop policy if exists "Public can read published events" on public.community_events;

create policy "Public can read published events"
  on public.community_events
  for select
  using (status = 'published');

create table if not exists public.event_registrations (
  id text primary key,
  event_id text not null references public.community_events(id) on delete cascade,
  user_id text not null,
  status text not null default 'registered',
  source text not null default 'web',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(event_id, user_id)
);

create index if not exists event_registrations_event_id_idx on public.event_registrations (event_id);
create index if not exists event_registrations_user_id_idx on public.event_registrations (user_id);

alter table public.event_registrations enable row level security;

drop policy if exists "Public can read event registration counts" on public.event_registrations;

create policy "Public can read event registration counts"
  on public.event_registrations
  for select
  using (true);

create table if not exists public.user_connections (
  id text primary key,
  event_id text references public.community_events(id) on delete set null,
  requester_user_id text not null,
  target_user_id text not null,
  target_user_tag text not null,
  proof_record_id text,
  created_at timestamptz not null default now(),
  unique(event_id, requester_user_id, target_user_id)
);

create index if not exists user_connections_requester_idx on public.user_connections (requester_user_id);
create index if not exists user_connections_target_idx on public.user_connections (target_user_id);
create index if not exists user_connections_event_id_idx on public.user_connections (event_id);

alter table public.user_connections enable row level security;

drop policy if exists "Public can read user connections" on public.user_connections;

create policy "Public can read user connections"
  on public.user_connections
  for select
  using (true);
