# Moto Acre 24h - Sprint Implementation Plan (Frontend Exclusive)

## Overview
Documento definitivo do plano de Sprints para o aplicativo **Moto Acre 24h**. Como este projeto é inteiramente focado no **Frontend**, o objetivo é construir todo o aplicativo em Flutter com gerenciamento de estado avançado (Riverpod), fluxos completos de UI (Passageiro e Motorista) e repositórios *Mock* para simular a presença de um backend.

## Project Type
MOBILE (Flutter Frontend UI/UX Heavy)

## Success Criteria
- Flow E2E do Passageiro e do Motorista completáveis 100% no app usando estado em memória.
- UX impecável seguindo as regras de *Velocity Noir*, Fitts' Law e *Thumb Zone*.
- Arquitetura limpa preparada para que, no futuro, apenas os *Mock Repositories* sejam trocados pelas chamadas reais de API (`Dio`).

## Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Routing**: GoRouter (para deep-linking e navegação declarativa)
- **Maps**: `google_maps_flutter` com rotas e markers simulados

## Sprints
O projeto Master-Class de Frontend foi particionado em 10 Sprints altamente detalhadas:

### Core Logic & UI Flows
1. `sprint-1-passenger-ui.md`
2. `sprint-2-driver-ui.md`
3. `sprint-3-profile-history.md`
4. `sprint-4-state-mocking.md`
5. `sprint-5-animations-polish.md`

### Advanced Operations & Extensibility (100% Completo)
6. `sprint-6-onboarding-auth.md` (Biometria, KYC de Documentos).
7. `sprint-7-advanced-maps.md` (Marcadores 3D, Polylines Gradient, Autocomplete Google Places).
8. `sprint-8-support-help.md` (Chat com Motorista, FAQ Interativo, Bot do Help Center).
9. `sprint-9-edge-cases.md` (Offline Lotties, Zero Drivers Available, Shimmer Loaders).
10. `sprint-10-localization-a11y.md` (AMOLED Dark Mode Toggles, Extração em ARB Multi-Linguagem, Acessibilidade Semântica para Cegos).
