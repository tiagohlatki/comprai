-- =============================================================
-- seed.sql
-- Dados iniciais para desenvolvimento local
-- =============================================================

-- Categorias base de produtos (usadas como enum no app)
-- Os produtos reais são inseridos via importação de NFC-e

-- Estabelecimento de exemplo para testes locais
insert into estabelecimentos (cnpj, nome, endereco, latitude, longitude, cidade, estado)
values
    ('00000000000191', 'Mercado Exemplo Maringá', 'Av. Brasil, 1000', -23.4273, -51.9375, 'Maringá', 'PR')
on conflict (cnpj) do nothing;
