import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  BluetoothDevice? _deviceToReset;

  // UUIDs del servicio BLE (deben coincidir con tu firmware ESP32)
  final String _serviceUUID = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  final String _writeUUID = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';

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

  Future<void> _resetDeviceWifi(String deviceId) async {
    try {
      // Buscar el dispositivo BLE
      final device = BluetoothDevice.fromId(deviceId);
      
      // Conectar
      await device.connect(autoConnect: false, timeout: const Duration(seconds: 10));
      
      // Buscar el servicio y característica
      final services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid.toString().toLowerCase() == _serviceUUID.toLowerCase(),
        orElse: () => throw 'Servicio no encontrado'
      );
      
      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toLowerCase() == _writeUUID.toLowerCase(),
        orElse: () => throw 'Característica no encontrada'
      );
      
      // Enviar comando de reset (formato debe coincidir con tu firmware)
      await characteristic.write("RESET_WIFI".codeUnits);
      
      await device.disconnect();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales WiFi eliminadas del ESP')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al resetear: $e')),
      );
    } finally {
      _deviceToReset = null;
    }
  }

  Future<void> _deleteDevice(int index) async {
    final device = _devices[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Eliminar ${device['deviceName']}?'),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text('También borrar credenciales del ESP'),
              value: _deviceToReset != null,
              onChanged: (v) {
                Navigator.pop(context, false);
                _showDeviceSelection(index);
              },
            ),
          ],
        ),
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
      
      if (_deviceToReset != null) {
        await _resetDeviceWifi(device['deviceId']);
      }
      
      _loadDevices();
    }
  }

  Future<void> _showDeviceSelection(int index) async {
    final result = await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar ESP físico'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            builder: (c, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Text('Buscando dispositivos...');
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: snapshot.data!
                  .where((r) => r.device.platformName.isNotEmpty)
                  .map((r) => ListTile(
                    title: Text(r.device.platformName),
                    subtitle: Text(r.device.remoteId.str),
                    onTap: () => Navigator.pop(context, r.device),
                  ))
                  .toList(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _deviceToReset = result;
      });
      _deleteDevice(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESPs Configurados'),
        backgroundColor: const Color(0xffFFE4AF),
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
                        leading: const Icon(Icons.router),
                        title: Text(device['deviceName'] ?? 'ESP32'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Red: ${device['ssid'] ?? 'Sin red'}'),
                            Text('IP: ${device['ipAddress'] ?? '0.0.0.0'}'),
                            Text(
                              'Configurado: ${DateFormat('dd/MM/yy HH:mm').format(
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
                      ),
                    );
                  },
                ),
    );
  }
}