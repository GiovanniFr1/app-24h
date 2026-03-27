# Sprint 4: State Management (Riverpod) & Failure Workflows

## Visão Geral
Trazendo toda a lógica à vida estritamente do lado de cá (Front-end). Essa Sprint costura as ações separadas em um espetáculo Reativo de Estado Contínuo (StateNotifier), inclusive gerenciando de forma inteligente as perdas/recusas de conectividade.

## Tarefas (Task Breakdown)

### Task 4.1: Modelos e Async Repositories (The Mocks)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `clean-code`
- **INPUT**: Modelagem das lógicas criadas visualmente.
- **OUTPUT**: Pasta `/models` (Entidades base) e `/repositories/mock`. Os Repositórios contêm os tempos mortos simulativos (ex: `Future.delayed(Duration(seconds: 3))`).
- **VERIFY**: Mocks geram instâncias randômicas simulando diferentes variações de nomes e avaliações dos motoristas.

### Task 4.2: Riverpod Providers de Controle Massivo (RideState)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-architecture` (State Integration)
- **INPUT**: App inteiro.
- **OUTPUT**: O estado `CurrentRideProvider` determinará a visualização da tela principal usando `switch/case` e Enumerações (*Idle*, *Requesting*, *DriverMatch*, *EnRoute*, *Completed*).
- **VERIFY**: Botar "Procurar Moto" no passageiro efetua a mudança do estado de `Idle` $\rightarrow$ `Requesting`. O Bottom sheet troca automaticamente reativo a este provimento através da árvore de Widgets.

### Task 4.3: Simulação do Timeout do Motorista (Rejection Flow)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-debugging`/lógica complexa.
- **INPUT**: Provider da Corrida + Anel temporal de 15 segundos (Task 2.2).
- **OUTPUT**: O Estado Global do Mock dispara 15 segundos. O app Passageiro visualiza "Motorista Roberto encontrado". Caso o temporizador `Timer.periodic` mockado acabe na view do motorista fantasma, a tela do Passageiro reage ao novo Estado devolvendo-o para a animação Radar de "Procurando pilotos" automaticamente.
- **VERIFY**: Demonstração de robustez caso um motorista demore para aceitar, o passageiro não fica congelado ou trava num Bottom Sheet infinito.

## Phase X: Verifications
- [ ] Uso rígido do padrão `ref.watch` vs `ref.read` sem vazar a re-renderização por widgets imutáveis.
