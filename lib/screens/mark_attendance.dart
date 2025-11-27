// lib/screens/mark_attendance_page.dart
import 'package:flutter/material.dart';
import '../services/attendance_api.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage>
    with SingleTickerProviderStateMixin {
  final _codigoController = TextEditingController();
  final _attendanceApi = AttendanceApi();

  // Tus locales (puedes ajustar nombres / ids según tu BD)
  final List<Map<String, dynamic>> _locales = const [
    {'id': 1, 'nombre': 'Mulchén'},
    {'id': 2, 'nombre': 'Los Ángeles'},
    {'id': 3, 'nombre': 'Santa Bárbara'},
    {'id': 10, 'nombre': 'Laja'},
    {'id': 12, 'nombre': 'Angol'},
  ];

  int? _localSeleccionado;
  bool _loading = false;
  String? _message;
  bool _messageIsError = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    // Por defecto seleccionamos el primer local
    _localSeleccionado = _locales.first['id'] as int;

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

  Future<void> _marcarAsistencia() async {
    if (_localSeleccionado == null || _codigoController.text.trim().isEmpty) {
      setState(() {
        _messageIsError = true;
        _message = 'Selecciona un local e ingresa el código de barra.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    final result = await _attendanceApi.marcarAsistencia(
      localId: _localSeleccionado!,
      codigoBarra: _codigoController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _messageIsError = !(result['ok'] == true);
      _message = result['message'] as String?;
    });

    if (result['ok'] == true) {
      // limpiar campo código para siguiente escaneo
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
                        horizontal: 22, vertical: 26),
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
                                  'Actualiza el estado de la entrada',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Selección de local (solo para enviar el local_id que ya existe en BD)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Local',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _localSeleccionado,
                          decoration: const InputDecoration(
                            hintText: 'Selecciona un local',
                          ),
                          items: _locales
                              .map(
                                (loc) => DropdownMenuItem<int>(
                                  value: loc['id'] as int,
                                  child: Text(
                                    '${loc['nombre']} (ID ${loc['id']})',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _localSeleccionado = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Código de barra (luego lo llenaremos con escáner)
                        TextField(
                          controller: _codigoController,
                          decoration: const InputDecoration(
                            labelText: 'Código de barra',
                            prefixIcon: Icon(Icons.confirmation_number_outlined),
                            hintText: 'Ej: 7803600002459',
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 8),

                        // Mensaje de resultado
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _message == null
                              ? const SizedBox.shrink()
                              : Container(
                                  key: ValueKey(_message),
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
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

                        // Botón
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),
                        Text(
                          'Los campos estado, fecha_asistencia y usuario se actualizan en el backend.',
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
