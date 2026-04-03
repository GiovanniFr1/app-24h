# 🎨 Componentes Reutilizáveis & Widgets

**Documento:** Mapeamento de Components Frontend
**Data:** 2026-04-03

---

## 📦 Shared Widgets

### 1️⃣ **CustomButton**
**Arquivo:** `lib/shared/widgets/custom_button.dart`

```dart
CustomButton({
  required String text,
  required VoidCallback onPressed,
  IconData? icon,
  bool isLoading = false,
})
```

**Uso:**
- Botões primários com gradient
- Suporta ícone + texto
- Estado loading com spinner
- Border radius: 9999px (pill shape)

**Aparência:**
```
┌────────────────────────┐
│  [Icon] TEXT           │
└────────────────────────┘
```

---

### 2️⃣ **BuscadorBairroSheet**
**Arquivo:** `lib/shared/widgets/buscador_bairro_sheet.dart`

**Funcionalidade:**
- BottomSheet com lista de bairros
- Seleção de destino
- Exibe: Nome, distância, multiplicador, periculosidade

**Entrada:**
```dart
List<Map<String, dynamic>> bairros = [
  {
    'nome': 'Centro',
    'distanciaKm': 1.5,
    'multiplicador': 1.0,
    'periculosidade': 'Baixa'
  },
  // ...
]
```

**Retorno:** Selected bairro map

---

### 3️⃣ **DriverInfoCard**
**Arquivo:** `lib/shared/widgets/driver_info_card.dart`

**Exibe:**
- Avatar do motorista
- Nome + Avaliação ⭐
- Placa do veículo
- Status

```
┌──────────────────────┐
│ [Avatar] João ⭐⭐⭐⭐⭐
│          ABC-1234    │
│          🟢 Online   │
└──────────────────────┘
```

---

### 4️⃣ **TripStatusCard**
**Arquivo:** `lib/shared/widgets/trip_status_card.dart`

**Estados Exibidos:**
- Aceito: Motorista + ETA
- Chegou: "Motorista chegou"
- Em trânsito: Destino + Distância

```
┌─────────────────────────┐
│ [Avatar] João           │
│ A 800m (5 min)          │
│ Destino: Taquari        │
│ [Cancelar] [Chat]       │
└─────────────────────────┘
```

---

### 5️⃣ **TripCompletedSheet**
**Arquivo:** `lib/shared/widgets/trip_completed_sheet.dart`

**Exibe:**
- Recibo detalhado
- Valor total + Breakdown
- Avaliação do motorista
- Botões: Compartilhar / Finalizar

```
┌──────────────────────────┐
│ ✓ Corrida Finalizada     │
│                          │
│ De: Centro → Taquari     │
│ Distância: 4.2 km       │
│ Tempo: 12 min           │
│                          │
│ Tarifa Base:    R$ 5,00 │
│ Distância:      R$ 6,30 │
│ ─────────────────────    │
│ Total:         R$ 11,30 │
│                          │
│ [Avaliar] [Compartilhar]│
└──────────────────────────┘
```

---

### 6️⃣ **NovaCorridaAlert**
**Arquivo:** `lib/shared/widgets/nova_corrida_alert.dart`

**Exibido em:** DriverHomeScreen (quando há novo chamado)

```
┌──────────────────────────┐
│ 🆕 NOVA CORRIDA!         │
│                          │
│ De: Centro (a 800m)      │
│ Para: Taquari            │
│                          │
│ ⏱️ 12 min aprox.         │
│ 📍 4.2 km               │
│ 💰 R$ 18,50             │
│                          │
│ [ACEITAR] [RECUSAR]      │
└──────────────────────────┘
```

---

## 🎭 Padrões de UI

### Modal Glassmorphism
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      color: AppTheme.surfaceContainer.withValues(alpha: 0.8),
    ),
  ),
)
```

**Usado em:**
- Top bar (Home + Driver)
- Ganhos display (Driver)
- Status online/offline

### Bento Grid Layout
```
┌─────────┬─────────┐
│ Item 1  │ Item 2  │
├─────────┴─────────┤
│ Item 3 (Full)     │
└───────────────────┘
```

**Usado em:**
- Payment methods (ProfileSetup)
- Safety options (Home)
- Shortcuts (Home)

---

## 🔌 Providers (Riverpod)

### 1. rideRequestProvider
```dart
final rideRequestProvider = StateNotifierProvider<
  RideRequestNotifier,
  RideRequestState
>((ref) => RideRequestNotifier(ref));

