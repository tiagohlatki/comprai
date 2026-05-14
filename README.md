# comprai — Comparador Inteligente de Preços via NFC-e

Aplicativo mobile colaborativo que importa dados de Notas Fiscais do Consumidor (NFC-e) via QR Code e sugere a combinação ótima de supermercados para uma lista de compras, considerando preço e distância.

## Estrutura do Monorepo

```
comprai/
├── app/          # Flutter — app mobile (Android/iOS)
├── backoffice/   # Next.js — painel administrativo
├── backend/      # Funções customizadas + Supabase migrations
├── shared/       # Tipos e contratos compartilhados
├── docs/         # Documentação e ADRs
└── .github/      # Pipelines CI/CD (GitHub Actions)
```

## Stack

| Camada | Tecnologia |
|---|---|
| App Mobile | Flutter (Dart) |
| Backoffice | Next.js + TypeScript + Tailwind |
| Backend / BaaS | Supabase (PostgreSQL) |
| Funções custom | Railway / Render |
| Mapas | Google Maps SDK |
| Normalização | EAN + Claude API |
| CI/CD | GitHub Actions |

## Pré-requisitos

- Flutter 3.x
- Node.js 20+
- Supabase CLI
- Docker (para testes de integração locais)

## Setup local

```bash
# 1. Copiar variáveis de ambiente
cp .env.example .env
# Preencher os valores no .env

# 2. Iniciar Supabase local
cd backend && supabase start

# 3. Aplicar migrations
supabase db push

# 4. App Flutter
cd app && flutter pub get && flutter run

# 5. Backoffice
cd backoffice && npm install && npm run dev
```

## Documentação

- [Contexto do Produto](docs/context.md)
- [Modelo de Dados](docs/data-model.md)
- [Arquitetura](docs/architecture.md)
- [ADRs](docs/adr/)

## Regras de contribuição

- `main` é protegida — todo código entra via Pull Request
- Nenhum PR sem testes correspondentes
- Nunca alterar schema direto no Supabase — sempre via migration SQL

---

MVP · Paraná · 2025–2026
