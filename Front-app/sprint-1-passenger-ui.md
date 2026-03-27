# Sprint 1: Core Passenger App UI & Navigation (Advanced UX)

## Visão Geral
Sprint focada na experiência fluida e segura do Passageiro. Aplicando a lei da "Carga Cognitiva Reduzida", a Home foca quase inteiramente no mapa, com integrações cruciais de segurança e transparência financeira.

## Tarefas (Task Breakdown)

### Task 1.1: A Abordagem Minimalista "Where To?" (Home)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: `home_screen.dart` atual e SDK do Google Maps.
- **OUTPUT**: Um bottom sheet limpo consumindo apenas 20% da tela inicial, contendo uma barra de pesquisa arrojada "Para onde vamos?". O mapa assume o protagonismo total da tela (80%).
- **VERIFY**: O mapa é renderizado expansivamente atrás de um BottomSheet flutuante responsivo.

### Task 1.2: Transparência de "Surge Pricing" (Seleção de Corrida)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: UI de seleção de categorias.
- **OUTPUT**: UI traçando a rota (Ponto A a B) preenchida com os cards de valores. Se a demanda mockada for "alta", um selo ou ícone neon brilhante (Alta Demanda) de alerta deve surgir sutilmente ao lado dos preços de certas categorias.
- **VERIFY**: O usuário visualiza claramente que o preço atualizado tem um modificador de demanda, evitando surpresas.

### Task 1.3: O Escudo de Segurança (Trust & Safety Toolbar)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: `searching_driver_screen.dart` e `trip_completed_sheet.dart`.
- **OUTPUT**: Inserção de um Ícone/Escudo persistente (Safety UI) no canto superior da tela durante toda a viagem ativa. Ao tocar, abre um mini-modal com atalhos de urgência mockados ("Compartilhar Rota", "Gravar Áudio", "Ligar para Polícia").
- **VERIFY**: O Escudo não sobrepõe informações cruciais do mapa e os atalhos abrem painéis de segurança claros e acessíveis na "Thumb Zone".

## Phase X: Verifications
- [ ] O usuário consegue pedir um carro usando o botão principal apenas com o polegar (Regra da Thumb Zone aplicada).
- [ ] Nenhum erro de overflow em dispositivos pequenos.
