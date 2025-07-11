import 'package:flutter/material.dart';

class SensoresScreen extends StatelessWidget {
  const SensoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sectores'),
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
            _buildSensorCard('Sector1', '30%', '32°', context),
            const SizedBox(height: 12),
            _buildSensorCard('Sector2', '45%', '32°', context),
            const SizedBox(height: 12),
            _buildSensorCard('Sector3', '60%', '32°', context),
            const SizedBox(height: 12),
            _buildSensorCard('Sector4', '75%', '32°', context),
            const SizedBox(height: 12),
            _buildSensorCard('Sector5', '90%', '32°', context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/configuracion');
        },
        backgroundColor: const Color(0xffFFE4AF),
        child: const Icon(Icons.settings, color: Colors.black),
      ),
    );
  }

  Widget _buildSensorCard(
    String sector,
    String humedad,
    String temperatura,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/arboles',
          arguments: {
            'sector': sector,
            'humedad': humedad,
            'temperatura': temperatura,
          },
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('image/riego.png', width: 60, height: 60),
              FittedBox(
                fit: BoxFit.contain,
                child: Column(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
}
