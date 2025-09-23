import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class RequestsScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const RequestsScreen({
    super.key,
    this.userData,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> friendRequests = [];
  List<Map<String, dynamic>> groupInvites = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoadingFriendRequests = false;
  bool isLoadingGroupInvites = false;
  bool isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFriendRequests();
    _loadGroupInvites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendRequests() async {
    if (widget.userData?['id'] == null) return;

    setState(() {
      isLoadingFriendRequests = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.friendRequestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userData!['id'],
          'action': 'get_requests',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            friendRequests =
                List<Map<String, dynamic>>.from(data['requests'] ?? []);
          });
        } else {
          print('Erro ao carregar solicitações de amizade: ${data['message']}');
        }
      } else {
        print('Erro de conexão: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar solicitações de amizade: $e');
    } finally {
      setState(() {
        isLoadingFriendRequests = false;
      });
    }
  }

  Future<void> _loadGroupInvites() async {
    if (widget.userData?['id'] == null) return;

    setState(() {
      isLoadingGroupInvites = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.groupRequestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userData!['id'],
          'action': 'get_invites',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            groupInvites =
                List<Map<String, dynamic>>.from(data['invites'] ?? []);
          });
        } else {
          print('Erro ao carregar convites de grupos: ${data['message']}');
        }
      } else {
        print('Erro de conexão: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar convites de grupos: $e');
    } finally {
      setState(() {
        isLoadingGroupInvites = false;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig
            .searchUserURL), // Você precisa adicionar esta URL no ApiConfig
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'search': query.trim(),
          'current_user_id': widget.userData!['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            searchResults =
                List<Map<String, dynamic>>.from(data['usuarios'] ?? []);
          });
        } else {
          print('Erro ao buscar usuários: ${data['message']}');
        }
      } else {
        print('Erro de conexão: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar usuários: $e');
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> _sendFriendRequest(String friendId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.friendRequestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userData!['id'],
          'friend_id': friendId,
          'action': 'enviar_solicitacao',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _showSnackBar(data['message'] ?? 'Solicitação enviada com sucesso');
          // Atualiza o resultado da pesquisa para mostrar que a solicitação foi enviada
          setState(() {
            searchResults = searchResults.map((user) {
              if (user['id'].toString() == friendId) {
                user['request_sent'] = 1;
              }
              return user;
            }).toList();
          });
        } else {
          _showSnackBar('Erro: ${data['message']}');
        }
      } else {
        _showSnackBar('Erro ao enviar solicitação');
      }
    } catch (e) {
      _showSnackBar('Erro ao enviar solicitação');
      print('Erro: $e');
    }
  }

  Future<void> _handleFriendRequest(String requestId, String action) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.friendRequestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'request_id': requestId,
          'action': action == 'accept'
              ? 'aceitar_solicitacao'
              : 'rejeitar_solicitacao',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _showSnackBar(data['message'] ?? 'Ação realizada com sucesso');
          _loadFriendRequests(); // Recarrega a lista
        } else {
          _showSnackBar('Erro: ${data['message']}');
        }
      } else {
        _showSnackBar('Erro ao processar solicitação');
      }
    } catch (e) {
      _showSnackBar('Erro ao processar solicitação');
      print('Erro: $e');
    }
  }

  Future<void> _handleGroupInvite(String inviteId, String action) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.groupRequestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'invite_id': inviteId,
          'action': action == 'accept' ? 'aceitar_convite' : 'rejeitar_convite',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSnackBar(data['message'] ?? 'Ação realizada com sucesso');
          _loadGroupInvites(); // Recarrega a lista
        } else {
          _showSnackBar('Erro: ${data['message']}');
        }
      } else {
        _showSnackBar('Erro ao processar convite');
      }
    } catch (e) {
      _showSnackBar('Erro ao processar convite');
      print('Erro: $e');
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Solicitações',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          indicatorWeight: 2,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 20),
                  const SizedBox(width: 4),
                  const Text('Amizade'),
                  if (friendRequests.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        friendRequests.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_add, size: 20),
                  const SizedBox(width: 4),
                  const Text('Grupos'),
                  if (groupInvites.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        groupInvites.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 20),
                  SizedBox(width: 4),
                  Text('Buscar'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendRequestsTab(),
          _buildGroupInvitesTab(),
          _buildAddFriendsTab(),
        ],
      ),
    );
  }

  Widget _buildAddFriendsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar usuários...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchResults = [];
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              if (value.length >= 2) {
                _searchUsers(value);
              } else {
                setState(() {
                  searchResults = [];
                });
              }
            },
          ),
        ),
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Buscar amigos',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Digite o nome do usuário que você\nquer adicionar como amigo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (searchResults.isEmpty && !isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum usuário encontrado',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tente buscar com um nome diferente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return _buildUserSearchItem(user);
      },
    );
  }

  Widget _buildUserSearchItem(Map<String, dynamic> user) {
    final bool requestSent = user['request_sent'] == 1;
    final bool alreadyFriends = user['is_friend'] == 1;
    final bool pendingRequest = user['pending_request'] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                user['photo'] ??
                    'https://lfcostldktmoevensqdj.supabase.co/storage/v1/object/public/fotosuser/user.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getAvatarColor(user['username'] ?? 'U'),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (user['username'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                Text(
                  user['username'] ?? 'Usuário Desconhecido',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user['nome'] != null &&
                    user['nome'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user['nome'],
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (alreadyFriends)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'Amigos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else if (pendingRequest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'Pendente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else if (requestSent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'Enviado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _sendFriendRequest(user['id'].toString()),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text(
                'Adicionar',
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendRequestsTab() {
    if (isLoadingFriendRequests) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (friendRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_disabled,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma solicitação de amizade',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Quando alguém te enviar uma solicitação\nde amizade, ela aparecerá aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendRequests,
      backgroundColor: Colors.grey[800],
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          final request = friendRequests[index];
          return _buildFriendRequestItem(request);
        },
      ),
    );
  }

  Widget _buildGroupInvitesTab() {
    if (isLoadingGroupInvites) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (groupInvites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_add_rounded,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum convite de grupo',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Quando alguém te convidar para um grupo,\no convite aparecerá aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroupInvites,
      backgroundColor: Colors.grey[800],
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupInvites.length,
        itemBuilder: (context, index) {
          final invite = groupInvites[index];
          return _buildGroupInviteItem(invite);
        },
      ),
    );
  }

  Widget _buildFriendRequestItem(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                request['photo'] ??
                    'https://lfcostldktmoevensqdj.supabase.co/storage/v1/object/public/fotosuser//user.png',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getAvatarColor(request['username'] ?? 'U'),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (request['username'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
                Text(
                  request['username'] ?? 'Usuário Desconhecido',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quer ser seu amigo',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                if (request['data_solicitacao'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Enviado em ${request['data_solicitacao']}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => _handleFriendRequest(
                  request['id'].toString(),
                  'accept',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Aceitar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _handleFriendRequest(
                  request['id'].toString(),
                  'reject',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: BorderSide(color: Colors.grey[600]!),
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Rejeitar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInviteItem(Map<String, dynamic> invite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: invite['grupo_foto'] != null &&
                          invite['grupo_foto'].isNotEmpty
                      ? Image.network(
                          invite['grupo_foto'],
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildGroupAvatar(
                                invite['grupo_nome'] ?? 'G');
                          },
                        )
                      : _buildGroupAvatar(invite['grupo_nome'] ?? 'G'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite['grupo_nome'] ?? 'Grupo Desconhecido',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Convite para entrar no grupo',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    if (invite['convidado_por_nome'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Convidado por ${invite['convidado_por_nome']}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (invite['grupo_descricao'] != null &&
              invite['grupo_descricao'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              invite['grupo_descricao'],
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleGroupInvite(
                    invite['id'].toString(),
                    'accept',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Aceitar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleGroupInvite(
                    invite['id'].toString(),
                    'reject',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey[600]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Rejeitar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAvatar(String groupName) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _getAvatarColor(groupName),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          groupName.isNotEmpty ? groupName[0].toUpperCase() : 'G',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final a = name.hashCode;
    return Color.fromARGB(255, a % 255, (a * 2) % 255, (a * 3) % 255);
  }
}
