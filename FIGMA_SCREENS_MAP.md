# 📐 Figma Screens Map - Moto Acre

**Formato:** Estrutura para Figma/Design Tools
**Data:** 2026-04-03
**Total de Frames:** 15 principais + variações

---

## 📋 Índice Hierárquico de Telas

```
Moto Acre App
├─ 01_Authentication
│  ├─ 01_LoginScreen
│  ├─ 02_PhoneVerificationScreen
│  ├─ 03_OtpVerificationScreen
│  └─ 04_ProfileSetupScreen
│
├─ 02_Passenger_Flow
│  ├─ 05_HomeScreen_Initial
│  ├─ 05a_HomeScreen_DestinationSelected
│  ├─ 05b_HomeScreen_RideTypeSelection
│  ├─ 05c_HomeScreen_SafetyCenter
│  ├─ 06_SearchingDriverScreen
│  ├─ 07_HomeScreen_TripInProgress
│  ├─ 07a_HomeScreen_TripCompleted
│  └─ 08_TripCompletedSheet
│
├─ 03_Driver_Flow
│  ├─ 09_DriverHomeScreen_Offline
│  ├─ 09a_DriverHomeScreen_Online
│  ├─ 09b_DriverHomeScreen_OnTheWay
│  ├─ 09c_DriverHomeScreen_Waiting
│  ├─ 09d_DriverHomeScreen_InTransit
│  ├─ 10_DriverEarningsScreen
│  └─ 11_NovaCorridaAlert
│
└─ 04_Components
   ├─ Components_CustomButton
   ├─ Components_Cards
   ├─ Components_Modals
   └─ Components_Icons
```

---

## 🎯 Ordem de Telas Linear (por fluxo do usuário)

### **Fluxo Passageiro (1º uso)**
1. **AuthGate** → (decisor, não visual)
2. **LoginScreen** → Principal
3. **PhoneVerificationScreen** → Input telefone
4. **OtpVerificationScreen** → Input OTP (6 campos)
5. **ProfileSetupScreen** → Role: Passageiro
6. **HomeScreen_Initial** → Mapa vazio
7. **HomeScreen_DestinationSelected** → Bairro selecionado
8. **HomeScreen_RideTypeSelection** → Eleição de moto
9. **SearchingDriverScreen** → Modal com radar
10. **HomeScreen_TripInProgress** → Status em tempo real
11. **TripCompletedSheet** → Recibo + Avaliação

### **Fluxo Motorista (1º uso)**
1. **AuthGate** → (decisor)
2. **LoginScreen** → Principal
3. **PhoneVerificationScreen** → Input telefone
4. **OtpVerificationScreen** → Input OTP
5. **ProfileSetupScreen** → Role: Motorista + veículo
6. **DriverHomeScreen_Offline** → Inicial
7. **DriverHomeScreen_Online** → Aguardando
8. **NovaCorridaAlert** → Novo chamado
9. **DriverHomeScreen_OnTheWay** → Indo buscar
10. **DriverHomeScreen_Waiting** → Esperando embarque
11. **DriverHomeScreen_InTransit** → Em viagem
12. **DriverEarningsScreen** → Dashboard ganhos

---

## 🖼️ Dimensões & Canvas

### Dimensionais Padrão (Mobile)

```json
{
  "device": "Mobile (360x800)",
  "safeAreaTop": 32,
  "safeAreaBottom": 24,
  "contentWidth": 360,
  "contentHeight": 744,
  "statusBarHeight": 24,
  "navigationBarHeight": 80,

  "frames": {
    "fullScreen": "360x800",
    "withAppBar": "360x728",
    "contentOnly": "360x640",
    "modalBottom": "360x600",
    "sheet": "360x400"
  }
}
```

---

## 📱 Frame Specifications

### **FRAME 01: LOGIN SCREEN**
```
Name: LoginScreen
Artboard: 360 × 800
Components:
├─ Background Layer (Gradient + Image)
│  └─ Overlay (Dark gradient)
├─ Logo Container (260 × 260)
├─ Button Group
│  ├─ ButtonPhone (56h, width: 100%)
│  ├─ ButtonEmail (56h, width: 100%)
│  └─ SocialButtons (Row of 2)
│     ├─ GoogleButton (56h, width: 48%)
│     └─ AppleButton (56h, width: 48%)
└─ Disclaimer Text (12px, bottom: 24px)

Colors Used:
- Background: #000000
- Primary: #6B5EFF
- Secondary: #FFC107
- Text: #FFFFFF
```

