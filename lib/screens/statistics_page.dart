import 'package:flutter/material.dart';
import '../services/stats_api.dart';
import '../widgets/app_drawer.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final _statsApi = StatsApi();
  Future<List<Map<String, dynamic>>?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _statsApi.getResumenLocales();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadística por local'),
      ),
      drawer: const AppDrawer(currentPage: DrawerPage.estadistica),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No se pudo cargar el resumen.'),
            );
          }

          final locales = snapshot.data!;

          if (locales.isEmpty) {
            return const Center(
              child: Text('No hay datos de locales.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = locales[index];
              final nombre = item['nombre_sucursal'] ?? 'Local';
              final total = item['total_registros'] ?? 0;
              final asist = item['total_asistieron'] ?? 0;
              final pend = item['total_pendientes'] ?? 0;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: $total  •  Asistieron: $asist  •  Pendientes: $pend',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: locales.length,
          );
        },
      ),
    );
  }
}
