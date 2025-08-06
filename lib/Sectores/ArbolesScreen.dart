import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ArbolesScreen extends StatefulWidget {
  const ArbolesScreen({super.key});

  @override
  State<ArbolesScreen> createState() => _ArbolesScreenState();
}

class _ArbolesScreenState extends State<ArbolesScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> datosFiltrados = [];
  Map<String, String>? routeData;
  List<Widget> cards = [];

  Future<List<Map<String, dynamic>>> fetchFilteredData(String idSector) async {
    final response = await http.get(
      Uri.parse(
        'https://monitoreo-railway-ues-production.up.railway.app/api/data',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      final filteredDataBySector = jsonData
          .where((item) {
            final sector = item['sensor']['sector']["idSector"];
            return sector != null && sector.toString() == idSector;
          })
          .map((e) => e as Map<String, dynamic>)
          .toList();


      final Map<int, Map<String, dynamic>> latestDataBySensor = {};
      for (var item in filteredDataBySector) {
        final int idSensor = item['sensor']['idSensor'];
        final DateTime timestamp = DateTime.parse(item['timestamp']);

        if (!latestDataBySensor.containsKey(idSensor) ||
            timestamp.isAfter(
              DateTime.parse(latestDataBySensor[idSensor]!['timestamp']),
            )) {
          latestDataBySensor[idSensor] = item;
        }
      }

      return latestDataBySensor.values.toList();
    } else {
      throw Exception('Error al cargar los datos de humedad');
    }
  }

  void cargarDatos() async {
    if (routeData == null) return;
    datosFiltrados = await fetchFilteredData(routeData!["idSector"]!);
    cards = _buildAllCards(); 
    setState(() {
      isLoading = false;
    });
  }

  List<Widget> _buildAllCards() {
    List<Widget> generatedCards = [];
    for (var item in datosFiltrados) {
      
      final String jsonString = item['data'];
      final List<dynamic> sensores = json.decode(jsonString);
      
      for (var sensorData in sensores) {
        final sensorId = sensorData['sensor'];
        final humedad = sensorData['humedad'] ?? '0%';
        final nombre = 'Sensor $sensorId';
        final temperatura = '—';
        generatedCards.add(_buildSensorCard(nombre, humedad, temperatura));
      }
    }
    return generatedCards;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (routeData == null) {
      routeData =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeData?['sector'] ?? 'Detalle'),
        centerTitle: true,
        backgroundColor: const Color(0xffFFE4AF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cards.isEmpty
            ? const Center(
                child: Text(
                  'No hay datos disponibles.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.separated(
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => cards[index],
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
          Image.asset('image/arbol.png', width: 60, height: 60),
          Column(
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  sector,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
        ],
      ),
    ),
  );
}

Widget _buildIndicator(String label, String value, IconData icon, Color color) {
  return Container(
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.all(8.0),
    margin: const EdgeInsets.only(right: 8.0),
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
