import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // ¡Necesario para jsonDecode!

class ConfiguredDevice {
  final String deviceId;
  final String deviceName;
  final String ssid;
  final DateTime configuredAt;
  final String ipAddress;

  ConfiguredDevice({
    required this.deviceId,
    required this.deviceName,
    required this.ssid,
    required this.configuredAt,
    required this.ipAddress,
  });

  factory ConfiguredDevice.fromJson(Map<String, dynamic> json) {
    return ConfiguredDevice(
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      ssid: json['ssid'],
      configuredAt: DateTime.parse(json['configuredAt']),
      ipAddress: json['ipAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'ssid': ssid,
      'configuredAt': configuredAt.toIso8601String(),
      'ipAddress': ipAddress,
    };
  }
}

class ListaESP extends StatefulWidget {
  const ListaESP({super.key});

  @override
  State<ListaESP> createState() => _ListaESPState();
}

class _ListaESPState extends State<ListaESP> {
  List<ConfiguredDevice> _configuredDevices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfiguredDevices();
  }

  Future<void> _loadConfiguredDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final devicesJson = prefs.getStringList('configured_devices') ?? [];
    
    setState(() {
      _configuredDevices = devicesJson
          .map((json) => ConfiguredDevice.fromJson(jsonDecode(json)))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteDevice(ConfiguredDevice device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar dispositivo'),
        content: const Text('¿Estás seguro de que quieres eliminar este dispositivo de la lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getStringList('configured_devices') ?? [];
      
      devicesJson.removeWhere((json) => 
          ConfiguredDevice.fromJson(jsonDecode(json)).deviceId == device.deviceId);
      
      await prefs.setStringList('configured_devices', devicesJson);
      _loadConfiguredDevices();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispositivo eliminado')),
      );
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
            onPressed: _loadConfiguredDevices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _configuredDevices.isEmpty
              ? const Center(
                  child: Text(
                    'No hay dispositivos configurados',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _configuredDevices.length,
                  itemBuilder: (context, index) {
                    final device = _configuredDevices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.wifi, size: 36),
                        title: Text(
                          device.deviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Red: ${device.ssid}'),
                            Text('IP: ${device.ipAddress}'),
                            Text(
                              'Configurado: ${DateFormat('dd/MM/yyyy HH:mm').format(device.configuredAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteDevice(device),
                        ),
                        onTap: () {
                          // Aquí puedes añadir acción al tocar un dispositivo
                        },
                      ),
                    );
                  },
                ),
    );
  }
}