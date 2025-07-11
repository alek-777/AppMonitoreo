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
      body: Container(
        margin: const EdgeInsets.all(80),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Período"),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: _tipoPeriodoSeleccionado,
                    hint: const Text("Selecciona un tipo de período"),
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
                    hint: const Text("Selecciona un mes"),
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
              padding: const EdgeInsets.only(bottom:40),
              child: Column(
                children: [
                  Image.asset('image/reporte.png', width: 250, height: 250,),
                  const SizedBox(height: 50),
                  ElevatedButton( onPressed:  () => {print("s")},
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  ), 
                  child: Text("Generar Reporte")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
