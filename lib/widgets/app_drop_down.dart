import 'package:flutter/material.dart';

class AppDropDpown extends StatelessWidget {
  final int? value;
  final List<DropdownMenuItem<int>>? items;
  final void Function(int?)? onChanged;
  final Widget? hint;
  const AppDropDpown(
      {required this.items,
      required this.value,
      required this.onChanged,
      required this.hint,
      super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black)),
      child: DropdownButton(
          isExpanded: true,
          underline: const SizedBox(),
          // ignore: prefer_const_constructors
          hint: hint,
          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
          value: value,
          items: items,
          onChanged: onChanged),
    );
  }
}
