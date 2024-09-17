import 'package:flutter/material.dart';


class ViewstockView extends StatelessWidget {
  const ViewstockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('view Stock'),
        centerTitle: true,
      ),
      body: Center(child: Text("view Stock")),
    );
  }
}