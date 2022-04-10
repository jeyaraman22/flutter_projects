import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';

class DaterangePicker extends StatefulWidget {
  DateTime firstDate,lastDate;
  DatePeriod selectedPeriod;
  Function(DatePeriod) onChanged;

  DaterangePicker(
      {
      required this.selectedPeriod,
      required this.firstDate,
      required this.lastDate,
      required this.onChanged});

    @override
  _DaterangePickerState createState() => _DaterangePickerState();
}

class _DaterangePickerState extends State<DaterangePicker> {
  DatePickerRangeStyles styles = DatePickerRangeStyles(
    selectedPeriodLastDecoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadiusDirectional.only(
            topEnd: Radius.circular(10.0), bottomEnd: Radius.circular(10.0))),
    selectedPeriodStartDecoration: const BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(10.0), bottomStart: Radius.circular(10.0)),
    ),
    selectedPeriodMiddleDecoration:
    BoxDecoration(color: Colors.yellow.shade400, shape: BoxShape.rectangle),
  );
  @override
  Widget build(BuildContext context) {
      return RangePicker(
        initiallyShowDate: DateTime.now(),
        datePickerStyles: styles,
        selectedPeriod: widget.selectedPeriod,
        onChanged:widget.onChanged,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate);
    /*datarange(context);*/
  }
  /* dateRangealertingBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (_, innerSetState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                height: 420,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(
                            "Select  Date",
                            style: TextStyle(fontSize: 18),
                          )),
                      Expanded(
                        flex: 10,
                        child: RangePicker(
                          initiallyShowDate: DateTime.now(),
                          datePickerStyles: styles,
                          selectedPeriod: widget.selectedPeriod,
                          onChanged: (value) {
                            innerSetState(() {
                              widget.selectedPeriod = value;
                            });
                          },
                          firstDate: DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed:(){
                              setState(() {
                               // filterbydateRange(DateFormat('dd/MM/yyyy').format(selectedPeriod.start),
                                    //DateFormat('dd/MM/yyyy').format(selectedPeriod.end));
                              });
                              Navigator.pop(context);
                            }, child: Text("OK")),
                            TextButton(onPressed:(){
                              setState(() {
                                //getcurrentuserList();
                              });
                              Navigator.pop(context);
                            }, child: Text("RESET")),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }*/

  /*Widget datarange(BuildContext context){
     return Dialog(
       shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(20.0)),
       child: Container(
         height: 420,
         color: Colors.white,
         child: Padding(
           padding: const EdgeInsets.all(12.0),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.start,
             children: [
               Expanded(
                   child: Text(
                     "Select  Date",
                     style: TextStyle(fontSize: 18),
                   )),
               Expanded(
                 flex: 10,
                 child: RangePicker(
                   initiallyShowDate: DateTime.now(),
                   datePickerStyles: styles,
                   selectedPeriod: widget.selectedPeriod,
                   onChanged: widget.onChanged,
                   firstDate: DateTime.now().subtract(Duration(days: 365)),
                   lastDate: DateTime.now().add(Duration(days: 365)),
                 ),
               ),
               Expanded(
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     TextButton(onPressed:(){
                       setState(() {
                         // filterbydateRange(DateFormat('dd/MM/yyyy').format(selectedPeriod.start),
                         //DateFormat('dd/MM/yyyy').format(selectedPeriod.end));
                       });
                       Navigator.pop(context);
                     }, child: Text("OK")),
                     TextButton(onPressed:(){
                       setState(() {
                         //getcurrentuserList();
                       });
                       Navigator.pop(context);
                     }, child: Text("RESET")),
                   ],
                 ),
               )
             ],
           ),
         ),
       ),
     );
  }*/
}




