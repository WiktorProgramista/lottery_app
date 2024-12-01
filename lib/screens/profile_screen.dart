import 'package:flutter/material.dart';
import 'package:lottery_app/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseService firebaseService = FirebaseService();
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await firebaseService.getCurrentUserName();
    setState(() {
      userName = name ?? 'Nieznany użytkownik';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          if (userName != null)
            Text(
              'Witaj, $userName!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 15.0),
          _customButton('Wyloguj się', firebaseService.logout),
        ],
      )),
    );
  }

  Widget _customButton(
      String text, Future<void> Function(BuildContext) function) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.blue.shade300, Colors.blue],
        ),
      ),
      child: ElevatedButton(
        onPressed: () async {
          await function(context); // Wywołanie funkcji z kontekstem
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
