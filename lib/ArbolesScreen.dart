import 'package:flutter/material.dart';

class ArbolesScreen extends StatelessWidget {
  const ArbolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['sector'] ?? 'Detalle'),
        centerTitle: true,
        backgroundColor: const Color(0xffFFE4AF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            _buildSensorCard('Árbol1', '30%', '32°'),
            const SizedBox(height: 12),
            _buildSensorCard('Árbol2', '45%', '32°'),
            const SizedBox(height: 12),
            _buildSensorCard('Árbol3', '60%', '32°'),
            const SizedBox(height: 12),
            _buildSensorCard('Árbol4', '75%', '32°'),
            const SizedBox(height: 12),
            _buildSensorCard('Árbol5', '90%', '32°'),
          ],
        ),
      ),
    );
  }
}

Widget _buildSensorCard(String sector, String humedad, String temperatura) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('image/arbol.png', width: 90, height: 90),
          Column(
            children: [
              Text(
                sector,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildIndicator(
                    'Humedad    ',
                    humedad,
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildIndicator(
                    'Temperatura',
                    temperatura,
                    Icons.thermostat,
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildIndicator(String label, String value, IconData icon, Color color) {
  return Container(
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.all(8.0),
    margin: const EdgeInsets.only(right: 8.0), // para separación
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
  );
}


// Center(
//         child: Text(
//           'Humedad: ${data['humedad']}, Temp: ${data['temperatura']}',
//           style: const TextStyle(fontSize: 20),
//         ),