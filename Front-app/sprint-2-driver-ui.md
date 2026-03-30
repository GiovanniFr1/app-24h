# Sprint 2: Core Driver App UI & Routing (Advanced UX)

## Visão Geral
Construir a interface do Motorista assumindo que ele está no trânsito. A interface deve ditar URGÊNCIA nas chamadas, clareza cirúrgica em rotas e gamificação nos lucros diários.

## Tarefas (Task Breakdown)

### Task 2.1: Painel "Ficar Online", Heatmaps e Dashboard de Ganhos
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Nova estrutura da `driver_home` mockada.
- **OUTPUT**: Botão imenso "GO" (Ficar Online). Adição de uma Pílula Verde persistente no topo exibindo os ganhos da diária (ex: "R$ 150,00 hoje"). Quando offline, o mapa fica dessaturado; quando online, manchas amarelas/vermelhas (Mock Heatmaps) aparecem no mapa instruindo-o a ir para zonas quentes.
- **VERIFY**: O mapa acende em resposta ao Toque em "GO" exibindo as áreas de alta demanda simuladas.
- **STATUS**: Implementado em `lib/screens/driver_home_screen.dart`.

### Task 2.2: O Anel Temporal Implacável (15s Accept Ring)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `touch-psychology`
- **INPUT**: Estado de aguardando nova chamada.
- **OUTPUT**: Modal Bottom Sheet hiper-invasivo sobrepondo 40% da tela inferior. Deve focar apenas em 3 dados cruciais: Preço Bruto, Distância até o cliente, e o Tempo de Viagem. No envolto do card, um anel visual (Ring Indicator) decrece em exatos 15 segundos.
- **VERIFY**: Se o motorista não interagir em 15 segundos, o modal retrocede automaticamente (simulando perda da corrida).
- **STATUS**: Implementado em `lib/shared/widgets/nova_corrida_alert.dart` e usado por `lib/screens/driver_home_screen.dart`.

### Task 2.3: Navegação Ativa e CTAs para Pilotos
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `touch-psychology`
- **INPUT**: Aceite da corrida da Sprint 2.2.
- **OUTPUT**: O mapa vira o guia de condução do Motorista. O botão inferior deve transformar-se em Botões Enormes Baseados no Estado ("CHEGUEI", "INICIAR A CORRIDA", "ENCERRAR VIAGEM"). Área de toque MÍNIMA de `64dp` para tolerar toques com luvas/vibração de moto.
- **VERIFY**: Todos os cliques principais da jornada de pilotagem podem ser dados "olhando de relance".
- **STATUS**: Implementado em `lib/screens/driver_home_screen.dart`.

## Phase X: Verifications
- [ ] Zonas de toque do motorista aprovadas por "Auditoria Cega" (fácil acerto táctil).
