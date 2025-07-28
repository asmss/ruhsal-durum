import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ruhsal_durum/HomePage.dart';
import 'package:ruhsal_durum/SignUp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mailController=TextEditingController();
  final TextEditingController _passwordController=TextEditingController();
  bool _obscureText=true;
  Future<void> kimlik_get()
  async {
    try{
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _mailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage(name: userCredential.user!.uid,)));
    }on FirebaseAuthException catch (e) {
      String errorMessage = "Giriş başarısız. Lütfen bilgilerinizi kontrol edin.";
      if (e.code == 'user-not-found') {
        errorMessage = "Kullanıcı bulunamadı.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Yanlış şifre.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu: tekrar deneyin")),
      );
    }
    
  }
  Future<void> _sifresifirlama() async {
    final email = _mailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen email adresinizi girin.")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre sıfırlama bağlantısı email adresinize gönderildi.")),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Şifre sıfırlama bağlantısı gönderilemedi.";
      if (e.code == 'user-not-found') {
        errorMessage = "Bu email adresiyle kayıtlı bir kullanıcı bulunamadı.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu: ${e.toString()}")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 150),
            Icon(Icons.login_rounded, size: 100, color: Colors.green[700]),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    style: GoogleFonts.alef(fontSize: 18, color: Colors.green[900]),
                    controller: _mailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email girin",
                      hintStyle: TextStyle(color: Colors.green[300]),
                      border: InputBorder.none,
                      icon: Icon(Icons.email, color: Colors.green[700]),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    style: GoogleFonts.alef(fontSize: 18, color: Colors.green[900]),
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: "Şifre girin",
                      hintStyle: TextStyle(color: Colors.green[300]),
                      border: InputBorder.none,
                      icon: Icon(Icons.lock, color: Colors.green[700]),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: kimlik_get,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "GİRİŞ YAP",
                    style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Signup()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "KAYIT OL",
                    style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            TextButton(
              onPressed: _sifresifirlama,
              child: Text(
                "Şifrenizi unuttuysanız sıfırlayın",
                style: GoogleFonts.alef(
                  textStyle: TextStyle(
                    color: Colors.green[800],
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

}
