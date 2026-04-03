# 🏗️ Arquitetura & Fluxogramas - Moto Acre Frontend

**Data:** 2026-04-03
**Última Revisão:** 2026-04-03

---

## 🎯 Visão Geral do Projeto

```
┌─────────────────────────────────────────────────────────┐
│              🏍️ APP MOTO ACRE - FRONTEND              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Plataforma de Ride-Sharing de Motos em Rio Branco      │
│  • Transport Urban / Delivery                           │
│  • Para Passageiros e Motoristas                        │
│  • Flutter + Firebase + Google Maps                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📱 Camadas da Arquitetura

```
┌────────────────────────────────────┐
│     PRESENTATION LAYER (UI)        │
│  • Screens (9 Telas)              │
│  • Widgets Compartilhados          │
│  • Theme & Styles                 │
└────────────────┬───────────────────┘
                 │
┌────────────────▼───────────────────┐
│   STATE MANAGEMENT (Riverpod)      │
│  • RideRequestProvider             │
│  • Auth Service Provider           │
│  • Trip Service Provider           │
│  • Firestore User Repository       │
└────────────────┬───────────────────┘
                 │
┌────────────────▼───────────────────┐
│     SERVICES & REPOSITORIES        │
│  • Firebase Auth Service           │
│  • Firestore User Repo             │
│  • Trip Service                    │
│  • Location Service                │
└────────────────┬───────────────────┘
                 │
┌────────────────▼───────────────────┐
│   EXTERNAL SERVICES & APIS         │
│  • Firebase Authentication         │
│  • Cloud Firestore                 │
│  • Google Maps API                 │
│  • Google Play Services            │
└────────────────────────────────────┘
```

---

## 🔄 Fluxo de Autenticação

```
START
  │
  ├─→ [AuthGate] ──┬─→ [No Auth] → LoginScreen
  │                │
  │                ├─→ [Auth + No Profile] → ProfileSetupScreen
  │                │
  │                └─→ [Auth + Profile] ─┬─→ role='driver'
  │                                       │
  │                                       ├─→ DriverHomeScreen
  │                                       │
  │                                       └─→ HomeScreen
  │
  └─→ USER LOGGED IN ✓
```

### Caminhos de Login

```
┌─────────────────────────────────────────┐
│         LoginScreen (Main)              │
├─────────────────────────────────────────┤
│                                         │
│  ┌─ PHONE AUTH ──────────────────────┐ │
│  │ [CONTINUAR COM TELEFONE]          │ │
│  │ → PhoneVerificationScreen         │ │
│  │ → OtpVerificationScreen           │ │
│  └─────────────────────────────────────┘ │
│                                         │
│  ┌─ EMAIL/PASSWORD ──────────────────┐ │
│  │ [CONTINUAR COM EMAIL] (BottomSheet)│ │
│  │ → Etapa 1: Email                  │ │
│  │ → Etapa 2: Senha                  │ │
│  │ → Auto-cria se não existir        │ │
│  └─────────────────────────────────────┘ │
│                                         │
│  ┌─ OAUTH ───────────────────────────┐ │
│  │ [GOOGLE] ✓ Implementado            │ │
│  │ [APPLE]  ✗ Placeholder            │ │
│  └─────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

---

## 👥 Decisão de Role

```
         ProfileSetupScreen
                │
        ┌───────┴───────┐
        │               │
     🚶 PASSENGER    🏍️ DRIVER
        │               │
        │               ├─→ Dados Veículo
        │               │   • Ano
        │               │   • Portas
        │               │   • A/C
        │               │
        │               ├─→ Dados CNH
        │               │   • Tipo (Def/PPD)
        │               │   • EAR
        │               │
        │               └─→ Background Check
        │
        ├─→ Payment Method
        │   • PIX
        │   • Credit Card
        │   • Cash
        │
        └─→ Profile Complete
            │
            ├─→ HomeScreen (if passenger)
            │
            └─→ DriverHomeScreen (if driver)
```

---

## 📊 Estado Global (Riverpod)

```
RideRequestProvider
├─ State:
│  ├─ status: RideRequestStatus
│  ├─ origin: String?
│  ├─ destination: String?
│  ├─ price: double?
│  ├─ driverInfo: Map?
│  └─ errorMessage: String?
│
└─ Notifier Methods:
   ├─ requestRide(origin, destination, price)
   ├─ cancelRide()
   ├─ onRideAccepted(driverInfo)
   └─ onRideError(message)
```

