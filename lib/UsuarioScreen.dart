import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Usuario desconocido';
    setState(() {
      _username = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuario"),
        centerTitle: true,
        backgroundColor: const Color(0xffFFE4AF),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("image/usuario.png", width: 80, height: 80),
                    _buildResponsiveText(
                      texto: _username,
                      size: 18,
                      weight: FontWeight.bold,
                    ),
                    _buildResponsiveText(
                      texto: "Datos de soporte:",
                      size: 20,
                      weight: FontWeight.bold,
                    ),
                    _buildResponsiveText(texto: "+52 6421987856", size: 20),
                    _buildResponsiveText(texto: "Correo@gmail.com", size: 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ElevatedButton(
                        onPressed: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Cerrar sesión'),
                              content: Text(
                                '¿Estás seguro de que deseas cerrar sesión?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text('Sí, salir'),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout ?? false) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (!mounted) return;
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            254,
                            179,
                            174,
                          ),
                          foregroundColor: Colors.black,
                          elevation: 2,
                          side: const BorderSide(color: Colors.red, width: 0.5),
                        ),
                        child: _buildResponsiveText(
                          texto: "Cerrar sesión",
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveText({
    required String texto,
    required double size,
    FontWeight? weight,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        margin: EdgeInsets.all(5),
        child: Text(
          texto,
          style: TextStyle(fontSize: size, fontWeight: weight),
        ),
      ),
    );
  }
}
