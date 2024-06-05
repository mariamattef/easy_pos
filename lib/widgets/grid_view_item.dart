import 'package:flutter/material.dart';

class GridViewItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;
  final void Function() onPrresed;

  GridViewItem(
      {required this.label,
      required this.color,
      required this.icon,
      required this.onPrresed,
      super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPrresed,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.3),
              radius: 30,
              child: Icon(icon, color: color, size: 40),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
      ),
    );
  }
}
