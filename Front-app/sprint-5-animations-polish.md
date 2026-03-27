# Sprint 5: UI/UX Audit, Hero Animations & Haptic Hype

## Visão Geral
O polimento absoluto e a compilação hiper otimizada. Transformando um código Flutter fluente em um "Candidato a App do Ano" nas lojas integrando animações customizadas e motores táteis.

## Tarefas (Task Breakdown)

### Task 5.1: Micro-Interações da Viagem (In-App Feedback)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Transições na viagen de Passageiro e Motorista.
- **OUTPUT**: Ao invés de o botão simplesmente mudar seu texto de "A Caminho" para "Cheguei", ele pulsa ou usa um *AnimatedSwitcher* de ícone deslizante. No Chat in-app simulado, as Quick Replies saltam animadas via *Staggered Animations* de baixo para cima.
- **VERIFY**: O visualizador entende a conversão de estado através de movimentos em `< 300 milisegundos`.

### Task 5.2: Fitts' Law Final & Haptic Feedback Pumping
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `touch-psychology`
- **INPUT**: Sprints Inteiras concluídas.
- **OUTPUT**: Injetar `HapticFeedback.lightImpact()` ao trocar Categorias de preço. Injetar `HapticFeedback.vibrate()` (Pesado) no momento do Anel de Corrida explodir na tela do motorista.
- **VERIFY**: O App parece ter *peso* e massa real ao interagir, devolvendo pequenas vibrações ao usuário e piloto de forma harmônica à identidade Noir.

### Task 5.3: Hero Animations Cinemáticas e Build do Motor Impeller
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-performance`, `deployment-procedures`
- **INPUT**: Codebase consolidada final.
- **OUTPUT**: Configurar widgets *Hero* para as as transições de imagem (ex: foto do motorista deslizando de lista para fullscreen). Adição do `Semantics` aos ícones para cegos/acessibilidade. Rodar flag do novo motor do Flutter (Impeller) explicitamente no iOS/Android manifest.
- **VERIFY**: Compilação Real (`flutter build apk --profile`) sem Janks e Drop Frames percebíveis nas animações Customizadas do bottom sheet principal.

## Phase X: Verifications
- [ ] Checagem técnica: Os FPS se mantém em $> 58fps$ rodando todos os flows E2E (Driver e Rider interlaçados localmente).
