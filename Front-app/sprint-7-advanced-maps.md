# Sprint 7: Advanced Routing, Custom Markers & Polylines

## Visão Geral
Um aplicativo de transporte vive e morre por seu mapa. Usar pinos padrão vermelhos do Google Maps não passa credibilidade. Aqui vamos desenhar rotas degradês, pinos 3D de motos que giram no próprio eixo dependendo do *bearing* (direção).

## Tarefas (Task Breakdown)

### Task 7.1: Polylines com Gradiente (O Delineado da Rota)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: `GoogleMap` da Sprint 1.
- **OUTPUT**: Uso do plugin `flutter_polyline_points` (ou Mocks de LatLng) para traçar o caminho do Passageiro ao Motorista. A linha deve ter curvas suaves (geodesic: true) e usar a cor base Neon do Velocity Noir (Gradiente do Primário para a cor Alfa transparente).
- **VERIFY**: Desenho da rota é visível no mapa se adaptando com as ruas da cidade localizadas.

### Task 7.2: Custom Map Markers (Moto 3D e Tilt Effect)
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Marker padrão do Maps.
- **OUTPUT**: Conversão de um Asset (PNG/SVG) da "motinha" em um marcador customizado e desenhado no Canvas nativo do Maps. Configuração da câmera do mapa para dar um leve *Tilt* (ângulo 3D) ao invés de olhar puramente de cima.
- **VERIFY**: Quando o Riverpod mockar o avanço do Ponto A para o Ponto B, o marcador do motorista gira a dianteira da moto simulando a curva na esquina fisicamente.

### Task 7.3: Autocomplete Geocoding de Localização
- **Agent Recomendado**: `@mobile-developer`
- **Skill**: `mobile-design`
- **INPUT**: Bottom Sheet de "Para onde vamos?".
- **OUTPUT**: Criação da lista deslizante baseada na API Google Places (mockada ou integrada). Digitar "Ave" popula com "Avenida Paulista" realçando a predição da string (Substring highlight).
- **VERIFY**: Limpeza limpa do campo de busca com 'X' e resultados exibidos com o pino de relógio ("Visualizados recentemente").
