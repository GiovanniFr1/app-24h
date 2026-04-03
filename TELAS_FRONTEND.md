# 📱 Mapeamento de Telas - Moto Acre Flutter

**Data:** 2026-04-03
**Aplicação:** App Moto Acre (Frontend Flutter)
**Status:** ✅ Análise Completa

---

## 📊 Resumo Executivo

- **Total de Telas:** 9
- **Fluxo Principal:** AuthGate → Login → Telefone/OTP → Profile Setup → Home (Passageiro/Motorista)
- **Tipos de Usuário:** Passageiro, Motorista
- **Padrão UI:** Material Design 3 + Dark Theme
- **Biblioteca de Mapa:** Google Maps Flutter
- **Gerenciamento de Estado:** Riverpod

---

## 🗺️ Fluxo de Navegação Geral

```
AuthGate (Verificação Auth)
├── LoginScreen (Múltiplas opções)
│   ├── Phone Verification
│   ├── Email/Password
│   └── Google/Apple OAuth
├── PhoneVerificationScreen → OtpVerificationScreen
└── ProfileSetupScreen (Role Selection)
    ├── → HomeScreen (Passageiro)
    └── → DriverHomeScreen (Motorista)
```

---

## 📋 Detalhamento das Telas

### 1️⃣ **AUTH GATE**
**Arquivo:** `lib/screens/auth_gate.dart`
**Tipo:** Roteador de Autenticação
**Acesso Direto:** Sim (Inicial)

#### Funcionalidade:
- Verifica estado de autenticação Firebase
- Redireciona para perfil baseado em role
- Loading states

#### Fluxo de Decisão:
```
Não Autenticado → LoginScreen
Autenticado + Profile Vazio → ProfileSetupScreen
Autenticado + role=='driver' → DriverHomeScreen
Autenticado + role≠'driver' → HomeScreen
```

#### Componentes:
- `StreamBuilder<User?>` - Monitora Firebase Auth
- `FutureBuilder` - Carrega perfil do Firestore
- `CircularProgressIndicator` - Loading

#### Dados Utilizados:
- `profile['role']` - Tipo de usuário
- `profile['is_driver']` - Flag de motorista

---

### 2️⃣ **LOGIN SCREEN**
**Arquivo:** `lib/screens/login_screen.dart`
**Tipo:** Tela de Autenticação Principal
**Navegação:** 3 caminhos principais

#### Layout:
```
┌─────────────────────────┐
│   Background (Gradient) │
│                         │
│        Logo             │
│                         │
│  [CONTINUAR TELEFONE]   │
│  [CONTINUAR EMAIL]      │
│  [GOOGLE] [APPLE]       │
│                         │
│      Disclaimer         │
└─────────────────────────┘
```

#### Funcionalidades:
- ✅ Login com Telefone → `PhoneVerificationScreen`
- ✅ Email/Password BottomSheet Modal
- ✅ Google OAuth Integration
- ✅ Apple OAuth (Placeholder)
- ✅ Auto-criação de conta se não existir

#### Campos de Email/Senha (BottomSheet):
- Etapa 1: Email Input
- Etapa 2: Password Input (após email confirmado)
- Tratamento de erros customizado

#### Cores/Tema:
- Background: `AppTheme.background`
- Botões: `AppTheme.primary`, `AppTheme.primaryContainer`
- Logo: Imagem Asset (260x260)

---

### 3️⃣ **PHONE VERIFICATION SCREEN**
**Arquivo:** `lib/screens/phone_verification_screen.dart`
**Tipo:** Verificação de Telefone
**Entrada:** -
**Saída:** `OtpVerificationScreen`

#### Layout:
```
┌──────────────────────────┐
│    [←] [LOGO] [ ]        │
├──────────────────────────┤
│ VERIFICATION             │
│ Qual seu número?         │
│ [Descrição de segurança] │
│                          │
│ [FLAG] [+55] [Número] ✏️│
│ (00) 00000-0000          │
│ [Info de privacidade]    │
│                          │
│ [Gradient Button: PRÓXIMO]
└──────────────────────────┘
```

