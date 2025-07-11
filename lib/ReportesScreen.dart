import 'package:flutter/material.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  String? _tipoPeriodoSeleccionado;
  String? _mesSeleccionado;

  final List<String> _tiposPeriodo = ['Mensual', 'Quincenal', 'Semanal', 'Hoy'];
  final List<String> _meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        centerTitle: true,
        backgroundColor: const Color(0xffFFE4AF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // Esto es el margen externo
        child: Container(
          padding: const EdgeInsets.all(.8), //el problema
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Período"),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: _tipoPeriodoSeleccionado,
                      hint: const Text("Seleccione un Período"),
                      items: _tiposPeriodo.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: (String? nuevoValor) {
                        setState(() {
                          _tipoPeriodoSeleccionado = nuevoValor;
                        });
                      },
                    ),
                    DropdownButton<String>(
                      value: _mesSeleccionado,
                      hint: const Text("Seleccione un Mes"),
                      items: _meses.map((String mes) {
                        return DropdownMenuItem<String>(
                          value: mes,
                          child: Text(mes),
                        );
                      }).toList(),
                      onChanged: (String? nuevoValor) {
                        setState(() {
                          _mesSeleccionado = nuevoValor;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Image.asset('image/reporte.png', width: 250, height: 250),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () => {print("s")},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16, //Lo alto del boton
                            ),
                          ),
                          child: Text("Generar Reporte"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
