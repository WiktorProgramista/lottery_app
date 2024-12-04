import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottery_app/firebase_service.dart';
import 'package:lottery_app/lottery_service.dart';
import 'package:lottery_app/objects/winning_bet.dart';
import 'package:lottery_app/widgets/bet_number_widget.dart';
import 'dart:developer' as developer;

class ResultsListScreen extends StatefulWidget {
  final List<dynamic> betGroup;

  const ResultsListScreen({super.key, required this.betGroup});

  @override
  State<ResultsListScreen> createState() => _ResultsListScreenState();
}

class _ResultsListScreenState extends State<ResultsListScreen> {
  final LotteryService lotteryService = LotteryService();
  final FirebaseService firebaseService = FirebaseService();
  List<WinningBet> winningBetList = [];
  User? user = FirebaseAuth.instance.currentUser;

  // Function to check if results are available
  Future<List<dynamic>> _checkIfResultsMatch() async {
    var bet = widget.betGroup[0];
    bool isDrawCompleted = await lotteryService.isDrawCompleted(
        bet['lotteryName'], bet['nextDrawId']);

    if (isDrawCompleted) {
      var results = await lotteryService.drawResultsById(
          bet['lotteryName'], bet['nextDrawId']);
      return results;
    } else {
      developer.log('Draw not completed');
      return [];
    }
  }

  // Function to count the number of hits
  int _countHits(List<dynamic> userNumbers, List<dynamic> winningNumbers) {
    int hits = 0;
    for (var num in userNumbers) {
      if (winningNumbers.contains(num)) {
        hits++;
      }
    }
    return hits;
  }

  Future<void> calcBetsWin() async {
    var results = await _checkIfResultsMatch();
    var isDrawComplete = await lotteryService.isDrawCompleted(
        widget.betGroup[0]['lotteryName'], widget.betGroup[0]['nextDrawId']);
    for (var bet in widget.betGroup) {
      if (isDrawComplete) {
        var basicNum = _countHits(bet['basicNum'], results[0]['resultsJson']);
        var addNum = bet.containsKey('additionalNum')
            ? _countHits(bet['additionalNum'], results[0]['specialResults'])
            : 0;
        var prizeNumber = lotteryService.calculateLotteryPrizeNumber(
            bet['lotteryName'], bet['nextDrawId'], basicNum, addNum);
        if (prizeNumber != "Brak nagrody") {
          var prizeValue = await lotteryService.calculatePrizeValue(
              bet['lotteryName'], bet['nextDrawId'], prizeNumber);
          developer.log("$prizeValue");
        }
      }
    }
  }

  Future<void> _initializeState() async {
    //final String uid = user!.uid;
    await calcBetsWin();
    //await lotteryService.checkUserBets(uid);
  }

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wyniki losowania"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _checkIfResultsMatch(), // Fetching the results
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Loading indicator
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Błąd: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Losowanie się nie odbyło.'));
                  } else {
                    // Results fetched successfully
                    var drawResults = snapshot.data!;
                    List<dynamic> basicNum = drawResults[0]['resultsJson'];
                    List<dynamic> additionalNum =
                        drawResults[0]['specialResults'];

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BetNumberWidget(
                                numbers: basicNum, officialNum: const []),
                            if (additionalNum.isNotEmpty) ...[
                              BetNumberWidget(
                                  numbers: additionalNum,
                                  isAdditional: true,
                                  officialNum: const []),
                            ],
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.betGroup.map((bet) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    BetNumberWidget(
                                        numbers: bet['basicNum'],
                                        bgColor: Colors.white,
                                        officialNum: basicNum),
                                    if (bet.containsKey('additionalNum') &&
                                        bet['additionalNum'].isNotEmpty) ...[
                                      BetNumberWidget(
                                          numbers: bet['additionalNum'],
                                          isAdditional: true,
                                          bgColor: Colors.white,
                                          officialNum: additionalNum),
                                    ],
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