#### Validação:
- Mínimo 10 dígitos
- Prefixo +55 automático (Brasil)
- Regex: `/\D/` remove caracteres não numéricos

#### Componentes:
- TextField com flag do Brasil (ícone)
- Info box com border left (4px, primary)
- Divisor visual entre país/número

#### Estados:
- Input inválido: Mensagem de erro
- Loading: Disabled button + spinner
- Sucesso: Navega para OTP

---

### 4️⃣ **OTP VERIFICATION SCREEN**
**Arquivo:** `lib/screens/otp_verification_screen.dart`
**Tipo:** Verificação de Código OTP
**Entrada:** `verificationId`, `phoneNumber`
**Saída:** `ProfileSetupScreen` ou Home (baseado em role)

#### Layout:
```
┌──────────────────────────┐
│    [←] [LOGO] [ ]        │
├──────────────────────────┤
│ VERIFICATION CODE        │
│ Enter the code           │
│ 6 digits sent to +55...  │
│                          │
│ [_] [_] [_] [_] [_] [_] │
│                          │
│ [Gradient Button: VERIFY]
└──────────────────────────┘
```

#### Funcionalidade:
- 6 TextFields (1 dígito cada)
- Auto-focus ao digitar
- Navegação entre campos (← → com backspace)
- Padrão Material 3

#### Validação:
- Requer 6 dígitos completos
- Verificação Firebase

#### Estados:
- Validação aguardando: Disabled button
- Código inválido: Mensagem erro
- Sucesso: Redireciona baseado em perfil

---

### 5️⃣ **PROFILE SETUP SCREEN**
**Arquivo:** `lib/screens/profile_setup_screen.dart`
**Tipo:** Configuração de Perfil Inicial
**Entrada:** Novo usuário após autenticação
**Saída:** Baseado em role (HomeScreen/DriverHomeScreen)

#### Layout - Seção 1: Role Selection
```
┌──────────────────────────┐
│ IDENTITY SETUP           │
│ Create your Rider Profile│
│                          │
│ Selecione seu perfil     │
│ [👤 Passageiro] [🏍️ Motorista]
│                          │
│        [Avatar - 120x120]│
│           [Edit Button]  │
└──────────────────────────┘
```

#### Campos Comuns (Todos):
1. **FULL NAME** - TextInput obrigatório
2. **EMAIL ADDRESS** - TextInput email
3. **CPF** - TextInput numérico (000.000.000-00)

#### Campos Adicionais - MOTORISTA (`if _selectedRole == 'driver'`):
- ANO DE FABRICAÇÃO (Veículo)
- QUANTIDADE DE PORTAS
- Switch: A/C (Ar-condicionado)
- Switch: CNH Definitiva (não PPD)
- Switch: EAR (Atividade Remunerada)
- Switch: Autorizo checagem antecedentes

#### Payment Methods (Bento Grid):
- 🟣 **PIX** - Confirmação instantânea
- 💳 **Credit Card** - Ending in ••• 4242
- 💵 **Cash** - Pagar após a corrida

#### Features UI:
- DEV Auto-fill Button (se `isDev == true`)
- Radio buttons para role/payment
- Custom Switch styling

#### Ações:
- **SAVE AND CONTINUE** - Valida e salva no Firestore

---

### 6️⃣ **HOME SCREEN** (Passageiro)
**Arquivo:** `lib/screens/home_screen.dart`
**Tipo:** Main Screen - Passageiro
**Mapa:** Google Maps + Marcadores
**Estado:** RideRequest Provider (Riverpod)

