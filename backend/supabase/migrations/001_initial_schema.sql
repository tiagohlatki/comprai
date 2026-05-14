-- =============================================================
-- 001_initial_schema.sql
-- Tabelas principais do comprai
-- =============================================================

-- =============================================================
-- Tabela: estabelecimentos
-- =============================================================
create table if not exists estabelecimentos (
    id              uuid primary key default gen_random_uuid(),
    cnpj            varchar(14) not null unique,
    nome            text        not null,
    endereco        text,
    latitude        double precision,
    longitude       double precision,
    cidade          text,
    estado          varchar(2),
    created_at      timestamptz  not null default now()
);

-- =============================================================
-- Tabela: produtos
-- =============================================================
create table if not exists produtos (
    id              uuid primary key default gen_random_uuid(),
    ean             varchar(14) unique,          -- null quando SEM GTIN
    nome_canonical  text        not null,
    categoria       text,
    created_at      timestamptz  not null default now()
);

-- =============================================================
-- Tabela: produto_aliases
-- =============================================================
create table if not exists produto_aliases (
    id          uuid primary key default gen_random_uuid(),
    produto_id  uuid        not null references produtos(id) on delete cascade,
    nome_raw    text        not null,
    fonte       text        not null,            -- ex: 'nfce_pr'
    created_at  timestamptz not null default now(),
    unique (produto_id, nome_raw)
);

-- =============================================================
-- Tabela: precos
-- =============================================================
create table if not exists precos (
    id                  uuid primary key default gen_random_uuid(),
    produto_id          uuid            not null references produtos(id),
    estabelecimento_id  uuid            not null references estabelecimentos(id),
    user_id             uuid            not null references auth.users(id),
    preco_unitario      numeric(10, 2)  not null,
    data_compra         date            not null,
    nfce_chave          varchar(44)     not null unique,   -- idempotência
    created_at          timestamptz     not null default now()
);

-- =============================================================
-- Tabela: listas_compra
-- =============================================================
create table if not exists listas_compra (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null references auth.users(id) on delete cascade,
    nome        text not null,
    created_at  timestamptz not null default now()
);

-- =============================================================
-- Tabela: itens_lista
-- =============================================================
create table if not exists itens_lista (
    id          uuid primary key default gen_random_uuid(),
    lista_id    uuid    not null references listas_compra(id) on delete cascade,
    produto_id  uuid    not null references produtos(id),
    quantidade  numeric(10, 3) not null default 1,
    unique (lista_id, produto_id)
);
