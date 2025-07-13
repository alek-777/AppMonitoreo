import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ESPScreen extends StatelessWidget {
  const ESPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: BluetoothScannerScreen(),
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

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();
  }

  void _startScan() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      devices.clear();
    });

    // Escuchar resultados del escaneo
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });

    // Iniciar escaneo por 15 segundos
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));

    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del ESP'),
        backgroundColor: Color(0xffFFE4AF),
        centerTitle: true,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 2,
                side: BorderSide(color: Colors.black, width: 0.5),
              ),
              child: Text(
                isScanning ? 'Escaneando...' : 'Buscar Dispositivos',
                maxLines: 2,
              ),
            ),
          ),
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
                  trailing: Text(device.platformName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}