---

## 🏠 Fluxo Passageiro - Completo

```
HomeScreen (Inicial)
│
├─ Seleciona Bairro
│  ├─ BuscadorBairroSheet Modal
│  ├─ Seleção: Bairro
│  └─ Calcula Preço (Tarifa × Multiplicador)
│
├─ Seleciona Tipo de Moto
│  ├─ Standard: R$ price
│  ├─ Comfort: R$ price × 1.4
│  └─ Express: R$ price × 1.9
│
├─ Clica "Solicitar Moto Acre"
│  ├─ rideRequestProvider.requestRide()
│  ├─ Status → searching
│  └─ Push → SearchingDriverScreen
│
├─ SearchingDriverScreen (Modal)
│  ├─ Radar animation
│  ├─ Buscando pilotos...
│  ├─ Pode cancelar (sem taxa < 2min)
│  └─ Riverpod listener verifica aceitação
│
├─ Motorista Aceita
│  ├─ Status → accepted
│  ├─ Pop SearchingDriver
│  ├─ HomeScreen → TripStatusCard
│  ├─ Exibe: Nome, Placa, ETA motorista
│  └─ Passageiro pode confirmar localização
│
├─ Motorista Chega
│  ├─ Status → driverArrived
│  ├─ Card muda: "Motorista chegou"
│  └─ App pode notificar via push
│
├─ Passageiro Entra
│  ├─ Motorista clica "INICIAR CORRIDA"
│  ├─ Status → inTransit
│  ├─ HomeScreen: Rota + Timer
│  └─ Mapa atualiza em tempo real
│
├─ Destino Alcançado
│  ├─ Motorista clica "FINALIZAR CORRIDA"
│  ├─ Status → completed
│  ├─ Pop → TripCompletedSheet
│  └─ Exibe recibo + avaliação
│
└─ Fim da Corrida ✓
   ├─ Rating: ⭐⭐⭐⭐⭐
   ├─ Feedback textual (opcional)
   ├─ Recibo compartilhável
   └─ HomeScreen reset
```

---

## 🏍️ Fluxo Motorista - Completo

```
DriverHomeScreen
│
├─ Estado: OFFLINE (Padrão)
│  ├─ Switch: Off
│  ├─ Mapa: Cinza desaturado
│  ├─ Apenas botão "GO"
│  └─ Sem chamados
│
├─ Clica Switch → ONLINE
│  ├─ Status: online
│  ├─ Mapa: Normal (cores)
│  ├─ Heatmap zones aparecem
│  ├─ Widget online no topo
│  └─ Aguardando chamados...
│
├─ Novo Chamado Recebido
│  ├─ NovaCorridaAlert Modal (não dismissível)
│  ├─ Exibe: Origem, Destino, Distância, Preço
│  ├─ Marcadores + Polyline no mapa
│  ├─ 2 Botões: ACEITAR / RECUSAR
│  └─ Timer opcional (timeout)
│
├─ ACEITA Corrida
│  ├─ tripService.acceptTrip(tripId)
│  ├─ Status: aCaminho
│  ├─ Modal fecha
│  ├─ Card inferior muda
│  ├─ Exibe: Passageiro, localização embarque
│  └─ Botão: "CHEGUEI NO LOCAL"
│
├─ Chega no Embarque
│  ├─ Clica "CHEGUEI NO LOCAL"
│  ├─ Status: embarque
│  ├─ Card: "Aguardando embarque..."
│  ├─ Timer espera (HH:MM)
│  └─ Botão: "INICIAR CORRIDA"
│
├─ Inicia Corrida
│  ├─ tripService.startTrip(tripId)
│  ├─ Status: emViagem
│  ├─ Card: Destino + Distância/Tempo
│  ├─ Polyline destacada
│  └─ Botão: "FINALIZAR CORRIDA"
│
├─ Conclui Corrida
│  ├─ tripService.completeTrip(tripId)
│  ├─ Status: online (volta)
│  ├─ Atualiza _ganhosHoje
│  ├─ SnackBar: "+ R$ XX,XX adicionados!"
│  ├─ Limpa marcadores/polylines
│  └─ Pronto para próximo chamado
│
└─ Ciclo Contínuo
   ├─ Motorista fica online
   ├─ Aguarda próximos chamados
   ├─ Pode clicar em ganhos → DriverEarningsScreen
   └─ Pode logout via drawer
```

