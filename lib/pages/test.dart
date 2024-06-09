import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  bool age = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 300,
            width: 300,
            color: Colors.red,
          ),
          Positioned(
            top: 0,
            right: 20,
            child: Container(
              height: 200,
              width: 200,
              color: Colors.green,
            ),
          ),
          Container(
            height: 100,
            width: 100,
            color: Colors.blue,
          )
        ],
      ),
    );
  }
}
