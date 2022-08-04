import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {

  final String text;
  final double size;

  const HighlightedText({Key? key, required this.text, this.size = 16}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          text,
          style: TextStyle(
          fontSize: size,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.black,
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          style: TextStyle(
            fontSize: size,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}