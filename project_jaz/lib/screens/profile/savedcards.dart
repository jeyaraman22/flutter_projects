import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_card_number_validator/credit_card_number_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jaz_app/helper/card_formatter.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/user/user.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';

class SavedCards extends StatefulWidget {
  const SavedCards({Key? key}) : super(key: key);

  @override
  _SavedCardsState createState() => _SavedCardsState();
}

class _SavedCardsState extends State<SavedCards> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool validateAndSave() {
    final FormState? form = _formKey2.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  int isPay = 0;
  ScrollController _controllerOne = ScrollController();
  TextEditingController _cardName = TextEditingController();

  // TextEditingController _lastName = TextEditingController();
  TextEditingController _cardNo = TextEditingController();
  TextEditingController _expMonth = TextEditingController();
  TextEditingController _expYear = TextEditingController();

  // TextEditingController _email = TextEditingController();
  final _formKey2 = GlobalKey<FormState>();
  bool isExpanded = false;
  String cardType = '';
  bool isSavedCard = false;
  bool checkValidate = false;
  var creditCardNumber;
  late String roomTypeCode,
      roomRatePlanCode,
      hotelCrsCode,
      hotelName,
      price,
      roomName;
  bool isValid = false;
  UserModel? users;

  Future<void> getUserDetails() async {
    final User? user = auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      var document = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      users = UserModel.fromJson(document.data() as Map<String, dynamic>);
      if (users != null) {
        setState(() {
          _cardName.text = users!.paymentCard.cardHolderName != null
              ? users!.paymentCard.cardHolderName
              : "";
          _cardNo.text = users!.paymentCard.cardNumber != null
              ? users!.paymentCard.cardNumber
              : "";
          _expMonth.text = users!.paymentCard.expireMonth != null
              ? users!.paymentCard.expireMonth
              : "";
          _expYear.text = users!.paymentCard.expireYear != null
              ? users!.paymentCard.expireYear
              : "";

          validationCardDetails(users!.paymentCard.cardNumber);
        });
      }
    }
  }

  String cardCodeDetails() {
    var cardCode;
    if (cardType == "MASTERCARD") {
      cardCode = "MC";
    } else if (cardType == "VISA") {
      cardCode = "VI";
    } else if (cardType == "AMEX") {
      cardCode = "AX";
    }
    // final User? user = auth.currentUser;
    // var payment = new PaymentCard();
    // payment.cardHolderName = this._firstName.text + this._lastName.text;
    // payment.cardNumber = this._cardNo.text.replaceAll(" ", "");
    // payment.expireDate =
    //     this._expMonth.text + this._expYear.text.substring(2, 4);
    // payment.cardCode = cardCode;
    //
    // if (user != null) {
    //   final userId = user.uid;
    //   print("userid");
    //   print(userId);
    //   var document = FirebaseFirestore.instance.collection('users').doc(userId);
    //   document.update({"payment": payment.toJson()});
    // }

    return cardCode;
  }

  validationCardDetails(String values) {
    String input = values.toString().replaceAll(" ", "");
    Map<String, dynamic> cardData = CreditCardValidator.getCard(input);
    setState(() {
      // Set Card Type and Validity
      cardType = cardData[CreditCardValidator.cardType];
      isValid = cardData[CreditCardValidator.isValidCard];
    });
  }

  Widget cardImage(cardTypes) {
    // print("cardtype");
    //print(cardType);
    switch (cardTypes) {
      case 'MASTERCARD':
        return Image.asset(
          "assets/images/mastercard.png",
          width: textFieldIconSize,
          height: textFieldIconSize,
        );
        break;
      case 'VISA':
        return Image.asset(
          "assets/images/visa.png",
          width: textFieldIconSize,
          height: textFieldIconSize,
        );
        break;
      case 'AMEX':
        return Image.asset(
          "assets/images/amex.png",
          width: textFieldIconSize,
          height: textFieldIconSize,
        );
        break;
      default:
        return Icon(
          Icons.credit_card,
          size: textFieldIconSize,
          color: Uicolors.desText,
        );
        break;
    }
    // Widget widget;
    // if (img) {
    //   widget = new Image.asset(
    //     'assets/images/$img',
    //     width: 40.0,
    //   );
    // } else {
    //   widget =icon;
    // }
    // return widget;
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var backTopSpace = overAllHeight * 0.0;
    var iconLeftPading = overAllWidth * 0.005;
    var leftPadding = overAllWidth * 0.033;
    final topPadding = overAllHeight * 0.015;
    var boxHeight = overAllHeight * 0.055;
    var borderRadius = fieldBorderRadius;
    var buttonWidth = overAllWidth * 0.6;
    var buttonHeight = overAllHeight * 0.055;
    var textfieldTopPadding = overAllHeight * 0.000;
    var buttontopPadding = overAllHeight * 0.05;

    if (boxHeight < 40) {
      boxHeight = 45;
      buttonHeight = 45;
    }

    return Scaffold(
        backgroundColor: Uicolors.backgroundColor,
        appBar: AppBar(
          toolbarHeight: AppUtility().isTablet(context)
              ? 80
              : AppBar().preferredSize.height,
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
                        Navigator.of(context, rootNavigator: true).pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: iconLeftPading),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Uicolors.backText,
                          size: backIconSize,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 0, top: 0),
                        child: Text(Strings.back, style: backStyle),
                      ),
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      margin: EdgeInsets.only(
                          right: iconLeftPading, top: backTopSpace),
                      child: Text(
                        Strings.savedCards,
                        style: welcomJazStyle,
                      )),
                ),
              ],
            ),
          ),
        ),
        body: StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            setSelectedRadio(int val) {
              setState(() {
                isPay = val;
              });
            }

            return Scrollbar(
              controller: _controllerOne,
              // thickness: 6,
              showTrackOnHover: true,
              //  hoverThickness: 12,
              isAlwaysShown: true,
              child: Form(
                  key: _formKey2,
                  child: Padding(
                      padding: EdgeInsets.all(0),
                      child: ListView(
                        controller: _controllerOne,
                        children: [
                          Padding(
                            child: Container(
                                alignment: Alignment.centerLeft,
                                height: boxHeight,
                                //   width: MediaQuery.of(context).size.width * 1,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                    color: Colors.white,
                                    border: border),
                                child: Padding(
                                  child: TextFormField(
                                    style: guestTextFieldStyle,
                                    autovalidateMode: checkValidate
                                        ? AutovalidateMode.onUserInteraction
                                        : AutovalidateMode.onUserInteraction,
                                    controller: _cardName,
                                    cursorColor: Uicolors.titleText,
                                    // cursorHeight: 18,
                                    decoration: InputDecoration(
                                        // fillColor: Uicolors.titleText,
                                        hintText: Strings.cardHolderName,
                                        hintStyle: guestHintTextFieldStyle,
                                        border: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        isCollapsed: true,
                                        errorStyle: errorTextStyle

                                        // contentPadding: EdgeInsets.only(bottom: 5),
                                        ),
                                    keyboardType: TextInputType.name,

                                    validator: (args) {
                                      if (args.toString().isNotEmpty) {
                                        return null;
                                      } else {
                                        return 'Card Holder Name is required';
                                      }
                                    },
                                  ),
                                  padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.05,
                                  ),
                                )),
                            padding: EdgeInsets.only(
                                top: topPadding,
                                left: leftPadding,
                                right: leftPadding),
                          ),
                          // Padding(
                          //   child: Container(
                          //       alignment: Alignment.centerLeft,
                          //       height: boxHeight,
                          //       // width: MediaQuery.of(context).size.width * 1,
                          //       decoration: BoxDecoration(
                          //         borderRadius:
                          //         BorderRadius.circular(borderRadius),
                          //         color: Colors.white,
                          //       ),
                          //       child: Padding(
                          //         child: TextFormField(
                          //           style: guestTextFieldStyle,
                          //           autovalidateMode: checkValidate
                          //               ? AutovalidateMode.onUserInteraction
                          //               : AutovalidateMode.onUserInteraction,
                          //           controller: _lastName,
                          //           cursorColor: Uicolors.titleText,
                          //           // cursorHeight: 18,
                          //           decoration: InputDecoration(
                          //             // errorStyle: TextStyle(height: 0.5),
                          //             //  fillColor: Uicolors.titleText,
                          //             hintText: Strings.lastStr,
                          //             hintStyle: guestHintTextFieldStyle,
                          //             border: InputBorder.none,
                          //             errorBorder: InputBorder.none,
                          //             isCollapsed: true,
                          //             // contentPadding:
                          //             //     EdgeInsets.only(bottom: 5),
                          //           ),
                          //           keyboardType: TextInputType.name,
                          //
                          //           validator: (args) {
                          //             if (args.toString().isNotEmpty) {
                          //               return null;
                          //             } else {
                          //               return 'Last Name is required';
                          //             }
                          //           },
                          //         ),
                          //         padding: EdgeInsets.only(
                          //           left: MediaQuery.of(context).size.width *
                          //               0.05,
                          //         ),
                          //       )),
                          //   padding: EdgeInsets.only(
                          //       top: topPadding,
                          //       left: leftPadding,
                          //       right: leftPadding),
                          // ),
                          Padding(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              height: boxHeight,
                              //  width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  color: Colors.white,
                                  border: border),
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Padding(
                                    child: TextFormField(
                                      style: guestTextFieldStyle,
                                      autovalidateMode: checkValidate
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.onUserInteraction,
                                      controller: _cardNo,
                                      cursorColor: Uicolors.titleText,
                                      // cursorHeight: 18,
                                      onChanged: (value) =>
                                          validationCardDetails(_cardNo.text),
                                      decoration: InputDecoration(
                                          // errorStyle: TextStyle(height: 0.5),
                                          //   fillColor: Uicolors.titleText,
                                          hintText: Strings.cardStr,
                                          hintStyle: guestHintTextFieldStyle,
                                          border: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          isCollapsed: true,
                                          errorStyle: errorTextStyle
                                          // contentPadding:
                                          //     EdgeInsets.only(bottom: 5),
                                          ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        // WhitelistingTextInputFormatter
                                        //     .digitsOnly,
                                        new LengthLimitingTextInputFormatter(
                                            16),
                                        new CardNumberInputFormatter()
                                      ],
                                      validator: (args) {
                                        if (args.toString().isNotEmpty) {
                                          if (args
                                                  .toString()
                                                  .replaceAll(" ", "")
                                                  .length >
                                              16) {
                                            return 'Please enter 16 digits';
                                          } else if (cardType == "UNKNOWN") {
                                            return 'Credit card type is not valid';
                                          } else {
                                            return null;
                                          }
                                          // return null;
                                        } else {
                                          return 'Credit card Number is required';
                                        }
                                      },
                                    ),
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.05,
                                    ),
                                  ),
                                  Container(
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.025),
                                        child: cardType != ""
                                            ? cardImage(cardType)
                                            : Icon(
                                                Icons.credit_card,
                                                size: textFieldIconSize,
                                                color: Uicolors.desText,
                                              )),
                                    alignment: Alignment.centerRight,
                                  )
                                ],
                              ),
                            ),
                            padding: EdgeInsets.only(
                                top: topPadding,
                                left: leftPadding,
                                right: leftPadding),
                          ),
                          Stack(
                            children: [
                              Padding(
                                child: Container(
                                    alignment: Alignment.centerLeft,
                                    height: boxHeight,
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(borderRadius),
                                        color: Colors.white,
                                        border: border),
                                    child: Padding(
                                      child: TextFormField(
                                        style: guestTextFieldStyle,
                                        autovalidateMode: checkValidate
                                            ? AutovalidateMode.onUserInteraction
                                            : AutovalidateMode
                                                .onUserInteraction,
                                        controller: _expMonth,
                                        cursorColor: Uicolors.titleText,
                                        // cursorHeight: 18,
                                        decoration: InputDecoration(
                                            // errorStyle: TextStyle(height: 0.5),
                                            //  fillColor: Colors.black,
                                            hintText: Strings.monthStr,
                                            hintStyle: guestHintTextFieldStyle,
                                            border: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            isCollapsed: true,
                                            errorStyle: errorTextStyle
                                            // contentPadding:
                                            //     EdgeInsets.only(bottom: 5),
                                            ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(2)
                                        ],
                                        validator: (month) {
                                          var monthReg = RegExp('^[0-3]?[0-9]')
                                              .hasMatch(_expMonth.text);
                                          if (month.toString().isNotEmpty) {
                                            if (month!.length != 2) {
                                              return 'Month is invalid';
                                            } else {
                                              return null;
                                            }
                                          } else {
                                            return 'Month is required';
                                          }
                                        },
                                      ),
                                      padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                    )),
                                padding: EdgeInsets.only(
                                    top: topPadding,
                                    left: leftPadding,
                                    right: leftPadding),
                              ),
                              Padding(
                                child: Container(
                                    alignment: Alignment.centerLeft,
                                    height: boxHeight,
                                    width: MediaQuery.of(context).size.width *
                                        0.465,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(borderRadius),
                                        color: Colors.white,
                                        border: border),
                                    child: Padding(
                                      child: TextFormField(
                                        style: guestTextFieldStyle,
                                        autovalidateMode: checkValidate
                                            ? AutovalidateMode.onUserInteraction
                                            : AutovalidateMode
                                                .onUserInteraction,
                                        controller: _expYear,
                                        cursorColor: Uicolors.titleText,
                                        // cursorHeight: 18,
                                        decoration: InputDecoration(
                                            // errorStyle: TextStyle(height: 0.5),
                                            //  fillColor: Colors.black,
                                            hintText: Strings.yearStr,
                                            hintStyle: guestHintTextFieldStyle,
                                            border: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            isCollapsed: true,
                                            errorStyle: errorTextStyle

                                            // contentPadding:
                                            //     EdgeInsets.only(bottom: 5),
                                            ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(4)
                                        ],
                                        validator: (year) {
                                          var yearReg =
                                              RegExp('^(201[4-9]|209[0-9])')
                                                  .hasMatch(year.toString());

                                          ///< Allows a number between 2014 and 2029
                                          if (year!.isNotEmpty) {
                                            if (year.length != 4) {
                                              return 'Year is invalid';
                                            } else {
                                              return null;
                                            }
                                          } else {
                                            return 'Year is required';
                                          }
                                        },
                                      ),
                                      padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                    )),
                                padding: EdgeInsets.only(
                                    top: topPadding,
                                    left: MediaQuery.of(context).size.width *
                                        0.50,
                                    right: leftPadding),
                              ),
                            ],
                          ),
                          // Padding(
                          //   child: Container(
                          //       alignment: Alignment.centerLeft,
                          //       height: boxHeight,
                          //       // width: MediaQuery.of(context).size.width * 1,
                          //       decoration: BoxDecoration(
                          //         borderRadius:
                          //         BorderRadius.circular(borderRadius),
                          //         color: Colors.white,
                          //       ),
                          //       child: Padding(
                          //         child: TextFormField(
                          //           style: guestTextFieldStyle,
                          //           autovalidateMode: checkValidate
                          //               ? AutovalidateMode.onUserInteraction
                          //               : AutovalidateMode.onUserInteraction,
                          //           controller: _email,
                          //           cursorColor: Uicolors.titleText,
                          //           // cursorHeight: 18,
                          //           decoration: InputDecoration(
                          //             // errorStyle: TextStyle(height: 0.5),
                          //             //  fillColor: Uicolors.titleText,
                          //             hintText: Strings.email,
                          //             hintStyle: guestHintTextFieldStyle,
                          //             border: InputBorder.none,
                          //             errorBorder: InputBorder.none,
                          //             isCollapsed: true,
                          //             // contentPadding:
                          //             //     EdgeInsets.only(bottom: 5),
                          //           ),
                          //           keyboardType: TextInputType.name,
                          //
                          //           validator: (args) {
                          //             if (args.toString().isNotEmpty) {
                          //               return null;
                          //             } else {
                          //               return 'Email is required';
                          //             }
                          //           },
                          //         ),
                          //         padding: EdgeInsets.only(
                          //           left: MediaQuery.of(context).size.width *
                          //               0.05,
                          //         ),
                          //       )),
                          //   padding: EdgeInsets.only(
                          //       top: topPadding,
                          //       left: leftPadding,
                          //       right: leftPadding),
                          // ),
                          Padding(
                            child: Container(
                              margin: AppUtility().isTablet(context)
                                  ? EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.15,
                                      right: MediaQuery.of(context).size.width *
                                          0.15)
                                  : EdgeInsets.all(0),
                              padding: EdgeInsets.only(
                                  top: textfieldTopPadding,
                                  left: leftPadding,
                                  right: leftPadding),
                              child: FlatButton(
                                minWidth: AppUtility().isTablet(context)
                                    ? MediaQuery.of(context).size.width * 0.70
                                    : buttonWidth,
                                height: buttonHeight,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(
                                      (buttonHeight) / 2),
                                ),
                                onPressed: () {
                                  if (validateAndSave()) {
                                    updateUsers();
                                  }
                                },
                                color: Uicolors.buttonbg,
                                child: Text(
                                  Strings.submit.toUpperCase(),
                                  style: buttonStyle,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.only(top: buttontopPadding),
                          ),
                        ],
                      ))),
            );
          },
        ));
  }

  void updateUsers() {
    CollectionReference userDetails =
        FirebaseFirestore.instance.collection('users');
    users!.paymentCard.cardHolderName = _cardName.text;
    users!.paymentCard.cardNumber = _cardNo.text;
    users!.paymentCard.expireMonth = _expMonth.text;
    users!.paymentCard.expireYear = _expYear.text;
    users!.paymentCard.cardCode = cardCodeDetails();

    final User? user = auth.currentUser;
    if (user != null) {
      var userId = user.uid;
      EasyLoading.show();
      // BuildContext? dialogContext;
      // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
      //   dialogContext = value;
      // });
      userDetails.doc(userId).update(users!.toJson()).then((value) async {
        EasyLoading.dismiss();
        // await new Future.delayed(const Duration(milliseconds: 500));
        // AppUtility().dismissDialog(dialogContext!);
        Navigator.of(context).pop();
      });
    }
  }
}
