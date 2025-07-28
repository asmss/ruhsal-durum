import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileEditPage extends StatefulWidget {
  final String currentName;
  final String currentEmail;

  const ProfileEditPage({
    Key? key,
    required this.currentName,
    required this.currentEmail,
  }) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  User? user = FirebaseAuth.instance.currentUser;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<bool> _showPasswordDialog() async {
    String password = '';
    final formKey = GlobalKey<FormState>();
    bool success = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Lütfen şifrenizi girin'),
        content: Form(
          key: formKey,
          child: TextFormField(
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Şifre',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Şifre boş olamaz';
              return null;
            },
            onChanged: (val) => password = val,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                success = true;
              }
            },
            child: const Text('Gönder'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              success = false;
            },
            child: const Text('İptal'),
          ),
        ],
      ),
    );

    if (!success) return false;

    try {
      if (user == null) return false;

      final cred = EmailAuthProvider.credential(email: user!.email!, password: password);
      await user!.reauthenticateWithCredential(cred);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kimlik doğrulama başarısız: Şifre yanlış olabilir')),
      );
      return false;
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    String newName = _nameController.text.trim();
    String newEmail = _emailController.text.trim();

    try {
      if (newEmail != user!.email) {
        bool reauthSuccess = await _showPasswordDialog();
        if (!reauthSuccess) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
        await user!.verifyBeforeUpdateEmail(newEmail);        await user!.reload();
        user = FirebaseAuth.instance.currentUser;
      }

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': newName,
        'email': newEmail,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('profil güncellendi son olarak mailinize gelen linkle onaylayınız')),
      );

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme başarısız: $e')),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Düzenle', style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen adınızı ve soyadınızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen email adresinizi girin';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return 'Geçerli bir email adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Kaydet', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
