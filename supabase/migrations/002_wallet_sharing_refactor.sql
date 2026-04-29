drop table if exists public.recurring_transactions cascade;
drop table if exists public.budgets cascade;
drop table if exists public.transactions cascade;
drop table if exists public.categories cascade;
drop table if exists public.wallet_members cascade;
drop table if exists public.wallets cascade;
drop table if exists public.workspace_members cascade;
drop table if exists public.workspaces cascade;

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) > 0),
  type text not null check (type in ('cash', 'bank', 'saving')),
  balance numeric(18, 2) not null default 0 check (balance >= 0),
  color integer not null default 0,
  icon text not null default 'account_balance_wallet',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz
);

create table if not exists public.wallet_members (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'editor')),
  created_at timestamptz not null default timezone('utc', now()),
  unique (wallet_id, user_id)
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets(id) on delete cascade,
  name text not null check (char_length(trim(name)) > 0),
  type text not null check (type in ('income', 'expense')),
  icon text not null default 'category',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz,
  unique (wallet_id, name, type)
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets(id) on delete restrict,
  target_wallet_id uuid references public.wallets(id) on delete restrict,
  amount numeric(18, 2) not null check (amount > 0),
  type text not null check (type in ('income', 'expense', 'transfer')),
  category_id uuid references public.categories(id) on delete restrict,
  note text,
  image_path text,
  status text not null default 'pending' check (status in ('pending', 'verified', 'review')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz,
  constraint transfer_wallets_must_differ
    check (target_wallet_id is null or target_wallet_id <> wallet_id),
  constraint transfer_requires_target
    check (
      (type = 'transfer' and target_wallet_id is not null)
      or (type <> 'transfer' and target_wallet_id is null)
    ),
  constraint transfer_category_optional
    check (
      (type = 'transfer' and category_id is null)
      or (type <> 'transfer' and category_id is not null)
    )
);

