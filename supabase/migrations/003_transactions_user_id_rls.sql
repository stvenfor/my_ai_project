-- transactions 表增加 user_id，并启用 RLS（与 profiles 一致的用户隔离策略）
-- 在 Supabase Dashboard → SQL Editor 中执行

alter table public.transactions
  add column if not exists user_id uuid references auth.users(id) on delete cascade;

create index if not exists transactions_user_id_idx on public.transactions(user_id);

alter table public.transactions enable row level security;

drop policy if exists "transactions_select_own" on public.transactions;
create policy "transactions_select_own"
  on public.transactions for select
  using (auth.uid() = user_id);

drop policy if exists "transactions_insert_own" on public.transactions;
create policy "transactions_insert_own"
  on public.transactions for insert
  with check (auth.uid() = user_id);

drop policy if exists "transactions_update_own" on public.transactions;
create policy "transactions_update_own"
  on public.transactions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "transactions_delete_own" on public.transactions;
create policy "transactions_delete_own"
  on public.transactions for delete
  using (auth.uid() = user_id);

-- 已有数据 user_id 为空，迁移后仅对新写入数据生效；可按需手动回填：
-- update public.transactions set user_id = '<your-user-uuid>' where user_id is null;
