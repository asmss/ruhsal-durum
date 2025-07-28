import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_IntroCardData> _cards = [
    _IntroCardData(
      icon: Icons.mood,
      title: "Duygularını Tanı",
      description: "Her gün ruh halini kaydederek kendini daha yakından keşfet.",
    ),
    _IntroCardData(
      icon: Icons.calendar_today,
      title: "Kişisel Planlama",
      description: "Meditasyon ve nefes egzersizlerini haftalık olarak planla.",
    ),
    _IntroCardData(
      icon: Icons.smart_toy,
      title: "Akıllı Rehberlik",
      description: "Yapay zekâ destekli sohbet asistanı ile sana özel öneriler al.",
    ),
    _IntroCardData(
      icon: Icons.check_circle_outline,
      title: "özel Görevler",
      description: "Kendine özel görevler oluştur, aylık-haftalık ilerlemeni takip et.",
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 10,
      width: isActive ? 25 : 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade700 : Colors.green.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Text(
              "Ruhsal Takip Uygulamasına Hoş Geldin!",
              style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return _buildCard(card);
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _cards.length,
                    (index) => _buildIndicator(index == _currentPage),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 60.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
              onPressed: () {
                if (_currentPage == _cards.length - 1) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                _currentPage == _cards.length - 1 ? "Başla" : "İleri",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_IntroCardData card) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 7,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(card.icon, size: 70, color: Colors.green.shade700),
            const SizedBox(height: 24),
            Text(
              card.title,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              card.description,
              style: GoogleFonts.alef(
                fontSize: 18,
                color: Colors.green.shade800.withOpacity(0.85),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCardData {
  final IconData icon;
  final String title;
  final String description;

  _IntroCardData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
