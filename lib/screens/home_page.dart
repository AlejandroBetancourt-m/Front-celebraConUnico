import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../services/attendance_api.dart';
import '../services/stats_api.dart';
import '../widgets/app_drawer.dart';
import 'barcode_scanner_page.dart';
import '../utils/color_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _codigoController = TextEditingController();
  final _attendanceApi = AttendanceApi();
  final _statsApi = StatsApi();
  final _authStorage = AuthStorage();

  bool _loading = false;
  String? _message;
  bool _messageIsError = false;
  int? _totalAsistencias;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
    _cargarTotalAsistencias();
  }

  @override
  void dispose() {
    _animController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _cargarTotalAsistencias() async {
    final total = await _statsApi.getTotalAsistencias();
    if (!mounted) return;
    setState(() {
      _totalAsistencias = total;
    });
  }

  Future<String> _getNombreCompleto() async {
    final name = await _authStorage.getUserName() ?? '';
    final last = await _authStorage.getUserLastName() ?? '';
    if (name.isEmpty && last.isEmpty) return 'Usuario';
    return '$name $last';
  }

  Future<void> _abrirEscaner() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerPage(),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _codigoController.text = result;
      });
    }
  }

  Future<void> _marcarAsistencia() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      setState(() {
        _messageIsError = true;
        _message = 'Ingresa o escanea un código de barra.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    final result =
        await _attendanceApi.marcarAsistencia(codigoBarra: codigo);

    if (!mounted) return;

    setState(() {
      _loading = false;
      _messageIsError = !(result['ok'] == true);
      _message = result['message'] as String?;
    });

    if (result['ok'] == true) {
      _codigoController.clear();
      _cargarTotalAsistencias();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Celebra Único'),
      ),
      drawer: const AppDrawer(currentPage: DrawerPage.home),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withOpacity(0.18),
              cs.primary.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FutureBuilder<String>(
                        future: _getNombreCompleto(),
                        builder: (context, snapshot) {
                          final nombre = snapshot.data ?? 'Usuario';
                          return Text(
                            'Bienvenido, $nombre 👋',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Escanea o ingresa los códigos de las entradas para registrar asistencia.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Card de escaneo / ingreso
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        cs.primary,
                                        cs.primary.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Marcar asistencia',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _codigoController,
                              decoration: InputDecoration(
                                labelText: 'Código de barra',
                                prefixIcon: const Icon(
                                  Icons.confirmation_number_outlined,
                                ),
                                hintText: 'Ej: 7803600002459',
                                suffixIcon: IconButton(
                                  tooltip: 'Escanear con cámara',
                                  icon: const Icon(Icons.camera_alt_rounded),
                                  onPressed: _abrirEscaner,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _abrirEscaner,
                                icon: Icon(
                                  Icons.camera_alt_rounded,
                                  color: cs.primary,
                                ),
                                label: Text(
                                  'Escanear con cámara',
                                  style: TextStyle(color: cs.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _message == null
                                  ? const SizedBox.shrink()
                                  : Container(
                                      key: ValueKey(_message),
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _messageIsError
                                            ? Colors.red.withOpacity(0.08)
                                            : Colors.green.withOpacity(0.08),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _messageIsError
                                              ? Colors.red.shade200
                                              : Colors.green.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _messageIsError
                                                ? Icons.error_outline
                                                : Icons
                                                    .check_circle_outline_rounded,
                                            color: _messageIsError
                                                ? Colors.red.shade400
                                                : Colors.green.shade600,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _message!,
                                              style: TextStyle(
                                                color: _messageIsError
                                                    ? Colors.red.shade400
                                                    : Colors.green.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _loading ? null : _marcarAsistencia,
                                icon: _loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded),
                                label: Text(
                                  _loading
                                      ? 'Registrando asistencia...'
                                      : 'Ingresar',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Card de resumen total asistencias
                      _ResumenTotalCard(totalAsistencias: _totalAsistencias),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumenTotalCard extends StatelessWidget {
  final int? totalAsistencias;

  const _ResumenTotalCard({required this.totalAsistencias});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.15),
            cs.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: cs.primary.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withOpacity(0.9),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total de asistencias registradas',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalAsistencias == null
                      ? 'Cargando...'
                      : '${totalAsistencias ?? 0}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary.darken(0.08),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// pequeña extensión para oscurecer color

