-- Chạy toàn bộ file này trong Supabase: SQL Editor > New query > Run
-- Nếu trước đó bạn đã chạy bản cũ, bỏ dấu -- ở 3 dòng dưới rồi chạy (sẽ xoá dữ liệu cũ):
-- drop table if exists public.attendance cascade;
-- drop table if exists public.profiles cascade;
-- drop function if exists public.handle_new_user() cascade;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  phone text not null default '',
  full_name text not null default '',
  role text not null default 'worker' check (role in ('worker','admin'))
);

create table public.attendance (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  work_date date not null,
  status text not null default 'work' check (status in ('work','leave')),
  check_in timestamptz,
  check_out timestamptz,
  task text not null default '',
  note text not null default '',
  unique (user_id, work_date)
);

-- Tự tạo hồ sơ khi có người đăng ký (tên để trống, người dùng tự đặt sau)
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, phone)
  values (new.id, coalesce(new.raw_user_meta_data->>'phone', ''));
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

create function public.is_admin() returns boolean
language sql security definer set search_path = public stable as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

alter table public.profiles enable row level security;
alter table public.attendance enable row level security;

-- Hồ sơ: mỗi người thấy của mình, admin thấy tất cả. Chỉ được sửa cột họ tên.
create policy "profiles_read" on public.profiles for select
  using (id = auth.uid() or public.is_admin());
revoke update on public.profiles from anon, authenticated;
grant update (full_name) on public.profiles to authenticated;
create policy "profiles_update_own" on public.profiles for update
  using (id = auth.uid()) with check (id = auth.uid());

-- Chấm công: mỗi người chỉ thấy và ghi của mình; admin xem tất cả.
-- Ngày làm việc chỉ được chấm cho hôm nay (giờ Việt Nam); nghỉ phép đăng ký được cho ngày bất kỳ.
create policy "att_read" on public.attendance for select
  using (user_id = auth.uid() or public.is_admin());
create policy "att_insert" on public.attendance for insert
  with check (user_id = auth.uid() and
    (status = 'leave' or work_date = (now() at time zone 'Asia/Ho_Chi_Minh')::date));
create policy "att_update" on public.attendance for update
  using (user_id = auth.uid() and status = 'work')
  with check (user_id = auth.uid() and status = 'work' and
    work_date = (now() at time zone 'Asia/Ho_Chi_Minh')::date);
create policy "att_delete_leave" on public.attendance for delete
  using (user_id = auth.uid() and status = 'leave');

-- Đặt tài khoản admin: đăng ký tài khoản bình thường trước, rồi chạy (thay số điện thoại):
-- update public.profiles set role = 'admin' where phone = '0901234567';
