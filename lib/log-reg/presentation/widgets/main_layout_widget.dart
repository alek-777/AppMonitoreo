import 'package:flutter/material.dart';

class MainLayoutWidget extends StatelessWidget {
  final Widget child;
  final Color color;

  const MainLayoutWidget({super.key, required this.child, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior verde
            Container(height: 50, width: double.infinity, color: color),
            // Espacio central
            Expanded(child: child),
            // Barra inferior verde
            Container(height: 50, width: double.infinity, color: color),
          ],
        ),
      ),
    );
  }
}
