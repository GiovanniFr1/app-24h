# Sprint 8: Support, In-App Chat & Help Center UI

## Visão Geral
Gerenciar frustrações é pilar da Retenção. Objetos perdidos, cobranças duplicadas, acidentes. Um projeto 100% precisa ter essas áreas prontas no frontend.

## Tarefas (Task Breakdown)

### Task 8.1: Chat In-App Integrado e Real-Time UX
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Flow de Corrida Ativa.
- **OUTPUT**: UI parecida com WhatsApp entre Piloto e Passageiro. Balões de fala reativos, indicadores de fita não-lida (Badge vermelho) sobre o ícone do motorista no mapa. Respostas automáticas em Pírolas (Quick Replies: "Estou esperando", "Estação de trem").
- **VERIFY**: Teclado abrindo não destrói a tela (*resizeToAvoidBottomInset* configurado corretamente). Rolagem forçada ao fim da mensagem nova simulada pelo Provider.

### Task 8.2: Central de Ajuda & Accordion FAQs
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Aba Perfil.
- **OUTPUT**: Uma tela longa rolável contendo categorias ("Corridas e Valores", "Conta", "Segurança"). Uso de *ExpansionTile/Accordion* limpos (sem a borda feia padronizada e com animações rotacionais na Seta Chevron).
- **VERIFY**: Tocar numa FAQ expande sem brusquidão arrastando o resto do conteúdo da tela graciosamente para baixo.

### Task 8.3: Floating Action FAB (Atendimento Bot/Humano)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Relatório de corrida problemática.
- **OUTPUT**: Interface interativa de Suporte com Bot. Layout imitando uma Thread guiada onde o usuário seleciona as cápsulas ("Cobrado a maior", "Objeto Perdido").
- **VERIFY**: Uma transição heróica quando o sistema entende e gera o número do ticket com checkmark verde final (Lottie).
