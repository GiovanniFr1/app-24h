import 'package:flutter/material.dart';
import '../../core/theme.dart';

class BuscadorBairroSheet extends StatefulWidget {
  final List<Map<String, dynamic>> bairros;

  const BuscadorBairroSheet({super.key, required this.bairros});

  @override
  State<BuscadorBairroSheet> createState() => _BuscadorBairroSheetState();
}

class _BuscadorBairroSheetState extends State<BuscadorBairroSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _bairrosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _bairrosFiltrados = widget.bairros;
  }

  void _filtrarBairros(String query) {
    setState(() {
      if (query.isEmpty) {
        _bairrosFiltrados = widget.bairros;
      } else {
        _bairrosFiltrados = widget.bairros
            .where(
              (bairro) => bairro['nome'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Para UX do Uber/99: o sheet ocupa a maior parte da tela ou expande conforme teclado
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Puxador visual
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header com título e Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Para onde?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _filtrarBairros,
              decoration: InputDecoration(
                hintText: 'Buscar destino...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primary,
                ),
                filled: true,
                fillColor: AppTheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Lista de Resultados
          Expanded(
            child: ListView.builder(
              itemCount: _bairrosFiltrados.length,
              itemBuilder: (context, index) {
                final bairro = _bairrosFiltrados[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    bairro['nome'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    'Rio Branco, AC',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  onTap: () {
                    // Retorna o bairro selecionado para a tela anterior
                    Navigator.pop(context, bairro);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
