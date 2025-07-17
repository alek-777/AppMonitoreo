import "package:flutter/material.dart";
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditSectorScreen extends StatefulWidget {
  const EditSectorScreen({super.key});

  @override
  State<EditSectorScreen> createState() => _EditSectorScreen();
}

class _EditSectorScreen extends State<EditSectorScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> updateSector(String nameSector, String description, String idSector) async {
    final response = await http.patch(
      Uri.parse(
        'https://monitoreo-railway-ues-production.up.railway.app/api/sectors/$idSector',
      ),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'nameSector': nameSector,
        'description': description,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Todo bien
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sector actualizado correctamente')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: ${response.body}')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>; 

    nameController.text = data['nombre']!;
    descriptionController.text = data['description']!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${data['nombre']}'),
        centerTitle: true,
        backgroundColor: const Color(0xffFFE4AF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Nombre del sector"),
            _buildCustomTextField(
              hint: "Sector 1",
              controller: nameController,
              dataType: Icon(Icons.add_box_outlined),
            ),
            const Text("Descripción"),
            _buildCustomTextField(
              hint: "De limones",
              controller: descriptionController,
              dataType: Icon(Icons.format_align_justify),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isNotEmpty && description.isNotEmpty) {
                  updateSector(name, description, data['idSector']!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa ambos campos')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 2,
                side: const BorderSide(color: Colors.black, width: 0.5),
              ),
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCustomTextField({
  required String hint,
  Icon? dataType,
  String? path,
  required TextEditingController controller,
}) {
  Widget? suffixIcon;
  if (path != null && path.isNotEmpty) {
    suffixIcon = Padding(
      padding: const EdgeInsets.all(12),
      child: SvgPicture.asset(path, width: 20, height: 20),
    );
  } else if (dataType != null) {
    suffixIcon = dataType;
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: TextField(
      
      controller: controller,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color.fromARGB(255, 241, 241, 241),
        contentPadding: const EdgeInsets.all(15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black),
        ),
        suffixIcon: suffixIcon,
      ),
    ),
  );
}
