import 'package:flutter/material.dart';

const Color kNavyBlue = Color(0xFF151929);
const Color kOrange = Color(0xFFF5A623);

class PitReportLogo extends StatelessWidget {
  final double iconHeight;
  final double fontSize;

  const PitReportLogo({
    super.key,
    this.iconHeight = 36,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/pitreport-icon-76.png', height: iconHeight),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Pit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Report',
                style: TextStyle(
                  color: kOrange,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
