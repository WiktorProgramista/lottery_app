import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottery_app/firebase_service.dart';
import 'package:lottery_app/widgets/bet_item_widget.dart';

class BetListScreen extends StatefulWidget {
  const BetListScreen({super.key});

  @override
  State<BetListScreen> createState() => _BetListScreenState();
}

class _BetListScreenState extends State<BetListScreen> {
  final FirebaseService firebaseService = FirebaseService();
  String? uid;
  DatabaseReference? betsRef;

  @override
  void initState() {
    super.initState();

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        firebaseService.alert(
          context,
          "Użytkownik nie jest zalogowany.",
        );
      }
    } else {
      setState(() {
        uid = user.uid;
        betsRef = FirebaseDatabase.instance.ref('users/$uid/bets');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null || betsRef == null) {
      return const Scaffold(
        body:
            Center(child: Text('Proszę się zalogować, aby zobaczyć zakłady.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista zakładów'),
      ),
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: betsRef!.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Wystąpił błąd: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData ||
                snapshot.data!.snapshot.value == null) {
              return const Center(child: Text('Brak danych do wyświetlenia.'));
            } else {
              final Map<dynamic, dynamic> bets = Map<dynamic, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);
              final Map<dynamic, List<dynamic>> groupedBets =
                  groupBetsByTimestamp(bets);

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                itemCount: groupedBets.keys.length,
                itemBuilder: (context, index) {
                  final timestamp = groupedBets.keys.elementAt(index);
                  final List<dynamic> betGroup = groupedBets[timestamp]!;

                  return BetItemWidget(
                    timestamp: timestamp,
                    betGroup: betGroup,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Map<dynamic, List<dynamic>> groupBetsByTimestamp(Map<dynamic, dynamic> bets) {
    final Map<dynamic, List<dynamic>> groupedBets = {};
    for (var entry in bets.entries) {
      final timestamp = entry.value['timestamp'];
      if (!groupedBets.containsKey(timestamp)) {
        groupedBets[timestamp] = [];
      }
      groupedBets[timestamp]!.add(entry.value);
    }
    return groupedBets;
  }
}
