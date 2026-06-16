-- 为 profiles 增加 phone 字段，并支持手机号 OTP 注册用户
alter table public.profiles add column if not exists phone text unique;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, phone, display_name)
  values (
    new.id,
    new.phone,
    coalesce(
      new.raw_user_meta_data->>'display_name',
      case
        when new.phone is not null then '用户' || right(new.phone, 4)
        when new.email is not null then split_part(new.email, '@', 1)
        else '用户'
      end
    )
  );
  return new;
end;
$$;
