import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bottom_nav.dart';
import 'api_config.dart';
import 'chat_screen.dart';
import 'group_chat_screen.dart';
import 'group_settings_screen.dart';
import 'request_screen.dart';

class SocialScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const SocialScreen({
    super.key,
    this.userData,
  });

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> conversations = [];
  List<Map<String, dynamic>> grupos = [];
  bool isLoadingFriends = false;
  bool isLoadingConversations = false;
  bool isLoadingGroups = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _loadFriends();
    _loadConversations();
    _loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    if (widget.userData?['id'] == null) return;

    setState(() {
      isLoadingFriends = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.friendsUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userData!['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            friends = List<Map<String, dynamic>>.from(data['friends'] ?? []);
          });
        } else {
          print('Erro ao carregar amigos: ${data['message']}');
        }
      } else {
        print('Erro de conexão: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar amigos: $e');
    } finally {
      setState(() {
        isLoadingFriends = false;
      });
    }
  }

  Future<void> _loadConversations() async {
    if (widget.userData?['id'] == null) return;

    setState(() {
      isLoadingConversations = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.conversationsUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userData!['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            conversations =
                List<Map<String, dynamic>>.from(data['conversations'] ?? []);
          });
        } else {
          print('Erro ao carregar conversas: ${data['message']}');
        }
      } else {
        print('Erro de conexão: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar conversas: $e');
    } finally {
      setState(() {
        isLoadingConversations = false;
      });
    }
  }

  Future<void> _loadGroups() async {
    if (widget.userData?['id'] == null) return;

    setState(() {
      isLoadingGroups = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.groupURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userData!['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            grupos = List<Map<String, dynamic>>.from(data['grupos'] ?? []);
          });
        } else {
          print('Erro ao carregar grupos: ${data['message']}');
        }
      } else {
        print('Erro de conexão: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar grupos: $e');
    } finally {
      setState(() {
        isLoadingGroups = false;
      });
    }
  }

  void _openChat(String contactId, String contactName, String? contactPhoto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          contactId: contactId,
          contactName: contactName,
          contactPhoto: contactPhoto,
          userData: widget.userData ?? {},
        ),
      ),
    ).then((_) {
      _loadConversations();
    });
  }

  void _openGroupChat(String groupId, String groupName, String? groupPhoto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatScreen(
          groupId: groupId,
          groupName: groupName,
          groupPhoto: groupPhoto,
          userData: widget.userData ?? {},
        ),
      ),
    ).then((_) {
      _loadGroups();
    });
  }

  void _openGroupSettings(String groupId, String groupName, String userRole) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupSettingsScreen(
          groupId: groupId,
          groupName: groupName,
          userData: widget.userData ?? {},
          userRole: userRole,
        ),
      ),
    ).then((_) {
      _loadGroups();
    });
  }

  void _showCreateGroupDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String groupType = 'privado';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Criar Grupo',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome do grupo',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Tipo: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  DropdownButton<String>(
                    value: groupType,
                    dropdownColor: Colors.grey[800],
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(
                        value: 'privado',
                        child: Text('Privado'),
                      ),
                      DropdownMenuItem(
                        value: 'publico',
                        child: Text('Público'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        groupType = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => _createGroup(
                  nameController.text, descController.text, groupType),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Criar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup(
      String name, String description, String type) async {
    if (name.trim().length < 3) {
      _showSnackBar('Nome deve ter pelo menos 3 caracteres');
      return;
    }

    Navigator.pop(context); 

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.createGroupURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userData!['id'],
          'nome': name.trim(),
          'descricao': description.trim(),
          'tipo': type,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSnackBar('Grupo criado com sucesso!');
          _loadGroups(); 
        } else {
          _showSnackBar('Erro: ${data['message']}');
        }
      } else {
        _showSnackBar('Erro ao criar grupo');
      }
    } catch (e) {
      _showSnackBar('Erro ao criar grupo');
      print('Erro ao criar grupo: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
      ),
    );
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.userData?['photo'] ??
                            'https://lfcostldktmoevensqdj.supabase.co/storage/v1/object/public/fotosuser//user.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 20),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Social',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Botão de Solicitações/Notificações
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestsScreen(
                            userData: widget.userData,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 2,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: 'Amigos'),
                  Tab(text: 'Grupos'),
                  Tab(text: 'Chats'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendsTab(),
                  _buildGroupsTab(),
                  _buildChatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavSeparate(
        currentPage: 'social',
        userData: widget.userData,
      ),
    );
  }

  Widget _buildFriendsTab() {
    if (isLoadingFriends) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (friends.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum amigo encontrado',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _buildFriendItem(
          friendId: friend['id'] ?? friend['friend_id'] ?? '',
          name: friend['username'] ?? 'Usuário',
          photoUrl: friend['photo'] ??
              'https://lfcostldktmoevensqdj.supabase.co/storage/v1/object/public/fotosuser//user.png',
          status: 'Online',
          time: '',
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    if (isLoadingGroups) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showCreateGroupDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Criar Grupo',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: grupos.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum grupo encontrado\nCrie ou participe de grupos!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGroups,
                  backgroundColor: Colors.grey[800],
                  color: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: grupos.length,
                    itemBuilder: (context, index) {
                      final grupo = grupos[index];
                      return _buildGroupItem(
                        groupId: grupo['id'] ?? '',
                        name: grupo['nome'] ?? 'Grupo',
                        description: grupo['ultima_mensagem_formatada'] ??
                            grupo['descricao'] ??
                            '',
                        photoUrl: grupo['foto'],
                        memberCount: grupo['total_membros'] ?? 0,
                        unreadCount: grupo['mensagens_nao_lidas'] ?? 0,
                        time: grupo['horario_formatado'] ?? '',
                        userRole: grupo['papel'] ?? 'membro',
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildChatsTab() {
    if (isLoadingConversations) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (conversations.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma conversa encontrada',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      backgroundColor: Colors.grey[800],
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return _buildChatItem(
            contactId: conversation['contact_id']?.toString() ?? '',
            avatar: _buildConversationAvatar(
              conversation['photo'] ??
                  'https://lfcostldktmoevensqdj.supabase.co/storage/v1/object/public/fotosuser//user.png',
              conversation['username'] ?? 'U',
            ),
            name: conversation['username'] ?? 'Usuário Desconhecido',
            message: conversation['last_message'] ?? '',
            time: conversation['formatted_time'] ?? '',
            unreadCount: conversation['unread_count'] ?? 0,
            photoUrl: conversation['photo'],
          );
        },
      ),
    );
  }

  Widget _buildFriendItem({
    required String friendId,
    required String name,
    required String photoUrl,
    required String status,
    required String time,
  }) {
    return InkWell(
      onTap: () {
        _openChat(friendId, name, photoUrl);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  photoUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getAvatarColor(name),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: status == 'Online' ? Colors.green : Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem({
    required String contactId,
    required Widget avatar,
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    String? photoUrl,
  }) {
    return InkWell(
      onTap: () {
        _openChat(contactId, name, photoUrl);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                avatar,
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: TextStyle(
                            color: unreadCount > 0 ? Colors.white : Colors.grey,
                            fontSize: 12,
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: unreadCount > 0 ? Colors.white70 : Colors.grey,
                        fontSize: 14,
                        fontWeight: unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationAvatar(String photoUrl, String name) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.network(
          photoUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getAvatarColor(name),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupItem({
    required String groupId,
    required String name,
    required String description,
    String? photoUrl,
    required int memberCount,
    int unreadCount = 0,
    required String time,
    required String userRole,
  }) {
    return InkWell(
      onTap: () {
        _openGroupChat(groupId, name, photoUrl);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildGroupAvatar(name);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildGroupAvatar(name),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildRoleBadge(userRole),
                          ],
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: TextStyle(
                            color: unreadCount > 0 ? Colors.white : Colors.grey,
                            fontSize: 12,
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$memberCount membros',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: unreadCount > 0 ? Colors.white70 : Colors.grey,
                        fontSize: 14,
                        fontWeight: unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Botão de configurações - Apenas para admins e moderadores
            if (userRole == 'admin' || userRole == 'moderador')
              GestureDetector(
                onTap: () => _openGroupSettings(groupId, name, userRole),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.settings,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupAvatar(String groupName) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getAvatarColor(groupName),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          groupName.isNotEmpty ? groupName[0].toUpperCase() : 'G',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    if (role == 'membro') return const SizedBox.shrink();

    Color badgeColor;
    String text;

    switch (role) {
      case 'admin':
        badgeColor = Colors.red;
        text = 'Admin';
        break;
      case 'moderador':
        badgeColor = Colors.orange;
        text = 'Mod';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final a = name.hashCode;
    return Color.fromARGB(255, a % 255, (a * 2) % 255, (a * 3) % 255);
  }
}
