-- Create diary_entries table
create table public.diary_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  user_email text not null,
  date timestamptz not null default now(),
  title text not null,
  feeling text not null,
  content text not null,
  created_at timestamptz not null default now()
);

-- Enable Row Level Security
alter table public.diary_entries enable row level security;

-- Users can only see their own entries
create policy "Users can view own entries"
  on public.diary_entries for select
  using (auth.uid() = user_id);

-- Users can insert their own entries
create policy "Users can insert own entries"
  on public.diary_entries for insert
  with check (auth.uid() = user_id);

-- Users can delete their own entries
create policy "Users can delete own entries"
  on public.diary_entries for delete
  using (auth.uid() = user_id);
