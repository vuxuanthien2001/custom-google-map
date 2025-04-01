import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomMarker extends StatelessWidget {
  const CustomMarker({super.key, required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const MaterialColor(
            0xFF2196F3,
            <int, Color>{
              50: Color(0xFFD1D1D1),
              100: Color(0xFFBFBFBF),
              200: Color(0xFF808080),
              250: Color(0xFFA6A6A6),
              300: Color(0xFFDBEEF4),
              400: Color(0xFFF1F1F1),
              500: Color(0xFF2196F3),
              600: Color(0xFFD7DAD6)
            },
          )[50],
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: FaIcon(
            FontAwesomeIcons.solidCircleDot,
            size: 30,
            color: color,
          ),
        ),
      ),
    ]);
  }
}
