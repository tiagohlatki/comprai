# context.md — Comparador Inteligente de Preços via NFe

> Documento de referência para IAs auxiliares e desenvolvedores.  
> Leia integralmente antes de sugerir qualquer código, arquitetura ou decisão técnica.  
> Versão 2.0 · MVP · 2025

---

## Índice

1. [Visão Geral do Produto](#1-visão-geral-do-produto)
2. [Contexto de Mercado](#2-contexto-de-mercado)
3. [Stack Técnica](#3-stack-técnica)
4. [Estrutura de Pastas](#4-estrutura-de-pastas)
5. [Práticas de Engenharia](#5-práticas-de-engenharia)
6. [Estratégia de Testes](#6-estratégia-de-testes)
7. [CI/CD — GitHub Actions](#7-cicd--github-actions)
8. [Modelo de Dados](#8-modelo-de-dados)
9. [Integração NFC-e / SEFAZ](#9-integração-nfc-e--sefaz)
10. [Algoritmo de Sugestão Logística](#10-algoritmo-de-sugestão-logística)
11. [Roadmap do MVP](#11-roadmap-do-mvp)
12. [Regras para a IA Auxiliar](#12-regras-para-a-ia-auxiliar)
13. [Perfil do Desenvolvedor](#13-perfil-do-desenvolvedor)
14. [Decisões em Aberto](#14-decisões-em-aberto)
15. [Glossário](#15-glossário)

---

## 1. Visão Geral do Produto

### 1.1 Problema

Consumidores brasileiros que fazem compras mensais em supermercados não têm como saber, com antecedência, em qual estabelecimento a sua lista de compras específica seria mais econômica naquela data — considerando não apenas preço, mas também distância e tempo de deslocamento.

### 1.2 Solução Proposta

Aplicativo mobile colaborativo onde cada usuário escaneia o QR Code da NFC-e (Nota Fiscal do Consumidor Eletrônica) após suas compras. Os dados importados da SEFAZ alimentam uma base coletiva de preços. Com base em uma lista de compras, o app sugere:

- O estabelecimento mais econômico para comprar todos os itens
- A **combinação ótima de até 2 estabelecimentos** (ex: compre X itens no Mercado A e Y itens no Mercado B) considerando economia vs. deslocamento
- Histórico de variação de preços por produto e estabelecimento

### 1.3 Proposta de Valor Única

A maioria dos concorrentes compara preços item a item. Este app resolve a **otimização de cesta completa com logística** — nenhum produto no mercado brasileiro faz isso de forma inteligente.

### 1.4 Filosofia do MVP

- Stack 100% gratuita (free tiers escaláveis)
- Foco em **aprendizado** — não há problema se não virar produto
- Boas práticas de engenharia desde o primeiro commit
- Projeto de portfólio completo: mobile + backoffice + backend + CI/CD

---

## 2. Contexto de Mercado

### 2.1 Concorrentes Relevantes

| Produto | Descrição | Limitação |
|---|---|---|
| Menor Preço (PR) | App governamental SEFAZ-PR | Sem otimização de cesta |
| Menor Preço Brasil | SEFAZ-RS, ~14 estados | Sem sugestão logística |
| Meus Preços (SP) | App privado, cobertura SP | Sem logística combinatória |
| ClickSuper | Lista + comparação básica | Sem otimização |

### 2.2 Diferencial Competitivo

- **Fonte de dados**: NFC-e via SEFAZ — mais confiável que scraping ou cadastro manual
- **Modelo colaborativo**: quanto mais usuários, melhores os dados
- **Sugestão de logística de compras** — ausente em todos os concorrentes
- Independente de parcerias com supermercados

### 2.3 Riscos de Negócio Identificados

- **Cold start**: o app só é útil com dados suficientes de uma região
- **Concorrência governamental**: o governo pode expandir o "Menor Preço" para o PR
- **Baixa recorrência**: compra mensal = usuário abre o app ~1x/mês
- **Cobertura SEFAZ**: nem todos os estados retornam itens via QR Code

---

## 3. Stack Técnica

> **Critérios de escolha**: free tier suficiente para MVP, escalabilidade futura, máxima produtividade com IA auxiliar.

| Camada | Tecnologia | Justificativa |
|---|---|---|
| App Mobile | Flutter (Dart) | Um código para Android e iOS; câmera nativa sem dor; IA entende bem |
| Backoffice | Next.js (App Router) + TypeScript + Tailwind | Roteamento automático, Server Actions, estrutura opinativa |
| Backend / BaaS | Supabase | PostgreSQL, Auth, Storage, Realtime, API REST — sem vendor lock-in |
| Funções custom | Railway ou Render | Normalização de produtos, algoritmo de sugestão — free tier |
| Mapas / Rotas | Google Maps SDK | Free tier generoso para volume de MVP |
| Dados fiscais | API pública SEFAZ via QR Code NFC-e | Fonte primária confiável |
| Normalização | EAN como chave + Claude API como fallback semântico | Resolve o problema de nomes livres |
| CI/CD | GitHub Actions | Gratuito para repos públicos, integrado ao GitHub |
| Publicação | Google Play Store | Android primeiro — processo mais simples |

### 3.1 Restrições de Stack — NÃO NEGOCIÁVEIS

- ❌ **Nunca usar Firebase** — vendor lock-in, PostgreSQL é superior para este modelo
- ❌ **Nunca usar React Native** — Flutter foi decidido definitivamente
- ❌ **Nunca alterar schema direto no dashboard Supabase** — sempre via migration SQL versionada
- ❌ **Nunca fazer push direto na `main`** — sempre via Pull Request

---

## 4. Estrutura de Pastas

### 4.1 Estratégia: Monorepo

Um único repositório Git. Justificativa: projeto solo, compartilhamento de tipos entre partes, IA entende o projeto inteiro de uma vez, CI/CD centralizado.

```
nfe-price/
├── app/                  # Flutter — app mobile do consumidor
├── backoffice/           # Next.js — painel administrativo
├── backend/              # Funções customizadas + Supabase migrations
├── shared/               # Tipos e contratos compartilhados
├── docs/                 # Documentação e ADRs
├── .github/
│   └── workflows/        # Pipelines CI/CD
├── .env.example          # Variáveis necessárias (sem valores reais)
└── README.md
```

### 4.2 `app/` — Flutter (Feature-First + Clean Architecture)

Organização Feature-First na superfície, Clean Architecture nas camadas internas de cada feature.

```
app/lib/
├── core/                         # Infraestrutura transversal (sem regra de negócio)
│   ├── config/                   # Env, constantes, flavors (dev/prod/staging)
│   ├── di/                       # Injeção de dependência (get_it + injectable)
│   ├── errors/                   # Exceções de domínio e failures
│   ├── extensions/               # Extensões Dart (String, DateTime, List...)
│   ├── network/                  # Cliente HTTP, interceptors, timeout SEFAZ
│   ├── router/                   # Roteamento declarativo (go_router)
│   └── utils/                    # Helpers genéricos sem estado
│
├── features/
│   └── [feature_name]/           # Ex: scan, catalog, shopping_list, suggestion, auth
│       ├── domain/               # Núcleo — ZERO dependências externas
│       │   ├── entities/         # Objetos com identidade (Produto, Estabelecimento, Preco)
│       │   ├── value_objects/    # Imutáveis sem identidade (Dinheiro, ChaveNFe, Localizacao)
│       │   └── repositories/    # Interfaces — sem implementação
│       ├── data/                 # Implementações concretas
│       │   ├── models/           # DTOs com fromJson/toJson
│       │   ├── repositories/    # Implementa interfaces do domain
│       │   └── datasources/     # Supabase, SEFAZ API, Maps
│       ├── application/          # Use cases — um arquivo por caso de uso
│       └── presentation/         # UI
│           ├── bloc/             # BLoC ou Cubit para gerenciamento de estado
│           ├── pages/
│           └── widgets/
│
└── main.dart
```

> **Regra de ouro**: cada feature é autossuficiente. Uma feature nunca importa diretamente de outra — se precisar de dados de outra feature, passa por um use case ou evento em `core/`.

### 4.3 `backoffice/` — Next.js (App Router)

```
backoffice/src/
├── app/
│   ├── (auth)/                   # Login, recuperação de senha
│   └── (admin)/                  # Rotas protegidas por role
│       ├── dashboard/            # Métricas: usuários, notas importadas, cobertura
│       ├── products/             # Curadoria: aprovar aliases, mesclar duplicatas
│       ├── establishments/       # Gerenciar estabelecimentos
│       ├── users/                # Usuários, permissões, banimentos
│       └── reports/              # Exportação e gráficos
├── components/
│   ├── ui/                       # Componentes genéricos (shadcn/ui base)
│   └── [feature]/                # Componentes específicos por contexto
├── lib/
│   ├── supabase/                 # Cliente com service role key (APENAS backoffice)
│   └── auth/                     # Middleware de proteção por role
├── actions/                      # Next.js Server Actions (operações administrativas)
└── types/                        # Importa de shared/types
```

### 4.4 `backend/` — Funções e Migrations

```
backend/
├── functions/
│   ├── normalize-product/        # EAN + nome_raw → produto_id canônico
│   │   ├── src/
│   │   │   ├── domain/           # DDD também aqui
│   │   │   ├── application/      # Use cases
│   │   │   └── infra/            # Implementações concretas
│   │   ├── tests/
│   │   └── Dockerfile
│   ├── suggest-markets/          # Algoritmo de otimização de cesta
│   └── parse-nfce/               # Parsing server-side (fallback ao mobile)
│
└── supabase/                     # Supabase CLI
    ├── migrations/               # SQL versionado — FONTE DA VERDADE do schema
    │   ├── 001_initial_schema.sql
    │   ├── 002_rls_policies.sql
    │   └── 003_indexes.sql
    ├── functions/                # Edge Functions (Deno) se necessário
    └── seed/                     # Dados iniciais (categorias, produtos base)
```

### 4.5 `shared/` — Contratos Compartilhados

```
shared/
└── types/
    ├── database.ts               # Gerado por: supabase gen types typescript
    └── enums.ts                  # Enums compartilhados (categorias, status, roles)
```

### 4.6 `docs/` — Documentação

```
docs/
├── context.md                    # Este arquivo
├── data-model.md
├── architecture.md
└── adr/                          # Architecture Decision Records
    ├── 001-flutter-over-rn.md
    ├── 002-supabase-over-firebase.md
    ├── 003-monorepo.md
    └── 004-nextjs-backoffice.md
```

---

## 5. Práticas de Engenharia

Aplicam-se a **todo código gerado neste projeto**, em todas as partes. São não-negociáveis e devem ser aplicadas desde o primeiro commit.

### 5.1 Clean Code

- Nomes revelam intenção — variáveis, funções e classes descrevem o que fazem, não como
- Funções fazem uma única coisa — se precisar de "e" para descrever, divida
- Sem comentários que explicam o óbvio — o código deve ser autoexplicativo
- Sem números mágicos — use constantes nomeadas
- Máximo de 3 parâmetros por função; acima disso, use um objeto/classe
- Sem código morto — não commitar código comentado

### 5.2 SOLID

| Princípio | Aplicação no projeto |
|---|---|
| **S** — Single Responsibility | Cada classe tem um único motivo para mudar. `PriceRepository` não normaliza produto. |
| **O** — Open/Closed | Adicionar novo estado SEFAZ não quebra o parser existente. |
| **L** — Liskov Substitution | `MockPriceRepository` e `SupabasePriceRepository` são intercambiáveis nos testes. |
| **I** — Interface Segregation | `IReadPrices` e `IWritePrices` separados, não um `IManagePrices` monolítico. |
| **D** — Dependency Inversion | Use cases dependem de interfaces de repositório injetadas, nunca de Supabase diretamente. |

### 5.3 Domain-Driven Design (DDD)

O domínio é o núcleo — sem dependências externas.

| Conceito | Descrição | Exemplo no projeto |
|---|---|---|
| **Entidades** | Objetos com identidade única | `Produto` (id), `Estabelecimento` (cnpj), `Preco` (id) |
| **Value Objects** | Imutáveis, sem identidade | `Dinheiro`, `Localizacao`, `ChaveNFe` (44 dígitos) |
| **Aggregates** | Cluster com um root | `ListaCompras` agrega `ItensLista` |
| **Repositories** | Interface no domínio, implementação na infra | O domínio nunca importa Supabase |
| **Use Cases** | Orquestram entidades e repos | `ImportarNFce`, `SugerirMercados`, `NormalizarProduto` |
| **Domain Events** | Desacoplamento entre features | `NFeImportada`, `ProdutoNormalizado` |
| **Bounded Contexts** | Cada feature é um contexto | `Scan`, `Catalog`, `ShoppingList`, `Suggestion` |

> **Regra de ouro do DDD**: o domínio (entities, value objects, use cases) nunca importa Flutter, Supabase, HTTP ou qualquer framework. É Dart/TypeScript puro e totalmente testável sem infraestrutura.

### 5.4 Design Patterns

| Pattern | Onde aplicar | Exemplo |
|---|---|---|
| Repository | `data/repositories/` | `SupabasePriceRepository implements IPriceRepository` |
| Factory | `domain/entities/` | `Produto.fromNFceItem()` — cria entidade a partir do XML |
| Strategy | `suggestion/application/` | Algoritmo troca estratégia (preço vs distância) |
| Observer / BLoC | `presentation/bloc/` | `ScanBloc` emite: `Scanning`, `Parsed`, `Error` |
| Adapter | `data/datasources/` | `SEFAZAdapter` converte XML para entidades de domínio |
| Singleton | `core/di/` | Supabase client via `get_it` — uma instância global |
| Command | `application/use_cases/` | Cada use case é um Command com `execute()` |
| Decorator | `core/network/` | `LoggingInterceptor` decora o cliente HTTP base |

### 5.5 Object Calisthenics

Aplicar progressivamente — não travar o MVP, mas ter como meta:

- Um nível de indentação por método
- Não usar `else` após `return` (early return pattern)
- Primitivos com regras de negócio encapsulados em Value Objects
- Coleções com comportamento encapsuladas em classes próprias
- Um ponto por linha (sem chaining excessivo)
- Sem abreviações — nomes completos e descritivos
- Classes pequenas — ~150 linhas como meta
- Máximo 2 variáveis de instância por classe (guideline, não dogma)

---

## 6. Estratégia de Testes

### 6.1 Pirâmide de Testes

| Nível | Volume | O que testa |
|---|---|---|
| **Unitários** (base) | Alto | Domínio puro: entidades, value objects, use cases. Sem I/O, sem framework. |
| **Integração** (meio) | Médio | Comunicação entre camadas: repositório real contra Supabase local, parser XML contra fixtures reais. |
| **E2E / Widget** (topo) | Baixo | Fluxos críticos completos: escanear QR → dados salvos; gerar sugestão → resultado correto. |

### 6.2 Cobertura Mínima Esperada

| Camada | Cobertura |
|---|---|
| Domain (entidades + use cases) | 90%+ |
| Data (repositories + parsers) | 70%+ |
| Presentation (BLoC/Cubit) | 60%+ |
| Algoritmo de sugestão | **100%** — diferencial do produto, zero tolerância a regressão |

### 6.3 Ferramentas

| Parte | Unitários | Integração |
|---|---|---|
| Flutter | `flutter_test` + `mocktail` | `integration_test` |
| Flutter UI | `flutter_test` + golden tests | — |
| Next.js | Jest + Testing Library | Jest + Supabase local (docker) |
| Backend | Jest ou pytest | Testcontainers |
| Migrations | pgTAP | — |

### 6.4 Convenções

- Nomenclatura: `dado_[contexto]_quando_[ação]_então_[resultado]`
- Um assert por teste como regra geral
- Fixtures de NFC-e reais (anonimizadas) para testar o parser XML
- Testes de domínio **nunca** instanciam Supabase, HTTP ou Flutter
- Todo bug corrigido ganha um teste de regressão **antes** do fix

> **Definition of Done**: nenhum PR/commit de feature é completo sem testes correspondentes.

---

## 7. CI/CD — GitHub Actions

### 7.1 Ambientes

| Ambiente | Trigger | Descrição |
|---|---|---|
| `development` | Local | Supabase local via CLI (`supabase start`) |
| `staging` | Push na `main` | Deploy automático. Supabase projeto separado. Railway/Render staging. |
| `production` | Tag Git (`v1.x.x`) | Deploy manual com aprovação. |

### 7.2 Pipeline do App (Flutter)

**Arquivo**: `.github/workflows/app.yml` — trigger: `push em app/**`

1. `flutter pub get`
2. `dart format --check` (lint de formatação)
3. `flutter analyze` (análise estática)
4. `flutter test --coverage` (unitários + widgets)
5. `flutter build apk --release` (verifica que builda)
6. Upload do coverage para Codecov

### 7.3 Pipeline do Backoffice (Next.js)

**Arquivo**: `.github/workflows/backoffice.yml` — trigger: `push em backoffice/**`

1. `npm ci`
2. `npx tsc --noEmit` (type check)
3. `npm run lint` (ESLint)
4. `npm test -- --coverage` (Jest)
5. `npm run build`
6. Deploy automático no Vercel via GitHub integration (staging)

### 7.4 Pipeline do Backend

**Arquivo**: `.github/workflows/backend.yml` — trigger: `push em backend/**`

1. Instalar dependências
2. Lint + type check
3. Testes unitários
4. Testes de integração (Supabase local via docker-compose)
5. Build da imagem Docker
6. Deploy no Railway (staging) via Railway CLI

### 7.5 Pipeline de Migrations

**Arquivo**: `.github/workflows/migrations.yml` — trigger: `push em backend/supabase/migrations/**`

1. `supabase db lint` (valida SQL)
2. Executar pgTAP tests
3. `supabase db push` para o projeto de staging

### 7.6 Branch Strategy

| Branch | Regra |
|---|---|
| `main` | Protegida. Sempre deployável. Requer PR + pipeline verde. |
| `feature/xxx` | Uma branch por feature ou fix. Merge via Pull Request. |
| Tags `v1.x.x` | Disparam deploy em produção após aprovação manual. |

> **Proteção da main**: a branch `main` nunca recebe push direto — nem sendo desenvolvedor solo. Todo código passa por PR para garantir que o pipeline roda antes do merge.

---

## 8. Modelo de Dados

### 8.1 Tabelas Principais (Supabase / PostgreSQL)

| Tabela | Campos principais |
|---|---|
| `users` | Gerenciada pelo Supabase Auth. Extras: `nome`, `cidade`, `created_at` |
| `estabelecimentos` | `id`, `cnpj` (unique), `nome`, `endereco`, `latitude`, `longitude`, `cidade`, `estado`, `created_at` |
| `produtos` | `id`, `ean` (nullable, unique quando presente), `nome_canonical`, `categoria`, `created_at` |
| `produto_aliases` | `id`, `produto_id` (FK), `nome_raw`, `fonte` (ex: `'nfce_pr'`) |
| `precos` | `id`, `produto_id` (FK), `estabelecimento_id` (FK), `user_id` (FK), `preco_unitario`, `data_compra`, `nfce_chave` (unique, 44 dígitos) |
| `listas_compra` | `id`, `user_id` (FK), `nome`, `created_at` |
| `itens_lista` | `id`, `lista_id` (FK), `produto_id` (FK), `quantidade` |

### 8.2 Normalização de Produtos — Estratégia

1. EAN presente na NFC-e → matching direto em `produtos.ean`
2. EAN ausente (`SEM GTIN`) → Claude API recebe `nome_raw` e retorna `produto_id` ou sugere novo
3. Usuário confirma ou corrige na tela de importação
4. Confirmações salvas em `produto_aliases` para aprendizado futuro
5. Moderador revisa aliases suspeitos via backoffice

> **Idempotência**: a `nfce_chave` (44 dígitos) é `unique constraint` em `precos`. Escanear o mesmo cupom duas vezes não duplica dados.

### 8.3 Regras de RLS (Row Level Security)

- Usuário lê/escreve apenas seus próprios dados em `precos` e `listas_compra`
- `precos` são legíveis por todos (base colaborativa) mas só editáveis pelo dono
- `produto_aliases` são moderados via backoffice com `service role key`
- RLS deve ser configurado **antes** de qualquer dado em produção

---

## 9. Integração NFC-e / SEFAZ

### 9.1 Fluxo de Importação

1. Usuário escaneia o QR Code impresso no cupom fiscal
2. O QR Code contém uma URL no formato da SEFAZ estadual
3. O app faz requisição GET a essa URL
4. A SEFAZ retorna o XML da NFC-e completo
5. O app parseia o XML e extrai os campos relevantes
6. Os dados são normalizados e salvos no Supabase

### 9.2 Campos Relevantes do XML NFC-e

| Campo XML | Uso |
|---|---|
| `emit/CNPJ` | Identificador único do estabelecimento |
| `emit/xNome` | Nome do estabelecimento |
| `emit/enderEmit` | Endereço para geolocalização |
| `det[n]/prod/cEAN` | EAN do produto (`SEM GTIN` quando ausente — tratar como `null`) |
| `det[n]/prod/xProd` | Descrição textual — campo crítico para normalização |
| `det[n]/prod/qCom` | Quantidade comprada |
| `det[n]/prod/vUnCom` | Valor unitário |
| `ide/dhEmi` | Data e hora de emissão |
| `infNFe/@Id` (chNFe) | Chave de 44 dígitos — `unique constraint` em `precos` |

### 9.3 Tratamento de Erros na SEFAZ

- Timeout de no máximo 10 segundos por requisição
- Retry com backoff exponencial (máximo 3 tentativas)
- Erro da SEFAZ nunca deve crashar o app — sempre exibir mensagem amigável
- Logs de falhas para diagnóstico (sem dados pessoais)

### 9.4 Cobertura por Estado

A consulta pública de itens via QR Code NFC-e **não é universal**. O MVP foca no **Paraná** (coberto). Validar cobertura antes de suportar novos estados.

---

## 10. Algoritmo de Sugestão Logística

### 10.1 Definição do Problema

Dado uma lista de N itens e M estabelecimentos com dados de preço recentes, encontrar a combinação de **até 2 estabelecimentos** que minimiza:

```
custo_total = Σ(preços dos itens) + peso_distância × distância_extra + peso_tempo × tempo_extra
```

### 10.2 Restrições do MVP

- Máximo de **2 estabelecimentos** por sugestão (3+ é NP-hard na prática)
- Considerar apenas preços com menos de **30 dias** de antiguidade
- Item sem preço cadastrado em nenhum estabelecimento: ignorar da otimização e alertar o usuário
- O usuário configura o peso entre preço e distância

### 10.3 Parâmetros Configuráveis

| Parâmetro | Descrição |
|---|---|
| Raio máximo | Distância máxima aceitável dos estabelecimentos (ex: 5km) |
| Prioridade | Slider entre "máxima economia" e "mínimo deslocamento" |
| Horário preferido | Para considerar trânsito em tempo real via Google Maps |

### 10.4 Cobertura de Testes

O algoritmo de sugestão deve ter **100% de cobertura de testes**. É o diferencial principal do produto — qualquer regressão é crítica.

---

## 11. Roadmap do MVP

| Fase | Duração | Objetivo | Entregável |
|---|---|---|---|
| **1** | 2–3 sem. | App Flutter rodando, auth, QR Code lendo NFC-e real, dados no Supabase, pipeline CI básico | Usuário escaneia cupom e vê itens importados |
| **2** | 3–4 sem. | Dados colaborativos, catálogo de produtos, normalização via EAN + Claude API, backoffice básico | Usuário vê onde cada produto foi mais barato |
| **3** | 3–4 sem. | Algoritmo de sugestão logística, Google Maps, parâmetros configuráveis | App sugere combinação ótima de mercados para a lista |
| **4** | 2 sem. | Polimento, cobertura de testes, CI/CD completo, publicação Play Store, ADRs e documentação | App publicado e portfólio completo |

### Fora do Escopo do MVP

- iOS (Flutter já estará pronto, mas publicação Play Store vem primeiro)
- Notificações push
- Features sociais (seguir amigos, compartilhar listas)
- Monetização
- Suporte a estados além do Paraná

---

## 12. Regras para a IA Auxiliar

### 12.1 Sempre fazer ✅

- Aplicar Clean Architecture em toda feature: `domain → application → data → presentation`
- Criar **interface no domínio** antes de qualquer implementação concreta
- Escrever **testes junto com o código** — não depois
- Usar injeção de dependência (`get_it` no Flutter, DI nativo no Next.js)
- Tratar erros explicitamente — sem exceções silenciosas
- Usar **migrations SQL** para qualquer alteração de schema
- Nomear seguindo o padrão da camada: `produto_repository.dart`, `NormalizarProdutoUseCase.ts`
- Tratar `SEM GTIN` como `null`, nunca como string
- Toda requisição à SEFAZ com timeout e tratamento de erro gracioso

### 12.2 Nunca fazer ❌

- Chamar Supabase, HTTP ou Maps diretamente de um use case ou entidade de domínio
- Usar Firebase, React Native ou qualquer tecnologia fora da stack definida
- Criar lógica de negócio em widgets Flutter ou componentes React
- Usar `WidthType.PERCENTAGE` em código `docx` — sempre `DXA`
- Implementar sugestão com mais de 2 estabelecimentos no MVP
- Fazer push direto na `main`
- Escrever testes que dependem de infraestrutura externa (internet, SEFAZ real)
- Armazenar o XML completo da NFC-e — apenas os campos mapeados na seção 9.2
- Fazer scraping de sites de supermercados

### 12.3 Perguntar antes de decidir ❓

- Qualquer decisão que impacte o schema do banco
- Modelo de monetização — ainda não definido
- Estratégia de cold start — como conseguir primeiros usuários em Maringá-PR
- Política de privacidade e LGPD — requer decisão jurídica
- Suporte a iOS — fora do escopo mas impacta algumas decisões

---

## 13. Perfil do Desenvolvedor

| Atributo | Descrição |
|---|---|
| Localização | Maringá, Paraná, Brasil |
| Perfil técnico | Não programador tradicional; desenvolve com auxílio de IA |
| Experiência comprovada | Deployou aplicação completa: AWS CloudFront, SonarQube, Docker |
| Objetivo do projeto | Portfólio completo + aprendizado de mobile + validação de modelo de negócio |
| Idioma | Português brasileiro — toda comunicação e documentação |
| Filosofia | Stack 100% gratuita. Aprendizado > perfeição. Boas práticas desde o início. |

---

## 14. Decisões em Aberto

Estas questões **não foram decididas** e não devem ser assumidas pela IA auxiliar. Sempre perguntar ao dono do projeto antes de implementar algo que dependa delas.

| Questão | Status |
|---|---|
| Modelo de monetização | Não definido |
| Estratégia de cold start em Maringá | Não definida |
| Política de privacidade e adequação LGPD | Requer parecer jurídico |
| Suporte a iOS | Fora do MVP — decidir antes da Fase 4 |
| Expansão para outros estados além do PR | Pós-MVP |
| Modelo de moderação de produtos no backoffice | Não detalhado |

---

## 15. Glossário

| Termo | Definição |
|---|---|
| **NFC-e** | Nota Fiscal do Consumidor Eletrônica — documento fiscal emitido no varejo ao consumidor final |
| **NF-e** | Nota Fiscal Eletrônica modelo 55 — para operações B2B |
| **DANFE NFC-e** | Documento Auxiliar da NFC-e — o cupom impresso com o QR Code |
| **SEFAZ** | Secretaria da Fazenda — órgão estadual que autoriza e armazena as notas fiscais eletrônicas |
| **EAN / GTIN** | Código de barras do produto. Nem sempre presente na NFC-e. |
| **Produto Canônico** | Representação normalizada de um produto, independente de como foi descrito na NFC-e |
| **RLS** | Row Level Security — controle de acesso por linha no PostgreSQL/Supabase |
| **ADR** | Architecture Decision Record — documento curto que registra uma decisão técnica e sua justificativa |
| **Cold Start** | Problema de sistemas colaborativos: sem usuários não há dados; sem dados não há valor |
| **BLoC** | Business Logic Component — padrão de gerenciamento de estado do Flutter |
| **Use Case** | Classe que orquestra entidades e repositórios para executar uma ação de negócio específica |
| **Value Object** | Objeto imutável sem identidade própria, definido por seus atributos. Ex: `Dinheiro`, `ChaveNFe` |
| **Aggregate** | Cluster de entidades tratadas como unidade para consistência. Ex: `ListaCompras` + `ItensLista` |
| **Bounded Context** | Contexto delimitado do DDD — cada feature é um contexto isolado |
| **Monorepo** | Estratégia de um único repositório Git para todas as partes do projeto |
| **Definition of Done** | Critérios que um código precisa atender para ser considerado completo (inclui testes) |

---

*— fim do context.md v2.0 —*
