import 'package:flutter/material.dart';
import 'package:flutter_application_2/log-reg/config/helpers/api_service.dart';
import 'package:flutter_application_2/log-reg/infrastructure/models/user_model.dart';
import 'package:flutter_application_2/log-reg/presentation/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyDescriptionController = TextEditingController();

  bool _isLoading = false;
  bool _createCompany = false;

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final companyName = _companyNameController.text.trim();

    int? companyIdCompany;
    bool wasCompanyCreated = false;

    if (_createCompany) {
      final created = await ApiService.createCompany({
        'name': companyName,
        'description': _companyDescriptionController.text.trim(),
      });

      if (!created['success']) {
        _showApiError(created['message']);
        setState(() => _isLoading = false);
        return;
      }

      companyIdCompany = created['data']?['idCompany'];
      wasCompanyCreated = true;
    } else {
      final existing = await ApiService.findCompanyByName(companyName);

      if (!existing['success']) {
        _showApiError(existing['message']);
        setState(() => _isLoading = false);
        return;
      }

      companyIdCompany = existing['data']?['idCompany'];
    }

    final newUser = UserModel(
      username: _userController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      idCompany: companyIdCompany,
    );

    final result = await ApiService.registerUser(newUser);

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      if (wasCompanyCreated && companyIdCompany != null) {
        await ApiService.deleteCompany(companyIdCompany);
      }

      _showApiError(result['message']);
    }
  }

  void _showApiError(dynamic message) {
    final formattedMessage = message is List
        ? message.join('\n')
        : message ?? 'Ocurrió un error inesperado';
    _showError(formattedMessage);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://agriculture.basf.com/api/imaging/focalarea/33x10/1920x/dam/jcr%3Aed68cfad-5c37-3712-8168-343eccad91d2/MX-cultivo-maiz.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                color: Color.fromARGB(111, 0, 0, 0),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DrewSite',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Todo tu monitoreo en un solo lugar',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(padding: const EdgeInsets.all(24.0), child: _buildForm()),
        ],
      ),
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<bool>(
            value: _createCompany,
            items: const [
              DropdownMenuItem(
                value: false,
                child: Text('Unirme a una compañía existente'),
              ),
              DropdownMenuItem(
                value: true,
                child: Text('Crear una nueva compañía'),
              ),
            ],
            onChanged: (value) {
              setState(() => _createCompany = value!);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona una opción',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la compañía',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingrese el nombre de la compañía';
              }
              return null;
            },
          ),
          if (_createCompany) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción de la compañía',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese una descripción';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _userController,
            decoration: const InputDecoration(
              labelText: 'Usuario',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'El usuario debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'El usuario debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              final regex = RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
              );
              if (value == null || !regex.hasMatch(value)) {
                return 'Debe tener al menos 8 caracteres,\nuna mayúscula, una minúscula,\nun número y un símbolo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _repeatPasswordController,
            decoration: const InputDecoration(
              labelText: 'Repite la contraseña',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Registrar', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
            child: const Text('¿Ya tienes cuenta? Ingresar'),
          ),
        ],
      ),
    );
  }
}
