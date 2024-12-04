import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottery_app/lottery_service.dart';
import 'package:lottery_app/objects/lottery.dart';
import 'package:lottery_app/objects/lottery_bet.dart';
import 'package:lottery_app/screens/bet_list_screen.dart';
import 'dart:developer' as developer;

class ChooseNumbers extends StatefulWidget {
  final Lottery lottery;
  const ChooseNumbers({super.key, required this.lottery});

  @override
  State<ChooseNumbers> createState() => _ChooseNumbersState();
}

class _ChooseNumbersState extends State<ChooseNumbers> {
  final ValueNotifier<List<int>> _selectedBasicNum =
      ValueNotifier<List<int>>([]);
  final ValueNotifier<List<int>> _selectedAdditionalNum =
      ValueNotifier<List<int>>([]);
  final List<LotteryBet> _savedBets = [];
  bool _isBetEditing = false;
  User? user = FirebaseAuth.instance.currentUser;
  LotteryService lotteryService = LotteryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          child: Column(
            children: [
              _listOfBets(context),
              _customButton(
                  'Dodaj zakład', () => _showBottomSheet(widget.lottery)),
              const SizedBox(height: 10.0),
              _customButton('Potwierdzam i dodaje', () => _uploadListToDb())
            ],
          ),
        ),
      ),
    );
  }

  Widget _listOfBets(context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _savedBets.length,
        itemBuilder: (context, index) {
          LotteryBet lotteryBet = _savedBets[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4.5,
                          spreadRadius: 0.1,
                          offset: const Offset(0, 3)),
                    ]),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: lotteryBet.basicNum.map((lotteryBet) {
                        return Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topCenter,
                                  colors: [Colors.blue, Colors.blue.shade300])),
                          child: Center(
                            child: Text(
                              lotteryBet.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: lotteryBet.additionalNum.map((lotteryBet) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.blue,
                                      Colors.blue.shade300
                                    ])),
                            child: Center(
                              child: Text(
                                lotteryBet.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _iconButton('edit', () {
                          setState(() {
                            _isBetEditing = true;
                            _selectedBasicNum.value = lotteryBet.basicNum;
                            _selectedAdditionalNum.value =
                                lotteryBet.additionalNum;
                          });
                          _showBottomSheet(widget.lottery);
                        }),
                        _iconButton('refresh', () {}),
                        _iconButton('remove', () {
                          setState(() {
                            _savedBets.removeAt(index);
                          });
                        }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _basicNumWidgetList(Lottery lottery, context) {
    return List<Widget>.generate(lottery.basicNumRange, (index) {
      return ValueListenableBuilder<List<int>>(
        valueListenable: _selectedBasicNum,
        builder: (context, selectedNumbers, _) {
          return ElevatedButton(
            onPressed: () {
              if (_selectedBasicNum.value.contains(index + 1) ||
                  _selectedBasicNum.value.length >= lottery.basicNum) {
                _selectedBasicNum.value =
                    selectedNumbers.where((item) => item != index + 1).toList();
              } else if (selectedNumbers.length < lottery.basicNumRange) {
                _selectedBasicNum.value = List.from(selectedNumbers)
                  ..add(index + 1);
                _selectedBasicNum.value =
                    _selectedBasicNum.value.toSet().toList();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              side: BorderSide(
                  width: 1.0,
                  color: _selectedBasicNum.value.contains(index + 1)
                      ? Colors.blue
                      : Colors.black.withOpacity(0.1)),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          );
        },
      );
    }).toList();
  }

  List<Widget> _additionalNumWidgetList(Lottery lottery, context) {
    return List<Widget>.generate(lottery.additionalNumRange, (index) {
      return ValueListenableBuilder<List<int>>(
        valueListenable: _selectedAdditionalNum,
        builder: (context, selectedNumbers, _) {
          return ElevatedButton(
            onPressed: () {
              // Sprawdzenie, czy liczba jest już wybrana lub liczba dodatkowych liczb jest już pełna
              if (_selectedAdditionalNum.value.contains(index + 1)) {
                _selectedAdditionalNum.value =
                    selectedNumbers.where((item) => item != index + 1).toList();
              } else if (_selectedAdditionalNum.value.length < 2) {
                // Umożliwiamy wybór tylko 2 liczb
                _selectedAdditionalNum.value = List.from(selectedNumbers)
                  ..add(index + 1);
                _selectedAdditionalNum.value =
                    _selectedAdditionalNum.value.toSet().toList();
              } else {
                // Dodaj komunikat lub zablokuj wybór, jeśli wybrano już 2 liczby
                showAlert(
                    context, "Możesz wybrać tylko dwie liczby dodatkowe.");
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              side: BorderSide(
                  width: 1.0,
                  color: _selectedAdditionalNum.value.contains(index + 1)
                      ? Colors.blue
                      : Colors.black.withOpacity(0.1)),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          );
        },
      );
    }).toList();
  }

  void _showBottomSheet(Lottery lottery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Wybierz ${lottery.basicNum} liczb z ${lottery.basicNumRange}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              runSpacing: 3.0,
              children: _basicNumWidgetList(lottery, context),
            ),
            if (lottery.additionalNum != 0) ...[
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Wybierz ${lottery.additionalNum} liczb z ${lottery.additionalNumRange}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              ...[
                if (lottery.additionalNum != 0) ...[
                  const SizedBox(height: 10.0),
                  Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    runSpacing: 3.0,
                    children: _additionalNumWidgetList(lottery, context),
                  ),
                ],
              ],
            ],
            const SizedBox(height: 10.0),
            _customButton(
                'Zapisz',
                () => _saveBetsToList(
                    _selectedBasicNum, _selectedAdditionalNum, lottery))
          ],
        );
      },
    );
  }

  void _saveBetsToList(
    ValueNotifier<List<int>> selectedBasicNum,
    ValueNotifier<List<int>> selectedAdditionalNum,
    Lottery lottery,
  ) async {
    setState(() {
      if (selectedBasicNum.value.length == lottery.basicNum &&
          (lottery.additionalNum == 0 ||
              selectedAdditionalNum.value.length == lottery.additionalNum)) {
        // Zapisujemy zakład tylko wtedy, gdy liczba liczb podstawowych i dodatkowych (jeśli wymagane) jest poprawna
        if (_isBetEditing) {
          var existingBetIndex =
              _savedBets.indexWhere((bet) => bet.lotteryName == lottery.name);
          if (existingBetIndex != -1) {
            _savedBets[existingBetIndex] = LotteryBet(
                lotteryName: lottery.name,
                basicNum: selectedBasicNum.value.toList(),
                additionalNum: selectedAdditionalNum.value.toList(),
                nextDrawId: 1);
          }
        } else {
          _savedBets.add(LotteryBet(
              lotteryName: lottery.name,
              basicNum: selectedBasicNum.value.toList(),
              additionalNum: selectedAdditionalNum.value.toList(),
              nextDrawId: 1));
        }
        _selectedBasicNum.value.clear();
        _selectedAdditionalNum.value.clear();
        _isBetEditing = false;
      } else {
        showAlert(context, "Musisz wybrać poprawną liczbę liczb.");
      }
    });
    Navigator.pop(context);
  }

  Future<void> _updateNextDrawId() async {
    try {
      var nextDrawId =
          await lotteryService.lastDrawResults(widget.lottery.name);

      for (LotteryBet bet in _savedBets) {
        bet.nextDrawId = nextDrawId[0]['drawSystemId'] + 1;
      }
    } catch (e) {
      developer.log(e.toString());
    }
  }

  void _uploadListToDb() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Używaj alertu, jeśli użytkownik nie jest zalogowany
        if (mounted) {
          showAlert(context, "Użytkownik nie jest zalogowany.");
        }
        return;
      }

      // Ensure we update nextDrawId before uploading
      await _updateNextDrawId();

      final String uid = user.uid;
      final DatabaseReference betsRef =
          FirebaseDatabase.instance.ref('users/$uid/bets');

      // Przygotowanie mapy z danymi do zapisania
      Map<String, dynamic> betsMap = {};

      for (var i = 0; i < _savedBets.length; i++) {
        String betId = betsRef.push().key ??
            i.toString(); // Unikalny identyfikator zakładu
        betsMap[betId] = {
          'lotteryName': _savedBets[i].lotteryName,
          'basicNum': _savedBets[i].basicNum,
          'additionalNum': _savedBets[i].additionalNum,
          'nextDrawId': _savedBets[i].nextDrawId,
          'timestamp': ServerValue.timestamp,
        };
      }

      // Wysyłanie wszystkich zakładów w jednym zapytaniu
      await betsRef.update(betsMap);

      // Powiadomienie o sukcesie
      if (mounted) {
        showAlert(context, "Zakłady zostały zapisane.");
      }

      // Zamknij aktualny ekran, jeśli operacja się powiedzie
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      // Obsługa błędów w przypadku problemów z bazą danych
      if (mounted) {
        showAlert(context, "Błąd podczas zapisywania zakładów: $error");
      }
    }
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const BetListScreen()));
    }
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

  Widget _iconButton(String name, Function function) {
    return InkWell(
      onTap: () => function(),
      child: SizedBox(
        child: SvgPicture.asset(
          'assets/svg/$name.svg',
          width: 23.0,
          height: 23.0,
        ),
      ),
    );
  }

  void showAlert(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Zamknij'),
            ),
          ],
        );
      },
    );
  }
}
