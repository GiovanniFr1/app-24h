# Sprint 6: Onboarding, Autenticação e Verificações (High-Fidelity)

## Visão Geral
A porta de entrada do aplicativo. Para um app 100% completo, o fluxo de entrada deve prever captura biométrica, validação de SMS e envio de documentos (crucial para Motoristas).

## Tarefas (Task Breakdown)

### Task 6.1: Fluxo de OTP (SMS) e Biometria
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: `login_screen.dart`
- **OUTPUT**: Tela de inserção do código de 4 ou 6 dígitos com um pacote como `pinput` (com suporte simulado a auto-preenchimento nativo do iOS/Android). Tela de convite para ativar `FaceID/TouchID` usando o pacote `local_auth` com ícones animados de escaneamento.
- **VERIFY**: Campos de texto transferem o foco automaticamente ao digitar e o teclado numérico é fechado no 6º dígito.

### Task 6.2: Driver Document Scanner (UI de KYC)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Fluxo de criação de conta do Motorista.
- **OUTPUT**: UI de captura da CNH/CRLV. A tela abre um `CameraPreview` (usando o pacote `camera`) com overlays (bordas brancas) demarcando onde o motorista deve alinhar o documento. Flash/Toggle Câmera.
- **VERIFY**: Botão de "Tirar Foto" captura as bordas simuladas e apresenta fluxo de "Documento em Análise".

### Task 6.3: Apresentação (Walkthrough/Carousel) Otimizada
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Telas Iniciais.
- **OUTPUT**: Um carrossel suave (`PageView`) explicando as 3 vantagens do Ride-Hailing, com pontos indicadores (`DotsIndicator`) na base que crescem/esticam baseados no percentual do scroll.
- **VERIFY**: Scroll suave acompanhado de animações lottie no centro da tela para cada página do tutorial.
