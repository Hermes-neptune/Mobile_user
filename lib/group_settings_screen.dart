import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class GroupSettingsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final Map<String, dynamic> userData;
  final String userRole;

  const GroupSettingsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userData,
    required this.userRole,
  });

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  List<Map<String, dynamic>> availableUsers = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.searchForGroupURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userData['id'],
          'grupo_id': widget.groupId,
          'search': _searchController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            availableUsers =
                List<Map<String, dynamic>>.from(data['usuarios'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Erro ao buscar usuários: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _inviteUser(String userId, String username) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.inviteGroupURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grupo_id': widget.groupId,
          'user_id': widget.userData['id'],
          'convidado_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSnackBar('Convite enviado para $username');
          _loadAvailableUsers(); // Recarrega a lista
        } else {
          _showSnackBar('Erro: ${data['message']}');
        }
      }
    } catch (e) {
      _showSnackBar('Erro ao enviar convite');
      print('Erro ao convidar usuário: $e');
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await _showConfirmDialog(
      'Sair do Grupo',
      'Tem certeza que deseja sair do grupo "${widget.groupName}"?',
      'Sair',
    );

    if (!confirmed) return;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.leaveGroupURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grupo_id': widget.groupId,
          'user_id': widget.userData['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          Navigator.popUntil(context, (route) => route.isFirst);
          _showSnackBar('Você saiu do grupo');
        } else {
          _showSnackBar('Erro: ${data['message']}');
        }
      }
    } catch (e) {
      _showSnackBar('Erro ao sair do grupo');
      print('Erro ao sair do grupo: $e');
    }
  }

  Future<void> _deleteGroup() async {
    final confirmed = await _showConfirmDialog(
      'Deletar Grupo',
      'Tem certeza que deseja deletar o grupo "${widget.groupName}"? Esta ação não pode ser desfeita.',
      'Deletar',
    );

    if (!confirmed) return;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.deleteGroupURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grupo_id': widget.groupId,
          'user_id': widget.userData['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          Navigator.popUntil(context, (route) => route.isFirst);
          _showSnackBar('Grupo deletado com sucesso');
        } else {
          _showSnackBar('Erro: ${data['message']}');
        }
      }
    } catch (e) {
      _showSnackBar('Erro ao deletar grupo');
      print('Erro ao deletar grupo: $e');
    }
  }

  Future<bool> _showConfirmDialog(
      String title, String content, String confirmText) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              content,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  confirmText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  Color _getAvatarColor(String username) {
    final hash = username.hashCode;
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configurações do Grupo',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de convites (apenas admins e moderadores)
            if (widget.userRole == 'admin' ||
                widget.userRole == 'moderador') ...[
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Convidar Membros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar amigos...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _loadAvailableUsers(),
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else if (availableUsers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Nenhum amigo disponível para convidar',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableUsers.length,
                  itemBuilder: (context, index) {
                    final user = availableUsers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: user['photo'] != null
                                ? NetworkImage(user['photo'])
                                : null,
                            backgroundColor:
                                _getAvatarColor(user['username'] ?? ''),
                            child: user['photo'] == null
                                ? Text(
                                    (user['username'] ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              user['username'] ?? 'Usuário',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                _inviteUser(user['id'], user['username']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Convidar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),
            ],

            // Seções de configurações
            _buildSectionTitle('Ações do Grupo'),
            _buildActionTile(
              icon: Icons.exit_to_app,
              title: 'Sair do Grupo',
              subtitle: 'Você não receberá mais mensagens deste grupo',
              color: Colors.orange,
              onTap: _leaveGroup,
            ),

            // Deletar grupo (apenas admins)
            if (widget.userRole == 'admin') ...[
              _buildActionTile(
                icon: Icons.delete,
                title: 'Deletar Grupo',
                subtitle: 'Esta ação não pode ser desfeita',
                color: Colors.red,
                onTap: _deleteGroup,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
