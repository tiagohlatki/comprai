# ADR 004 — Next.js para o Backoffice

**Status**: Aceito  
**Data**: 2025

## Contexto

Necessidade de painel administrativo para moderação de produtos, visualização de métricas e gerenciamento de usuários.

## Decisão

Usar Next.js (App Router) com TypeScript e Tailwind CSS.

## Justificativa

- App Router: roteamento automático por estrutura de pastas
- Server Actions: operações administrativas sem API route extra
- TypeScript: type-safety com tipos gerados do Supabase
- Tailwind + shadcn/ui: componentes acessíveis sem design system from scratch
- Deploy no Vercel: integração nativa com GitHub Actions

## Consequências

- `service role key` do Supabase fica **apenas** no backoffice (server-side)
- Nunca expor `service role key` no app mobile ou em código client-side
