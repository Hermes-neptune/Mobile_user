import 'package:flutter/material.dart';

class AchievementDetailsScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isUnlocked;

  const AchievementDetailsScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Achievement details
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Achievement icon
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade900,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _buildAchievementIcon(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Achievement title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress bar
                    Container(
                      width: 200,
                      child: Column(
                        children: [
                          Text(
                            isUnlocked ? '100/100' : '45/100',
                            style: TextStyle(
                              color: isUnlocked ? Colors.yellow : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: isUnlocked ? 200 : 90,
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? Colors.yellow
                                        : Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Achievements section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Conquistas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Achievement cards
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  _buildAchievementCard(
                    context,
                    'Jogue 3 Jogos',
                    'assets/achievement1.png',
                    true,
                  ),
                  const SizedBox(width: 12),
                  _buildAchievementCard(
                    context,
                    'Consiga 100 Pontos',
                    'assets/achievement2.png',
                    true,
                  ),
                  const SizedBox(width: 12),
                  _buildAchievementCard(
                    context,
                    'Mestre da comunidade',
                    'assets/achievement3.png',
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementIcon() {
    if (title == 'Consiga 100 Pontos') {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    } else if (title == 'Jogue 3 Jogos') {
      return const Icon(
        Icons.sports_esports,
        color: Colors.white,
        size: 60,
      );
    } else {
      return const Icon(
        Icons.emoji_events,
        color: Colors.white,
        size: 60,
      );
    }
  }

  Widget _buildHAtom() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.yellow.shade300,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: const Center(
        child: Text(
          'H',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    String title,
    String imageUrl,
    bool isUnlocked,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (this.title != title) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AchievementDetailsScreen(
                  title: title,
                  imageUrl: imageUrl,
                  isUnlocked: isUnlocked,
                ),
              ),
            );
          }
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: this.title == title
                ? Border.all(color: Colors.yellow, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.purple : Colors.grey.shade700,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isUnlocked ? Icons.check : Icons.lock,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
