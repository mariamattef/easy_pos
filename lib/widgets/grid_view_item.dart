import 'package:flutter/material.dart';

class GridViewItem extends StatelessWidget {
  Color color;
  String label;
  IconData icon;
  GridViewItem(
      {required this.label,
      required this.color,
      required this.icon,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.3),
            radius: 40,
            child: Icon(icon, color: color, size: 40),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          )
        ],
      ),
    );
  }
}
