import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:intl/intl.dart';


class DateRangePage extends StatefulWidget {
  final  DateTime startDate;
  final  DateTime endDate;
  final Function(DateTime start,DateTime end) selectedDateRange;

  DateRangePage(this.startDate,this.endDate,{required this.selectedDateRange});
  @override
  _DateRangePageState createState() => new _DateRangePageState();
}

class _DateRangePageState extends State<DateRangePage> {
  DateTime? startDate = DateTime.now().add(const Duration(days: 3));
  DateTime? endDate = DateTime.now().add(const Duration(days: 6));
  var checkInDay ="";
  var checkInDayName = "";
  var checkInMonth = "";
  var checkOutDay ="";
  var checkOutDayName = "";
  var checkOutMonth = "";
  var numberOfNight = "";

  void initState() {
    super.initState();
    //this.setState(() {
      var start = "${widget.startDate.year}-${widget.startDate.month}-${widget.startDate.day}";
      var end = "${widget.endDate.year}-${widget.endDate.month}-${widget.endDate.day}";
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      startDate = formatter.parse(start);
      endDate = formatter.parse(end);
      numberOfNight = getDateDiff(startDate, endDate);
    //});
  }

  String getDateDiff(startDate, endDate) {
    final DateFormat startFormatter = DateFormat('dd');
    final String startFormatted = startFormatter.format(startDate);
    final String endFormatted = startFormatter.format(endDate);

    final DateFormat dayNameFormatter = DateFormat('EEE');
    final String startDayNameFormatted = dayNameFormatter.format(startDate);
    final String endDayNameFormatted = dayNameFormatter.format(endDate);

    final DateFormat monthFormatter = DateFormat('MMM');
    final String startMonthFormatted = monthFormatter.format(startDate);
    final String endMonthFormatted = monthFormatter.format(endDate);

    int difference = endDate.difference(startDate).inDays;
    var nights = "";
    if (difference > 1) {
      nights = Strings.nights;
    } else if(difference<0){
      difference=0;
      nights = Strings.night;
    }else{
      nights = Strings.night;
    }
    setState(() {
      checkInDay = startFormatted;
      checkInDayName = startDayNameFormatted.toUpperCase();
      checkInMonth = startMonthFormatted.toUpperCase();
      checkOutDay =endFormatted;
      checkOutDayName = endDayNameFormatted.toUpperCase();
      checkOutMonth = endMonthFormatted.toUpperCase();
    });

    return difference.toString()+" "+nights;
  }
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.06;
    final overallHeight = MediaQuery.of(context).size.height;
    final overallWidth = MediaQuery.of(context).size.width;
    final leftPadding = overallWidth * 0.035;
    final bottomPadding = overallHeight * 0.005;
    final buttonHeight = overallHeight * 0.058;
    final buttonWidth = overallWidth *0.75;
    final searchBottomPadding = overallHeight * 0.02;

