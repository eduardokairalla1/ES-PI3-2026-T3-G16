# Plano de Implementação — MesclaInvest (Completo)

> Este documento é o backlog técnico consolidado do projeto. Cada item descreve o problema, a causa raiz identificada e a solução proposta. Use o status para priorizar a execução.

---

## Legenda de Status

| Ícone | Significado |
|-------|-------------|
| ✅ | Concluído |
| 🔧 | Em progresso / parcialmente feito |
| ⬜ | Pendente |
| 🔴 | Bloqueador / crítico |

---

## 1. Tela de Home (`/home` — `DashboardPage`)

### 1.1 Notificações ⬜
- **Problema:** O ícone de sino não tem funcionalidade real.
- **Causa:** Nenhum sistema de notificações existe no backend.
- **Solução Proposta:**
  - Criar coleção Firestore `notifications/{uid}/items/{id}` com campos `title`, `body`, `read`, `createdAt`.
  - Criar Cloud Function `onCreateNotification` (callable ou trigger de `orders`).
  - Criar trigger automático: quando uma ordem é executada (`status = 'completed'`), gerar uma notificação para o usuário.
  - No frontend: exibir badge com contagem de não-lidas; clicar abre bottom sheet com lista de notificações.

### 1.2 Gráfico de Evolução Patrimonial Real ⬜
- **Problema:** O gráfico usa dados mockados/estáticos.
- **Causa:** Não há coleta histórica do valor do portfólio.
- **Solução Proposta:**
  - Criar coleção `portfolio_snapshots/{uid}/snapshots/{date}` com campo `totalValue`.
  - Criar Cloud Function agendada (`onSchedulePortfolioSnapshot`) — executar diariamente via Cloud Scheduler — que calcula `Σ(tokens * preço_atual)` para cada usuário e salva o snapshot.
  - No frontend: buscar os últimos N snapshots via callable `onGetPortfolioHistory`, plotar no gráfico de linha existente.

### 1.3 Botões "Comprar" e "Vender" na Home ⬜
- **Problema:** Os botões `Comprar` e `Vender` presentes no Dashboard não fazem nada (ou navegam para o local errado).
- **Causa:** `onTap` sem implementação ou que navega para `/startup/${id}` sem abrir o painel de trade.
- **Solução Proposta:**
  - Ao clicar em **Comprar** ou **Vender** em um card de portfólio: navegar para `/investimentos` e abrir imediatamente o `CreateOrderDialog` pré-preenchido com `startupId` e `type = 'buy'` ou `'sell'`.
  - Alternativa mais simples: abrir `CreateOrderDialog` diretamente como modal (`showDialog`) a partir da Home, passando `startupId` e `type`.

### 1.4 Rentabilidade Real (% "este mês") ⬜
- **Problema:** O percentual de rentabilidade mensal exibido é fixo/falso.
- **Causa:** Não há cálculo real de variação.
- **Solução Proposta:**
  - Fórmula: `rentabilidade = (valorAtual - valorMêsAnterior) / valorMêsAnterior * 100`.
  - Usar os snapshots de portfólio (item 1.2) para comparar o snapshot do início do mês com o valor atual.
  - Expor via `onGetDashboard` ou calcular no frontend após buscar o histórico.

### 1.5 "Meu Patrimônio" — Variação Real ⬜
- **Problema:** A variação de valor exibida em "Meu Patrimônio" é placeholder.
- **Causa:** Igual ao item 1.4 — ausência de histórico.
- **Solução Proposta:**
  - Calcular variação D-1: `Σ(tokens * preço_ontem) vs Σ(tokens * preço_hoje)`.
  - Depende do snapshot diário (item 1.2).

### 1.6 Favoritos — Ícone de Estrela e Integração com Perfil ⬜
- **Problema:** O ícone de favoritar (coração?) não persiste e não aparece em "Startups Favoritas" no Perfil.
- **Causa:** `favoriteIds` provavelmente é atualizado localmente mas não persistido/lido corretamente.
- **Solução Proposta:**
  - Trocar ícone de ❤️ para ⭐ em todos os cards de startup.
  - Garantir que ao clicar a Cloud Function `onToggleFavorite` (ou campo `favoriteIds` no documento do usuário) seja chamada.
  - Na tela de Perfil → "Startups Favoritas": buscar lista de startups cujo ID está em `AppState.profile.favoriteIds` e exibir cards navegáveis.

---

## 2. Tela de Investimentos (`/investimentos` — `BalcaoPage`)

### 2.1 Lógica de Mercado — Revisão Completa 🔴
- **Problema:** A lógica de match entre ordens de compra e venda pode estar incorreta ou ausente.
- **Análise Necessária:**
  - Uma ordem de **compra** (bid) deve ser executada quando existe uma ordem de **venda** (ask) com `preço_venda ≤ preço_compra`.
  - O `onMatchOrders` (Cloud Function) deve rodar como trigger após cada nova ordem inserida.
  - Verificar se a Cloud Function está exportada em `index.ts` e com trigger de Firestore correto (`onDocumentCreated('orders/{orderId')`).
- **Correções Pendentes:**
  1. Confirmar que o `onMatchOrders` tem trigger de Firestore (não apenas callable).
  2. Garantir transação atômica: transferência de tokens do vendedor para o comprador + transferência de saldo do comprador para o vendedor.
  3. Marcar ambas as ordens como `status: 'completed'`.
  4. Registrar a transação em `transactions`.
  5. Atualizar o portfólio (`investments`) de ambos os usuários.

