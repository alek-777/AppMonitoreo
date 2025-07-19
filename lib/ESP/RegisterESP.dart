import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class RegisterESP extends StatefulWidget {
  const RegisterESP({super.key});

  @override
  State<RegisterESP> createState() => _RegisterESPState();
}

class _RegisterESPState extends State<RegisterESP> {
  final _formKey = GlobalKey<FormState>();
  final _apiUrl = 'https://monitoreo-railway-ues-production.up.railway.app/api/sensors';
  final TextEditingController _macController = TextEditingController();

  // Campos del formulario
  String _etiqueta = '';
  String _mac = '';
  int _sector = 0;
  int _confirmacionSector = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  bool _isScanning = false;
  List<BluetoothDevice> _dispositivos = [];

  @override
  void initState() {
    super.initState();
    _solicitarPermisos();
  }

  Future<void> _solicitarPermisos() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _escaneardispositivos() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _dispositivos.clear();
    });

    FlutterBluePlus.scanResults.listen((resultados) {
      for (var resultado in resultados) {
        if (!_dispositivos.contains(resultado.device)) {
          setState(() {
            _dispositivos.add(resultado.device);
          });
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    setState(() => _isScanning = false);
  }

  Future<void> _registrarESP() async {
  if (!_formKey.currentState!.validate()) return;
  if (_sector != _confirmacionSector) {
    setState(() => _errorMessage = 'Los números de sector no coinciden');
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
  });

  try {
    final respuesta = await http.post(
      Uri.parse('https://monitoreo-railway-ues-production.up.railway.app/api/sensors'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tag': _etiqueta,
        'mac': _mac,
        'idSector': _sector,
      }),
    ).timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 201) {
      setState(() {
        _successMessage = 'ESP registrado exitosamente!';
        _resetCampos();
      });
    } else {
      _manejarErrorRespuesta(respuesta);
    }
  } on TimeoutException {
    setState(() => _errorMessage = 'Tiempo de espera agotado. Intente nuevamente');
  } on SocketException {
    setState(() => _errorMessage = 'Error de conexión. Verifique su internet');
  } catch (e) {
    setState(() => _errorMessage = 'Error: ${e.toString()}');
  } finally {
    setState(() => _isLoading = false);
  }
}

void _resetCampos() {
  _etiqueta = '';
  _mac = '';
  _sector = 0;
  _confirmacionSector = 0;
  _macController.clear();
  _formKey.currentState?.reset();
}

void _manejarErrorRespuesta(http.Response respuesta) {
  try {
    final errorData = jsonDecode(respuesta.body);
    setState(() {
      _errorMessage = errorData['message'] ?? 'Error al registrar ESP (Código ${respuesta.statusCode})';
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Error ${respuesta.statusCode}: ${respuesta.body}';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nuevo ESP'),
        backgroundColor: const Color(0xffFFE4AF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Etiqueta/Nombre
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Etiqueta del ESP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un nombre para el ESP';
                  }
                  return null;
                },
                onChanged: (value) => _etiqueta = value,
              ),
              const SizedBox(height: 20),

              // Campo MAC Address
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _macController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección MAC',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bluetooth),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la dirección MAC';
                        }
                        if (!RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')
                            .hasMatch(value)) {
                          return 'Formato MAC inválido';
                        }
                        return null;
                      },
                      onChanged: (value) => _mac = value.toUpperCase(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isScanning ? Icons.stop : Icons.search),
                    onPressed: _escaneardispositivos,
                    tooltip: 'Escanear dispositivos BLE',
                  ),
                ],
              ),

              // Lista de dispositivos escaneados
              if (_dispositivos.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: _dispositivos.length,
                    itemBuilder: (context, index) {
                      final dispositivo = _dispositivos[index];
                      return ListTile(
                        title: Text(dispositivo.platformName),
                        subtitle: Text(dispositivo.remoteId.toString()),
                        onTap: () {
                          setState(() {
                            _mac = dispositivo.remoteId.toString();
                            _macController.text = _mac;
                          });
                        },
                      );
                    },
                  ),
                ),

              // Campo Número de Sector
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Número de Sector',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el número de sector';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
                onChanged: (value) => _sector = int.tryParse(value) ?? 0,
              ),

              // Campo Confirmación de Sector
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirmar Número de Sector',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme el número de sector';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
                onChanged: (value) => _confirmacionSector = int.tryParse(value) ?? 0,
              ),

              // Botón y mensajes
              const SizedBox(height: 30),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _registrarESP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFE4AF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('REGISTRAR ESP'),
                ),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _successMessage,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _macController.dispose();
    super.dispose();
  }
}