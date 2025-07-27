import 'package:flutter/material.dart';
import 'social_screen.dart';
import 'home_screen.dart';

class BottomNav extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.userData,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    return _buildBottomNavigation();
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.people, 'Social', 1),
          _buildNavItem(Icons.grid_view, 'Library', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Container(
        color: Colors.transparent, // Para aumentar a área de toque
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
        ),
      ),
    );
  }
}

class BottomNavSeparate extends StatelessWidget {
  final String currentPage;
  final Map<String, dynamic>? userData; // Adicionado parâmetro userData

  const BottomNavSeparate({
    super.key,
    required this.currentPage,
    this.userData, // Adicionado parâmetro userData
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, 'Home', 'home'),
          _buildNavItem(context, Icons.people, 'Social', 'social'),
          _buildNavItem(context, Icons.grid_view, 'Library', 'library'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, String page) {
    bool isSelected = currentPage == page;

    return GestureDetector(
      onTap: () => _navigateToPage(context, page),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String page) {
    if (currentPage == page) return; // Não navegar se já está na página

    Widget targetPage;
    switch (page) {
      case 'home':
        targetPage = HomeScreen(userData: userData); // Passando userData
        break;
      case 'social':
        targetPage = SocialScreen(userData: userData); // Passando userData
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionDuration: Duration.zero, // Sem animação
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
