import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruhsal_durum/GunlukPage.dart';
import 'package:ruhsal_durum/Settings.dart';
import 'package:ruhsal_durum/SuggestionsPage.dart';
import 'package:ruhsal_durum/chatbot.dart';
import 'package:ruhsal_durum/meditasionPage.dart';
import 'package:ruhsal_durum/nefes_page.dart';
import 'package:ruhsal_durum/planlistpage.dart';
import 'profilPage.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.name});
  final String name;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int secili_index = 0;
  String isim = "kullanıcı yok";

  @override
  void initState() {
    super.initState();
    Getisim();
  }

  Future<void> Getisim() async {
    final kullanici = _auth.currentUser;
    if (kullanici != null) {
      final isim1 = await _firestore.collection("users").doc(kullanici.uid).get();
      setState(() {
        isim = isim1.get("name").toString();
      });
    }
  }

  Widget _buildCurrentPage() {
    switch (secili_index) {
      case 0:
        return HomeContent(name: isim);
      case 1:
        return ProfilePage();
      case 2:
        return ChatbotPage(
          initialPrompt: "",
          moodLabel: "Genel",
          moodEmoji: "😊",
        );
      case 3:
        return SettingsPage();
      default:
        return HomeContent(name: isim);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Text(
                  "Menü",
                  style: TextStyle(color: Colors.grey, fontSize: 24),
                ),
                decoration: BoxDecoration(color: Colors.grey),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Ana Sayfa"),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    secili_index = 0;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profil'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => secili_index = 1);
                },
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Asistan'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => secili_index = 2);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Ayarlar'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => secili_index = 3);
                },
              ),
            ],
          ),
        ),
        body: _buildCurrentPage(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: secili_index,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              secili_index = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Asistan'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String name;

  const HomeContent({super.key, required this.name});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String isim = "kullanıcı yok";
  int _selectedMoodIndex = 2;

  @override
  void initState() {
    super.initState();
    Getisim();
  }

  Future<void> Getisim() async {
    final kullanici = _auth.currentUser;
    if (kullanici != null) {
      final isim1 = await _firestore.collection("users").doc(kullanici.uid).get();
      setState(() {
        isim = isim1.get("name").toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildClickableEmojis(context),
            const SizedBox(height: 20),
            _buildQuickActionsGrid(),
            const SizedBox(height: 20),
            _planlama(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "Merhaba $isim!",
          style: GoogleFonts.poppins(fontSize: 35, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          "Bugün nasıl hissediyorsun?",
          style: GoogleFonts.aclonica(fontSize: 16, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildClickableEmojis(BuildContext context) {
    List<Map<String, dynamic>> moods = [
      {"emoji": "😢", "label": "Kötü", "prompt": "kendimi kötü hissediyorum ne yapmalıyım?"},
      {"emoji": "😞", "label": "Üzgün", "prompt": "kendimi üzgün hissediyorum ne yapmalıyım?"},
      {"emoji": "😐", "label": "Normal", "prompt": "kendimi normal hissediyorum ne yapmalıyım?"},
      {"emoji": "😊", "label": "Mutlu", "prompt": "kendimi mutlu hissediyorum ne yapmalıyım?"},
      {"emoji": "😄", "label": "Harika", "prompt": "kendimi harika hissediyorum ne yapmalıyım?"},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: moods.asMap().entries.map((entry) {
            int idx = entry.key;
            bool isSelected = _selectedMoodIndex == idx;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedMoodIndex = idx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatbotPage(
                      initialPrompt: moods[idx]["prompt"],
                      moodLabel: moods[idx]["label"],
                      moodEmoji: moods[idx]["emoji"],
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    entry.value["emoji"],
                    style: TextStyle(fontSize: isSelected ? 40 : 30),
                  ),
                  Text(entry.value["label"]),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(
          "Seçilen: ${moods[_selectedMoodIndex]["label"]}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    final List<Map<String, dynamic>> buttons = [
      {"icon": Icons.self_improvement, "label": "Meditasyon"},
      {"icon": Icons.edit, "label": "Günlük"},
      {"icon": Icons.air, "label": "Nefes"},
      {"icon": Icons.lightbulb, "label": "Öneriler"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        var btn = buttons[index];
        return GestureDetector(
          onTap: () {
            switch (btn["label"]) {
              case "Meditasyon":
                Navigator.push(context, MaterialPageRoute(builder: (_) => MeditationPage()));
                break;
              case "Günlük":
                Navigator.push(context, MaterialPageRoute(builder: (_) => GunlukPage()));
                break;
              case "Nefes":
                Navigator.push(context, MaterialPageRoute(builder: (_) => NefesPage()));
                break;
              case "Öneriler":
                Navigator.push(context, MaterialPageRoute(builder: (_) => SavedSuggestionsPage()));
                break;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green[200],
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(btn["icon"], size: 40, color: Colors.green),
                const SizedBox(height: 10),
                Text(btn["label"], style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _planlama() {
    return Row(
      children: [
        Text(
          "HADI PLAN YAPALIM !!!",
          style: GoogleFonts.allerta(fontSize: 20),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PlanlamaMainPage()));
          },
          icon: const Icon(Icons.arrow_circle_right, color: Colors.green, size: 32),
        ),
      ],
    );
  }
}
