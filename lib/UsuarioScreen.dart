import 'package:flutter/material.dart';

class UsuarioScreen extends StatelessWidget {
  const UsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuario'),
        backgroundColor: Color(0xffFFE4AF),
      ),
      body: const Center(child: Text('Contenido de Usuario')),
    );
  }
}
