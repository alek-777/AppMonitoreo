import 'package:flutter/material.dart';

class RiegoScreen extends StatelessWidget {
  const RiegoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo de Riego'),
        backgroundColor: Color(0xffFFE4AF),
      ),
      body: const Center(child: Text('reportes')),
    );
  }
}
