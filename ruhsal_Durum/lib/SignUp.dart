import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ruhsal_durum/Login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _namecontroller=TextEditingController();
  final TextEditingController _surnamecontroller=TextEditingController();
  final TextEditingController _phonecontroller=TextEditingController();
  final TextEditingController _emailcontroller=TextEditingController();
  final TextEditingController _passwordcontroller=TextEditingController();
  bool _obscureText = false;
  bool kontrol=false;
  Future<bool> Kaydet()
  async {
    setState(() {
      kontrol=true;
    });
    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailcontroller.text.trim(),
        password: _passwordcontroller.text.trim(),
      );
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userCredential.user!.uid)
      .set({
         'name':_namecontroller.text,
         'surname':_surnamecontroller.text,
         'phone':_phonecontroller.text,
         'email':_emailcontroller.text
         });
     return true;
    }on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf. Daha güçlü bir şifre giriniz.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Bu e-posta adresi zaten kullanımda.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi.';
          break;
        default:
          errorMessage = 'Bir hata oluştu: tekrar deneyin';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Beklenmeyen bir hata oluştu: $e')),
      );
      return false;
    }
    finally{
      setState(() {
        kontrol=false;
      });
    }
  }

  void kayit_basarili() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kayıt başarılı! Giriş yapabilirsiniz.")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Column(
            children: [
              Icon(Icons.assignment_ind, size: 70, color: Colors.green[700]),
              const SizedBox(height: 40),

              _buildInputCard(_namecontroller, "İsim", Icons.person),
              const SizedBox(height: 15),

              _buildInputCard(_surnamecontroller, "Soyisim", Icons.person_outline),
              const SizedBox(height: 15),

              _buildInputCard(
                _phonecontroller,
                "Telefon Numarası",
                Icons.phone,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                prefixText: "+90 ",
              ),
              const SizedBox(height: 15),

              _buildInputCard(_emailcontroller, "Email", Icons.email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),

              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    style: GoogleFonts.alef(
                        fontSize: 18, color: Colors.green[900]),
                    controller: _passwordcontroller,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: "Şifre",
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
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: kontrol
                        ? null
                        : () async {
                      bool succes = await Kaydet();
                      if (succes == true) {
                        kayit_basarili();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "KAYDET",
                      style: GoogleFonts.montserrat(
                          textStyle:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "GERİ ÇIK",
                      style: GoogleFonts.montserrat(
                          textStyle:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(
      TextEditingController controller,
      String hintText,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        String? prefixText,
      }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          style: GoogleFonts.alef(fontSize: 18, color: Colors.green[900]),
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.green[300]),
            border: InputBorder.none,
            prefixText: prefixText,
            icon: Icon(icon, color: Colors.green[700]),
          ),
        ),
      ),
    );
  }

}
