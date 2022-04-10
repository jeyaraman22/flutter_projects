import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingbarWidget extends StatelessWidget {
  const RatingbarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RatingBarIndicator(
        unratedColor: Colors.grey.shade300,
        rating: 4.5,
        itemBuilder: (context,index){
        return Icon(Icons.circle_rounded,color: Color(0xff008078),);
      },
        itemCount: 5,
        itemSize: 17,
        direction: Axis.horizontal,
      ),
    );
  }
}
