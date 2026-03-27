# Bruno Collection - Ride App Trips

## Como usar
1. Abra a pasta `bruno/ride-app-trips` no Bruno.
2. Selecione o ambiente `Local`.
3. Rode `Auth/Passenger Register` e depois `Auth/Passenger Login`.
4. Rode `Auth/Driver Register Missing Docs (Should Fail)` e confirme retorno `400`.
5. Rode `Auth/Driver Register` e depois `Auth/Driver Login Pending (Should Fail)` para validar bloqueio por aprovação (`400`).
6. Aprove o motorista no Django Admin:
   - `driver_verification_status = APPROVED`
7. Rode `Auth/Driver Login` e copie o `access` para `driverAccessToken`.
8. Rode `Trips/Passenger Request Trip` e copie `id` para `tripId`.
9. Rode os endpoints de fluxo em ordem:
   - `Driver Accept Trip`
   - `Driver Start Trip`
   - `Driver Complete Trip` (ou `Passenger Cancel Trip`)
   - `Trip History`

## Pré-requisitos
- Backend rodando em `http://127.0.0.1:8000`
- Usuários podem ser criados pela própria pasta `auth/`
