import 'package:flutter/material.dart';
import 'WifiESP.dart';
import 'ListaESP.dart';
import 'RegisterESP.dart';

class ESPScreen extends StatelessWidget {
  const ESPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración ESP32'),
        backgroundColor: const Color(0xffFFE4AF),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón 1: Registrar ESP
            _MenuButton(
              icon: Icons.add_circle_outline,
              text: 'Registrar ESP',
              onPressed: () {
                // Navegar a pantalla de registro (a implementar)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterESP(), // Reemplazar con tu pantalla de registro
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Botón 2: Configuración WiFi
            _MenuButton(
              icon: Icons.wifi,
              text: 'Configuración WiFi',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WifiESP(), // Usamos la pantalla que ya teníamos
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Botón 3: ESP Configurados
            _MenuButton(
              icon: Icons.list_alt,
              text: 'ESP Configurados',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListaESP(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget personalizado para los botones del menú
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffFFE4AF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}