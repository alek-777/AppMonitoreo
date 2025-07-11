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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // Margen externo uniforme
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Período", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),

              // Dropdowns alineados
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      isExpanded: true,
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
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      isExpanded: true,
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

              const SizedBox(height: 20),
              Image.asset('image/reporte.png', width: 250, height: 250),
              const SizedBox(height: 20),
              // Botón alineado con los dropdowns
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => print("s"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Generar Reporte"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
