import 'package:flutter/material.dart';
import 'package:lottery_app/firebase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              'Zarejestruj się',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            TextField(
              controller: _email,
              decoration: InputDecoration(
                  fillColor: Colors.blue.shade300,
                  hintText: 'Wpisz email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )),
            ),
            const SizedBox(height: 15.0),
            TextField(
              obscureText: true,
              controller: _password,
              decoration: InputDecoration(
                  fillColor: Colors.blue.shade300,
                  hintText: 'Wpisz hasło',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )),
            ),
            const SizedBox(height: 15.0),
            TextField(
              obscureText: true,
              controller: _confirmPassword,
              decoration: InputDecoration(
                  fillColor: Colors.blue.shade300,
                  hintText: 'Potwierdź hasło',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )),
            ),
            const SizedBox(height: 15.0),
            _customButton('Zarejestruj się', () async {
              if (_email.text.isNotEmpty &&
                  _password.text.isNotEmpty &&
                  _confirmPassword.text.isNotEmpty &&
                  _confirmPassword.text == _password.text) {
                await _firebaseService.registerUser(
                    _email.text, _password.text, context);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _customButton(String text, VoidCallback function) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.blue.shade300, Colors.blue]),
      ),
      child: ElevatedButton(
          onPressed: function,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent),
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );
  }
}