// Estados: initial, searching, accepted, inTransit, completed, error
```

### 2. firebaseAuthServiceProvider
```dart
// Methods:
- signInWithPhoneNumber()
- signInWithEmailAndPassword()
- registerWithEmailAndPassword()
- signInWithGoogle()
- verifyPhoneNumber()
- verifyOtp()
- logout()
```

### 3. firestoreUserRepositoryProvider
```dart
// Methods:
- getUserProfile()
- setRole(role, cpf?, cnh?)
- updateProfile(name?, email?, etc)
```

### 4. tripServiceProvider
```dart
// Methods:
- getTrips()
- acceptTrip(id)
- startTrip(id)
- completeTrip(id)
```

---

## 🎯 Estados de Inputs

### TextInput Estados:
```
Normal:        ┌─────────────────┐
               │ Insira valor    │
               └─────────────────┘

Focused:       ┌═════════════════┐  (Border primary)
               │ Typing...       │
               └═════════════════┘

Error:         ┌─────────────────┐
               │ Erro!           │  (Red text)
               └─────────────────┘

Disabled:      ┌─────────────────┐  (Greyed out)
               │ (Disabled)      │
               └─────────────────┘
```

### Button Estados:
```
Default:       ──────────────────
               │  SAVE AND GO   │
               ──────────────────

Hover:         ══════════════════
               │  SAVE AND GO   │  (Elevated)
               ══════════════════

Loading:       ──────────────────
               │ Aguarde... ⟳  │
               ──────────────────

Disabled:      ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
               │ (Greyed out)   │
               ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
