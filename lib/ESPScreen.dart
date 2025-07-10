import 'package:flutter/material.dart';

class ESPScreen extends StatelessWidget {
  const ESPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del ESP'),
        backgroundColor: Color(0xffFFE4AF),
      ),
      body: const Center(child: Text('Contenido de Configuración del ESP')),
    );
  }
}
