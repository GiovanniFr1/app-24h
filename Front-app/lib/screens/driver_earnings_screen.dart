import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class DriverEarningsScreen extends StatelessWidget {
  final double ganhosTotais;
  final List<String> historicoModalidades;

  const DriverEarningsScreen({
    super.key,
    required this.ganhosTotais,
    required this.historicoModalidades,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ganhos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bloco Grande de Ganhos
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.surfaceContainerLow, Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Hoje',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${ganhosTotais.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMiniStat(
                        LucideIcons.car,
                        '${historicoModalidades.length}',
                        'Corridas',
                      ),
                      Container(height: 40, width: 1, color: Colors.white24),
                      _buildMiniStat(LucideIcons.clock, '1h 12m', 'Online'),
                      Container(height: 40, width: 1, color: Colors.white24),
                      _buildMiniStat(LucideIcons.star, '5.0', 'Avaliação'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Linha do tempo visual (Gráfico Mockado)
            const Text(
              'Próximo ao repasse',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Barras fictícias do gráfico
                  Positioned(
                    bottom: 24,
                    left: 32,
                    child: _buildChartBar(60, Colors.white24),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 82,
                    child: _buildChartBar(100, Colors.white24),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 132,
                    child: _buildChartBar(40, Colors.white24),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 182,
                    child: _buildChartBar(130, AppTheme.primary),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 232,
                    child: _buildChartBar(80, Colors.white24),
                  ),
                  const Positioned(
                    bottom: 8,
                    left: 32,
                    right: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Seg',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          'Ter',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          'Qua',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          'Qui',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sex',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Atividades Recentes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Lista Renderizada caso tenha corridas
            historicoModalidades.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Nenhuma corrida finalizada hoje.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: historicoModalidades.length,
                    itemBuilder: (context, index) {
                      return _buildTripListTile(historicoModalidades[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildChartBar(double height, Color color) {
    return Container(
      width: 16,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildTripListTile(String modalidade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.checkCircle,
              color: Colors.greenAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modalidade,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Finalizada agora',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Text(
            '+ R\$ 18,50',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
