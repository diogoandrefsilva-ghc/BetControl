-- ===== Apostas — schema Supabase =====
-- Projeto: gjweqwfbnkgnibhajldc.supabase.co  | região Europa
-- Correr no SQL Editor. ADMIN: diogo.andre.f.silva@gmail.com
-- LEMBRA: depois expor o schema "apostas" em Settings > API > Data API > Exposed schemas

create schema if not exists apostas;

create table if not exists apostas.casas (
  nome      text primary key,
  cor       text not null default '#8A93A6',
  ordem     int  not null default 99,
  ativa     boolean not null default true,
  saldo     numeric not null default 0,        -- saldo atual na casa (€)
  saldo_em  timestamptz,                        -- quando o saldo foi atualizado
  created_at timestamptz not null default now()
);

create table if not exists apostas.movimentos (
  id         bigint primary key,
  data       date not null,
  casa       text not null references apostas.casas(nome) on update cascade,
  tipo       text not null check (tipo in ('deposito','levantamento')),
  valor      numeric not null check (valor > 0),
  nota       text,
  created_at timestamptz not null default now()
);
create index if not exists movimentos_data_idx on apostas.movimentos(data);
create index if not exists movimentos_casa_idx on apostas.movimentos(casa);

-- ===== GRANTS (sem isto dá 403 permission denied) =====
grant usage on schema apostas to anon, authenticated;
grant all on all tables in schema apostas to anon, authenticated;
grant all on all sequences in schema apostas to anon, authenticated;
alter default privileges in schema apostas grant all on tables to anon, authenticated;
alter default privileges in schema apostas grant all on sequences to anon, authenticated;

-- ===== RLS — só o dono =====
alter table apostas.casas enable row level security;
alter table apostas.movimentos enable row level security;

create policy casas_owner on apostas.casas
  for all using (auth.email() = 'diogo.andre.f.silva@gmail.com')
  with check (auth.email() = 'diogo.andre.f.silva@gmail.com');

create policy movimentos_owner on apostas.movimentos
  for all using (auth.email() = 'diogo.andre.f.silva@gmail.com')
  with check (auth.email() = 'diogo.andre.f.silva@gmail.com');
