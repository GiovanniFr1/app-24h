# Sprint 1: Core Passenger App UI & Navigation (Advanced UX)

## Visão Geral
Sprint focada na experiência fluida e segura do Passageiro. Aplicando a lei da "Carga Cognitiva Reduzida", a Home foca quase inteiramente no mapa, com integrações cruciais de segurança e transparência financeira.

## Tarefas (Task Breakdown)

### Task 1.1: A Abordagem Minimalista "Para onde?" (Home)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: `lib/screens/home_screen.dart` e `google_maps_flutter`.
- **OUTPUT**: Painel inferior compacto contendo um campo de destino "Insira o destino"; o mapa ocupa o fundo da tela.
- **VERIFY**: O mapa é renderizado como base e o painel inferior não sobrepõe o conteúdo principal.
- **STATUS**: Implementado em `lib/screens/home_screen.dart`.

### Task 1.2: Transparência de "Surge Pricing" (Seleção de Corrida)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: UI de seleção de categorias.
- **OUTPUT**: UI de seleção de corridas com cards de preço. Para bairros com periculosidade Alta ou Crítica, um selo "ALTA" aparece ao lado do preço.
- **VERIFY**: O usuário visualiza claramente que o preço atualizado tem um modificador de demanda.
- **STATUS**: Implementado em `lib/screens/home_screen.dart`.

### Task 1.3: O Escudo de Segurança (Trust & Safety Toolbar)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: `lib/screens/home_screen.dart`, `searching_driver_screen.dart` e `trip_completed_sheet.dart`.
- **OUTPUT**: Ícone de escudo persistente na fase de corrida ativa. Ao tocar, abre um modal com atalhos de segurança ("Compartilhar Rota", "Gravar Áudio", "Ligar para Polícia (190)").
- **VERIFY**: O Escudo não sobrepõe informações cruciais do mapa e os atalhos abrem painéis claros.
- **STATUS**: Implementado em `lib/screens/home_screen.dart`.

## Phase X: Verifications
- [x] O usuário consegue pedir um carro usando o botão principal apenas com o polegar (Regra da Thumb Zone aplicada).
- [ ] Nenhum erro de overflow em dispositivos pequenos. Requer testes práticos em telas pequenas; a implementação atual usa `SafeArea`, `Expanded` e `AnimatedSize`, então não há overflow evidente no layout atual.
