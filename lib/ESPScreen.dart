import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ESPScreen extends StatelessWidget {
  const ESPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BluetoothScannerScreen(),
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

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  TextEditingController _textController = TextEditingController();

  final String targetCharacteristicUUID = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';

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

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    setState(() {
      isScanning = false;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
  try {
    await device.connect(timeout: const Duration(seconds: 10));
    
    setState(() {
      connectedDevice = device;
    });

    List<BluetoothService> services = await device.discoverServices();
    print("Servicios descubiertos: ${services.length}"); // Debug

    for (var service in services) {
      print("Servicio UUID: ${service.uuid}"); // Debug
      
      for (var characteristic in service.characteristics) {
        print("Característica UUID: ${characteristic.uuid}"); // Debug
        
        if (characteristic.uuid.toString().toLowerCase() == targetCharacteristicUUID.toLowerCase()) {
          setState(() {
            writeCharacteristic = characteristic;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Dispositivo conectado y listo!")),
          );
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No se encontró la característica de escritura.")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al conectar: ${e.toString()}")),
    );
  }
}

  Future<void> _sendMessage(String message) async {
  if (writeCharacteristic != null) {
    try {
      // Primero intenta con withoutResponse (más rápido si está soportado)
      await writeCharacteristic!.write(message.codeUnits, withoutResponse: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mensaje enviado: $message")),
      );
    } catch (e) {
      // Si falla, intenta con withResponse (más lento pero más compatible)
      try {
        await writeCharacteristic!.write(message.codeUnits, withoutResponse: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mensaje enviado (con respuesta): $message")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al enviar: ${e.toString()}")),
        );
      }
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No estás conectado a un ESP32 válido.")),
    );
  }
}

  Widget _buildSendBox() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: "Mensaje para ESP32",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final text = _textController.text.trim();
              if (text.isNotEmpty) {
                _sendMessage(text);
                _textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexión ESP32 BLE'),
        backgroundColor: const Color(0xffFFE4AF),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _startScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 2,
                side: const BorderSide(color: Colors.black, width: 0.5),
              ),
              child: Text(isScanning ? 'Escaneando...' : 'Buscar Dispositivos'),
            ),
          ),
          if (connectedDevice != null && writeCharacteristic != null) _buildSendBox(),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(
                    device.platformName.isEmpty ? 'Dispositivo Desconocido' : device.platformName,
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
      ),
    );
  }
}