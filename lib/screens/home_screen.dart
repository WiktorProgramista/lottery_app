import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottery_app/constants.dart';
import 'package:lottery_app/screens/bet_list_screen.dart';
import 'package:lottery_app/screens/choose_numbers.dart';
import 'package:lottery_app/screens/profile_screen.dart';
import 'package:lottery_app/screens/user_wins_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista ekranów do przełączania
  final List<Widget> _screens = [
    const HomeView(), // Ekran główny
    const BetListScreen(), // Ekran zakładów
    const UserWinsScreen(), // Ekran wygranych
    const ProfileScreen() // Ekran profilu
  ];

  // Zmiana indeksu podczas kliknięcia w element dolnej nawigacji
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNav(),
      body: _screens[_selectedIndex], // Wyświetla odpowiedni ekran
    );
  }

  Widget bottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/home.svg'),
          label: 'Strona główna',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/bars.svg'),
          label: 'Zakłady',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/chart.svg'),
          label: 'Wygrane',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/profile.svg'),
          label: 'Konto',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedFontSize: 14,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      onTap: _onItemTapped,
    );
  }
}

// Oddzielny widget reprezentujący ekran główny
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: lotterys.map((lotteryName) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4.5,
                        spreadRadius: 0.1,
                        offset: const Offset(0, 3))
                  ]),
              child: Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      lotteryName.imagePath,
                      width: 80.0,
                      height: 80.0,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.blue.shade300, Colors.blue]),
                      ),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChooseNumbers(
                                          lottery: lotteryName,
                                        )));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent),
                          child: const Text(
                            'Zagraj',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
