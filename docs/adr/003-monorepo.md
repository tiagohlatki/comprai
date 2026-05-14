# ADR 003 — Monorepo

**Status**: Aceito  
**Data**: 2025

## Contexto

Projeto com múltiplas partes: app mobile, backoffice web, funções backend e migrations de banco.

## Decisão

Usar estratégia de monorepo em um único repositório Git.

## Justificativa

- Projeto solo: sem overhead de coordenação entre repos
- Tipos compartilhados entre partes sem publicação de pacote
- IA auxiliar vê o projeto inteiro de uma vez — contexto completo
- CI/CD centralizado com triggers por pasta
- Facilita refatorações que cruzam fronteiras de camadas

## Consequências

- Pipelines CI/CD com triggers por path (`app/**`, `backoffice/**`, etc.)
- `shared/types` é a única dependência cruzada permitida