#### Layout - Estado Inicial:
```
┌─────────────────────────────┐
│ [☰] [LOGO] [👤]            │
│                             │
│ ╔═══ Google Map ════╗       │
│ ║                  ║[📍]   │
│ ║                  ║        │
│ ║                  ║        │
│ ╚══════════════════╝        │
│                             │
│ ┌─ Botão Meu Local ────┐   │
│                        │    │
│ "Para onde?" ┌────────┘    │
│ [🔍 Insira destino] │      │
│                            │
│ ┌─ Atalhos Bento ─────┐   │
│ │ [🏠 Casa 15m] [🏢 Trabalho]
│ │                    │    │
│ │ ATIVIDADE RECENTE  │    │
│ │ [📍 Ace Coffee...]│ │    │
│ └────────────────────┘    │
│                             │
│ ══ [CORRIDA] [ATIVIDADE]   │
│ ═══ [CARTEIRA] [PERFIL]    │
└─────────────────────────────┘
```

#### Dados do App:
- **Bairros:** Centro, Bosque, Placas, Cidade Nova, Taquari
- **Tarifa Base:** R$ 5.00
- **Valor/km:** R$ 1.50
- **Multiplicador por Bairro:** 1.0 a 2.5 (periculosidade)

#### Estados Principais:
1. **Initial** - Seleção de destino
2. **Ride Selection** - Escolhe tipo de moto
3. **Searching** - Procurando motorista (modal push)
4. **Accepted** - Motorista aceitou
5. **Driver Arrived** - Motorista chegou
6. **In Transit** - Viagem em curso
7. **Completed** - Viagem finalizada
8. **Error** - Erro na requisição

#### Componentes:
- GoogleMap (initialPosition: -9.97499, -67.8243)
- Trip Status Card
- Safety Center Button (modo escudo com backdrop blur)
- Bottom Sheet Animado
- Navigation Bar (4 tabs)

#### Tipos de Moto:
- 🏍️ **Moto Standard** - R$ `_valorFinal` (economia)
- 🏍️ **Moto Comfort** - R$ `_valorFinal * 1.4` (premium)
- ⚡ **Moto Express** - R$ `_valorFinal * 1.9` (mais rápida)

#### Safety Center (Quando em Viagem):
- 📍 Compartilhar Rota
- 🎙️ Gravar Áudio
- 🚔 Ligar para Polícia (190)

#### Widgets Utilizados:
- `BottomNavigationBar`
- `AnimatedSize`
- `BackdropFilter` (blur effect)
- `ClipRRect`
- `TripStatusCard`
- `TripCompletedSheet`

---

### 7️⃣ **DRIVER HOME SCREEN**
**Arquivo:** `lib/screens/driver_home_screen.dart`
**Tipo:** Main Screen - Motorista
**Mapa:** Google Maps com Heatmap & Polylines
**Estados:** DriverStatus (offline, online, aCaminho, embarque, emViagem)

#### Layout - Estado Online:
```
┌───────────────────────────┐
│ [☰] [Moto Acre] [ ]       │
│                           │
│ ╔═ Google Map (Gray) ═╗   │
│ ║     [Heatmap Zona]  ║   │
│ ║ ┌─ Ganhos Hoje ─┐   ║   │
│ ║ │ 💰 R$ X,XX   │   ║   │
│ ╚═════════════════════╝   │
│                           │
│ ┌─ Status Online ────────┐│
│ │ Você está Online ◉ ▬   ││
│ │ Zonas quentes         ││
│ └───────────────────────┘│
│                           │
│ ┌─────────────────────┐   │
│ │     Radar Icon      │   │
│ │ Aguardando...       │   │
│ │ [SIM: Chamado]      │   │
│ └─────────────────────┘   │
└───────────────────────────┘
```

#### Estados do Motorista:
```
DriverStatus {
  offline      → Mapa cinza, offline
  online       → Aguardando chamados
  aCaminho     → Indo buscar passageiro
  embarque     → Esperando embarque
  emViagem     → Em trânsito com passageiro
}
```

#### Componentes por Estado:

**🔴 Offline:**
- Botão: "GO" (ativar online)
- Mapa: Estilo cinza

