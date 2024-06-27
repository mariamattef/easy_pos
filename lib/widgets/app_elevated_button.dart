import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final Size? fixedSize;
  const AppElevatedButton(
      {this.fixedSize = const Size(double.maxFinite, 50),
      required this.onPressed,
      required this.label,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          fixedSize: fixedSize,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: onPressed,
        child: Text(label));
  }
}
