import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  String? _messageType; // 'success' ou 'error'

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = null;
        _messageType = null;
      });

      try {
        final response = await http.post(
          Uri.parse(ApiConfig
              .forgotPasswordUrl), // Você precisa adicionar esta URL no seu ApiConfig
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': _emailController.text.trim(),
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            _message = data['message'] ??
                'Se o email estiver cadastrado, você receberá as instruções.';
            _messageType = 'success';
          });
        } else {
          setState(() {
            _message = data['message'] ??
                'Erro ao enviar instruções. Tente novamente.';
            _messageType = 'error';
          });
        }
      } catch (e) {
        setState(() {
          _message = 'Erro de conexão: $e';
          _messageType = 'error';
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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

                // Card de Recuperação de Senha
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Recuperar Senha',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA78BFA),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Mensagem informativa
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade800),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.blue.shade300,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Digite seu email cadastrado para receber as instruções de recuperação de senha.',
                                    style: TextStyle(
                                      color: Colors.blue.shade300,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Mensagem de feedback
                          if (_message != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _messageType == 'success'
                                    ? Colors.green.shade900.withOpacity(0.3)
                                    : Colors.red.shade900.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _messageType == 'success'
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _messageType == 'success'
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: _messageType == 'success'
                                        ? Colors.green.shade300
                                        : Colors.red.shade300,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _message!,
                                      style: TextStyle(
                                        color: _messageType == 'success'
                                            ? Colors.green.shade300
                                            : Colors.red.shade300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_message != null) const SizedBox(height: 16),

                          // Campo de email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                              prefixIcon:
                                  Icon(Icons.email, color: Color(0xFF9F7AEA)),
                              hintText: 'Digite seu email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite seu email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Por favor, digite um email válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Botão de enviar
                          ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetEmail,
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
                                      Icon(Icons.send),
                                      SizedBox(width: 8),
                                      Text('Enviar Instruções'),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Link para voltar ao login
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back, size: 16),
                                SizedBox(width: 4),
                                Text('Voltar para o login'),
                              ],
                            ),
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
