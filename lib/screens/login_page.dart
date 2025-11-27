import 'package:flutter/material.dart';
import '../services/auth_api.dart';
import '../services/auth_storage.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _rutController = TextEditingController();
  final _passController = TextEditingController();
  final _authApi = AuthApi();
  final _authStorage = AuthStorage();

  bool _loading = false;
  String? _error;

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
    _rutController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final rut = _rutController.text.trim();
    final pass = _passController.text;

    final result = await _authApi.login(rut: rut, contrasena: pass);

    if (!mounted) return;

    if (result['ok'] == true) {
      final token = result['token'] as String;
      await _authStorage.saveToken(token);

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) {
            final offsetAnim = Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnim, child: child),
            );
          },
        ),
      );
    } else {
      setState(() {
        _error = result['message'] as String?;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  void _goToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RegisterPage(),
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnim = Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnim, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withOpacity(0.2),
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
                  child: _buildCard(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo + título
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
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
                  Icons.event_available_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Celebra Único',
                    style: textTheme.titleLarge?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    'Control de asistencia',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Subtítulo
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Inicia sesión',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Campos
          TextField(
            controller: _rutController,
            decoration: const InputDecoration(
              labelText: 'RUT',
              hintText: '11111111-1',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passController,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 8),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _error == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            size: 18, color: Colors.red.shade400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Botón login
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _doLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Iniciar sesión'),
            ),
          ),

          const SizedBox(height: 12),

          // Botón registro
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes cuenta?',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              TextButton(
                onPressed: _goToRegister,
                child: Text(
                  'Regístrate',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