---

## 🗺️ Mapa de Navegação Hierárquico

```
APPLICATION ROOT
│
├─ AuthGate
│  │
│  └─ Decision Tree:
│     ├─ Not Authenticated → LoginScreen
│     │  ├─ Phone Path:
│     │  │  ├─ PhoneVerificationScreen
│     │  │  └─ OtpVerificationScreen
│     │  │
│     │  ├─ Email Path (Modal):
│     │  │  └─ Email + Password Input
│     │  │
│     │  └─ OAuth Path:
│     │     ├─ Google ✓
│     │     └─ Apple (disabled)
│     │
│     ├─ Authenticated + No Profile
│     │  └─ ProfileSetupScreen
│     │
│     └─ Authenticated + Profile
│        ├─ role == 'driver' → DriverHomeScreen
│        │  ├─ DrawerMenu
│        │  │  └─ Logout
│        │  └─ DriverEarningsScreen (modal push)
│        │
│        └─ role != 'driver' → HomeScreen
│           ├─ BuscadorBairroSheet (modal)
│           ├─ SearchingDriverScreen (platform)
│           └─ TripCompletedSheet (modal)
│
└─ Global Widgets
   ├─ CustomButton
   ├─ DriverInfoCard
   ├─ TripStatusCard
   ├─ TripCompletedSheet
   └─ NovaCorridaAlert
```

---

## 📍 Navegação por Tipo

| Tipo | De | Para | Método | Modal |
|------|----|----|--------|-------|
| Auth Flow | Login | Phone Verify | push | false |
| Verification | OTP | OTP Verify | push | false |
| Setup | Verify | Profile | replace | false |
| Role Decision | Profile | Home/Driver | replace | false |
| Destination | Home | Buscador | modal | true |
| Search | Home | Search Driver | push | false |
| Earnings | Driver | Earnings | push | false |
| Drawer | Driver | Menu | drawer | true |
| Completed | Home | TripSheet | modal | true |

---

## 🔐 Segurança & Autenticação

```
Client
  │
  ├─ [Local Storage]
  │  └─ Firebase Session Token (JWT)
  │
  ├─ Firebase Auth SDK
  │  ├─ Phone: SMS OTP (6 dígitos)
  │  ├─ Email: Password + Signup auto
  │  └─ Social: OAuth tokens (Google)
  │
  └─ Server-side (Firebase)
     ├─ UID gerado
     ├─ Profile criado (Firestore)
     └─ Cloud Functions (onUserCreate)
```

---

## 📲 Estados & Transições

```
RideRequestStatus Diagram:

INITIAL
  ↓
  ├─ requestRide() → SEARCHING
  │                      ↓
  │              driverAccepted() → ACCEPTED
  │                                    ↓
  │                              driverArrived() → DRIVER_ARRIVED
  │                                                      ↓
  │                                              tripStarted() → IN_TRANSIT
  │                                                                  ↓
  │                                                          tripCompleted() → COMPLETED
  │                                                                               ↓
  │                                                                         INITIAL (novo)
  │
  └─ cancelRide() → [Error State] → INITIAL
                    [Network Error]
                    [Driver Rejection]
```

---

## 🎨 Design System Hierarchy

```
AppTheme (core/theme.dart)
│
├─ Colors
│  ├─ Primary: #6B5EFF (Violeta)
│  ├─ Secondary: #FFC107 (Amarelo)
│  ├─ Tertiary: #84DAFF (Azul)
│  ├─ Error: #F44336 (Vermelho)
│  └─ Surface: #1A1B23 (Dark)
│
├─ Typography
│  ├─ Headlines: Plus Jakarta Sans (w800, italic)
│  ├─ Body: Inter (w500)
│  └─ Captions: Inter (w400)
│
├─ Components
│  ├─ Buttons: 56px height, 9999px radius
│  ├─ Cards: 16px radius, shadow
│  ├─ TextFields: 12px radius
│  └─ Bottom Sheets: 32px top radius
│
└─ Spacing Scale
   ├─ xs: 4px
   ├─ sm: 8px
   ├─ md: 12px
   ├─ lg: 16px
   ├─ xl: 24px
   └─ 2xl: 32px
```

---

## 🔗 Estrutura de Pastas

