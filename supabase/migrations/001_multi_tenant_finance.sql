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

create table if not exists public.workspaces (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) > 0),
  owner_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz
);

create table if not exists public.workspace_members (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'editor')),
  created_at timestamptz not null default timezone('utc', now()),
  unique (workspace_id, user_id)
);

create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  name text not null check (char_length(trim(name)) > 0),
  type text not null check (type in ('cash', 'bank', 'saving')),
  balance numeric(18, 2) not null default 0 check (balance >= 0),
  color integer not null default 0,
  icon text not null default 'wallet',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  name text not null check (char_length(trim(name)) > 0),
  type text not null check (type in ('income', 'expense')),
  icon text not null default 'category',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz,
  unique (workspace_id, name, type)
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
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
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete cascade,
  amount numeric(18, 2) not null check (amount >= 0),
  period text not null check (period in ('monthly')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz
);

create table if not exists public.recurring_transactions (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  amount numeric(18, 2) not null check (amount > 0),
  type text not null check (type in ('income', 'expense', 'transfer')),
  wallet_id uuid references public.wallets(id) on delete restrict,
  target_wallet_id uuid references public.wallets(id) on delete restrict,
  category_id uuid references public.categories(id) on delete restrict,
  note text,
  status text not null default 'pending' check (status in ('pending', 'verified', 'review')),
  frequency text not null check (frequency in ('daily', 'weekly', 'monthly')),
  next_run timestamptz not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz,
  constraint recurring_transfer_requires_target
    check (
      (type = 'transfer' and target_wallet_id is not null)
      or (type <> 'transfer' and target_wallet_id is null)
    )
);

create index if not exists idx_workspace_members_user_id
  on public.workspace_members(user_id);
create index if not exists idx_wallets_workspace_id
  on public.wallets(workspace_id, updated_at desc);
create index if not exists idx_categories_workspace_id
  on public.categories(workspace_id, updated_at desc);
create index if not exists idx_transactions_workspace_id
  on public.transactions(workspace_id, updated_at desc);
create index if not exists idx_budgets_workspace_id
  on public.budgets(workspace_id, updated_at desc);
create index if not exists idx_recurring_transactions_workspace_id
  on public.recurring_transactions(workspace_id, updated_at desc);

drop trigger if exists set_workspaces_updated_at on public.workspaces;
create trigger set_workspaces_updated_at
before update on public.workspaces
for each row execute function public.set_updated_at();

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

create or replace function public.is_workspace_member(target_workspace_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = target_workspace_id
      and wm.user_id = auth.uid()
  );
$$;

create or replace function public.create_workspace(name text)
returns public.workspaces
language plpgsql
security definer
set search_path = public
as $$
declare
  new_workspace public.workspaces;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  insert into public.workspaces (name, owner_id)
  values (trim(name), auth.uid())
  returning * into new_workspace;

  insert into public.workspace_members (workspace_id, user_id, role)
  values (new_workspace.id, auth.uid(), 'owner')
  on conflict (workspace_id, user_id) do update set role = excluded.role;

  return new_workspace;
end;
$$;

alter table public.workspaces enable row level security;
alter table public.workspace_members enable row level security;
alter table public.wallets enable row level security;
alter table public.categories enable row level security;
alter table public.transactions enable row level security;
alter table public.budgets enable row level security;
alter table public.recurring_transactions enable row level security;

drop policy if exists "workspaces_select_members" on public.workspaces;
create policy "workspaces_select_members"
on public.workspaces
for select
using (
  owner_id = auth.uid()
  or public.is_workspace_member(id)
);

drop policy if exists "workspaces_insert_owner" on public.workspaces;
create policy "workspaces_insert_owner"
on public.workspaces
for insert
with check (owner_id = auth.uid());

drop policy if exists "workspaces_update_owner_editor" on public.workspaces;
create policy "workspaces_update_owner_editor"
on public.workspaces
for update
using (public.is_workspace_member(id))
with check (public.is_workspace_member(id));

drop policy if exists "workspace_members_select_members" on public.workspace_members;
create policy "workspace_members_select_members"
on public.workspace_members
for select
using (public.is_workspace_member(workspace_id));

drop policy if exists "workspace_members_insert_owner" on public.workspace_members;
create policy "workspace_members_insert_owner"
on public.workspace_members
for insert
with check (
  exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = workspace_members.workspace_id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  )
);

drop policy if exists "workspace_members_update_owner" on public.workspace_members;
create policy "workspace_members_update_owner"
on public.workspace_members
for update
using (
  exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = workspace_members.workspace_id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  )
)
with check (
  exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = workspace_members.workspace_id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  )
);

drop policy if exists "workspace_members_delete_owner" on public.workspace_members;
create policy "workspace_members_delete_owner"
on public.workspace_members
for delete
using (
  exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = workspace_members.workspace_id
      and wm.user_id = auth.uid()
      and wm.role = 'owner'
  )
);

drop policy if exists "wallets_all_members" on public.wallets;
create policy "wallets_all_members"
on public.wallets
for all
using (public.is_workspace_member(workspace_id))
with check (public.is_workspace_member(workspace_id));

drop policy if exists "categories_all_members" on public.categories;
create policy "categories_all_members"
on public.categories
for all
using (public.is_workspace_member(workspace_id))
with check (public.is_workspace_member(workspace_id));

drop policy if exists "transactions_all_members" on public.transactions;
create policy "transactions_all_members"
on public.transactions
for all
using (public.is_workspace_member(workspace_id))
with check (public.is_workspace_member(workspace_id));

drop policy if exists "budgets_all_members" on public.budgets;
create policy "budgets_all_members"
on public.budgets
for all
using (public.is_workspace_member(workspace_id))
with check (public.is_workspace_member(workspace_id));

drop policy if exists "recurring_transactions_all_members" on public.recurring_transactions;
create policy "recurring_transactions_all_members"
on public.recurring_transactions
for all
using (public.is_workspace_member(workspace_id))
with check (public.is_workspace_member(workspace_id));

alter publication supabase_realtime add table public.wallets;
alter publication supabase_realtime add table public.categories;
alter publication supabase_realtime add table public.transactions;
alter publication supabase_realtime add table public.budgets;