create table if not exists public.budgets (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete cascade,
  amount numeric(18, 2) not null check (amount >= 0),
  period text not null check (period in ('monthly')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz
);

create table if not exists public.recurring_transactions (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets(id) on delete cascade,
  target_wallet_id uuid references public.wallets(id) on delete restrict,
  amount numeric(18, 2) not null check (amount > 0),
  type text not null check (type in ('income', 'expense', 'transfer')),
  category_id uuid references public.categories(id) on delete restrict,
  note text,
  status text not null default 'pending' check (status in ('pending', 'verified', 'review')),
  frequency text not null check (frequency in ('daily', 'weekly', 'monthly')),
  next_run timestamptz not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz
);

create index if not exists idx_wallet_members_user_id
  on public.wallet_members(user_id);
create index if not exists idx_categories_wallet_id
  on public.categories(wallet_id, updated_at desc);
create index if not exists idx_transactions_wallet_id
  on public.transactions(wallet_id, updated_at desc);
create index if not exists idx_transactions_target_wallet_id
  on public.transactions(target_wallet_id, updated_at desc);
create index if not exists idx_budgets_wallet_id
  on public.budgets(wallet_id, updated_at desc);
create index if not exists idx_recurring_transactions_wallet_id
  on public.recurring_transactions(wallet_id, updated_at desc);

drop trigger if exists set_wallets_updated_at on public.wallets;
create trigger set_wallets_updated_at
before update on public.wallets
for each row execute function public.set_updated_at();

drop trigger if exists set_categories_updated_at on public.categories;
create trigger set_categories_updated_at
before update on public.categories
for each row execute function public.set_updated_at();

drop trigger if exists set_transactions_updated_at on public.transactions;
create trigger set_transactions_updated_at
before update on public.transactions
for each row execute function public.set_updated_at();

drop trigger if exists set_budgets_updated_at on public.budgets;
create trigger set_budgets_updated_at
before update on public.budgets
for each row execute function public.set_updated_at();

drop trigger if exists set_recurring_transactions_updated_at on public.recurring_transactions;
create trigger set_recurring_transactions_updated_at
before update on public.recurring_transactions
for each row execute function public.set_updated_at();

create or replace function public.is_wallet_member(target_wallet_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.wallet_members wm
    where wm.wallet_id = target_wallet_id
      and wm.user_id = auth.uid()
  );
$$;

create or replace function public.add_wallet_owner_membership()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.wallet_members (wallet_id, user_id, role)
  values (new.id, new.owner_id, 'owner')
  on conflict (wallet_id, user_id) do update set role = excluded.role;
  return new;
end;
$$;

drop trigger if exists create_wallet_owner_membership on public.wallets;
create trigger create_wallet_owner_membership
after insert on public.wallets
for each row execute function public.add_wallet_owner_membership();

create or replace function public.invite_user_to_wallet(
  target_wallet_id uuid,
  member_email text,
  member_role text default 'editor'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  invited_user_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if member_role not in ('owner', 'editor') then
    raise exception 'Invalid role';
  end if;

  if not exists (
    select 1
    from public.wallet_members wm
    where wm.wallet_id = target_wallet_id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  ) then
    raise exception 'Only wallet owners can invite members';
  end if;

  select id
    into invited_user_id
  from auth.users
  where lower(email) = lower(trim(member_email))
  limit 1;

  if invited_user_id is null then
    raise exception 'User with this email was not found';
  end if;

  insert into public.wallet_members (wallet_id, user_id, role)
  values (target_wallet_id, invited_user_id, member_role)
  on conflict (wallet_id, user_id) do update set role = excluded.role;
end;
$$;

grant execute on function public.invite_user_to_wallet(uuid, text, text) to authenticated;

alter table public.wallets enable row level security;
alter table public.wallet_members enable row level security;
alter table public.categories enable row level security;
alter table public.transactions enable row level security;
alter table public.budgets enable row level security;
alter table public.recurring_transactions enable row level security;

drop policy if exists wallets_select_members on public.wallets;
create policy wallets_select_members
on public.wallets
for select
using (public.is_wallet_member(id));

drop policy if exists wallets_insert_owner on public.wallets;
create policy wallets_insert_owner
on public.wallets
for insert
with check (coalesce(owner_id, auth.uid()) = auth.uid());

drop policy if exists wallets_update_members on public.wallets;
create policy wallets_update_members
on public.wallets
for update
using (public.is_wallet_member(id))
with check (public.is_wallet_member(id));

drop policy if exists wallets_delete_owner on public.wallets;
create policy wallets_delete_owner
on public.wallets
for delete
using (
  exists (
    select 1
    from public.wallet_members wm
    where wm.wallet_id = wallets.id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  )
);

drop policy if exists wallet_members_select_members on public.wallet_members;
create policy wallet_members_select_members
on public.wallet_members
for select
using (public.is_wallet_member(wallet_id));

drop policy if exists wallet_members_insert_owner on public.wallet_members;
create policy wallet_members_insert_owner
on public.wallet_members
for insert
with check (
  exists (
    select 1
    from public.wallet_members wm
    where wm.wallet_id = wallet_members.wallet_id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  )
);

drop policy if exists wallet_members_update_owner on public.wallet_members;
create policy wallet_members_update_owner
on public.wallet_members
for update
using (
  exists (
    select 1
    from public.wallet_members wm
    where wm.wallet_id = wallet_members.wallet_id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  )
)
with check (
  exists (
    select 1
    from public.wallet_members wm
    where wm.wallet_id = wallet_members.wallet_id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  )
);

drop policy if exists wallet_members_delete_owner on public.wallet_members;
create policy wallet_members_delete_owner
on public.wallet_members
for delete
using (
  exists (
    select 1
    from public.wallet_members wm
    where wm.wallet_id = wallet_members.wallet_id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  )
);

drop policy if exists categories_all_members on public.categories;
create policy categories_all_members
on public.categories
for all
using (public.is_wallet_member(wallet_id))
with check (public.is_wallet_member(wallet_id));

drop policy if exists transactions_all_members on public.transactions;
create policy transactions_all_members
on public.transactions
for all
using (
  public.is_wallet_member(wallet_id)
  or (target_wallet_id is not null and public.is_wallet_member(target_wallet_id))
)
with check (
  public.is_wallet_member(wallet_id)
  and (target_wallet_id is null or public.is_wallet_member(target_wallet_id))
);

drop policy if exists budgets_all_members on public.budgets;
create policy budgets_all_members
on public.budgets
for all
using (public.is_wallet_member(wallet_id))
with check (public.is_wallet_member(wallet_id));

drop policy if exists recurring_transactions_all_members on public.recurring_transactions;
create policy recurring_transactions_all_members
on public.recurring_transactions
for all
using (
  public.is_wallet_member(wallet_id)
  or (target_wallet_id is not null and public.is_wallet_member(target_wallet_id))
)
with check (
  public.is_wallet_member(wallet_id)
  and (target_wallet_id is null or public.is_wallet_member(target_wallet_id))
);

alter publication supabase_realtime add table public.wallets;
alter publication supabase_realtime add table public.wallet_members;
alter publication supabase_realtime add table public.categories;
alter publication supabase_realtime add table public.transactions;
alter publication supabase_realtime add table public.budgets;
