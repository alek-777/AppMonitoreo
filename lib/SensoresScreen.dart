import 'package:flutter/material.dart';

class SensoresScreen extends StatelessWidget {
  const SensoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensores'),
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
          children: [
            _buildSensorCard('Sector1', '60%', '32°'),
            const SizedBox(height: 12),
            _buildSensorCard('Sector2', '60%', '32°'),
            const SizedBox(height: 12),
            _buildSensorCard('Sector3', '60%', '32°'),
            const SizedBox(height: 12),
            _buildSensorCard('Sector4', '60%', '32°'),
            const SizedBox(height: 12),
            _buildSensorCard('Sector5', '60%', '32°'),
          ],
        ),
      ),
      // Botón de configuración añadido aquí
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a pantalla de configuración
          Navigator.pushNamed(context, '/configuracion');
        },
        backgroundColor: const Color(0xffFFE4AF), // Mismo color que el app bar
        child: const Icon(Icons.settings, color: Colors.black), // Icono de tuerca
      ),
    );
  }

  Widget _buildSensorCard(String sector, String humedad, String temperatura) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'image/arbol.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  sector,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildIndicator('Humedad', humedad, Icons.water_drop, Colors.blue),
                const SizedBox(width: 16),
                _buildIndicator('Temperatura', temperatura, Icons.thermostat, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}