import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage>
    with SingleTickerProviderStateMixin {
  bool isMeditationActive = false;
  bool isMeditationCompleted = false;
  bool isAudioPlaying = false;

  late AnimationController _breathController;
  late AudioPlayer _audioPlayer;
  int totalSeconds = 60;
  int secondsLeft = 60;
  Timer? _timer;

  String? _statusMessage;

  final String audioUrl =
      'https://www.soundjay.com/nature/sounds/rain-01.mp3';

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalSeconds),
    );

    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerComplete.listen((event) {
      _onMeditationComplete();
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startMeditation() async {
    setState(() {
      isMeditationActive = true;
      isMeditationCompleted = false;
      secondsLeft = totalSeconds;
      isAudioPlaying = true;
    });

    _breathController.forward(from: 0);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          secondsLeft--;
           if(secondsLeft == 59){
             _showStatusMessage("BAŞLADIN!!");
           }
          else if (secondsLeft == 30) {
            _showStatusMessage("Zamanın yarısındayız!");
          } else if (secondsLeft == 10) {
            _showStatusMessage("Az kaldı, rahatladın!");
          }else if(secondsLeft == 0){
            _showStatusMessage("Tebrikler🎉,Meditasyon bitti\n bekleyin lütfen...");
           }
        });
      }
    });

    try {
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ses çalma hatası')),
      );
      setState(() {
        isMeditationActive = false;
        isAudioPlaying = false;
        _breathController.stop();
        _timer?.cancel();
      });
    }
  }

  void _toggleAudio() async {
    if (isAudioPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isAudioPlaying = false;
      });
    } else {
      await _audioPlayer.resume();
      setState(() {
        isAudioPlaying = true;
      });
    }
  }

  void _onMeditationComplete() async {
    setState(() {
      isMeditationActive = false;
      isMeditationCompleted = true;
      isAudioPlaying = false;
      _breathController.stop();
      _timer?.cancel();
      secondsLeft = totalSeconds;
      _statusMessage = null;
    });

    await logMeditationSession();
  }

  Future<void> logMeditationSession() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı oturumu bulunamadı!")),
      );
      return;
    }

    final now = DateTime.now();
    final docId = now.toIso8601String().split('T')[0]; // YYYY-MM-DD

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('meditations')
          .doc(docId)
          .set({
        'completed': true,
        'timestamp': now,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veritabanına kayıt yapılamadı: $e")),
      );
    }
  }

  void _showStatusMessage(String message) {
    setState(() {
      _statusMessage = message;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _statusMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        title: const Text("Meditasyon",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isMeditationActive)
            IconButton(
              icon: Icon(
                isAudioPlaying ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
              ),
              onPressed: _toggleAudio,
              tooltip: isAudioPlaying ? 'Sesi Kapat' : 'Sesi Aç',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 55,
                child: _statusMessage != null
                    ? Text(
                  _statusMessage!,
                  style: GoogleFonts.alike(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                  textAlign: TextAlign.start,
                )
                    : const SizedBox.shrink(),  // Boş alan
              ),

              if (!isMeditationActive) ...[
                ElevatedButton(
                  onPressed: _startMeditation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    "Meditasyonu Başlat",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                if (isMeditationCompleted)
                  const Text(
                    "Bugünkü meditasyonun tamamlandı!",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),

                const SizedBox(height: 20),

                if (uid != null)
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('meditations')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;

                        if (docs.isEmpty) {
                          return const Center(
                              child: Text("Henüz meditasyon kaydı yok."));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                            docs[index].data()! as Map<String, dynamic>;
                            final date = docs[index].id;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                leading: const Icon(Icons.self_improvement,
                                    color: Colors.green),
                                title: Text(date),
                                subtitle: Text(
                                    data['completed'] ? 'Tamamlandı' : 'Tamamlanmadı'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ] else ...[
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 1 - (secondsLeft / totalSeconds),
                        strokeWidth: 100,
                        color: Colors.green.shade700,
                        backgroundColor: Colors.green.shade300,
                      ),
                      Text(
                        '$secondsLeft',
                        style:  GoogleFonts.allerta(
                            fontSize: 60, fontWeight: FontWeight.bold,),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left:20.0),
                  child: Text(
                    "Meditasyon sürüyor, ses rehberi çalıyor...",
                    style: GoogleFonts.alef(
                        fontSize: 35,
                        color: Colors.green.shade900),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
