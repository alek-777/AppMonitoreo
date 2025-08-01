import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SectoresScreen extends StatefulWidget {
  const SectoresScreen({super.key});

  @override
  State<SectoresScreen> createState() => _SectoresScreenState();
}

class _SectoresScreenState extends State<SectoresScreen> {
  String _idCompany = "";

  @override
  void initState() {
    super.initState();
    _getIdCompany();
  }

  Future<void> _getIdCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final idCompany = prefs.getInt('idCompany') ?? 'Compañia no encontrada';
    setState(() {
      _idCompany = idCompany.toString();
    });
  }

  Future<List<Map<String, dynamic>>> fetchData(String id) async {
    final response = await http.get(
      Uri.parse(
        'https://monitoreo-railway-ues-production.up.railway.app/api/sectors/company/$id',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  void deleteSector(int id) async {
    final response = await http.delete(
      Uri.parse(
        'https://monitoreo-railway-ues-production.up.railway.app/api/sectors/$id',
      ),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error al borrar los datos');
    }
  }

  //PROMEDIOS
  Future<Map<int, double>> fetchAverageHumidityBySector() async {
    final response = await http.get(
      Uri.parse(
        'https://monitoreo-railway-ues-production.up.railway.app/api/data',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      // Mapeo de sectorId a lista de humedades
      Map<int, List<double>> humedadPorSector = {};

      for (var item in jsonData) {
        int sectorId = item['sensor']['sector']['idSector'];
        String rawData = item['data'];
        List<dynamic> sensores = json.decode(rawData);

        for (var sensor in sensores) {
          String humedadStr = sensor['humedad'] ?? '0.0%';
          double humedad =
              double.tryParse(humedadStr.replaceAll('%', '')) ?? 0.0;

          if (!humedadPorSector.containsKey(sectorId)) {
            humedadPorSector[sectorId] = [];
          }
          humedadPorSector[sectorId]!.add(humedad);
        }
      }

      // Calcular promedios
      Map<int, double> promedios = {};
      humedadPorSector.forEach((sectorId, humedades) {
        if (humedades.isNotEmpty) {
          final promedio = humedades.reduce((a, b) => a + b) / humedades.length;
          promedios[sectorId] = promedio;
        }
      });

      return promedios;
    } else {
      throw Exception('Error al cargar datos de humedad');
    }
  }

  @override
  void dispose() {
    super.dispose();
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
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/add_sector');
              setState(() {}); // Esto fuerza a recargar el FutureBuilder
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          fetchData(_idCompany),
          fetchAverageHumidityBySector(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data![0].isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          final sectores = snapshot.data![0] as List<Map<String, dynamic>>;
          final promedios = snapshot.data![1] as Map<int, double>;

          final List<Widget> sensorCards = sectores.map((sector) {
            final idSector = sector['idSector'];
            final humedadProm = promedios[idSector]?.toStringAsFixed(1) ?? '—';

            return _buildSensorCard(
              sector['description'],
              idSector,
              sector['nameSector'] ?? 'Sin nombre',
              '$humedadProm%',
              '—', // Temperatura no disponible
              context,
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(children: sensorCards),
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
    String description,
    int idSector,
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
            'idSector': idSector.toString(),
          },
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('image/riego.png', width: 60, height: 60),
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
                        'Humedad',
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
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pushNamed(
                        context,
                        '/edit_sector',
                        arguments: {
                          'nombre': sector,
                          'idSector': idSector.toString(),
                          'description': description,
                        },
                      );
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Alerta de eliminar'),
                            content: const SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('¿Esta seguro de eliminar este sector?'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Si'),
                                onPressed: () {
                                  deleteSector(idSector);
                                  setState(() {});
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('No'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
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
      margin: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: MediaQuery.of(context).size.width >= 411,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    overflow: TextOverflow.ellipsis,
                  ),
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
    );
  }
}
