# Sprint 9: Edge Cases & Tela de Erros Amigáveis (Graceful Failures)

## Visão Geral
Os designers projetam o caminho "Feliz", mas a engenharia real trata a internet oscilando, falta de GPS e falta de motoristas. Se cairmos com arte, o usuário não desinstala.

## Tarefas (Task Breakdown)

### Task 9.1: O Estado "No Internet" (Lottie Animators)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Provider global de Internet (conectividade).
- **OUTPUT**: Em vez de uma tela em branco com exceção vermelha, o aplicativo escorrega uma `SnackBar` vermelha "Sem conexão" ou, se a tela principal recarregar offline, mostra um lottie dinossauro/motinha quebrada altamente agradável.
- **VERIFY**: Integrar pacote `connectivity_plus` no mock e desligar os dados celular no Emulador testa essa tela em tempo real.

### Task 9.2: "Nenhum Motorista Próximo" e "Tente Novamente"
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `touch-psychology`
- **INPUT**: Animação de radar do passageiro terminada em Timeout sem aceites (Sprint 4).
- **OUTPUT**: Tela de erro macia dizendo "A demanda está altíssima no momento. Tente expandir a categoria ou aguardar uns minutinhos". Oferecer CTA sedutor ("Me avise quando liberarem motos").
- **VERIFY**: Botões de escape funcionais para o usuário voltar tranquilamente à tela Home sem o App parecer engasgado.

### Task 9.3: Shimmer Loaders Globais em Requisições
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-performance`
- **INPUT**: Todas as Futures e chamadas HTTP(s) simuladas do projeto.
- **OUTPUT**: Implementar o pacote `shimmer`. Substituir os rodopios nativos tristes (`CircularProgressIndicator`) por esqueletos cintilantes dos cards que as APIs ainda vão preencher (Ex: No Hitórico de Corridas ou no Carregamento do Perfil).
- **VERIFY**: A percepção de velocidade de abertura do App aumenta por indução psicológica (Hick's Law).
