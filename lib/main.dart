import 'package:flutter/material.dart';
import 'package:flutter_application_2/ArbolesScreen.dart';
import 'package:flutter_application_2/ConfiguracionSector.dart';
import 'package:flutter_application_2/ESPScreen.dart';
import 'package:flutter_application_2/RiegoScreen.dart';
import 'package:flutter_application_2/UsuarioScreen.dart';
import 'package:flutter_application_2/ReportesScreen.dart';
import 'package:flutter_application_2/SectoresScreen.dart';



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
        '/reportes' :(context)=> const ReportesScreen(),
        '/sensores' :(context)=> const SensoresScreen(),
        '/configuracion' :(context)=> const ConfiguracionSector(),
        '/arboles': (context)=> const ArbolesScreen(),
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
        title: const Text('Menú'),
        centerTitle: true,
        backgroundColor: Color(0xffFFE4AF),
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
              leading: Image.asset("image/riego.png", width: 40, height: 40),
              onTap: () => Navigator.pushNamed(context, '/riego'),
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context: context,
              title: 'Configuración del ESP',
              leading: Image.asset("image/esp.png", width: 40, height: 40), 
              onTap: () => Navigator.pushNamed(context, '/esp'),
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context: context,
              title: 'Usuario',
              leading: Image.asset("image/usuario.png", width: 40, height: 40),
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
  required Widget leading,
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
            leading,
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