**🟢 Online:**
- Status: "Você está Online"
- Toggle switch (online/offline)
- Heatmap zones no mapa (3 círculos com cores)
- Botão: "Simular Chamado"

**🟡 A Caminho:**
- Avatar + Nome Passageiro
- Localização embarque
- Botão: "CHEGUEI NO LOCAL"
- Chat button

**🟠 Embarque:**
- Ícone hail (levanta mão)
- Timer de espera
- Botão: "INICIAR CORRIDA"

**🔵 Em Viagem:**
- Destino + distância/tempo
- Polyline no mapa
- Botão: "FINALIZAR CORRIDA"

#### Ganhos:
- Widget de ganhos hoje (topo)
- Clicável → `DriverEarningsScreen`
- Atualiza ao finalizar corrida

#### Drawer:
- Nome motorista + veículo
- "Honda CG 160 • ABC-1234"
- Avatar circular
- Botão Logout (vermelho)

#### Heatmap (Hot Zones):
```javascript
[
  { center: [-9.9695, -67.8220], radius: 450m, color: #FFD54F },
  { center: [-9.9810, -67.8320], radius: 520m, color: #FF8F00 },
  { center: [-9.9660, -67.8380], radius: 380m, color: #91D500 }
]
```

#### Trip Model:
```dart
Trip {
  id: String
  origin: String
  destination: String
  price: double
  isPending: bool
}
```

---

### 8️⃣ **SEARCHING DRIVER SCREEN**
**Arquivo:** `lib/screens/searching_driver_screen.dart`
**Tipo:** Modal de Busca (Push Navigation)
**Entrada:** Após requisitar corrida
**Saída:** Motorista aceita ou cancela

#### Layout:
```
┌──────────────────────────┐
│ [☰] [LOGO] [👤]          │
│                          │
│  ╔════════════════════╗  │
│  ║   RADAR ANIM.      ║  │
│  ║ Procurando pilotos ║  │
│  ║ Conectando você... ║  │
│  ║  ┌─ ESPERA EST. ─┐ ║  │
│  ║  │ 2-4 MIN       │ ║  │
│  ║  └───────────────┘ ║  │
│  ║  ┌─ TRÂNSITO ────┐ ║  │
│  ║  │ Leve          │ ║  │
│  ║  └───────────────┘ ║  │
│  ║ ⚫ 3 Pilotos próx.  ║  │
│  ║   RASTREANDO 7G    ║  │
│  ╚════════════════════╝  │
│                          │
│ ┌─────────────────────┐  │
│ │ [✕ CANCELAR PEDIDO] │  │
│ │ Sem taxa (2min)     │  │
│ └─────────────────────┘  │
└──────────────────────────┘
```

#### Animações:
- **Radar:** 2 anéis pulsantes (escala 1.0 → 2.5, opacity: 0.6 → 0)
- **Varredura:** Linha giratória 360° (4s)
- **Cores:** Primary + Secondary

#### Informações Exibidas:
- Tempo espera estimado: 2-4 MIN
- Status trânsito: Leve
- Pilotos próximos: 3
- Setor rastreando: 7G

#### Ações:
- **Cancelar:** Remove ride, pop navigation
- Aviso: Sem taxa nos próximos 2 min

#### Glass Panels:
- Background: Dark + Border
- Backdrop blur effect
- Opacity: 0.7

---

### 9️⃣ **DRIVER EARNINGS SCREEN**
**Arquivo:** `lib/screens/driver_earnings_screen.dart`
**Tipo:** Dashboard Ganhos (Estatístico)
**Entrada:** Clique no widget de ganhos (DriverHomeScreen)
**Saída:** Pop/Navegação volta

