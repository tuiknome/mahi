-- Split · Supabase setup
-- Paste this whole file into Supabase → SQL Editor → New query, then click Run.
-- Safe to run more than once.

-- 1) One row per saved document: "profile" (settings, supplements, tools, saved foods)
--    and "day-YYYY-MM-DD" (that day's meals, sessions, recovery, plans).
create table if not exists public.user_docs (
  user_id    uuid        not null references auth.users(id) on delete cascade,
  doc_id     text        not null,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, doc_id)
);

-- 2) Row Level Security: each signed-in user can only see and change their own rows.
alter table public.user_docs enable row level security;

drop policy if exists "Read own docs"   on public.user_docs;
drop policy if exists "Insert own docs" on public.user_docs;
drop policy if exists "Update own docs" on public.user_docs;
drop policy if exists "Delete own docs" on public.user_docs;

create policy "Read own docs"   on public.user_docs for select to authenticated using ((select auth.uid()) = user_id);
create policy "Insert own docs" on public.user_docs for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Update own docs" on public.user_docs for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Delete own docs" on public.user_docs for delete to authenticated using ((select auth.uid()) = user_id);

-- 3) Storage for exercise / drill videos.
--    Files are saved under <user id>/<random name>.mp4. Users can only upload or delete in their own folder.
--    The bucket is public-read so videos play without extra sign-in steps; file names are random and unlisted.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('exercise-videos', 'exercise-videos', true, 52428800, array['video/mp4','video/webm','video/quicktime'])
on conflict (id) do update set public = true, file_size_limit = 52428800, allowed_mime_types = array['video/mp4','video/webm','video/quicktime'];

drop policy if exists "Upload own videos" on storage.objects;
drop policy if exists "Delete own videos" on storage.objects;

create policy "Upload own videos" on storage.objects for insert to authenticated
  with check (bucket_id = 'exercise-videos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "Delete own videos" on storage.objects for delete to authenticated
  using (bucket_id = 'exercise-videos' and (storage.foldername(name))[1] = (select auth.uid())::text);
