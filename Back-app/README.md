# app-acre-24h-back

Backend da Ride App usando Django + DRF + Channels + Celery + PostGIS + Redis.

## Regra de negócio principal
- O app é de corrida urbana, com foco em precificação contextual por região.
- Diferencial competitivo: o valor da corrida pode variar por **bairro** e nível de **periculosidade** definido pela operação.
- O painel administrativo web (Django Admin) deve permitir ao time interno:
  - Cadastrar/editar bairros atendidos
  - Definir multiplicador de preço por bairro
  - Definir fator adicional por periculosidade
  - Ativar/desativar regras com efeito operacional imediato

## Contexto de produto
- Referência de mercado: apps como Uber usam precificação dinâmica geral.
- Neste produto, a estratégia principal é a gestão de tarifa por território e risco operacional, com controle direto pelo admin.

## Sprint 1 entregue (2026-03-09)
- Setup inicial do projeto Django
- Configuração de ambientes (`base`, `dev`, `test`, `prod`)
- Docker + docker-compose com `db`, `redis`, `web`, `worker`, `beat`
- Autenticação JWT (`register`, `login`, `refresh`, `logout`, `profile`)
- Custom User model com papéis `PASSENGER` e `DRIVER`
- Validação inicial de CPF/CNH para motorista
- Testes iniciais do fluxo de auth

## Sprint 2 entregue (2026-03-09)
- App `trips` com ciclo de estados da corrida (FSM)
- Status suportados: `SEARCHING -> ACCEPTED -> IN_PROGRESS -> COMPLETED | CANCELLED`
- Endpoints REST:
  - `POST /api/v1/trips/request/`
  - `POST /api/v1/trips/{id}/accept/`
  - `POST /api/v1/trips/{id}/start/`
  - `POST /api/v1/trips/{id}/complete/`
  - `POST /api/v1/trips/{id}/cancel/`
  - `GET /api/v1/trips/` (histórico por usuário)
- Regras de permissão por papel (`PASSENGER`/`DRIVER`) e proteção de aceite concorrente
- Testes unitários e de API para transições e cenários de erro

## Sprint 3 entregue (2026-03-09)
- App `locations` com `DriverLocation(driver, point GEOGRAPHY, updated_at)` em PostGIS
- Busca de motoristas próximos por raio com `ST_DWithin` (via `point__distance_lte`)
- Cache Redis da última localização do motorista (TTL 10s)
- WebSocket com JWT no handshake:
  - `ws/passenger/trips/{trip_id}/` para passageiro receber posição do motorista
  - `ws/driver/dispatch/` para motorista receber solicitações próximas
- Dispatch em tempo real ao solicitar corrida com coordenadas de pickup
- Broadcast de localização do motorista para corrida ativa (`ACCEPTED`/`IN_PROGRESS`)
- Testes de WebSocket para autenticação/escopo e recebimento de eventos

## QA executado (2026-03-09)
- Testes unitários e de API/Auth com foco em validações e JWT
- Cenários de segurança cobertos: JWT manipulado, JWT expirado, acesso sem token, logout com refresh inválido
- Cobertura de testes atual: 95%
- SAST com Bandit (excluindo `tests` e `migrations`): sem findings no código de aplicação

## Como rodar local (venv)
```bash
python -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python manage.py migrate
.venv/bin/python manage.py runserver
```

## Como rodar local sem Docker (recomendado para teste rápido)
Este modo não depende de PostGIS nem Redis externo e usa `SQLite` + Channels em memória.

```bash
./scripts/run_local.sh
```

Observação:
- Nesse modo, o app `locations` (geolocalização PostGIS da Sprint 3) fica desabilitado.
- Fluxos de `users`, `trips` e testes de WebSocket continuam funcionando para validação funcional.

## Como rodar com Docker
```bash
docker compose up --build
```

## Testes
```bash
.venv/bin/pytest -q
```

## Coverage
```bash
.venv/bin/coverage run -m pytest -q
.venv/bin/coverage report -m
```

## Segurança estática (Bandit)
```bash
.venv/bin/bandit -q -r apps core manage.py -x apps/users/tests,apps/users/migrations -s B101,B105,B106
```
