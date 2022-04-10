import 'package:flutter/material.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NewScreen appbar"),),
      body: Container(
        color: Colors.teal,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: const Text(
                'Screen 2',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),
              ),
              margin: EdgeInsets.all(16),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}