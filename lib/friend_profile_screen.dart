import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class FriendProfileScreen extends StatefulWidget {
  final Map<String, dynamic> friendData;
  final Map<String, dynamic>? currentUserData;

  const FriendProfileScreen({
    super.key,
    required this.friendData,
    this.currentUserData,
  });

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  Map<String, dynamic>? fullFriendData;
  List<Map<String, dynamic>> friendBadges = [];
  bool isLoading = true;
  bool isLoadingBadges = true;

  @override
  void initState() {
    super.initState();
    _loadFriendProfile();
    _loadFriendBadges();
  }

  Future<void> _loadFriendProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Se necessário, aqui você pode fazer uma chamada para buscar mais detalhes do perfil
      // Por enquanto, vamos usar os dados que já temos
      setState(() {
        fullFriendData = widget.friendData;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar perfil do amigo: $e');
      setState(() {
        fullFriendData = widget.friendData;
        isLoading = false;
      });
    }
  }

  Future<void> _loadFriendBadges() async {
    setState(() {
      isLoadingBadges = true;
    });

    try {
      // Placeholder para badges/emblemas - substitua pela sua API quando estiver pronta
      // final response = await http.get(
      //   Uri.parse('${ApiConfig.baseUrl}/user_badges/${widget.friendData['id']}'),
      //   headers: {'Content-Type': 'application/json'},
      // );

      // Por enquanto, criamos badges de exemplo
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        friendBadges = [
          {
            'id': 1,
            'nome': 'Primeiro Login',
            'descricao': 'Fez o primeiro login no aplicativo',
            'icone': 'login',
            'conquistado_em': '2024-01-15',
          },
          {
            'id': 2,
            'nome': 'Amizade',
            'descricao': 'Adicionou o primeiro amigo',
            'icone': 'friend',
            'conquistado_em': '2024-01-20',
          },
          {
            'id': 3,
            'nome': 'Ativo',
            'descricao': 'Usou o app por 7 dias consecutivos',
            'icone': 'active',
            'conquistado_em': '2024-01-27',
          },
        ];
        isLoadingBadges = false;
      });
    } catch (e) {
      print('Erro ao carregar badges: $e');
      setState(() {
        isLoadingBadges = false;
      });
    }
  }

  String _getLastSeenText() {
    // Aqui você pode implementar a lógica para calcular "visto pela última vez"
    // Por exemplo, usando a data do último login
    return 'Visto pela última vez há 2 dias';
  }

  Color _getAvatarColor() {
    // Gera uma cor baseada no username para consistência
    final username = fullFriendData?['username'] ?? '';
    final colors = [
      const Color(0xFF2E8B57),
      const Color(0xFF375A7F),
      const Color(0xFF7F3F7F),
      const Color(0xFFB8860B),
      const Color(0xFF8B4513),
      const Color(0xFF556B2F),
    ];
    return colors[username.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final username = fullFriendData?['username'] ?? 'Usuário';
    final fullName = fullFriendData?['nome_completo'] ?? username;
    final photoUrl = fullFriendData?['photo'] ??
        'https://lfcostldktmoevensqdj.supabase.co/storage/v1/object/public/fotosuser//user.png';
    final credits = fullFriendData?['creditos'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Cover / banner
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade800, Colors.grey.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Content scroll
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  _buildProfileHeader(username, fullName, photoUrl, credits),
                  const SizedBox(height: 16),
                  _buildTabSection(),
                  const SizedBox(height: 12),
                  _buildBadgesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _circleIconButton(
            context,
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Perfil do Amigo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      String username, String fullName, String photoUrl, int credits) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Avatar e informações básicas
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: ClipOval(
                  child: Image.network(
                    photoUrl,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: _getAvatarColor(),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child:
                              Icon(Icons.person, color: Colors.white, size: 34),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
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
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (fullName != username)
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _getLastSeenText(),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$credits créditos',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botões de ação
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Implementar funcionalidade de mensagem
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Funcionalidade de mensagens em desenvolvimento'),
                        backgroundColor: Color(0xff21065c),
                      ),
                    );
                  },
                  child: const Text('Mensagem'),
                ),
              ),
              const SizedBox(width: 8),
              _circleIconButton(
                context,
                icon: Icons.more_horiz,
                onTap: () {
                  // Implementar menu de opções
                  _showOptionsMenu(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tab(label: 'Conquistas', selected: true),
          _tab(label: 'Sobre'),
          _tab(label: 'Atividade'),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conquistas e Emblemas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoadingBadges)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (friendBadges.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.white54,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nenhuma conquista ainda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Este usuário ainda não conquistou nenhum emblema',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: friendBadges.length,
              itemBuilder: (context, index) {
                return _buildBadgeCard(friendBadges[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    IconData badgeIcon;
    Color badgeColor;

    // Define ícone e cor baseado no tipo do badge
    switch (badge['icone']) {
      case 'login':
        badgeIcon = Icons.login;
        badgeColor = Colors.blue;
        break;
      case 'friend':
        badgeIcon = Icons.people;
        badgeColor = Colors.green;
        break;
      case 'active':
        badgeIcon = Icons.star;
        badgeColor = Colors.orange;
        break;
      default:
        badgeIcon = Icons.emoji_events;
        badgeColor = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              badgeIcon,
              color: badgeColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge['nome'],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            badge['descricao'],
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(BuildContext context,
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _tab({required String label, bool selected = false}) {
    return Expanded(
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text(
                'Remover amigo',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmRemoveFriend(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.white70),
              title: const Text(
                'Bloquear usuário',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implementar bloqueio
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.white70),
              title: const Text(
                'Denunciar',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implementar denúncia
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveFriend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Remover amigo',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja remover ${fullFriendData?['username'] ?? 'este usuário'} da sua lista de amigos?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Voltar para a tela anterior
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade em desenvolvimento'),
                  backgroundColor: Color(0xff21065c),
                ),
              );
            },
            child: const Text(
              'Remover',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
