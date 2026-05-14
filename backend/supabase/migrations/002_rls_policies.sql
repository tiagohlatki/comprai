-- =============================================================
-- 002_rls_policies.sql
-- Row Level Security — controle de acesso por linha
-- =============================================================

-- Habilitar RLS em todas as tabelas
alter table estabelecimentos   enable row level security;
alter table produtos            enable row level security;
alter table produto_aliases     enable row level security;
alter table precos              enable row level security;
alter table listas_compra       enable row level security;
alter table itens_lista         enable row level security;

-- =============================================================
-- estabelecimentos — leitura pública, escrita via backoffice
-- =============================================================
create policy "estabelecimentos_select_all"
    on estabelecimentos for select
    using (true);

-- =============================================================
-- produtos — leitura pública, escrita via backoffice
-- =============================================================
create policy "produtos_select_all"
    on produtos for select
    using (true);

-- =============================================================
-- produto_aliases — leitura pública, moderação via service role
-- =============================================================
create policy "produto_aliases_select_all"
    on produto_aliases for select
    using (true);

-- =============================================================
-- precos — leitura pública; escrita e deleção apenas pelo dono
-- =============================================================
create policy "precos_select_all"
    on precos for select
    using (true);

create policy "precos_insert_own"
    on precos for insert
    with check (auth.uid() = user_id);

create policy "precos_update_own"
    on precos for update
    using (auth.uid() = user_id);

create policy "precos_delete_own"
    on precos for delete
    using (auth.uid() = user_id);

-- =============================================================
-- listas_compra — apenas o dono
-- =============================================================
create policy "listas_compra_own"
    on listas_compra for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- =============================================================
-- itens_lista — acesso via lista_id (dono da lista)
-- =============================================================
create policy "itens_lista_own"
    on itens_lista for all
    using (
        exists (
            select 1 from listas_compra
            where listas_compra.id = itens_lista.lista_id
              and listas_compra.user_id = auth.uid()
        )
    );
