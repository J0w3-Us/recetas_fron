import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../../services/api_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    print('🔐 [LOGIN] Iniciando proceso de login');
    print('🔐 [LOGIN] Validando formulario...');

    if (_formKey.currentState!.validate()) {
      print('✅ [LOGIN] Formulario válido');
      setState(() => _isLoading = true);

      try {
        print('🔐 [LOGIN] Creando instancia de ApiService');
        final apiService = ApiService();

        print('🔐 [LOGIN] Intentando login con:');
        print('   - Email: ${_emailController.text}');
        print('   - Contraseña: [HIDDEN]');

        await apiService.iniciarSesion(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          print('✅ [LOGIN] Login exitoso, navegando al Home');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
        print('❌ [LOGIN] Error durante el login: $e');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('❌ [LOGIN] Formulario inválido');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 80),

                  // Título
                  Text(
                    'Bienvenido de nuevo',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 48),

                  // Formulario
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo Email
                        Text(
                          'Email',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Ingresa tu email',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Campo Contraseña
                        Text(
                          'Contraseña',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Ingresa tu contraseña',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Botón de Iniciar Sesión
                        SizedBox(
                          height: 54,
                          child: CustomButton(
                            text: 'Iniciar Sesión',
                            onPressed: _handleLogin,
                            isLoading: _isLoading,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Link a Crear cuenta
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text('Crear una cuenta'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text('RecipeBrand', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