### **FRAME 02: PHONE VERIFICATION**
```
Name: PhoneVerificationScreen
Artboard: 360 × 800
Components:
├─ AppBar
│  ├─ BackButton
│  ├─ LogoImage (32h)
│  └─ OpenDrawerButton
├─ Content
│  ├─ Label: "VERIFICATION"
│  ├─ Title: "Qual seu número?"
│  ├─ Description (14px)
│  ├─ PhoneInput
│  │  ├─ CountryFlag (24 × 16)
│  │  ├─ "+55" Text
│  │  ├─ Divider
│  │  └─ PhoneTextField (Placeholder)
│  ├─ ErrorMessage (if needed)
│  └─ InfoBox (16px border-left)
│     ├─ Icon: verified_user
│     ├─ Title: "Privacidade garantida"
│     └─ Description
└─ BottomButton
   └─ GradientButton: "PRÓXIMO"

Padding: 24px horizontal, 16px vertical
```

### **FRAME 03: OTP VERIFICATION**
```
Name: OtpVerificationScreen
Artboard: 360 × 800
Components:
├─ AppBar (same as Frame 02)
├─ Content
│  ├─ Label: "VERIFICATION CODE"
│  ├─ Title: "Enter the code"
│  ├─ Description + Phone Number
│  ├─ OTPInputRow (6 TextFields)
│  │  ├─ Field_1 (48 × 56, 1 digit)
│  │  ├─ Field_2 (48 × 56, 1 digit)
│  │  ├─ Field_3 (48 × 56, 1 digit)
│  │  ├─ Field_4 (48 × 56, 1 digit)
│  │  ├─ Field_5 (48 × 56, 1 digit)
│  │  └─ Field_6 (48 × 56, 1 digit)
│  └─ ErrorMessage (if invalid)
└─ BottomButton
   └─ GradientButton: "VERIFY"

Spacing between digits: 12px
Border radius: 12px per field
```

### **FRAME 04: PROFILE SETUP**
```
Name: ProfileSetupScreen
Artboard: 360 × 800
Components:
├─ AppBar
├─ ScrollView Content
│  ├─ Header Section
│  │  ├─ Label: "IDENTITY SETUP"
│  │  ├─ Title: "Create your Rider Profile"
│  │  └─ RoleSelector (2 buttons side-by-side)
│  │     ├─ PassengerOption (active/inactive)
│  │     └─ DriverOption (active/inactive)
│  │
│  ├─ Avatar Section (Center)
│  │  ├─ CircleAvatar (120 × 120)
│  │  └─ EditButton (40 × 40, positioned bottom-right)
│  │
│  ├─ Form Fields
│  │  ├─ LabelGroup("FULL NAME")
│  │  ├─ TextInput("Enter your name")
│  │  ├─ LabelGroup("EMAIL ADDRESS")
│  │  ├─ TextInput("name@example.com")
│  │  ├─ LabelGroup("CPF")
│  │  └─ TextInput("000.000.000-00")
│  │
│  ├─ [Conditionally if Driver]
│  │  ├─ Divider
│  │  ├─ Label: "DADOS DO VEÍCULO E CNH"
│  │  ├─ TextInput("ANO DE FABRICAÇÃO")
│  │  ├─ TextInput("QUANTIDADE DE PORTAS")
│  │  ├─ Switch("Veículo possui Ar-Condicionado?")
│  │  ├─ Switch("CNH é Definitiva?")
│  │  ├─ Switch("CNH possui EAR?")
│  │  └─ Switch("Autorizo checagem antecedentes")
│  │
│  └─ Payment Methods (Bento Grid)
│     ├─ Label: "PREFERRED PAYMENT"
│     ├─ PaymentOption_PIX (selected state)
│     ├─ PaymentOption_CreditCard
│     └─ PaymentOption_Cash
│
└─ FixedBottomButton
   └─ GradientButton: "SAVE AND CONTINUE"
```

### **FRAME 05: HOME SCREEN - INITIAL**
```
Name: HomeScreen_Initial
Artboard: 360 × 800
Components:
├─ ExtendedAppBar (transparent)
│  ├─ MenuButton
│  ├─ LogoImage
│  └─ ProfileButton (40 × 40)
├─ GoogleMapContainer (fill)
│  └─ MyLocationButton (bottom-right, 48 × 48)
├─ GlassPanel_Top (if destination selected)
│  ├─ LocationIcon
│  └─ DestinationName
├─ BottomSheetContainer (AnimatedSize)
│  ├─ DragHandle (48 × 6)
│  ├─ Title: "Para onde?"
│  ├─ SearchBar
│  ├─ QuickShortcuts
│  │  ├─ Home (icon + "Casa")
│  │  └─ Work (icon + "Trabalho")
│  ├─ RecentActivity
│  │  ├─ Label: "ATIVIDADE RECENTE"
│  │  ├─ ClearButton
│  │  └─ RecentItem
│  └─ [Conditionally if Destination Selected]
│     ├─ Title: "Selecione sua moto"
│     ├─ RideOption_Standard (with status)
│     ├─ RideOption_Comfort
│     ├─ RideOption_Express
│     ├─ PaymentMethod Selector
│     └─ RequestButton
└─ BottomNavigation (4 items)
   ├─ CORRIDA
   ├─ ATIVIDADE
   ├─ CARTEIRA
   └─ PERFIL
```

