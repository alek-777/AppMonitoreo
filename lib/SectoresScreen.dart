import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SensoresScreen extends StatelessWidget {
  const SensoresScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await http.get(Uri.parse('https://monitoreo-railway-ues-production.up.railway.app/api/sensores'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          // Combinar todos los sectores de todos los objetos
          final List<Widget> sensorCards = [];

          for (var item in snapshot.data!) {
            item.forEach((sectorKey, sectorData) {
              sensorCards.add(
                _buildSensorCard(
                  sectorKey.toUpperCase(),
                  sectorData['humedad'],
                  sectorData['temperatura'],
                  context,
                ),
              );
              sensorCards.add(const SizedBox(height: 12));
            });
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: sensorCards,
            ),
          );
        },
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
