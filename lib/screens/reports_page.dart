import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_storage.dart';
import '../widgets/app_drawer.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  // ajusta esta base igual que las demás
  static const String _baseRoot = 'http://192.168.2.181:8000';

  Future<void> _openExport(
    BuildContext context, {
    required String path,
  }) async {
    final uri = Uri.parse('$_baseRoot$path');

    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace de descarga.'),
        ),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
      ),
      drawer: const AppDrawer(currentPage: DrawerPage.reportes),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Exportar reportes',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Desde aquí puedes descargar los reportes de asistentes e inasistentes en formato Excel.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                _ReportButton(
                  icon: Icons.groups_rounded,
                  title: 'Asistentes (todos los locales)',
                  subtitle:
                      'Descarga un Excel con todas las entradas en estado Asiste.',
                  color: cs.primary,
                  onTap: () => _openExport(
                    context,
                    path: '/api/export/registros/asistidos',
                  ),
                ),
                const SizedBox(height: 12),
                _ReportButton(
                  icon: Icons.hourglass_empty_rounded,
                  title: 'Inasistentes (todos los locales)',
                  subtitle:
                      'Descarga un Excel con las entradas aún pendientes.',
                  color: Colors.orange.shade700,
                  onTap: () => _openExport(
                    context,
                    path: '/api/export/registros/pendientes',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Al abrir el enlace se usará el navegador del dispositivo para manejar la descarga.',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ReportButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
