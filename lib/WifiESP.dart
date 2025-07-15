import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WifiESP extends StatefulWidget {
  const WifiESP({super.key});

  @override
  State<WifiESP> createState() => _WifiESPState();
}

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

class _WifiESPState extends State<WifiESP> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;
  
  final String _targetServiceUUID = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  final String _targetCharacteristicUUID = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  final String _notifyCharacteristicUUID = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';

  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _connectionStatus = 'No conectado';
  String _wifiStatus = '';
  String _ipAddress = '';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _devices.clear();
      _connectionStatus = 'Buscando dispositivos...';
    });

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!_devices.contains(result.device)) {
          setState(() {
            _devices.add(result.device);
          });
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    
    setState(() {
      _isScanning = false;
      _connectionStatus = 'Escaneo completado';
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _connectionStatus = 'Conectando...';
    });

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      
      setState(() {
        _connectedDevice = device;
        _connectionStatus = 'Conectado a ${device.platformName}';
      });

      List<BluetoothService> services = await device.discoverServices();

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == _targetServiceUUID.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == _targetCharacteristicUUID.toLowerCase()) {
              setState(() {
                _writeCharacteristic = characteristic;
              });
            }
            if (characteristic.uuid.toString().toLowerCase() == _notifyCharacteristicUUID.toLowerCase()) {
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                _handleNotification(value);
              });
              setState(() {
                _notifyCharacteristic = characteristic;
              });
            }
          }
        }
      }

      if (_writeCharacteristic == null) {
        setState(() {
          _connectionStatus = 'Característica no encontrada';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error de conexión: $e';
      });
    }
  }

  void _handleNotification(List<int> value) {
    final message = String.fromCharCodes(value);
    
    if (message.startsWith("CONFIG_SUCCESS:")) {
      final ip = message.replaceFirst("CONFIG_SUCCESS:", "");
      setState(() {
        _wifiStatus = 'Configuración exitosa!';
        _ipAddress = 'IP: $ip';
      });
      _saveConfiguredDevice(ip);
    } else if (message == "CONFIG_FAILED") {
      setState(() {
        _wifiStatus = 'Error en la configuración WiFi';
        _ipAddress = '';
      });
    }
  }

  Future<void> _saveConfiguredDevice(String ipAddress) async {
    if (_connectedDevice == null || _ssidController.text.isEmpty) return;

    final device = ConfiguredDevice(
      deviceId: _connectedDevice!.remoteId.toString(),
      deviceName: _connectedDevice!.platformName.isEmpty 
          ? 'ESP32' 
          : _connectedDevice!.platformName,
      ssid: _ssidController.text,
      configuredAt: DateTime.now(),
      ipAddress: ipAddress,
    );

    final prefs = await SharedPreferences.getInstance();
    final devicesJson = prefs.getStringList('configured_devices') ?? [];
    devicesJson.add(jsonEncode(device.toJson()));
    await prefs.setStringList('configured_devices', devicesJson);
    
    setState(() {
      _wifiStatus = 'Dispositivo guardado';
    });
  }

  Future<void> _sendWifiCredentials() async {
    if (_writeCharacteristic == null || _ssidController.text.isEmpty || _passwordController.text.isEmpty) return;

    final credentials = 'WIFI:${_ssidController.text}:${_passwordController.text}';
    
    setState(() {
      _wifiStatus = 'Enviando credenciales...';
    });

    try {
      if (_writeCharacteristic!.properties.writeWithoutResponse) {
        await _writeCharacteristic!.write(credentials.codeUnits, withoutResponse: true);
      } else {
        await _writeCharacteristic!.write(credentials.codeUnits, withoutResponse: false);
      }
      
      setState(() {
        _wifiStatus = 'Credenciales enviadas';
      });
    } catch (e) {
      setState(() {
        _wifiStatus = 'Error al enviar: $e';
      });
    }
  }

  void _showCredentialsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar WiFi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'SSID',
                hintText: 'Nombre de la red WiFi',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                hintText: 'Mínimo 8 caracteres',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _sendWifiCredentials();
              Navigator.pop(context);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración WiFi ESP32'),
        backgroundColor: const Color(0xffFFE4AF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de conexión BLE
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Conexión ESP32',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(_connectionStatus),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _startScan,
                      child: Text(_isScanning ? 'Escaneando...' : 'Buscar dispositivos'),
                    ),
                    const SizedBox(height: 10),
                    if (_devices.isNotEmpty)
                      ..._devices.map((device) => ListTile(
                        title: Text(device.platformName),
                        subtitle: Text(device.remoteId.toString()),
                        trailing: ElevatedButton(
                          onPressed: () => _connectToDevice(device),
                          child: const Text('Conectar'),
                        ),
                      )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Sección de configuración WiFi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Configuración WiFi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(_wifiStatus),
                    if (_ipAddress.isNotEmpty)
                      Text(_ipAddress),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _connectedDevice != null ? _showCredentialsDialog : null,
                      child: const Text('Configurar WiFi'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    if (_connectedDevice != null) {
      _connectedDevice!.disconnect();
    }
    super.dispose();
  }
}