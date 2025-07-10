import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menú Principal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MenuScreen(),
      routes: {
        '/riego': (context) => const RiegoScreen(),
        '/esp': (context) => const ESPScreen(),
        '/usuario': (context) => const UsuarioScreen(),
      },
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildMenuOption(
              context: context,
              title: 'Monitoreo de Riego',
              icon: Icons.water_drop,
              onTap: () => Navigator.pushNamed(context, '/riego'),
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context: context,
              title: 'Configuración del ESP',
              icon: Icons.developer_board, // O usar Icons.settings
              onTap: () => Navigator.pushNamed(context, '/esp'),
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context: context,
              title: 'Usuario',
              icon: Icons.person,
              onTap: () => Navigator.pushNamed(context, '/usuario'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantallas de ejemplo
class RiegoScreen extends StatelessWidget {
  const RiegoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoreo de Riego')),
      body: const Center(child: Text('Contenido de Monitoreo de Riego')),
    );
  }
}

class ESPScreen extends StatelessWidget {
  const ESPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración del ESP')),
      body: const Center(child: Text('Contenido de Configuración del ESP')),
    );
  }
}

class UsuarioScreen extends StatelessWidget {
  const UsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuario')),
      body: const Center(child: Text('Contenido de Usuario')),
    );
  }
}