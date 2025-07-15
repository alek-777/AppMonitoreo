import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/ESPScreen.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> _checkIfConfigured() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isConfigured') ?? false;
}

class WifiESP extends StatelessWidget {
  const WifiESP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _checkIfConfigured(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data == true
                ? ReceiverConfiguredScreen()
                : BluetoothScannerScreen();
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}

class BluetoothScannerScreen extends StatefulWidget {
  const BluetoothScannerScreen({super.key});

  @override
  State<BluetoothScannerScreen> createState() => _BluetoothScannerScreenState();
}

class _BluetoothScannerScreenState extends State<BluetoothScannerScreen> {
  List<BluetoothDevice> devices = [];
  bool isScanning = false;
  List<WiFiAccessPoint> wifiNetworks = [];
  bool isScanningWifi = false;

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? notifyCharacteristic;

  final String targetServiceUUID = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  final String targetCharacteristicUUID =
      '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  final String notifyCharacteristicUUID =
      '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';

  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  StreamSubscription<List<int>>? notificationSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    notificationSubscription?.cancel();
    _disconnectDevice();
    super.dispose();
  }

  Future<void> _disconnectDevice() async {
    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
      } catch (e) {
        print("Error al desconectar: $e");
      }
    }
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();
  }

  Future<void> _markAsConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isConfigured', true);
  }

  void _startScan() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      devices.clear();
    });

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al escanear: $e")));
    } finally {
      setState(() => isScanning = false);
    }
  }

  Future<void> _scanWifiNetworks() async {
    if (isScanningWifi) return;

    setState(() => isScanningWifi = true);

    try {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        throw "No se puede escanear WiFi: $canScan";
      }

      final results = await WiFiScan.instance.getScannedResults();
      setState(() => wifiNetworks = results);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al escanear WiFi: $e")));
    } finally {
      setState(() => isScanningWifi = false);
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // Desconectar primero si hay una conexión previa
      if (connectedDevice != null) {
        await _disconnectDevice();
      }

      // Conectar al dispositivo
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 15),
      );

      // Pequeña pausa para estabilizar la conexión
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => connectedDevice = device);

      // Descubrir servicios
      List<BluetoothService> services;
      try {
        services = await device.discoverServices();
      } catch (e) {
        throw "Error al descubrir servicios: $e";
      }

      bool foundWriteChar = false;
      bool foundNotifyChar = false;

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() ==
            targetServiceUUID.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            // Característica de escritura
            if (characteristic.uuid.toString().toLowerCase() ==
                targetCharacteristicUUID.toLowerCase()) {
              setState(() => writeCharacteristic = characteristic);
              foundWriteChar = true;
            }
            // Característica de notificación
            if (characteristic.uuid.toString().toLowerCase() ==
                notifyCharacteristicUUID.toLowerCase()) {
              try {
                await characteristic.setNotifyValue(true);
                notificationSubscription?.cancel();
                notificationSubscription = characteristic.onValueReceived
                    .listen((value) {
                      String message = String.fromCharCodes(value);
                      if (message.contains("CONFIG_SUCCESS")) {
                        _markAsConfigured();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiverConfiguredScreen(),
                          ),
                        );
                      }
                    });
                setState(() => notifyCharacteristic = characteristic);
                foundNotifyChar = true;
              } catch (e) {
                print("Error al configurar notificaciones: $e");
              }
            }
          }
        }
      }

      if (!foundWriteChar || !foundNotifyChar) {
        throw "No se encontraron todas las características necesarias";
      }

      await _scanWifiNetworks();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al conectar: $e")));
      await device.disconnect();
      setState(() {
        connectedDevice = null;
        writeCharacteristic = null;
        notifyCharacteristic = null;
      });
    }
  }

  Future<void> _sendWifiCredentials(String ssid, String password) async {
    if (writeCharacteristic == null) return;

    final credentials = 'WIFI:$ssid:$password';
    try {
      if (writeCharacteristic!.properties.writeWithoutResponse) {
        await writeCharacteristic!.write(
          credentials.codeUnits,
          withoutResponse: true,
        );
      } else {
        await writeCharacteristic!.write(
          credentials.codeUnits,
          withoutResponse: false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al enviar: $e")));
      throw e;
    }
  }

  void _showWifiCredentialsDialog(WiFiAccessPoint network) {
    _ssidController.text = network.ssid;
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar credenciales WiFi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Red: ${network.ssid}'),
            const SizedBox(height: 16),
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(labelText: 'SSID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
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
            onPressed: () async {
              try {
                await _sendWifiCredentials(
                  _ssidController.text.trim(),
                  _passwordController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Credenciales enviadas al ESP32"),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error al enviar credenciales: $e")),
                );
              }
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
        title: const Text('Configurar WiFi ESP32'),
        backgroundColor: const Color(0xffFFE4AF),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _startScan),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _startScan,
              child: Text(isScanning ? 'Escaneando...' : 'Buscar Dispositivos'),
            ),
          ),
          if (connectedDevice != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _scanWifiNetworks,
                child: Text(
                  isScanningWifi ? 'Buscando redes...' : 'Escanear redes WiFi',
                ),
              ),
            ),
            Expanded(
              child: wifiNetworks.isEmpty
                  ? const Center(child: Text("No se encontraron redes WiFi"))
                  : ListView.builder(
                      itemCount: wifiNetworks.length,
                      itemBuilder: (context, index) {
                        final network = wifiNetworks[index];
                        return ListTile(
                          leading: const Icon(Icons.wifi),
                          title: Text(network.ssid),
                          subtitle: Text("Señal: ${network.level} dBm"),
                          trailing: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () =>
                                _showWifiCredentialsDialog(network),
                          ),
                        );
                      },
                    ),
            ),
          ] else ...[
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(
                      device.platformName.isEmpty
                          ? 'Dispositivo Desconocido'
                          : device.platformName,
                    ),
                    subtitle: Text(device.remoteId.toString()),
                    trailing: ElevatedButton(
                      onPressed: () => _connectToDevice(device),
                      child: const Text("Conectar"),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ReceiverConfiguredScreen extends StatelessWidget {
  const ReceiverConfiguredScreen({super.key});

  Future<void> _resetConfiguration(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isConfigured', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ESPScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Completa'),
        backgroundColor: const Color(0xffFFE4AF),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Tu receptor está configurado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'El dispositivo ESP32 está conectado correctamente a la red WiFi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              onPressed: () => _resetConfiguration(context),
              child: const Text(
                'Cambiar Configuración',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
