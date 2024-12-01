import 'package:flutter/material.dart';

class BetNumberWidget extends StatelessWidget {
  final List<dynamic> numbers;
  final List<dynamic> officialNum;
  final bool isAdditional;
  final Color bgColor;

  const BetNumberWidget(
      {super.key,
      required this.numbers,
      required this.officialNum,
      this.isAdditional = false,
      this.bgColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isAdditional ? Colors.blue.shade300 : Colors.black.withOpacity(0.1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map<Widget>((number) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
          child: Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: borderColor),
                shape: BoxShape.circle,
                color: officialNum.contains((number)) ? Colors.green : bgColor),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
