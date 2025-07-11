import 'package:flutter/material.dart';

class RiegoScreen extends StatelessWidget {
  const RiegoScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo de riego'),
        centerTitle: true,
        backgroundColor: const Color(0xffFFE4AF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMenuOption(
              context: context,
              title: 'Sensores',
              leading: Image.asset("image/riego.png", width: 80, height: 80),
              onTap: () {
                // Navegar a pantalla de sensores
                Navigator.pushNamed(context, '/sensores');
              },
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context: context,
              title: 'Informes',
              leading: Image.asset("image/info.png", width: 80, height: 80),
              onTap: () {
                // Navegar a pantalla de informes
                Navigator.pushNamed(context, '/reportes' );
              },
            ),
            // Puedes añadir más secciones aquí
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