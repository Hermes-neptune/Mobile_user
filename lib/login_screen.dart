import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'api_config.dart';
import 'forgot_password_screen.dart';

//login page
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rmController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Verifica se o usuário já está logado
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      // Usuário já está logado, navegar para home
      final user = jsonDecode(userData);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userData: user),
        ),
      );
    }
  }

  // Salva os dados do usuário no armazenamento local
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
    await prefs.setBool('is_logged_in', true);
  }

  // Remove os dados do usuário do armazenamento local
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.setBool('is_logged_in', false);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await http.post(
          Uri.parse(ApiConfig.loginUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'rm': _rmController.text,
            'password': _passwordController.text,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          // Login bem-sucedido
          _showMessage('Login realizado com sucesso!', Colors.green);

          // Salvar dados do usuário no armazenamento local
          await _saveUserData(data['user']);

          // Navegar para a tela do dashboard passando os dados do usuário
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userData: data['user'], // Passando os dados do usuário
              ),
            ),
          );
        } else {
          // Login falhou
          setState(() {
            _errorMessage = data['message'] ?? 'Erro ao fazer login';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Erro de conexão: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _forgotPassword() async {
    // Navegar para a tela de recuperação de senha
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _rmController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Hero(
                    tag: "imagem",
                    child: Image.network(
                      "https://raw.githubusercontent.com/Hermes-neptune/site-produto/refs/heads/main/img/logo/logo-white.png",
                      width: 1000,
                      height: 1000,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Card de Login
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA78BFA),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Mensagem de erro
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade900.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade800),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade300),
                              ),
                            ),
                          if (_errorMessage != null) const SizedBox(height: 16),

                          // Campo de RM
                          TextFormField(
                            controller: _rmController,
                            decoration: const InputDecoration(
                              labelText: 'RM (Registro de Matrícula)',
                              labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                              prefixIcon:
                                  Icon(Icons.badge, color: Color(0xFF9F7AEA)),
                            ),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu RM';
                              }
                              if (value.length < 3) {
                                return 'RM deve ter pelo menos 3 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo de senha
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle:
                                  const TextStyle(color: Color(0xFFA78BFA)),
                              prefixIcon: const Icon(Icons.lock,
                                  color: Color(0xFF9F7AEA)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: const Color(0xFF4B5563),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua senha';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Botão de login
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login),
                                      SizedBox(width: 8),
                                      Text('Entrar'),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Link para recuperar senha
                          TextButton(
                            onPressed: _isLoading ? null : _forgotPassword,
                            child: const Text('Esqueceu sua senha?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
