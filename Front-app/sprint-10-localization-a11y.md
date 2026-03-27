# Sprint 10: Localization (i18n), Temas e Final A11y Audit

## Visão Geral
A embalagem para o lançamento internacional. Fazer com que o aplicativo suporte fluência em outras línguas, modos adaptativos AMOLED, e leitura absoluta por ferramentas nativas (Acessibilidade) completam os "100% Frontend".

## Tarefas (Task Breakdown)

### Task 10.1: Internacionalização e Arquivos ARB (i18n)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `i18n-localization`
- **INPUT**: Strings hardcoded do projeto (ex: "Confirmar Viagem Moto Acre").
- **OUTPUT**: Extrair todas as 250+ strings puras de Dart e isolar no pacote `flutter_localizations` via dicionários `app_en.arb`, `app_pt.arb`, `app_es.arb`.
- **VERIFY**: Alterando o idioma do Sistema Operacional (iOS Einstellungen -> Language) para Inglês, o App reinicia instantaneamente mudado de idioma sem "quebrar" ou dar clipping (*overflow*) visual.

### Task 10.2: Pure AMOLED Dark Theme
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: O arquivo `AppTheme` do Velocity Noir.
- **OUTPUT**: Refinamento adicional criando dois sub-temas escuros. O tema Escuro ("Gris/Dark") e o OLED Amoled ("Pitch Black"). Em OLED, todos os `#000000` economizam bateria, sendo uma configuração atraente aos usuários e motoristas.
- **VERIFY**: Botão acessível nas configurações e troca não demanda reinício do aplicativo.

### Task 10.3: O Lançador de "VoiceOver/TalkBack" Semantics
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-accessibility`
- **INPUT**: Telas primárias concluídas.
- **OUTPUT**: Preencher os nós do RenderTree onde avatares são ignorados por leitores de tela e campos de inserção não estão marcados. Implementar os widgets `ExcludeSemantics` na fumaça/grafismos não importantes e `Semantics` em imagens clicáveis essenciais (Ex: "Selecionar Motorista Categoria Executivo, valor 25 reais").
- **VERIFY**: Rodar a Ferramenta "Accessibility Scanner" do Android Studio e conseguir "zero sugestões" de alarme de usabilidade. App está pronto para 100% da população.
