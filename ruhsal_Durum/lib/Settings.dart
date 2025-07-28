import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruhsal_durum/Login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  late DocumentReference settingsRef;


  @override
  void initState() {
    super.initState();
    settingsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('settings')
        .doc('preferences');
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Ruhsal Takip',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.spa, color: Colors.green),
      children: const [
        SizedBox(height: 8),
        Text(
          'Bu uygulama ruhsal dengeyi korumanız ve takip etmeniz için geliştirilmiştir.',
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Ayarlar",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const SizedBox(height: 16),

          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text("Uygulama Hakkında", style: TextStyle(color: Colors.black)),
            onTap: _showAboutDialog,
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text("Çıkış Yap", style: TextStyle(color: Colors.black)),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}
