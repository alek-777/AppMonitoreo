import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfiguracionSector extends StatelessWidget {
  const ConfiguracionSector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Sector'),
        backgroundColor: Color(0xffFFE4AF),
      ),
      body: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text("Humedad máxima (%)", maxLines: 1, overflow: TextOverflow.ellipsis,),
                      buildCustomTextField(
                        hint: "50",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text("Temperatura máxima (°C)", maxLines: 1, overflow: TextOverflow.ellipsis,),
                      buildCustomTextField(
                        hint: "37",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text("Humedad mínima (%)", maxLines: 1, overflow: TextOverflow.ellipsis,),
                      buildCustomTextField(
                        hint: "40",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text("Temperatura mínima (°C)", maxLines: 1, overflow: TextOverflow.ellipsis,),
                      buildCustomTextField(
                        hint: "30",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: ElevatedButton(
                onPressed: () => {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  side: BorderSide(
                    color: Colors.black,
                    width: 0.5
                  )
                ),
                child: const Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildCustomTextField({required String hint}) {
  return Container(
    margin: const EdgeInsets.only(left:20, right: 20, bottom: 20, top: 10),
    child: TextField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        hintText: hint,
        filled: true,
        fillColor: const Color.fromARGB(255, 241, 241, 241),
        contentPadding: const EdgeInsets.all(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    ),
  );
}
