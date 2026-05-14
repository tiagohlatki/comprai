-- =============================================================
-- 003_indexes.sql
-- Índices de performance
-- =============================================================

-- Busca de preços por produto (consulta mais frequente)
create index if not exists idx_precos_produto_id
    on precos (produto_id);

-- Busca de preços por estabelecimento
create index if not exists idx_precos_estabelecimento_id
    on precos (estabelecimento_id);

-- Preços recentes (algoritmo de sugestão filtra por data_compra)
create index if not exists idx_precos_data_compra
    on precos (data_compra desc);

-- Busca de aliases por nome_raw (normalização)
create index if not exists idx_produto_aliases_nome_raw
    on produto_aliases using gin (to_tsvector('portuguese', nome_raw));

-- Busca de preços por usuário (histórico do usuário)
create index if not exists idx_precos_user_id
    on precos (user_id);

-- Busca por EAN (mais rápida que unique constraint scan)
create index if not exists idx_produtos_ean
    on produtos (ean)
    where ean is not null;

-- Estabelecimentos por cidade/estado
create index if not exists idx_estabelecimentos_cidade_estado
    on estabelecimentos (estado, cidade);