#### Layout:
```
┌────────────────────────┐
│ [←] Ganhos            │
├────────────────────────┤
│ ┌──────────────────┐  │
│ │ Hoje             │  │
│ │ R$ XXXX,XX       │  │
│ │ ┌────────────────┤  │
│ │ │🏍️ 2   |🕐 1h12m│  │
│ │ │ Corridas|Online│  │
│ │ │⭐ 5.0          │  │
│ │ │Avaliação       │  │
│ └────────────────┘   │
│                       │
│ Próximo ao repasse   │
│ ┌─ Gráfico Barras ──┐│
│ │ █  █ █  █▓ █      ││
│ │ Seg Ter Qua Qui Sex││
│ └───────────────────┘│
│                       │
│ Atividades Recentes   │
│ ┌───────────────────┐ │
│ │✓ Moto Standard    │ │
│ │  Finalizada agora │ │
│ │  + R$ 18,50       │ │
│ └───────────────────┘ │
└────────────────────────┘
```

#### Dados Exibidos:

**Big Stats:**
- Ganhos totais hoje (R$)
- Número de corridas
- Tempo online (hh:mm)
- Avaliação média (⭐)

**Gráfico de Ganhos:**
- 5 barras semanais (Seg-Sex)
- Barra atual destacada (cor primary)
- Valores: 60, 100, 40, 130 (Qui), 80

**Atividades Recentes:**
- Lista de modalidades completadas
- Timestamp: "Finalizada agora"
- Valor: "+ R$ 18,50"
- Estado vazio: Mensagem

#### Props Recebidos:
```dart
DriverEarningsScreen(
  ganhosTotais: double,
  historicoModalidades: List<String> ['Moto Standard', 'Moto Comfort']
)
```

#### Componentes:
- `SingleChildScrollView`
- `ListView.builder` (dinâmico)
- Mini stat boxes (ícone + valor + label)
- Chart bars customizadas
- Dividers (linhas separadoras)

---

## 🎨 Design System

### Cores (AppTheme):
- **Primary:** `#6B5EFF` (Violeta)
- **Secondary:** `#FFC107` (Amarelo/Laranja)
- **Tertiary:** `#84DAFF` (Azul claro)
- **Background:** `#000000` (Preto)
- **Surface:** `#1A1B23` (Dark)
- **Error:** `#F44336` (Vermelho)

### Fonts:
- **Headlines:** Google Fonts - Plus Jakarta Sans (bold, w800)
- **Body:** Google Fonts - Inter (regular, w500)
- **Special:** Plus Jakarta Sans (italic para destaque)

### Border Radius Padrão:
- Buttons/Cards: 9999px (fully rounded)
- Containers: 16px-24px
- Top sheets: 32-40px

### Spacing:
- Horizontal padding: 24px
- Vertical gaps: 16px, 24px, 32px
- Border width: 1.5-2px

---

## 🔄 Fluxos de Usuário

### Fluxo Passageiro (Completo):
```
AuthGate
  ↓
LoginScreen (Telefone/Email/OAuth)
  ↓
PhoneVerificationScreen / OtpVerificationScreen
  ↓
ProfileSetupScreen (Seleciona Passageiro)
  ↓
HomeScreen (Mapa + Seleção Destino)
  ↓
Seleciona Bairro
  ↓
Seleciona Tipo de Moto
  ↓
SearchingDriverScreen (Procura motorista)
  ↓
Motorista Aceita
  ↓
HomeScreen (Trip Status: Accepted/In Transit)
  ↓
TripCompletedSheet (Avaliação + Recibo)
```

### Fluxo Motorista (Completo):
```
AuthGate
  ↓
LoginScreen (Telefone/Email/OAuth)
  ↓
PhoneVerificationScreen / OtpVerificationScreen
  ↓
ProfileSetupScreen (Seleciona Motorista + Dados Veículo)
  ↓
DriverHomeScreen
  ↓ (Toggle Offline → Online)
  ↓
Aguardando Chamados (Status: Online)
  ↓ (SnackBar: Novo Chamado)
  ↓
NovaCorridaAlert Modal
  ↓
Aceita/Recusa Corrida
  ↓ (Se aceita)
  ↓
DriverHomeScreen (Status: A Caminho)
  ↓
Clica "CHEGUEI" → Status: Embarque
  ↓
Clica "INICIAR" → Status: Em Viagem
  ↓
Clica "FINALIZAR" → Corrida Completa
  ↓
Atualiza Ganhos + Modal Sucesso
```