### **FRAME 06: SEARCHING DRIVER SCREEN**
```
Name: SearchingDriverScreen
Artboard: 360 × 800
Components:
├─ AppBar (transparent with gradient)
│  ├─ MenuButton
│  ├─ LogoImage
│  └─ ProfileButton
├─ Radar Animation (Center)
│  ├─ PulsingRings (2 concentric)
│  ├─ RotatingScanLine
│  └─ CentralIcon (Motorcycle icon)
├─ StatusInfo
│  ├─ Title: "Procurando pilotos..."
│  ├─ Subtitle: "Conectando você..."
│  └─ BentoGrid_2x2
│     ├─ Wait Time (2-4 MIN)
│     └─ Traffic (Leve)
├─ ScanningInfo
│  ├─ DotIndicator
│  ├─ PilotCount ("3 Pilotos próximos")
│  └─ SectorLabel ("RASTREANDO 7G")
└─ FixedBottomButton
   └─ CancelButton ("CANCELAR PEDIDO")
     └─ WarningText: "Sem taxa (2 min)"
```

### **FRAME 07: DRIVER HOME - OFFLINE**
```
Name: DriverHomeScreen_Offline
Artboard: 360 × 800
Components:
├─ ExtendedAppBar
│  ├─ DrawerButton
│  ├─ Title: "Moto Acre"
│  └─ ProfileButton
├─ GoogleMapContainer (GrayStyle/Desaturated)
├─ BottomSheetContainer
│  ├─ RadarIcon (80 × 80)
│  ├─ Title: "Fique online para receber viagens"
│  ├─ Subtitle: "Você não receberá chamados no momento"
│  └─ Button: "GO" (ativar online)
└─ Drawer (Menu lateral)
   ├─ UserHeader
   │  ├─ Avatar (CircleAvatar)
   │  ├─ Name: "João (Motorista)"
   │  └─ Vehicle: "Honda CG 160 • ABC-1234"
   └─ LogoutButton (Red)
```

### **FRAME 08: DRIVER HOME - ONLINE**
```
Name: DriverHomeScreen_Online
Artboard: 360 × 800
Components:
├─ ExtendedAppBar
├─ TopGlassPanel
│  ├─ GainsButton (clickable)
│  │  ├─ WalletIcon
│  │  └─ "R$ XX,XX"
│  └─ StatusPanel
│     ├─ "Você está Online"
│     └─ OnlineSwitch (enabled)
├─ GoogleMapContainer (Normal style)
│  └─ HeatmapCircles (3x)
│     ├─ Zone1 (Yellow)
│     ├─ Zone2 (Orange)
│     └─ Zone3 (Green)
├─ BottomSheetContainer
│  ├─ RadarIcon (80 × 80)
│  ├─ Title: "Aguardando solicitações..."
│  ├─ Subtitle: "Seu carro está visível..."
│  ├─ DescriptionText
│  └─ Button: "SIMULAR CHAMADO"
└─ Drawer (same as Offline)
```

### **FRAME 09: NOVA CORRIDA ALERT (Modal)**
```
Name: NovaCorridaAlert
Artboard: 360 × 500 (BottomSheet modal)
Components:
├─ Header with Map backdrop
├─ CorridaDetails
│  ├─ Icon: Person
│  ├─ Origin: "Centro (a 800m)"
│  ├─ Icon: Location
│  ├─ Destination: "Taquari"
│  ├─ Distance: "4.2 km"
│  ├─ Time: "12 min aprox."
│  └─ Price: "R$ 18,50"
├─ ButtonGroup (Row)
│  ├─ AcceptButton (Green/Primary)
│  └─ DeclineButton (Gray)
└─ Divider
```

### **FRAME 10: DRIVER EARNINGS SCREEN**
```
Name: DriverEarningsScreen
Artboard: 360 × 800
Components:
├─ AppBar
│  └─ Title: "Ganhos"
├─ ScrollView Content
│  ├─ BigStats Card
│  │  ├─ "Hoje"
│  │  ├─ Total: "R$ XXXX,XX" (huge)
│  │  └─ MiniStats (Row of 3)
│  │     ├─ Rides Count
│  │     ├─ Online Time
│  │     └─ Rating
│  │
│  ├─ ChartSection
│  │  ├─ Title: "Próximo ao repasse"
│  │  ├─ BarChart (5 bars for week)
│  │  │  └─ Thu highlighted (primary color)
│  │  └─ DayLabels (Seg-Sex)
│  │
│  └─ RecentActivities
│     ├─ Title: "Atividades Recentes"
│     ├─ TripItem (if exists)
│     │  ├─ CheckCircleIcon
│     │  ├─ ModalityName
│     │  ├─ "Finalizada agora"
│     │  └─ Price: "+ R$ 18,50"
│     └─ EmptyState (if no activities)
```

