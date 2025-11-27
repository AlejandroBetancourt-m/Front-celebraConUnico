import 'package:flutter/material.dart';
import '../services/attendance_api.dart';
import 'barcode_scanner_page.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage>
    with SingleTickerProviderStateMixin {
  final _codigoController = TextEditingController();
  final _attendanceApi = AttendanceApi();

  bool _loading = false;
  String? _message;
  bool _messageIsError = false;

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
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _codigoController.dispose();
    super.dispose();
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
      // opcional: podrías llamar automáticamente a _marcarAsistencia();
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

    final result = await _attendanceApi.marcarAsistencia(
      codigoBarra: codigo,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _messageIsError = !(result['ok'] == true);
      _message = result['message'] as String?;
    });

    if (result['ok'] == true) {
      _codigoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcar asistencia'),
      ),
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
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 26,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Marcar asistencia',
                                  style: textTheme.titleLarge,
                                ),
                                Text(
                                  'Escanea o ingresa el código de la entrada',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),

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

                        const SizedBox(height: 12),

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
                                    borderRadius: BorderRadius.circular(16),
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
                                            : Icons.check_circle_outline,
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
                            onPressed: _loading ? null : _marcarAsistencia,
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
                                  : 'Marcar asistencia',
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),
                        Text(
                          'El backend actualiza estado, fecha_asistencia y usuario según el token.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
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
