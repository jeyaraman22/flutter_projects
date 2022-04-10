import 'package:flutter/material.dart';

class TextEmbedded extends StatelessWidget {
  const TextEmbedded({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width*0.65,
              height: 80,
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              //padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey, width: 3),
                shape: BoxShape.rectangle,
              ),
            ),
            Positioned(
                left: MediaQuery.of(context).size.width*0.65/4,
                top: 7.5,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  color: Colors.white,
                  child: Text(
                    'Become A Member',
                    style: TextStyle(color: Color(0xff018079), fontSize: 23,
                    fontFamily: "Brayles",
                    ),
                  ),
                )),
            Positioned(
              top: 40,
              child: Container(
                height: 50,
                padding: const EdgeInsets.only(bottom: 3, left: 3, right: 3,top: 3),
                color: Colors.white,
                child: const Center(
                  child: Text("ENJOY EXCLUSIVE BENEFITS",
                  style: TextStyle(fontSize: 25,
                  fontFamily: "Arno Pro"),),
                ),
              ),
            ),
            Positioned(
              bottom: -12,
              left: 100,
              child: MaterialButton(onPressed:(){},
                textColor: Colors.white,
                color: Colors.green,
              child: Text("Join Now"),),
            )
          ],
        ),
      ),
    );
  }
}
