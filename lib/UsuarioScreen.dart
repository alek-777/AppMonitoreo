import 'package:flutter/material.dart';

class UsuarioScreen extends StatelessWidget {
  const UsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuario"),
        centerTitle: true,
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
                  _buildResponsiveText(texto: "Don Tierras", size: 18, weight: FontWeight.bold)
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 40),
            //   child: Column(
            //     children: [
            //       // _buildResponsiveText(texto: "Nombre génerico de dón", size: 20), 
            //       _buildResponsiveText(texto: "Cargo: Don", size: 20)],
            //   ),
            // ),
            Column(
              children: [
                _buildResponsiveText(texto: "Datos de soporte:", size: 20, weight: FontWeight.bold),
                _buildResponsiveText(texto: "+52 6421987856", size: 20),
                _buildResponsiveText(texto: "Correo@gmail.com", size: 20)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: ElevatedButton(
                onPressed: () => {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 254, 179, 174),
                  foregroundColor: Colors.black,
                  elevation: 2,
                  side: BorderSide(
                    color: Colors.red,
                    width: 0.5
                  )
                ),
                child: _buildResponsiveText(texto: "Cerrar sesión", size: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildResponsiveText({required String texto, required double size, FontWeight? weight}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Container(
      margin: EdgeInsets.all(5),
      child: Text(texto, style: TextStyle(fontSize: size, fontWeight: weight))),
  );
}
