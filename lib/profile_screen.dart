import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                    _buildPlayAndEarnPoints(),
                    const SizedBox(height: 80), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
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
              const Icon(Icons.more_vert, color: Colors.white),
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
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child:
                          Icon(Icons.person, color: Colors.white70, size: 30),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Malow',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Malow#1234',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            const Text(
                              '1,310',
                              style: TextStyle(
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
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Botao teste',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildTab('teste', isSelected: true),
                  _buildTab('teste'),
                  _buildTab('teste'),
                  _buildTab('teste'),
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
    );
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
                children: const [
                  Text(
                    'Creditos Disponiveis',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '1,335',
                    style: TextStyle(
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
                  color: const Color(0xFF107C10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0E6B0E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.gamepad,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confira seus',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white)),
                        Text('benefícios',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white)),
                        Text('Teste teste',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white)),
                      ],
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

  Widget _buildPlayAndEarnPoints() {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'teste',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Encontre atividades divertidas onde você ganha pontos',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildPointActivity(
            icon: Icons.arrow_upward,
            title: 'Login para jogar',
            points: '+5',
            progress: '0%',
          ),
          const SizedBox(height: 12),
          _buildPointActivity(
            icon: Icons.refresh,
            title: 'Usar o aplicativo ',
            points: '+25',
            isCompleted: true,
          ),
          const SizedBox(height: 12),
          _buildPointActivity(
            icon: Icons.laptop,
            title: 'Jogar um jogo',
            points: '+10',
            progress: '0%',
          ),
          const SizedBox(height: 12),
          _buildPointActivity(
            icon: Icons.refresh,
            title: 'Bônus semanal',
            points: '+150',
            progress: '4/5',
          ),
          const SizedBox(height: 12),
          _buildPointActivity(
            icon: Icons.refresh,
            title: 'Jogar um jogo',
            points: '+10',
            progress: '0%',
          ),
          const SizedBox(height: 24),
          _buildGamePassQuests(),
        ],
      ),
    );
  }

  Widget _buildPointActivity({
    required IconData icon,
    required String title,
    required String points,
    String? progress,
    bool isCompleted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF107C10),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  points,
                  style: const TextStyle(
                    color: Color(0xFF107C10),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (isCompleted)
          const Icon(Icons.check, color: Colors.white)
        else
          Text(
            progress!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildGamePassQuests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ganhe mais pontos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'missões exclusivas',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        _buildWeeklyGamePassSequence(
          title: 'Sequências semanais',
          completedDays: 4,
          nextWeekPoints: 100,
          remainingDays: 2,
        ),
        const SizedBox(height: 24),
        _buildWeeklyGamePassSequence(
          title: 'Sequências semanais ',
          completedDays: 4,
          nextWeekPoints: 100,
          remainingDays: 2,
          isTeal: true,
        ),
        const SizedBox(height: 24),
        _buildGamePassBundle(
          title: 'Pacote mensal de 4 jogos',
          gameCount: 2,
          points: 50,
        ),
        const SizedBox(height: 24),
        _buildGamePassBundle(
          title: 'Pacote mensal de 8 jogos',
          gameCount: 8,
          points: 250,
          isGrid: true,
        ),
      ],
    );
  }

  Widget _buildWeeklyGamePassSequence({
    required String title,
    required int completedDays,
    required int nextWeekPoints,
    required int remainingDays,
    bool isTeal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            ...List.generate(
                completedDays,
                (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.check,
                                size: 12, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${index + 1}d',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    )),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isTeal ? Colors.teal.shade900 : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: isTeal
                            ? const Color(0xFF0B7373)
                            : const Color(0xFF3A3A3A),
                        child: Text(
                          '${completedDays + 1}d',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+$nextWeekPoints',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  if (!isTeal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Próxima semana',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            if (remainingDays > 1)
              ...List.generate(
                  remainingDays - 1,
                  (index) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isTeal
                                ? Colors.teal.shade900
                                : const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: isTeal
                                    ? const Color(0xFF0B7373)
                                    : const Color(0xFF3A3A3A),
                                child: Text(
                                  '${completedDays + index + 2}d',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+$nextWeekPoints',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )),
          ],
        ),
      ],
    );
  }

  Widget _buildGamePassBundle({
    required String title,
    required int gameCount,
    required int points,
    bool isGrid = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (isGrid)
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(
              gameCount,
              (index) => Container(color: Colors.grey.shade800),
            ),
          )
        else
          Row(
            children: List.generate(
              gameCount,
              (index) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade800,
                margin: EdgeInsets.only(right: index < gameCount - 1 ? 8 : 0),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', isSelected: true),
          _buildNavItem(Icons.people, 'Social'),
          _buildNavItem(Icons.grid_view, 'Library'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label,
      {bool isSelected = false, bool isGamePass = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isGamePass)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 24,
          ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ],
    );
  }
}

Widget _buildNavItem(IconData icon, String label,
    {bool isSelected = false, bool isGamePass = false}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (isGamePass)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(2),
          ),
        )
      else
        Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 24,
        ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    ],
  );
}