### 2.2 Livro de Ofertas — Correções e Robustez 🔧
- **Problema atual:** `[firebase_functions/internal] Failed to fetch order book` (500).
- **Causa identificada:** `order.created_at.toISOString()` — Firestore retorna `Timestamp`, não `Date`. **Já corrigido.**
- **Pendências adicionais:**
  - [ ] Após criar uma nova ordem via `CreateOrderDialog`, o livro deve **atualizar automaticamente** (refresh com `UniqueKey`). **Já implementado.**
  - [ ] Implementar paginação ou limitar a 50 ordens por tipo para não sobrecarregar.
  - [ ] Adicionar filtro para mostrar apenas ordens do usuário logado (toggle "Minhas ordens").
  - [ ] Botão de cancelamento de ordem do próprio usuário já existe — validar que o `onCancelOrder` estorna saldo/tokens corretamente.

### 2.3 Aba "Meus Investimentos" — Reorganização da UI ⬜
- **Problema:** A tela está desorganizada / com dados insuficientes.
- **Proposta de Reorganização:**
  - **Seção 1 — Resumo Financeiro:** Cards com `Patrimônio Total`, `Rentabilidade`, `Saldo disponível`.
  - **Seção 2 — Portfólio de Tokens:** Lista de holdings com nome da startup, quantidade de tokens, valor atual, variação %.
  - **Seção 3 — Ordens Pendentes:** Lista das ordens com status `pending`, permitindo editar (preço, quantidade, tipo) ou cancelar. Usar o `EditOrderDialog` já existente.
  - **Seção 4 — Histórico de Ordens Executadas:** Ordens com status `completed`.
  - Usar `TabBar` ou `SliverList` com seções colapsáveis para organizar.

### 2.4 Comprar/Vender — Modal "Nova Ordem" na Tela do Livro ✅
- O botão "NOVA ORDEM" agora abre o `CreateOrderDialog` diretamente na tela. **Concluído.**

---

## 3. Tela de Perfil (`/profile` — `ProfilePage`)

### 3.1 "Minha Carteira" → Navegar para Investimentos ⬜
- **Problema:** O botão "Minha Carteira" no menu de Perfil abre um `_comingSoon()`.
- **Solução:**
  - Substituir `_comingSoon(context)` por `context.push('/investimentos')` no `_menuCard` de `ProfilePage`.
  - **Arquivo:** `frontend/app/lib/pages/profile/profile_page.dart` linha ~398.

### 3.2 "Startups Favoritas" — Implementar a Tela ⬜
- **Problema:** Clicar em "Startups Favoritas" também chama `_comingSoon()`.
- **Solução:**
  - Criar a rota `/profile/favorites` com `FavoritesPage`.
  - A página busca `AppState.profile.favoriteIds` e exibe um grid/lista de startups correspondentes.
  - Cada card da startup é clicável e navega para `/startup/{id}`.

---

## 4. Pesquisa Global de Startups ⬜

### 4.1 Barra de Pesquisa em Startups e Investimentos
- **Problema:** Não existe campo de busca de startups em nenhuma das telas.
- **Solução:**
  - Adicionar `SearchBar` (widget nativo Flutter 3.x) no topo das telas:
    - **Catálogo de Startups** (`/catalog`)
    - **Tela de Investimentos** (`/investimentos`) — para buscar no portfólio
  - Filtro realizado **no cliente** (não requer nova Cloud Function): filtrar a lista já carregada pelo nome da startup (case-insensitive).
  - Opcional: adicionar filtro por setor (Tecnologia, Saúde, etc.) usando chips horizontais acima da lista.

---

## 5. Infraestrutura / Já Concluído ✅

| Item | Status |
|------|--------|
| `onGetOrderBook` — fix Timestamp `toDate()` | ✅ |
| `OrderBookPage` → `StatefulWidget` com refresh | ✅ |
| `CreateOrderDialog` como modal na tela | ✅ |
| `ProfileController` / `BalcaoController` — fix "used after dispose" | ✅ |
| `onGetOrderBook` exportado em `index.ts` | ✅ |
| Seed de 30 ordens (`seed-orders.ts`) | ✅ |
| Nome "Investimentos" (ex-Balcão) | ✅ |
| Ordens pendentes visíveis em "Meus Investimentos" | ✅ |
| Autoria do commit "Improve project folder structure" alterada | ✅ |

---

## 6. Ordem de Execução Sugerida

```
Prioridade ALTA (estabilidade e lógica core):
  1. [2.1] Revisar e corrigir lógica de match de ordens
  2. [2.3] Reorganizar UI de Meus Investimentos

Prioridade MÉDIA (UX e navegação):
  3. [3.1] Minha Carteira → /investimentos
  4. [1.6] Favoritos com ícone de estrela + tela no Perfil
  5. [4.1] Barra de pesquisa de startups
  6. [1.3] Botões Comprar/Vender da Home funcionais

Prioridade BAIXA (dados reais):
  7. [1.2 + 1.4 + 1.5] Snapshots de portfólio + gráfico real + rentabilidade real
  8. [1.1] Sistema de Notificações
```
