# Sprint 6: Onboarding, Autenticação e Verificações (High-Fidelity)

## Visão Geral
A porta de entrada do aplicativo. O fluxo de entrada deve prever cadastro com Email e Senha (com forte validação), validação adicional via SMS/OTP (para segurança), captura biométrica, e envio de documentos KYC (crucial para Motoristas).

## Tarefas (Task Breakdown)

### Task 6.1: Autenticação, OTP (SMS), e Biometria
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: `login_screen.dart`, `forgot_password_screen.dart`
- **OUTPUT**: Tela de inserção do código OTP de 4 ou 6 dígitos usando `pinput`. Este componente de SMS atuará depois do cadastro / login bem-sucedido com e-mail/senha. Adicionar Tela de "Esqueci Minha Senha" enviando link ou OTP para e-mail. Adicionar também ativação de `FaceID/TouchID` usando `local_auth`.
- **VERIFY**: Campos OTP transferem foco automaticamente e permitem auto-preenchimento. Envio de e-mail de recuperação de senha exibe notificação de sucesso.

### Task 6.2: Driver Document Scanner & Selfie (UI de KYC)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Fluxo de criação de conta do Motorista.
- **OUTPUT**: UI para KYC completo. 1) Tela para digitalizar a **CNH** e CRLV abrindo um `CameraPreview` com overlays (bordas brancas) indicando alinhamento. 2) Tela para capturar uma **Foto do Usuário (Selfie)** garantindo compatibilidade biométrica facial futura.
- **VERIFY**: O processo deve permitir tirar foto da CNH e Selfie, visualizar o preview, re-tirar a foto se ficar borrada e, ao aprovar, avançar para a tela de "Em Análise".

### Task 6.3: Apresentação (Walkthrough/Carousel) Otimizada
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Telas Iniciais.
- **OUTPUT**: Um carrossel suave (`PageView`) explicando as 3 vantagens do Ride-Hailing, com pontos indicadores (`DotsIndicator`) na base que crescem/esticam baseados no percentual do scroll.
- **VERIFY**: Scroll suave acompanhado de animações lottie no centro da tela para cada página do tutorial.

### Task 6.4: Fluxo de Cadastro (Email e Senha)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: `signup_screen.dart`
- **OUTPUT**: Tela de cadastro em fluxo de passos (Stepper/PageView). Fase 1: Seleção de Perfil (Passageiro vs Motorista). Fase 2: Email e Senha (validação `FormState`). Fase 3: Dados Pessoais e Diferenciação. Se Motorista, solicitar explicitamente o **CPF** validado e o encaminhar para a *Task 6.2* (Envio de CNH e Selfie).
- **VERIFY**: Passageiro pula a leitura de documentos e finaliza cadastro mais rápido. Motorista é obrigado a fornecer CPF válido, Foto da CNH e Selfie antes de o cadastro ser submetido ao backend.

### Task 6.5: Integração de Autenticação e State Management (JWT)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Camada de lógica BLoC/Riverpod e repositório da API (ex: `AuthRepository()`).
- **OUTPUT**: Implementação completa do controle de estado: `AuthInitial`, `AuthUnauthenticated`, `AuthInRegistration`, `AuthAuthenticated`. Uso de `flutter_secure_storage` para salvar localmente o `access_token` e o `refresh_token` gerados pela API DRF (Django).
- **VERIFY**: Reiniciar o aplicativo pula o Onboarding caso o JWT esteja válido na memória segura do dispositivo. O status "Autenticado" direciona direto para o mapa.
