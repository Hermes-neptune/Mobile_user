import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import 'api_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  bool _isLoadingPreferences = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  // Inicializar configurações
  Future<void> _initializeSettings() async {
    await _loadUserId();
    await _loadNotificationSettings();
    if (_userId != null) {
      await _loadServerPreferences();
    }
    setState(() {
      _isLoadingPreferences = false;
    });
  }

  // Carregar ID do usuário
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final userJson = json.decode(userData);
      _userId = userJson['id'];
    }
  }

  // Carregar configurações locais de notificação
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  // Carregar preferências do servidor
  Future<void> _loadServerPreferences() async {
    if (_userId == null) return;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getPreferencesURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': _userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final preferences = data['preferences'];
          setState(() {
            _notificationsEnabled = preferences['mobile_notif'] ?? true;
          });

          // Sincronizar com SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('notifications_enabled', _notificationsEnabled);
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar preferências: $e');
    }
  }

  // Salvar configurações locais de notificação
  Future<void> _saveNotificationSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });

    // Também atualizar no servidor se usuário estiver logado
    if (_userId != null) {
      _updateServerPreference('mobile_notif', value);
    }
  }

  // Atualizar preferência específica no servidor
  Future<void> _updateServerPreference(
      String preferenceType, bool value) async {
    if (_userId == null) return;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updatePreferencesURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': _userId,
          preferenceType: value,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSnackBar('Preferência atualizada com sucesso', Colors.green);
        } else {
          _showSnackBar('Erro: ${data['message']}', Colors.red);
          // Reverter mudança local em caso de erro
          await _loadServerPreferences();
        }
      } else {
        _showSnackBar('Erro de conexão', Colors.red);
        await _loadServerPreferences();
      }
    } catch (e) {
      _showSnackBar('Erro ao salvar preferência', Colors.red);
      await _loadServerPreferences();
    }
  }

  // Mostrar SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Função para abrir o site "Sobre Nós"
  Future<void> _openAboutUsWebsite() async {
    final Uri url = Uri.parse('https://hermes-neptune.github.io/site-produto/');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showSnackBar('Não foi possível abrir o site', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erro ao abrir o site: $e', Colors.red);
    }
  }

  Future<void> _openConfigWebsite() async {
    final Uri url = Uri.parse(ApiConfig.configUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showSnackBar('Não foi possível abrir o site', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erro ao abrir o site: $e', Colors.red);
    }
  }

  // Função para fazer logout
  Future<void> _logout() async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Confirmar Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Tem certeza que deseja sair?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_data');
        await prefs.setBool('is_logged_in', false);

        Navigator.of(context).pop();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        Navigator.of(context).pop();
        _showSnackBar('Erro ao fazer logout: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // Settings Groups
            Expanded(
              child: _isLoadingPreferences
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // Notification Settings
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                // Header das Notificações
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.notifications_outlined,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Notificações',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                    color: Color(0xFF3A3A3A), height: 1),

                                // Notificações Gerais (Local)
                                _buildToggleSetting(
                                  title: 'Notificações do App',
                                  subtitle: 'Controle geral das notificações',
                                  isOn: _notificationsEnabled,
                                  showDivider: true,
                                  onToggle: _saveNotificationSettings,
                                ),
                              ],
                            ),
                          ),

                          // Account Settings
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: _buildNavigationSetting(
                              title: 'Conta',
                              icon: Icons.person_outline,
                              onTap: _openConfigWebsite,
                            ),
                          ),

                          // About Us
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: _buildNavigationSetting(
                              title: 'Sobre Nós',
                              icon: Icons.info_outline,
                              onTap: _openAboutUsWebsite,
                            ),
                          ),

                          // Logout
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildSimpleSetting(
                              title: 'Desconectar',
                              icon: Icons.logout,
                              onTap: _logout,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required String title,
    String? subtitle,
    IconData? icon,
    required bool isOn,
    required bool showDivider,
    bool enabled = true,
    required Function(bool) onToggle,
  }) {
    return Column(
      children: [
        Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            title,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: EdgeInsets.only(left: icon != null ? 32 : 0),
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: enabled ? () => onToggle(!isOn) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isOn ? Colors.green : const Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment:
                          isOn ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            color: Color(0xFF3A3A3A),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildNavigationSetting({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleSetting({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
