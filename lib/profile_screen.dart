import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'settings_screen.dart';
import 'bottom_nav.dart';
import 'game_details_screen.dart';
import 'achievement_details_screen.dart';
import 'api_config.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfileScreen({
    super.key,
    this.userData,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> medalhas = [];
  bool isLoadingFriends = false;
  bool isLoadingMedalhas = false;
  String selectedTab = 'Perfil';

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadMedalhas();
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

  Future<void> _loadMedalhas() async {
    if (widget.userData?['id'] == null) return;

    setState(() {
      isLoadingMedalhas = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            ApiConfig.getMedalhasURL), // Adicione esta URL ao seu ApiConfig
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
            medalhas = List<Map<String, dynamic>>.from(data['medalhas'] ?? []);
          });
        } else {
          print('Erro ao carregar medalhas: ${data['message']}');
        }
      } else {
        print('Erro de conexão: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar medalhas: $e');
    } finally {
      setState(() {
        isLoadingMedalhas = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserProfile(context),
                    _buildRewardsPoints(),
                    _buildTabContent(),
                    const SizedBox(height: 80), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavSeparate(
        currentPage: 'home',
        userData: widget.userData,
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.userData?['photo'] ??
                            'https://lfcostldktmoevensqdj.supabase.co/storage/v1/object/public/fotosuser//user.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person,
                                  color: Colors.white70, size: 24),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 40,
                            height: 40,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userData?['username'] ?? 'Usuário',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.userData?['nome_completo'] ?? 'Usuário#1234',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.userData?['creditos'] ?? '0'} créditos',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('🥇', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              '${medalhas.length} medalhas',
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
              Row(
                children: [
                  _buildTab('Perfil', isSelected: selectedTab == 'Perfil'),
                  _buildTab('Jogos', isSelected: selectedTab == 'Jogos'),
                  _buildTab('Amigos', isSelected: selectedTab == 'Amigos'),
                  _buildTab('Medalhas', isSelected: selectedTab == 'Medalhas'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, {bool isSelected = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 'Jogos':
        return _buildRecentlyPlayed(context);
      case 'Amigos':
        return _buildFriends();
      case 'Medalhas':
        return _buildMedalhas();
      default:
        return _buildAchievements(context);
    }
  }

  Widget _buildRewardsPoints() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Créditos Disponíveis',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${widget.userData?['creditos'] ?? '0'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF111827),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.gamepad,
                          size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedalhas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medalhas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${medalhas.length} total',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoadingMedalhas)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (medalhas.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32.0),
              child: const Column(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma medalha ainda',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Continue jogando e participando para ganhar suas primeiras medalhas!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
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
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: medalhas.length,
              itemBuilder: (context, index) {
                final medalha = medalhas[index];
                return _buildMedalhaCard(medalha);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMedalhaCard(Map<String, dynamic> medalha) {
    return GestureDetector(
      onTap: () {
        _showMedalhaDetails(medalha);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.amber.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: medalha['url_img'] != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          medalha['url_img'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 40,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.amber),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 40,
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      medalha['name'] ?? 'Medalha',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (medalha['descricao'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        medalha['descricao'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedalhaDetails(Map<String, dynamic> medalha) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: medalha['url_img'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        medalha['url_img'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 50,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              medalha['name'] ?? 'Medalha',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (medalha['descricao'] != null)
              Text(
                medalha['descricao'],
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🏆 Medalha Conquistada',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayed(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recentemente Jogados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildGameCard(
                context,
                'Street Fighter II',
                'assets/street_fighter.png',
                const Color(0xFF111827),
              ),
              const SizedBox(width: 12),
              _buildGameCard(
                context,
                'Contra',
                'assets/contra.png',
                const Color(0xFF111827),
              ),
              const SizedBox(width: 12),
              _buildGameCard(
                context,
                'Streets of Rage',
                'assets/streets_of_rage.png',
                const Color(0xFF111827),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String imageUrl,
    Color color,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailsScreen(
                gameName: title,
                imageUrl: imageUrl,
              ),
            ),
          );
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriends() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amigos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoadingFriends)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (friends.isEmpty)
            const Center(
              child: Text(
                'Nenhum amigo encontrado',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: friends.length > 3 ? 3 : friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return Container(
                    width: 120,
                    margin: EdgeInsets.only(
                      right: index < 2 && index < friends.length - 1 ? 12.0 : 0,
                    ),
                    child: _buildFriendCard(
                      friend['username'] ?? 'Usuário',
                      friend['photo'] ??
                          'https://lfcostldktmoevensqdj.supabase.co/storage/v1/object/public/fotosuser//user.png',
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(String name, String photoUrl) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                photoUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child:
                          Icon(Icons.person, color: Colors.white70, size: 24),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 50,
                    height: 50,
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
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          const Text(
            'Online',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conquistas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAchievementCard(
                context,
                'Jogue 3 Jogos',
                Icons.gamepad,
                Colors.green,
                true,
              ),
              const SizedBox(width: 12),
              _buildAchievementCard(
                context,
                'Consiga 100 Pontos',
                Icons.emoji_events,
                Colors.amber,
                true,
              ),
              const SizedBox(width: 12),
              _buildAchievementCard(
                context,
                'Mestre da comunidade',
                Icons.people,
                Colors.purple,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isUnlocked,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AchievementDetailsScreen(
                title: title,
                imageUrl: 'assets/achievement.png',
                isUnlocked: isUnlocked,
              ),
            ),
          );
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Achievement image/icon
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 30,
                    ),
                  ),
                ),
              ),
              // Achievement info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
