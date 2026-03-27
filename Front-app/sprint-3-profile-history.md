# Sprint 3: User Profile, Gamification & History UI

## Visão Geral
Expandindo as configurações para reter o interesse a longo prazo (Gamificação) e construir confiança com o registro de viagens (Histórico e Recibos).

## Tarefas (Task Breakdown)

### Task 3.1: Hub de Gamificação e Níveis (Passageiro e Piloto)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: `profile_setup_screen.dart` convertido em "Gestão de Conta".
- **OUTPUT**: A aba de perfil agora exibe, além dos dados, os "Tiers" ou Níveis. Para o Passageiro, métricas como "Passageiro Ouro (Avaliação 4.9)", e para o Motorista exibe Conquistas de *Streaks* (ex: "Complete 3 corridas seguidas e ganhe um multiplicador").
- **VERIFY**: Inserção visual clara do sistema de Tiers usando as cores premium e neutras do Velocity Noir para denotar progresso de conta. 

### Task 3.2: Carteira Elegante e Input Formatters
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Tela de Configuração de Pagamento atual (`profile_setup_screen`).
- **OUTPUT**: Construção visual do Cartão de Crédito digital na tela. Usar máscaras (Masked Input Formatter) para MM/YY, CVV e Cartão. Preparação da tela de "Gerar QR Code Pix Simulador" ao fim da corrida na interface de passageiro.
- **VERIFY**: A digitação de números insere os espaços sozinhos automaticamente em blocos de 4 dígitos.

### Task 3.3: Histórico de Alto Padrão
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-performance`
- **INPUT**: Nada (Nova tela de Histórico).
- **OUTPUT**: Um `ListView.builder` de cards condensados. Eles exibem mini-mapas de imagem estática mockada, os valores e os status (Cancelado cor Vermelha / Finalizado cor Verde). Paginação simulando Spinner no fim do Scroll.
- **VERIFY**: Transição sedosa de scroll mesmo populando a lista com 50+ itens lixões (mockados).

## Phase X: Verifications
- [ ] Layout "SliverAppBar" operante na tela de perfil para efeito expandível responsivo na foto do usuário.
