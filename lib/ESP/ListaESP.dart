import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ListaESP extends StatefulWidget {
  const ListaESP({super.key});

  @override
  State<ListaESP> createState() => _ListaESPState();
}

class _ListaESPState extends State<ListaESP> {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final devices = prefs.getStringList('configured_devices') ?? [];
    setState(() {
      _devices = devices.map((d) => jsonDecode(d) as Map<String, dynamic>).toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteDevice(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar ${_devices[index]['deviceName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final newList = List<String>.from(prefs.getStringList('configured_devices') ?? []);
      newList.removeAt(index);
      await prefs.setStringList('configured_devices', newList);
      _loadDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESPs Configurados'),
        backgroundColor: const Color(0xffFFE4AF),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? const Center(child: Text('No hay dispositivos registrados'))
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.router, size: 36),
                        title: Text(device['deviceName'] ?? 'ESP32'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MAC: ${device['mac'] ?? 'No disponible'}'), // Nueva línea para MAC
                            Text('Red: ${device['ssid'] ?? 'Sin red'}'),
                            Text('IP: ${device['ipAddress'] ?? '0.0.0.0'}'),
                            Text(
                              'Configurado: ${DateFormat('dd/MM/yy - HH:mm').format(
                                DateTime.tryParse(device['configuredAt'] ?? '') ?? DateTime.now()
                              )}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteDevice(index),
                        ),
                        onTap: () {
                          // Opcional: Acción al tocar un dispositivo
                        },
                      ),
                    );
                  },
                ),
    );
  }
}