import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppFormField extends StatelessWidget {
  final TextEditingController Controller;
  final String? Function(String?)? validator;
  final String label;
  final List<TextInputFormatter>? formater;
  final TextInputType? texInputType;

  const AppFormField(
      {required this.Controller,
      required this.validator,
      required this.label,
      this.formater,
      this.texInputType,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: formater,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: texInputType,
      controller: Controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
      ),
    );
  }
}
