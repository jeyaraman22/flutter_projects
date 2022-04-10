import 'package:flutter/material.dart';

class Priceslider extends StatefulWidget {
  double firstprice,endprice;
  Function(RangeValues) onChanged;

  Priceslider({required this.firstprice,
    required this.endprice,
    required this.onChanged});

  @override
  _PricesliderState createState() => _PricesliderState();
}

class _PricesliderState extends State<Priceslider> {
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        showValueIndicator: ShowValueIndicator.always,
      ),
      child: RangeSlider(
          min: 0,
          max: 100000,
          divisions: 50,
          values: RangeValues(widget.firstprice,widget.endprice),
          labels: RangeLabels(widget.firstprice.round().toString(),
              widget.endprice.round().toString()),
          onChanged:widget.onChanged
      ),
    );
  }
}
