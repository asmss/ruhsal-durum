import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ruhsal_durum/Login.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String name = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchName();
  }

  Future<void> fetchName() async {
    if (user == null) return;
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists && mounted) {
      setState(() {
        name = doc.get('name') ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        name = '';
        isLoading = false;
      });
    }
  }

  double _calculateTotalProgress(List<QueryDocumentSnapshot> docs) {
    int totalItems = 0;
    int completedItems = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final progress = data['progress'] ?? {};

      Map meditationDays = progress['meditationDays'] ?? {};
      Map breathingDays = progress['breathingDays'] ?? {};
      Map tasks = progress['tasks'] ?? {};

      totalItems += meditationDays.length + breathingDays.length + tasks.length;
      completedItems += meditationDays.values.where((v) => v == true).length;
      completedItems += breathingDays.values.where((v) => v == true).length;
      completedItems += tasks.values.where((v) => v == true).length;
    }

    if (totalItems == 0) return 0;
    return completedItems / totalItems;
  }

  Map<String, double> _calculateMonthlyProgress(List<QueryDocumentSnapshot> docs) {
    Map<String, List<bool>> monthlyStatus = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final progress = data['progress'] ?? {};

      String monthKey;

      if (data.containsKey('month') && data['month'] != null) {
        monthKey = data['month'].toString();
      } else if (data.containsKey('timestamp') && data['timestamp'] != null) {
        Timestamp ts = data['timestamp'] as Timestamp;
        DateTime dt = ts.toDate();
        monthKey = "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}";
      } else {
        monthKey = 'Bilinmeyen Ay';
      }

      Map meditationDays = progress['meditationDays'] ?? {};
      Map breathingDays = progress['breathingDays'] ?? {};
      Map tasks = progress['tasks'] ?? {};

      if (!monthlyStatus.containsKey(monthKey)) {
        monthlyStatus[monthKey] = [];
      }

      monthlyStatus[monthKey]!.addAll(meditationDays.values.cast<bool>());
      monthlyStatus[monthKey]!.addAll(breathingDays.values.cast<bool>());
      monthlyStatus[monthKey]!.addAll(tasks.values.cast<bool>());
    }

    Map<String, double> tempMonthlyProgress = {};
    monthlyStatus.forEach((month, statuses) {
      if (statuses.isEmpty) {
        tempMonthlyProgress[month] = 0;
      } else {
        int completed = statuses.where((e) => e == true).length;
        tempMonthlyProgress[month] = completed / statuses.length;
      }
    });

    return tempMonthlyProgress;
  }

  @override
  Widget build(BuildContext context) {
    final Color green700 = Colors.green.shade700;
    final Color green800 = Colors.green.shade800;
    final Color green900 = Colors.green.shade900;
    final Color green100 = Colors.green.shade100;
    final Color green50 = Colors.green.shade50;

    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: Text('Profilim', style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: user == null
            ? Center(
            child: Text('Kullanıcı bulunamadı.',
                style: GoogleFonts.alef(fontSize: 18)))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green[300],
                child: Text(
                  user!.email != null && user!.email!.isNotEmpty
                      ? user!.email![0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.montserrat(
                      fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),

              Text('Email:',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text(user!.email ?? 'Email bilgisi yok',
                  style: GoogleFonts.alef(fontSize: 16)),
              const SizedBox(height: 20),

              Text('Ad Soyad:',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text(name.isNotEmpty ? name : 'İsim Soyisim bilgisi yok',
                  style: GoogleFonts.alef(fontSize: 16)),
              const SizedBox(height: 12),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    bool? updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditPage(
                          currentName: name,
                          currentEmail: user!.email ?? '',
                        ),
                      ),
                    );
                    if (updated == true) {
                      await fetchName();
                      setState(() {
                        user = FirebaseAuth.instance.currentUser;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Bilgileri Düzenle',
                      style: GoogleFonts.montserrat(
                          fontSize: 16, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Genel İlerleme',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: green800,
                ),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('plans')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Planlar yüklenirken hata oluştu"));
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Henüz planınız yok."));
                  }

                  final docs = snapshot.data!.docs;
                  final totalProgress = _calculateTotalProgress(docs);
                  final monthlyProgress = _calculateMonthlyProgress(docs);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircularPercentIndicator(
                          radius: 110.0,
                          lineWidth: 12.0,
                          animation: true,
                          animationDuration: 1200,
                          percent: totalProgress.clamp(0, 1),
                          center: Text(
                            "${(totalProgress * 100).toStringAsFixed(1)}%",
                            style: GoogleFonts.montserrat(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: green900,
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: green700,
                          backgroundColor: green100,
                        ),
                      ),

                      const SizedBox(height: 40),

                      Text(
                        'Aylara Göre İlerleme',
                        style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 12),

                      ...monthlyProgress.entries.map((entry) {
                        return Card(
                          elevation: 4,
                          margin:
                          const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            title: Text(
                              entry.key,
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            subtitle: Padding(
                              padding:
                              const EdgeInsets.only(top: 8.0),
                              child: LinearProgressIndicator(
                                value: entry.value.clamp(0, 1),
                                minHeight: 10,
                                backgroundColor: green100,
                                color: green700,
                              ),
                            ),
                            trailing: Text(
                              "${(entry.value * 100).toStringAsFixed(1)}%",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
