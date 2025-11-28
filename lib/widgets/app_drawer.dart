import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../screens/home_page.dart';
import '../screens/statistics_page.dart';
import '../screens/reports_page.dart';
import '../screens/login_page.dart';

enum DrawerPage {
  home,
  estadistica,
  reportes,
}

class AppDrawer extends StatelessWidget {
  final DrawerPage currentPage;

  const AppDrawer({super.key, required this.currentPage});

  Future<Map<String, String>> _getUserInfo() async {
    final storage = AuthStorage();
    final name = await storage.getUserName() ?? '';
    final lastName = await storage.getUserLastName() ?? '';
    return {
      'name': name,
      'lastName': lastName,
    };
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final storage = AuthStorage();
    await storage.clearToken();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          FutureBuilder<Map<String, String>>(
            future: _getUserInfo(),
            builder: (context, snapshot) {
              final name = snapshot.data?['name'] ?? '';
              final lastName = snapshot.data?['lastName'] ?? '';

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary,
                      cs.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    (name.isNotEmpty ? name[0] : 'U').toUpperCase(),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
                accountName: Text(
                  name.isEmpty && lastName.isEmpty
                      ? 'Usuario'
                      : '$name $lastName',
                ),
                accountEmail: const Text('Celebra Único'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            selected: currentPage == DrawerPage.home,
            onTap: () {
              if (currentPage != DrawerPage.home) {
                _navigateTo(context, const HomePage());
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: const Text('Estadística'),
            selected: currentPage == DrawerPage.estadistica,
            onTap: () {
              if (currentPage != DrawerPage.estadistica) {
                _navigateTo(context, const StatisticsPage());
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_rounded),
            title: const Text('Reportes'),
            selected: currentPage == DrawerPage.reportes,
            onTap: () {
              if (currentPage != DrawerPage.reportes) {
                _navigateTo(context, const ReportsPage());
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text(
                      '¿Estás seguro que deseas cerrar sesión y salir de la aplicación?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _logout(context);
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
