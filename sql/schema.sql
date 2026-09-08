-- System Design Study App — Schema
-- Run this in Supabase: Project > SQL Editor > New Query > paste > Run

create extension if not exists pgcrypto; -- needed for gen_random_uuid()

-- ============ CONTENT TABLES (read-mostly, same for every device) ============

create table topics (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  difficulty text not null check (difficulty in ('easy','medium','hard')),
  sequence_order int not null,
  summary text not null,
  source_links jsonb not null default '[]',   -- [{ "title": "...", "url": "..." }]
  blog_links jsonb not null default '[]',     -- [{ "company": "...", "title": "...", "url": "..." }]
  created_at timestamptz not null default now()
);

create table problems (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  difficulty text not null check (difficulty in ('easy','medium','hard')),
  related_topic_ids uuid[] not null default '{}',
  hints jsonb not null default '[]',   -- ordered array of strings
  solution text not null,
  created_at timestamptz not null default now()
);

create table flashcards (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('definition','tradeoff')),
  front text not null,
  back text not null,
  difficulty text not null check (difficulty in ('easy','medium','hard')),
  related_topic_id uuid references topics(id) on delete set null,
  related_problem_id uuid references problems(id) on delete set null,
  created_at timestamptz not null default now()
);

create table estimation_drills (
  id uuid primary key default gen_random_uuid(),
  scenario text not null,
  answer_guidance text not null,
  difficulty text not null check (difficulty in ('easy','medium','hard')),
  created_at timestamptz not null default now()
);

-- ============ PERSONAL DATA TABLES (per user, synced across devices) ============

create table user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  difficulty_filter text not null default 'easy' check (difficulty_filter in ('easy','medium','hard')),
  timer_enabled boolean not null default false,
  timer_default_seconds int not null default 1200,
  updated_at timestamptz not null default now()
);

create table problem_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  problem_id uuid not null references problems(id) on delete cascade,
  my_attempt_text text default '',
  hints_revealed_count int not null default 0,
  solution_revealed boolean not null default false,
  struggled boolean not null default false,
  timer_used_seconds int,
  attempted_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, problem_id)
);

create table flashcard_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  flashcard_id uuid not null references flashcards(id) on delete cascade,
  last_reviewed_at timestamptz,
  next_due_at timestamptz not null default now(),
  ease_factor numeric not null default 2.5,
  struggled boolean not null default false,
  unique (user_id, flashcard_id)
);

create table estimation_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  drill_id uuid not null references estimation_drills(id) on delete cascade,
  my_estimate text not null,
  attempted_at timestamptz not null default now()
);

-- ============ ROW LEVEL SECURITY ============

alter table topics enable row level security;
alter table problems enable row level security;
alter table flashcards enable row level security;
alter table estimation_drills enable row level security;
alter table user_settings enable row level security;
alter table problem_attempts enable row level security;
alter table flashcard_reviews enable row level security;
alter table estimation_attempts enable row level security;

-- Content tables: any logged-in user can read. No one writes from the client (you'll add content via the SQL editor/table view).
create policy "content readable by logged-in users" on topics for select using (auth.role() = 'authenticated');
create policy "content readable by logged-in users" on problems for select using (auth.role() = 'authenticated');
create policy "content readable by logged-in users" on flashcards for select using (auth.role() = 'authenticated');
create policy "content readable by logged-in users" on estimation_drills for select using (auth.role() = 'authenticated');

-- Personal tables: a user can only ever see/write their own rows.
create policy "own settings" on user_settings for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own attempts" on problem_attempts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own reviews" on flashcard_reviews for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own estimation attempts" on estimation_attempts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
