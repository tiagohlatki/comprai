# ADR 002 — Supabase ao invés de Firebase

**Status**: Aceito  
**Data**: 2025

## Contexto

Necessidade de BaaS (Backend as a Service) com banco de dados, autenticação, armazenamento e API REST para MVP sem servidor dedicado.

## Decisão

Usar Supabase como BaaS principal.

## Justificativa

- PostgreSQL nativo: relacional, RLS, migrations versionadas
- Sem vendor lock-in: stack open-source (pode auto-hospedar)
- Free tier generoso e escalável
- Supabase CLI para desenvolvimento local
- Auth, Storage, Realtime, Edge Functions — tudo em um

## Consequências

- Firebase descartado definitivamente — não reabrir esta decisão
- Toda alteração de schema via migration SQL versionada (nunca pelo dashboard)
