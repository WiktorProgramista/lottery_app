import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class LotteryService {
  Future<void> checkUserBets(String uid) async {
    final DatabaseReference betsRef =
        FirebaseDatabase.instance.ref('users/$uid/bets');

    try {
      // Pobranie zakładów użytkownika
      final userBetsSnapshot = await betsRef.get();

      if (!userBetsSnapshot.exists) {
        developer.log("No bets found for user $uid");
        return;
      }

      final bets = Map<String, dynamic>.from(userBetsSnapshot.value as Map);

      // Grupowanie zakładów według gry i losowania
      final groupedBets = <String, Map<int, List<dynamic>>>{};
      bets.forEach((key, betData) {
        final lotteryName = betData['lotteryName'];
        final nextDrawId = betData['nextDrawId'];

        if (!groupedBets.containsKey(lotteryName)) {
          groupedBets[lotteryName] = {};
        }
        if (!groupedBets[lotteryName]!.containsKey(nextDrawId)) {
          groupedBets[lotteryName]![nextDrawId] = [];
        }

        groupedBets[lotteryName]![nextDrawId]!.add(betData);
      });

      // Sprawdzanie wyników dla każdej grupy
      for (final lotteryName in groupedBets.keys) {
        for (final drawId in groupedBets[lotteryName]!.keys) {
          await Future.delayed(
              const Duration(seconds: 3)); // Dodanie opóźnienia

          //inal betsForDraw = groupedBets[lotteryName]![drawId]!;
          final url =
              'https://www.lotto.pl/api/lotteries/draw-prizes?drawType=$lotteryName&drawSystemId=$drawId';

          try {
            developer.log(url);
            final response = await http.get(Uri.parse(url));

            // Sprawdź, czy odpowiedź jest poprawna
            if (response.statusCode == 200) {
              final List<dynamic> data = jsonDecode(response.body);

              developer.log(data.toString());
            } else {
              developer.log("Błąd: ${response.statusCode}");
            }
          } catch (e) {
            developer.log("Błąd: $e");
          }
        }
      }
    } catch (e) {
      developer.log(e.toString());
    }
  }

  Future<List<dynamic>> lastDrawResults(String lotteryName) async {
    String url =
        "https://www.lotto.pl/api/lotteries/draw-results/last-results-per-game?gameType=$lotteryName";

    try {
      final response = await http.get(Uri.parse(url));

      // Sprawdź, czy odpowiedź jest poprawna
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data;
      } else {
        developer.log("Błąd: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      developer.log("Błąd: $e");
      return [];
    }
  }

  Future<List<Map>> drawResultsById(String lotteryName, int drawId) async {
    String url =
        "https://www.lotto.pl/api/lotteries/draw-results/by-number-per-game?gameType=$lotteryName&drawSystemId=$drawId&index=1&size=10&sort=drawSystemId&order=DESC";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['items'].isNotEmpty) {
          final lastDraw = data['items'][0]['results'];

          List<Map> resultsList = List<Map>.from(lastDraw);
          return resultsList;
        } else {
          // Jeśli brak wyników, zwróć pustą listę
          return [];
        }
      } else {
        throw Exception('Błąd pobierania wyników: ${response.statusCode}');
      }
    } catch (e) {
      // Obsługuje błąd, np. brak połączenia z internetem
      throw Exception('Błąd: $e');
    }
  }

  Future<Map<dynamic, dynamic>> gamePrizes(
      String lotteryName, int drawId) async {
    String url =
        "https://www.lotto.pl/api/lotteries/draw-prizes/single-quick-game-prizes?drawSystemId=$drawId&gameType=$lotteryName";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data[0].isNotEmpty) {
          final lastDraw = data[0];

          Map<dynamic, dynamic> resultsList =
              Map<dynamic, dynamic>.from(lastDraw);
          return resultsList;
        } else {
          // Jeśli brak wyników, zwróć pustą listę
          return {};
        }
      } else {
        throw Exception('Błąd pobierania wyników: ${response.statusCode}');
      }
    } catch (e) {
      developer.log(e.toString());
      return {};
    }
  }

  Future<bool> isDrawCompleted(String lotteryName, int drawId) async {
    String url =
        "https://www.lotto.pl/api/lotteries/draw-results/by-number-per-game?gameType=$lotteryName&drawSystemId=$drawId&index=1&size=10&sort=drawSystemId&order=DESC";
    try {
      final response = await http.get(Uri.parse(url));

      // Sprawdź, czy odpowiedź jest poprawna
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Sprawdzenie, czy są jakiekolwiek wyniki
        if (data['items'].isNotEmpty) {
          // Ostatni wynik (pierwszy w liście, posortowane malejąco po drawSystemId)
          final lastDraw = data['items'][0];

          // Wyciągamy ostatni 'drawSystemId' oraz datę losowania
          int lastDrawId = lastDraw['drawSystemId'];

          // Sprawdzamy, czy podany 'drawId' jest równy ostatniemu
          if (lastDrawId == drawId) {
            return true; // Losowanie zostało zakończone
          } else {
            return false; // Losowanie nie zostało zakończone
          }
        } else {
          developer.log("Brak wyników.");
          return false;
        }
      } else {
        developer.log("Błąd: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      developer.log("Błąd: $e");
      return false;
    }
  }

  Future<dynamic> calculatePrizeValue(
      String lotteryName, int drawId, String prizeNum) async {
    String url =
        "https://www.lotto.pl/api/lotteries/draw-prizes/single-quick-game-prizes?drawSystemId=$drawId&gameType=$lotteryName";
    try {
      final response = await http.get(Uri.parse(url));

      // Sprawdź, czy odpowiedź jest poprawna
      if (response.statusCode == 200) {
        final List<Map<dynamic, dynamic>> data = jsonDecode(response.body)[0];

        // Sprawdzenie, czy istnieją wyniki i czy obiekt 'prizes' zawiera 'prizeNum'
        if (data.isNotEmpty) {
          // Zwróć 'prizeValue' dla danego 'prizeNum'
          return data;
        } else {
          // Jeśli 'prizes' lub 'prizeNum' nie istnieje, zwróć 0
          return 0;
        }
      } else {
        // Jeśli odpowiedź ma status inny niż 200, zwróć 0
        return 0;
      }
    } catch (e) {
      // W przypadku błędu zwróć 0
      return 0;
    }
  }

  String calculateLotteryPrizeNumber(
      String lotteryName, int drawId, int basicNum, int additionalNum) {
    if (lotteryName == "Lotto") {
      switch (basicNum) {
        case 6:
          return "1"; // Pierwsza nagroda za 6 trafień
        case 5:
          return "2"; // Druga nagroda za 5 trafień
        case 4:
          return "3"; // Trzecia nagroda za 4 trafienia
        case 3:
          return "4"; // Czwarta nagroda za 3 trafienia
        default:
          return "Brak nagrody";
      }
    } else if (lotteryName == "MiniLotto") {
      switch (basicNum) {
        case 5:
          return "1"; // Pierwsza nagroda za 5 trafień
        case 4:
          return "2"; // Druga nagroda za 4 trafienia
        case 3:
          return "3"; // Trzecia nagroda za 3 trafienia
        default:
          return "Brak nagrody";
      }
    } else if (lotteryName == "Szybkie600") {
      switch (basicNum) {
        case 6:
          return "1"; // Pierwsza nagroda za 6 trafień
        case 5:
          return "2"; // Druga nagroda za 5 trafień
        case 4:
          return "3"; // Trzecia nagroda za 4 trafienia
        case 3:
          return "4"; // Czwarta nagroda za 3 trafienia
        case 2:
          return "5"; // Piąta nagroda za 2 trafienia
        default:
          return "Brak nagrody";
      }
    } else if (lotteryName == "EuroJackpot") {
      // EuroJackpot uwzględnia dodatkowe liczby i 12 kategorii nagród
      if (basicNum == 5 && additionalNum == 2) {
        return "1"; // 5+2 - Pierwsza nagroda
      } else if (basicNum == 5 && additionalNum == 1) {
        return "2"; // 5+1 - Druga nagroda
      } else if (basicNum == 5 && additionalNum == 0) {
        return "3"; // 5+0 - Trzecia nagroda
      } else if (basicNum == 4 && additionalNum == 2) {
        return "4"; // 4+2 - Czwarta nagroda
      } else if (basicNum == 4 && additionalNum == 1) {
        return "5"; // 4+1 - Piąta nagroda
      } else if (basicNum == 4 && additionalNum == 0) {
        return "6"; // 4+0 - Szósta nagroda
      } else if (basicNum == 3 && additionalNum == 2) {
        return "7"; // 3+2 - Siódma nagroda
      } else if (basicNum == 2 && additionalNum == 2) {
        return "8"; // 2+2 - Ósma nagroda
      } else if (basicNum == 3 && additionalNum == 1) {
        return "9"; // 3+1 - Dziewiąta nagroda
      } else if (basicNum == 3 && additionalNum == 0) {
        return "10"; // 3+0 - Dziesiąta nagroda
      } else if (basicNum == 1 && additionalNum == 2) {
        return "11"; // 1+2 - Jedenasta nagroda
      } else if (basicNum == 2 && additionalNum == 1) {
        return "12"; // 2+1 - Dwunasta nagroda
      } else {
        return "Brak nagrody";
      }
    } else {
      return "Nieznana loteria";
    }
  }
}
