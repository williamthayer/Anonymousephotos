create table if not exists public.gallery_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  added_at timestamptz not null default now()
);

create table if not exists public.photos (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  alt_text text not null,
  link_url text,
  image_url text,
  tags text[] not null default '{}',
  storage_path text unique,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);

alter table public.photos add column if not exists link_url text;
alter table public.photos add column if not exists image_url text;
alter table public.photos alter column storage_path drop not null;

alter table public.gallery_admins enable row level security;
alter table public.photos enable row level security;

create or replace function public.is_gallery_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.gallery_admins
    where user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_gallery_admin() from public;
grant execute on function public.is_gallery_admin() to authenticated;
grant select on public.photos to anon, authenticated;
grant insert, update, delete on public.photos to authenticated;

drop policy if exists "Anyone can view gallery metadata" on public.photos;
create policy "Anyone can view gallery metadata"
  on public.photos for select
  to anon, authenticated
  using (true);

drop policy if exists "Gallery admins can add photos" on public.photos;
create policy "Gallery admins can add photos"
  on public.photos for insert
  to authenticated
  with check (public.is_gallery_admin() and created_by = (select auth.uid()));

drop policy if exists "Gallery admins can update photos" on public.photos;
create policy "Gallery admins can update photos"
  on public.photos for update
  to authenticated
  using (public.is_gallery_admin())
  with check (public.is_gallery_admin());

drop policy if exists "Gallery admins can delete photos" on public.photos;
create policy "Gallery admins can delete photos"
  on public.photos for delete
  to authenticated
  using (public.is_gallery_admin());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('gallery', 'gallery', true, 10485760, array['image/jpeg', 'image/png', 'image/webp', 'image/avif'])
on conflict (id) do update set
  public = true,
  file_size_limit = 10485760,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'image/avif'];

drop policy if exists "Anyone can view gallery images" on storage.objects;
create policy "Anyone can view gallery images"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'gallery');

drop policy if exists "Gallery admins can upload images" on storage.objects;
create policy "Gallery admins can upload images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'gallery'
    and public.is_gallery_admin()
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Gallery admins can update images" on storage.objects;
create policy "Gallery admins can update images"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'gallery'
    and public.is_gallery_admin()
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'gallery'
    and public.is_gallery_admin()
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Gallery admins can delete images" on storage.objects;
create policy "Gallery admins can delete images"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'gallery'
    and public.is_gallery_admin()
  );