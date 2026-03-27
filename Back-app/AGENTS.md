# 🤖 AGENTS.md — Moto Acre 24h Backend
> Metodologia: **Scrum** | Stack: Firebase (Cloud Functions + Firestore + FCM + Storage) + Next.js Admin

---

## 🏗️ Estrutura do Projeto

```
app-acre-24h-back/
├── firebase/                        # Firebase project
│   ├── firebase.json                # Firebase CLI config
│   ├── firestore.rules              # Firestore security rules
│   ├── firestore.indexes.json       # Firestore indexes
│   ├── storage.rules                # Storage security rules
│   └── functions/                   # Cloud Functions (Node.js 20 + TypeScript)
│       ├── src/
│       │   ├── index.ts             # Entry point — exports all functions
│       │   ├── auth.ts              # onUserCreated, setRole, saveFcmToken
│       │   ├── admin.ts             # approveDriver, rejectDriver, setAdminRole
│       │   ├── trips.ts             # Trip lifecycle FSM (Sprint 7)
│       │   ├── matching.ts          # Driver geo-matching (Sprint 7)
│       │   ├── notifications.ts     # FCM push notifications (Sprint 8)
│       │   └── payments.ts          # Pagar.me integration (Sprint 9)
│       ├── package.json
│       └── tsconfig.json
│
├── app-acre-24h-admin/              # Next.js admin web app (Sprint 5)
│   ├── app/                         # Next.js App Router pages
│   ├── lib/
│   │   ├── firebase.ts              # Firebase init
│   │   └── auth.ts                  # Admin auth helpers
│   └── package.json
│
└── sprints/                         # Sprint artifacts
    ├── sprint-04-2026-03-25.md
    └── ...
```

---

## 🗺️ Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (repo: app-acre-24h-front) |
| Admin web | Next.js + TypeScript + Tailwind CSS |
| Cloud Functions | Node.js 20 + TypeScript (firebase-functions v6) |
| Database | Firestore |
| Auth | Firebase Auth (email/password + Google) |
| Push notifications | Firebase Cloud Messaging (FCM) |
| File storage | Firebase Storage |
| Payment | Pagar.me (PIX + credit card) |
| Driver matching | GeoFirestore (geohash-based) |

---

## 🗄️ Firestore Schema

```
/users/{uid}
  role: 'passenger' | 'driver' | 'admin'
  name, email, phone
  fcmToken: string
  profilePhotoUrl: string
  # driver only:
  cpf, cnh: string
  approvalStatus: 'pending' | 'approved' | 'rejected'
  rejectionReason: string | null
  isVerified: bool

/drivers/{uid}
  isOnline: bool
  location: GeoPoint
  geohash: string
  currentTripId: string | null

/trips/{tripId}
  passengerId, driverId: string
  status: 'searching' | 'accepted' | 'in_progress' | 'completed' | 'cancelled'
  origin, destination: { address, lat, lng, bairro }
  price, bairroMultiplier: number
  paymentStatus: 'pending' | 'paid' | 'failed'
  createdAt, updatedAt: Timestamp

/payments/{paymentId}
  tripId, passengerId: string
  amount: number
  method: 'pix' | 'credit_card'
  status: 'pending' | 'paid' | 'failed'
  pagarmeOrderId: string
  createdAt: Timestamp

/config/pricing
  baseFare: 7.00
  perKmRate: 2.50
  perMinuteRate: 0.35
  bairroMultipliers: { [bairro]: number }
```

---

## 🔄 Controle de Sprints

Sprints representam **marcos de versionamento**, não períodos de tempo.

### Branch por Sprint
- **Padrão:** `sprint-XX-<resumo-kebab-case>`
- Merge para `main` somente após testes e checklist concluídos

### Artefato por Sprint
- **Caminho:** `sprints/sprint-XX-YYYY-MM-DD.md`
- **Conteúdo mínimo:** objetivo, itens implementados, arquivos alterados, pendências

---

## 👥 Agentes

---

### 🧑‍💻 Agente 1 — Senior Software Engineer
**Papel:** Implementação de Cloud Functions, lógica de negócio, integrações e páginas Next.js.

**Checklist obrigatório a cada sprint:**
- [ ] Cloud Functions novas têm tratamento de erro com `HttpsError` correto?
- [ ] Nenhuma lógica de negócio está no cliente (Flutter/Next.js) — está nas Functions?
- [ ] Todas as integrações externas (Pagar.me, FCM) têm tratamento de erro e fallback?
- [ ] Nenhuma secret/credencial foi commitada (usar Firebase environment config)?
- [ ] Firestore rules foram atualizadas para cobrir os novos dados?
- [ ] `npm run build` passa sem erros em `firebase/functions/`?

---

### 🏛️ Agente 2 — Senior Software Architect
**Papel:** Design de sistema, segurança, escalabilidade e decisões de infraestrutura Firebase.

**Checklist obrigatório a cada sprint:**
- [ ] Decisões de design foram documentadas no artefato da sprint?
- [ ] Nenhuma query Firestore nova causa leitura excessiva de documentos?
- [ ] Firestore security rules cobrem todos os novos collections/campos?
- [ ] Cloud Functions sensíveis verificam autenticação e role antes de executar?
- [ ] Variáveis de ambiente e secrets estão no Firebase config, não no código?

---

### 🔨 Agente 3 — Senior QA Engineer
**Papel:** Garantir qualidade e segurança. Quebrar o app antes do usuário.

**Checklist obrigatório a cada sprint:**

**Qualidade**
- [ ] Fluxos críticos testados ponta a ponta (happy path + falhas)?
- [ ] Cloud Functions testadas com Firebase Emulator antes do deploy?
- [ ] Race conditions consideradas (ex: dois motoristas aceitando a mesma corrida)?

**Segurança**
- [ ] Firestore rules testadas com `firebase emulators:exec`?
- [ ] Cloud Functions verificam que o caller tem permissão (role/uid)?
- [ ] Webhooks externos (Pagar.me) validam assinatura HMAC?
- [ ] Tokens FCM inválidos são tratados sem derrubar a Function?

---

### 🚀 Agente 4 — Senior Release & Versioning Engineer
**Papel:** Versionamento, qualidade de release e rastreabilidade entre sprint, commit e deploy.

**Checklist obrigatório a cada sprint:**
- [ ] Branch no padrão `sprint-XX-<resumo-kebab-case>`?
- [ ] Artefato `sprints/sprint-XX-YYYY-MM-DD.md` criado e completo?
- [ ] `firebase deploy --only functions` executado e sem erros após merge?
- [ ] Breaking changes documentados (mudanças em Firestore schema, rules)?
- [ ] Rollback documentado para mudanças críticas (pagamentos, auth)?

---

## 📋 Decisões Arquiteturais (ADRs)

- [x] `ADR-01` Firebase vs Django → **Firebase** (Sprint 4)
- [x] `ADR-02` Pagar.me como provedor de pagamento (Sprint 9)
- [ ] `ADR-03` Estratégia de deploy do admin (Vercel vs Firebase Hosting)
- [ ] `ADR-04` Observabilidade (Firebase Crashlytics + Analytics)
- [ ] `ADR-05` Estratégia de roteamento e ETA (Google Maps vs Mapbox)

---

## 🚀 Deploy

```bash
# Build functions
cd firebase/functions && npm run build

# Deploy tudo
firebase deploy

# Deploy apenas functions
firebase deploy --only functions

# Deploy apenas rules
firebase deploy --only firestore:rules,storage

# Emulator local (sem deploy)
firebase emulators:start
```

> ⚠️ Cloud Functions exigem plano **Blaze** (pay-as-you-go) para deploy.