```

---

## 🗺️ Wireframes por Tela

### HomeScreen - Full Flow

**Estado 1: Seleção de Destino**
```
┌─────────────────────────────┐
│ [☰] [L] [👤]                │
│ ┌───────────────────────────┤
│ │∼∼∼∼∼ Google Map ∼∼∼∼∼       │
│ │                           │
│ │                           │
│ │              [🗺️ My Loc]  │
│ │                           │
│ │ ┌─────────────────────┐  │
│ │ │ "Para onde?"        │  │
│ │ │ [🔍 Insira destino] │  │
│ │ │ [🏠 Casa 15m] [🏢] │  │
│ │ │ ATIVIDADE RECENTE   │  │
│ │ │ [📍 Ace Coffee...] │  │
│ │ └─────────────────────┘  │
│ └─────────────────────────────┘
│ [CORRIDA] [ATIV] [CART] [PERF] │
└─────────────────────────────────┘
```

**Estado 2: Seleção de Tipo de Moto**
```
┌─────────────────────────────┐
│ [☰] [L] [👤]                │
│ ┌───────────────────────────┤
│ │ Map (rota visível)      │
│ │                         │
│ │ ┌─────────────────────┐ │
│ │ │ Selecione sua moto  │ │
│ │ │⬜ Moto Standard R$ 15│ │
│ │ │⬜ Moto Comfort  R$ 21│ │
│ │ │⬜ Moto Express  R$ 29│ │
│ │ │─────────────────────│ │
│ │ │ [💳 •••• 4242]      │ │
│ │ │ [REQUEST BTN]       │ │
│ │ └─────────────────────┘ │
│ └─────────────────────────────┘
```

**Estado 3: Procurando Motorista**
```
┌─────────────────────────────┐
│ [☰] [L] [👤]                │
│ │∼∼∼∼∼ Google Map ∼∼∼∼∼       │
│ │                           │
│ │         [Radar Anim]      │
│ │      Procurando...        │
│ │      ⚫ 3 pilotos próx.    │
│ │                           │
│ │  [CANCELAR PEDIDO]        │
│ │  Sem taxa (2 min)         │
│ └─────────────────────────────┘
```

**Estado 4: Motorista Aceito**
```
┌─────────────────────────────┐
│ [☰] [L] [👤]                │
│ │Map com rota + Motorista     │
│ │                           │
│ │ ┌───────────────────────┐ │
│ │ │ [Avatar] João ⭐⭐⭐⭐⭐ │ │
│ │ │ ABC-1234, Honda CG   │ │
│ │ │ A 3 min (800m)       │ │
│ │ │ [Chat] [Share]       │ │
│ │ │ [CANCELAR CORRIDA]   │ │
│ │ └───────────────────────┘ │
│ └─────────────────────────────┘
```

**Estado 5: Corrida Finalizada**
```
┌─────────────────────────────┐
│ [☰] [L] [👤]                │
│ │Map                          │
│ │                           │
│ │ ┌───────────────────────┐ │
│ │ │ ✓ CORRIDA FINALIZADA │ │
│ │ │                      │ │
│ │ │ Centro → Taquari     │ │
│ │ │ 4.2 km • 12 min      │ │
│ │ │ Base R$ 5,00         │ │
│ │ │ Dist R$ 6,30         │ │
│ │ │ Total R$ 11,30       │ │
│ │ │ [AVALIAR] [FAV]      │ │
│ │ └───────────────────────┘ │
│ └─────────────────────────────┘
```

---

### DriverHomeScreen - Estados

**1. Offline**
```
┌──────────────────────────┐
│ [☰] Moto Acre [👤]       │
│                          │
│ Map (CINZA - DESATIVADO) │
│                          │
│ ┌──────────────────────┐ │
│ │      [Radar]        │ │
│ │ Fique online para    │ │
│ │ receber chamados     │ │
│ │                      │ │
│ │ [GO - Ativar Online] │ │
│ └──────────────────────┘ │
└──────────────────────────┘
```

**2. Online (Aguardando)**
```
┌──────────────────────────┐
│ 💰 R$ XX,XX                │
│ Você está Online ◉ ⚪───   │
│                          │
│ Map (Normal) com heatmap│
│                          │
│ ┌──────────────────────┐ │
│ │      [Radar]        │ │
│ │ Aguardando chamados  │ │
│ │ Zonas: destacadas    │ │
│ │                      │ │
│ │ [SIMULAR CHAMADO]    │ │
│ └──────────────────────┘ │
└──────────────────────────┘
```

**3. A Caminho (Pickup)**
```
┌──────────────────────────┐
│ 💰 R$ XX,XX                │
│ Você está Online ◉ ⚪───   │
│                          │
│ Map + Marcador Passageiro│
│ ┌─ Rota ────────────┐   │
│ │ Centro → Taquari  │   │
│ └───────────────────┘   │
│ ┌──────────────────────┐ │
│ │ [Avatar] Passageiro  │ │
│ │ Embarque: Centro     │ │
│ │ [Chat Button]        │ │
│ │ [CHEGUEI NO LOCAL]   │ │
│ └──────────────────────┘ │
└──────────────────────────┘
```

**4. Em Viagem**
```
┌──────────────────────────┐
│ 💰 R$ XX,XX                │
│ Você está Online ◉ ⚪───   │
│                          │
│ Map + Polyline (rota)   │
│                          │
│ ┌──────────────────────┐ │
│ │ Destino: Taquari     │ │
│ │ Faltam 4.2 km        │ │
│ │ ~12 min              │ │
│ │                      │ │
│ │ [FINALIZAR CORRIDA]  │ │
│ └──────────────────────┘ │
└──────────────────────────┘
```

---

## 📐 Dimensões & Spacing

| Elemento | Dimensão |
|----------|----------|
| AppBar height | 60-100px |
| Avatar (circle) | 40-120px |
| Card padding | 16-24px |
| Button height | 48-56px |
| Icon size | 16-48px |
| Corner radius | 12-9999px |
| Bottom sheet padding | 24px |
| Gap horizontal | 12-24px |
| Gap vertical | 8-32px |

---

## 🎬 Animações Principais

### 1. Radar Scan (SearchingDriver)
```
Duration: 4s
Loop: true
─
Scale: 1.0 → 2.5 (opacity 0.6 → 0)
Rotation: 0° → 360°
─
Effect: Pulse + Scan lines
```

### 2. Page Transitions
```
MaterialPageRoute
- Slide from right
- Duration: 300ms
```

### 3. AnimatedSize (Estado Container)
```
Duration: 300ms
Curve: easeInOut
─
Muda tamanho ao trocar estado
(Initial → Ride Selection → Status)
```

### 4. AnimatedSwitcher (Content Switch)
```
Duration: 300ms
─
Troca conteúdo ao mudar estado
```

---

## 🌍 Mapas & Coordenadas

### Rio Branco (Brazil)
```
Latitude:  -9.97499
Longitude: -67.8243
Zoom:      13.5
```

### Bairros (Mock Data)
```
Centro       → -9.97499, -67.8243 (Baseado)
Bosque       → 3.2 km
Placas       → 5.8 km
Cidade Nova  → 8.5 km
Taquari      → 12.4 km
```

### Heatmap Zones (Driver)
```
Zona 1: [-9.9695, -67.8220], radius: 450m
Zona 2: [-9.9810, -67.8320], radius: 520m
Zona 3: [-9.9660, -67.8380], radius: 380m
```

---

## 💬 Copy/Textos Principais

| Tela | Texto |
|------|-------|
| PhoneVerif | "Qual seu número?" |
| OtpVerif | "Enter the code" |
| ProfileSetup | "Create your Rider Profile" |
| HomeScreen | "Para onde?" |
| DriverHome | "Aguardando solicitações..." |
| SearchDriver | "Procurando pilotos..." |
| Earnings | "Ganhos" |

---

## 🔗 Dependências de UI

```yaml
flutter_riverpod:          # State
google_maps_flutter:       # Maps
google_fonts:              # Typography
fire_base_auth:            # Auth
cloud_firestore:           # DB
image_picker:              # Images (future)
geolocator:                # GPS (future)
lucide_icons:              # Icons (Stats)
```

---

**Última atualização:** 2026-04-03
**Status:** ✅ Mapeamento Completo
