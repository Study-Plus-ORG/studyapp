// paginainiciial.dart
import 'package:flutter/material.dart';


class Study extends StatelessWidget {
  @override
  Widget build(BuildContext  context) {
    return Scaffold(
      body: Center(
        child: Container(
        height: 400,
        width: 400,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.teal[600],
        )
      )
    )
    );
    
  }
}