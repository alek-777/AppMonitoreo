import 'package:flutter/material.dart';

class UsuarioScreen extends StatelessWidget {
  const UsuarioScreen({super.key});

  void cerrarSesion() {
    print(3 + 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuario'),
        backgroundColor: Color(0xffFFE4AF),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  Image.asset("image/usuario.png", width: 80, height: 80),
                  Text(
                    "Don Tierras",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [Text("Nombre génerico de dón"), Text("Cargo: Don")],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ElevatedButton(
                onPressed: cerrarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: Text("Cerrar Sesión"),
              ),
            ),
            Column(
              children: [
                Text("Datos de soporte:", style: TextStyle(fontSize: 20)),
                Text("+52 6421987856"),
                Text("Correo@gmail.com"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
