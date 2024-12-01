import 'package:flutter/material.dart';

class UserWinsScreen extends StatefulWidget {
  const UserWinsScreen({super.key});

  @override
  State<UserWinsScreen> createState() => _UserWinsScreenState();
}

class _UserWinsScreenState extends State<UserWinsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Text('users wins')),
    );
  }
}
