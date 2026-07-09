-- transactions 表增加 user_id，并启用 RLS（与 profiles 一致的用户隔离策略）
-- 在 Supabase Dashboard → SQL Editor 中执行
-- https://supabase.com/dashboard/project/uqznnzkugvhsrlcudrbj/sql/new

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

-- 验证（应 rls_enabled=true, policy_count>=4）
select
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  (select count(*) from pg_policies p where p.tablename = c.relname) as policy_count
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relname = 'transactions';