---

## 🎨 Color Palette (for Figma styles)

```json
{
  "primary": {
    "name": "Primary",
    "hex": "#6B5EFF",
    "rgb": "rgb(107, 94, 255)"
  },
  "secondary": {
    "name": "Secondary",
    "hex": "#FFC107",
    "rgb": "rgb(255, 193, 7)"
  },
  "tertiary": {
    "name": "Tertiary",
    "hex": "#84DAFF",
    "rgb": "rgb(132, 218, 255)"
  },
  "background": {
    "name": "Background",
    "hex": "#000000",
    "rgb": "rgb(0, 0, 0)"
  },
  "surface": {
    "name": "Surface",
    "hex": "#1A1B23",
    "rgb": "rgb(26, 27, 35)"
  },
  "error": {
    "name": "Error",
    "hex": "#F44336",
    "rgb": "rgb(244, 67, 54)"
  },
  "onSurface": {
    "name": "OnSurface",
    "hex": "#FFFFFF",
    "rgb": "rgb(255, 255, 255)"
  }
}
```

---

## 🔤 Typography Styles (for Figma)

```json
{
  "heading_1": {
    "fontFamily": "Plus Jakarta Sans",
    "fontSize": 36,
    "fontWeight": 800,
    "lineHeight": 1.1,
    "letterSpacing": -1
  },
  "heading_2": {
    "fontFamily": "Plus Jakarta Sans",
    "fontSize": 24,
    "fontWeight": 800,
    "lineHeight": 1.2,
    "letterSpacing": -0.5
  },
  "body_regular": {
    "fontFamily": "Inter",
    "fontSize": 14,
    "fontWeight": 500,
    "lineHeight": 1.5,
    "letterSpacing": 0
  },
  "caption": {
    "fontFamily": "Inter",
    "fontSize": 12,
    "fontWeight": 400,
    "lineHeight": 1.4,
    "letterSpacing": 0.5
  },
  "button": {
    "fontFamily": "Plus Jakarta Sans",
    "fontSize": 14,
    "fontWeight": 800,
    "lineHeight": 1,
    "letterSpacing": 2
  }
}
```

---

## 📦 Component Library

### Button Components
```
├─ CustomButton_Default (56h × 100%)
├─ CustomButton_Loading
├─ CustomButton_Disabled
├─ CustomButton_Small (48h)
└─ CustomButton_Icon (56h with icon)
```

### Card Components
```
├─ Card_Default (rounded 16px)
├─ Card_Glass (with blur effect)
├─ Card_Elevated (with shadow)
├─ Card_Trip (with driver info)
└─ Card_Payment (with icon)
```

### Input Components
```
├─ TextField_Default
├─ TextField_Error
├─ TextField_Focused
├─ OTPField_Single (48 × 56)
└─ OTPField_Group (6 fields)
```

---

## 📊 Summary Table

| Screen Name | Frame # | Type | Complexity | Status |
|------------|---------|------|-----------|--------|
| LoginScreen | 01 | Auth | High | ✅ |
| PhoneVerification | 02 | Auth | Medium | ✅ |
| OTPVerification | 03 | Auth | Medium | ✅ |
| ProfileSetup | 04 | Onboarding | High | ✅ |
| HomeScreen_Initial | 05 | Main | High | ✅ |
| HomeScreen_Selection | 05a | Main | High | ✅ |
| SearchingDriver | 06 | Main | Medium | ✅ |
| DriverHome_Offline | 07 | Main | Medium | ✅ |
| DriverHome_Online | 08 | Main | Medium | ✅ |
| NovaCorridaAlert | 09 | Modal | Medium | ✅ |
| DriverEarnings | 10 | Detail | Medium | ✅ |

---

## 🔗 Como Importar para Figma

1. **Método 1: Manual**
   - Criar novo Figma project
   - Duplicar estrutura de frames conforme acima
   - Adicionar componentes e estilos

2. **Método 2: JSON Import (Plugin)**
   - Usar plugin "JSON to Figma"
   - Converter este documento para JSON
   - Importar diretamente

3. **Método 3: Figma Tokens**
   - Exportar como Figma Tokens (color palette + typography)
   - Aplicar em todos os frames

---

**Gerado em:** 2026-04-03
**Total de Frames:** 15+ variações
**Pronto para Figma:** ✅ Sim

Este documento contém toda a estrutura necessária para replicar o design no Figma.