---

## 📡 Dados & Models

### RideRequest State (Provider):
```dart
enum RideRequestStatus {
  initial,      // Pronto para requisitar
  searching,    // Procurando motorista
  accepted,     // Motorista aceito
  driverArrived,// Motorista chegou
  inTransit,    // Em trânsito
  completed,    // Corrida finalizada
  error         // Erro na busca
}

class RideRequestState {
  final RideRequestStatus status;
  final String? origin;
  final String? destination;
  final double? price;
  final Map<String, dynamic>? driverInfo;
  final String? errorMessage;
}
```

### Trip Model:
```dart
class Trip {
  final String id;
  final String origin;
  final String destination;
  final double price;
  final bool isPending;
}
```

### Profile (Firestore):
```dart
{
  'uid': String,
  'name': String,
  'email': String,
  'phone': String,
  'role': 'passenger' | 'driver',
  'cpf': String,          // Se motorista
  'cnh': 'DEFINITIVA' | 'PPD',  // Se motorista
  'carYear': int,         // Se motorista
  'carDoors': int,        // Se motorista
  'paymentMethod': 'pix' | 'credit' | 'cash',
  'createdAt': Timestamp
}
```

---

## 🔐 Autenticação

### Métodos:
1. **Firebase Phone Auth** - SMS OTP (6 dígitos)
2. **Firebase Email/Password** - Auto-cria se não existir
3. **Google OAuth** - Via Firebase
4. **Apple OAuth** - Placeholder (não implementado)

### Token Storage:
- Local: `SharedPreferences` (via `token_storage.dart`)
- Remote: Firebase Auth Session

---

## 🌐 Navegação

### Padrão:
- `Navigator.push()` - Navegar
- `Navigator.pushReplacement()` - Substituir
- `showModalBottomSheet()` - Modals
- `Riverpod` - State listeners para auto-navegação

### Widgets de Navegação:
- Bottom Navigation (HomeScreen - 4 tabs)
- Drawer (DriverHomeScreen)
- App Bar com Botões

---

## 📊 Estatísticas UI

| Métrica | Valor |
|---------|-------|
| Telas Totais | 9 |
| Modals/BottomSheets | 5+ |
| Animações Complexas | 3 (Radar, Pulse, Scan) |
| Mapas Integrados | 2 (Home, Driver) |
| TextFields | 15+ |
| Bottões | 20+ |
| Cards/Containers | 50+ |

---

## 🚀 Tecnologias Utilizadas

```yaml
flutter_riverpod:    # State management
firebase_auth:       # Authentication
cloud_firestore:     # Backend
google_maps_flutter: # Maps
google_fonts:        # Typography
image_picker:        # Avatar upload (não implementado)
geolocator:          # Location services (tbd)
```

---

## 📝 Notas & Observações

- ✅ Layout responsivo com SafeArea
- ✅ Dark theme implementado
- ✅ Glassmorphism effects (BackdropFilter)
- ✅ Animações fluidas com AnimatedBuilder
- ✅ Estados de carregamento bem definidos
- ⚠️ Avatar upload não implementado
- ⚠️ Apple OAuth apenas placeholder
- ⚠️ Localização em tempo real (GPS) não integrado
- ⚠️ Avaliação/Rating não completa

---

## 📌 Próximas Etapas Recomendadas

1. Implementar upload de Avatar/Imagens
2. Integração GPS/Geolocalização
3. Sistema de Avaliação (Ratings)
4. Notificações Push (FCM)
5. Modo Offline (Local Cache)
6. Testes de Integração
7. Otimização de Performance
8. Documentação de API

---

**Gerado em:** 2026-04-03
**Versão:** 1.0
**Status:** Documentação Completa ✅