```
Front-app/lib/
│
├─ main.dart (App Root + Riverpod)
│
├─ screens/
│  ├─ auth_gate.dart (Router)
│  ├─ login_screen.dart
│  ├─ phone_verification_screen.dart
│  ├─ otp_verification_screen.dart
│  ├─ profile_setup_screen.dart
│  ├─ home_screen.dart (Passenger)
│  ├─ driver_home_screen.dart (Driver)
│  ├─ searching_driver_screen.dart
│  └─ driver_earnings_screen.dart
│
├─ core/
│  ├─ theme.dart (Design System)
│  ├─ api/
│  │  ├─ api_client.dart
│  │  └─ token_storage.dart
│  ├─ models/
│  │  └─ trip_model.dart
│  ├─ providers/
│  │  ├─ service_providers.dart (Riverpod)
│  │  └─ ride_request_provider.dart
│  ├─ services/
│  │  ├─ auth_service.dart (Interface)
│  │  ├─ firebase_auth_service.dart (Impl)
│  │  ├─ firestore_user_repository.dart
│  │  ├─ location_service.dart
│  │  └─ trip_service.dart
│  └─ dev/
│     └─ dev_utils.dart (Mock data)
│
├─ shared/
│  └─ widgets/
│     ├─ custom_button.dart
│     ├─ buscador_bairro_sheet.dart
│     ├─ driver_info_card.dart
│     ├─ trip_status_card.dart
│     ├─ trip_completed_sheet.dart
│     └─ nova_corrida_alert.dart
│
├─ firebase_options.dart (Config)
│
└─ pubspec.lock + pubspec.yaml
```

---

## 🚀 Fluxo de Deployment

```
Source (local)
  │
  ├─ Commit & Push
  │  └─ GitHub Branches
  │     ├─ feature/*
  │     ├─ develop
  │     └─ main
  │
  ├─ CI/CD (GitHub Actions)
  │  ├─ Lint Check
  │  ├─ Unit Tests
  │  ├─ Build APK
  │  └─ Build IPA
  │
  └─ Distribution
     ├─ Play Store (Android)
     └─ App Store (iOS)
```

---

## 📊 Métricas de Implementação

| Aspecto | Status | Nota |
|---------|--------|------|
| Telas Core | ✅ 100% | 9 telas implementadas |
| Auth | ✅ 95% | Phone + Email + Google OK, Apple placeholder |
| Maps | ✅ 100% | Google Maps integrado |
| State Mgmt | ✅ 100% | Riverpod com providers |
| UI/UX | ✅ 95% | Material 3 + Glassmorphism |
| Animações | ✅ 90% | Radar, Pulse, SwiftUI-like |
| Testing | ⚠️ 10% | Poucos testes |
| Docs | ✅ 100% | Este mapeamento |
| I18n | ❌ 0% | Apenas português |
| Offline | ❌ 0% | Requer implementação |

---

## 🔮 Roadmap Futuro

### Phase 1 (Q2 2026)
- [ ] Sistema de ratings/avaliações
- [ ] Notificações Push (FCM)
- [ ] GPS tracking em tempo real
- [ ] Tests (Unit + Integration)

### Phase 2 (Q3 2026)
- [ ] Modo offline + sync
- [ ] Histrico de corridas
- [ ] Payment integration
- [ ] Analytics

### Phase 3 (Q4 2026)
- [ ] Support dashboard
- [ ] Admin panel
- [ ] AR navigation
- [ ] Multi-language

---

## ✅ Checklist de Review

- [x] **Telas:** 9/9 implementadas
- [x] **Navegação:** Todos os fluxos mapeados
- [x] **Estados:** RideRequest + Auth definidos
- [x] **Componentes:** Reutilizáveis documentados
- [x] **Arquitetura:** Camadas definidas
- [x] **Design:** Theme + Spacing sistematizado
- [x] **Documentação:** Completa (este arquivo)
- [ ] **Testes:** Pendente
- [ ] **Performance:** Profiling necessário
- [ ] **Acessibilidade:** Revisar

---

**Documento Gerado:** 2026-04-03
**Versão:** 1.0
**Status:** ✅ Arquitetura Mapeada Completamente

---

## 📞 Contato & Support

Para dúvidas sobre a arquitetura ou mapeamento:
- Revisar `/TELAS_FRONTEND.md` - Detalhes por tela
- Revisar `/COMPONENTES_E_UI.md` - Componentes & UI
- Examinar arquivos `.dart` diretamente em `lib/screens/`

---

**FIM DO DOCUMENTO**
