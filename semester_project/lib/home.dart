import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    loadLabels();
  }

  Future<void> loadLabels() async {
    try {
      String contents = await rootBundle.loadString('assets/labels.txt');
      List<String> labels = contents.split('\n');
      setState(() {
        _labels = labels;
      });
    } catch (e) {
      print('Error loading labels: $e');
      // Handle error (e.g., display an error message to the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Load Labels Example'),
      ),
      body: Center(
        child: _labels.isEmpty
            ? CircularProgressIndicator() // Show a loading indicator while labels are being loaded
            : ListView.builder(
          itemCount: _labels.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_labels[index]),
            );
          },
        ),
      ),
    );
  }
}