    var currentDate = DateTime.now();
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: AppUtility().isTablet(context)?80:AppBar().preferredSize.height,
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.005, 0, 0, 0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Uicolors.buttonbg,
                          size: backIconSize,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Text(Strings.backtosearch,
                            style: backSigninGreenStyle),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Container(
            margin: EdgeInsets.only(left: leftPadding, right: leftPadding),
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: bottomPadding),
                    child: Divider(
                      color: Uicolors.desText,
                      thickness: 0.5,
                    )),
                Container(
                  margin: EdgeInsets.only(bottom: bottomPadding),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          child: Column(
                        children: [
                          Text(
                            "Check-in",
                            style: dayCellTextStyle,
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Text(
                                    checkInDay,
                                    style: checkinDayTextStyle,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Column(
                                      children: [
                                        Text(
                                          checkInDayName,
                                          style: checkInDayStyle,
                                        ),
                                        Text(
                                          checkInMonth,
                                          style: checkInDayStyle1,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ))
                        ],
                      )),
                      Container(
                          padding: EdgeInsets.only(top: 10),
                          alignment: Alignment.center,
                          height: 45,
                          child: VerticalDivider(
                            color: Uicolors.desText,
                            thickness: 0.5,
                            indent: 0,
                            endIndent: 0,
                            width: 20,
                          )),
                      Container(
                          child: Column(
                        children: [
                          Text(
                            "Check-out",
                            style: dayCellTextStyle,
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Text(
                                    checkOutDay,
                                    style: checkinDayTextStyle,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Column(
                                      children: [
                                        Text(
                                          checkOutDayName,
                                          style: checkInDayStyle,
                                        ),
                                        Text(
                                          checkOutMonth,
                                          style: checkInDayStyle1,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ))
                        ],
                      )),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Container(
                      padding: EdgeInsets.only(top: 10,bottom: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Color.fromRGBO(215, 235, 235, 1),
                      ),
                      child: Row(
                        //mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          weekCenterText('Mo'),
                          weekCenterText('Tu'),
                          weekCenterText('We'),
                          weekCenterText('Th'),
                          weekCenterText('Fr'),
                          weekCenterText('Sa'),
                          weekCenterText('Su'),
                        ],
                      )
                  ),
                ),
                SizedBox(height: 20,),
                Expanded(
                  child:

                  PagedVerticalCalendar(
                    startDate: DateTime.utc(currentDate.year, currentDate.month, 1),
                    addAutomaticKeepAlives: true,
                    /// customize the month header look by adding a week indicator
                    monthBuilder: (context, month, year) {
                      return Column(
                        children: [
                          /// create a customized header displaying the month and year
                          Container(
                            //padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            margin: const EdgeInsets.all(10),
                            // decoration: BoxDecoration(
                            //   color: Theme.of(context).primaryColor,
                            //   borderRadius: BorderRadius.all(Radius.circular(50)),
                            // ),
                            child: Text(DateFormat('MMM yyyy').format(DateTime(year, month)),
                              style: monthTextStyle,
                            ),
                          ),
                        ],
                      );
                    },
                    dayBuilder: (context, date) {
                      // update the days color based on if it's selected or not
                      final color = isInRange(date) ? Uicolors.buttonbg : Colors.transparent;
                      var isBelow = date.isBefore(DateTime.utc(currentDate.year, currentDate.month, currentDate.day,0,0,0).subtract(Duration(days: 1)));

                      return Container(
                        child: isInRange(date) && (date == startDate || date == endDate) ?
                        Stack(
                          children: [
                            endDate !=null ? Container(
                                child: Center(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(date == endDate ? 40.0 : 0),
                                            bottomRight: Radius.circular(date == endDate ? 40.0 : 0),
                                            topLeft: Radius.circular(date == startDate ? 40.0 : 0),
                                            bottomLeft: Radius.circular(date == startDate ? 40.0 : 0)),
                                        color: Uicolors.sslEncriptionBgColor,
                                      ),
                                      width: double.infinity,
                                      height: AppUtility().isTablet(context)?60:40,
                                      child: Center(
                                        child: Text(DateFormat('d').format(date),style: cellStyle),
                                      )
                                  ),
                                )
                            ):Container(),
                            Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Uicolors.buttonbg,
                                ),
                                child: Center(
                                  child: Text(DateFormat('d').format(date),style: selectedCellTextStyle),
                                )
                            )
                          ],
                        ) : isInRange(date) && date != startDate && date != endDate ?
                        Container(
                          // decoration: BoxDecoration(
                          //   shape: BoxShape.rectangle,
                          //   color: Colors.red[100],
                          // ),
                            child: Center(
                                child: Container(
                                    color: Uicolors.sslEncriptionBgColor,
                                    width: double.infinity,
                                    height: AppUtility().isTablet(context)?60:40,
                                    child: Center(
                                      child: Text(DateFormat('d').format(date), style: cellStyle),
                                    )
                                )
                            )
                        ):
                        Container(
                          color: color,
                          child: Center(
                            child: Text(DateFormat('d').format(date),style: isBelow?dayCellTextStyle:cellStyle)
                          ),
                        ),
                      );
                    },
                    onDayPressed: (date) {
                      var isBelow = date.isBefore(DateTime.utc(currentDate.year, currentDate.month, currentDate.day,0,0,0).subtract(Duration(days: 1)));
                      if(!isBelow) {
                        setState(() {
                          // if start is null, assign this date to start
                          if (startDate == null) {
                            startDate = date;
                            setState(() {
                              numberOfNight = getDateDiff(startDate, startDate);
                            });
                            // if only end is null assign it to the end
                          } else if (endDate == null) {
                            endDate = date;
                          //  print('selected range from $startDate to $endDate');
                            setState(() {
                              numberOfNight = getDateDiff(startDate, endDate);
                            });
                            // if both start and end arent null, show results and reset
                          } else {
                          //  print('selected range from $startDate to $endDate');
                            startDate = null;
                            endDate = null;
                          }
                        });
                      }
                    },
                  )
                ),
                Container(
                  margin: EdgeInsets.only(bottom: searchBottomPadding),
                  child: Center(
                    child: FlatButton(
                      color: Uicolors.buttonbg,
                      minWidth: buttonWidth,
                      height: buttonHeight,
                      shape: new RoundedRectangleBorder(
                        borderRadius:
                        new BorderRadius.circular(buttonHeight / 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            Strings.confirm.toUpperCase(),
                            style: buttonStyle,
                          ),
                          Text('( '+ numberOfNight+ ' )',style: numberOfNightStyle,)
                        ],
                      ),
                      onPressed: () {
                        if(startDate!=null&&endDate!=null&&endDate!.difference(startDate!).inDays>0){
                          widget.selectedDateRange.call(startDate!, endDate!);
                          // GlobalState.checkInDate = startDate!;
                          // GlobalState.checkOutDate = endDate!;
                          Navigator.pop(context);
                        }else {
                          AppUtility().showToastView(
                              Strings.dateValidationStr, context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            )));
  }

 Widget weekCenterText(String text) {
   return Container(
     child: Center(
       child: Text(text,
         style: descTextStyle,
       ),
     ),
   );
 }

 /// method to check wether a day is in the selected range
 /// used for highlighting those day
 bool isInRange(DateTime date) {
   // if start is null, no date has been selected yet
   if (startDate == null) return false;
   // if only end is null only the start should be highlighted
   if (endDate == null) return date == startDate;
   // if both start and end aren't null check if date false in the range
   return ((date == startDate || date.isAfter(startDate!)) &&
       (date == endDate || date.isBefore(endDate!)));
 }

}
