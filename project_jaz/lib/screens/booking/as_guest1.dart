import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_card_number_validator/credit_card_number_validator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/helper/card_formatter.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/roommodel.dart';
import 'package:jaz_app/models/user/user.dart';
import 'package:jaz_app/screens/booking/as_guest2.dart';
import 'package:jaz_app/screens/booking/termssandconditions.dart';
import 'package:jaz_app/screens/bottomnavigation/bottombar.dart';
import 'package:jaz_app/screens/search/confirmsearch.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/widgets/summaryroomlist.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../homebottombar.dart';

class AsGuestSummery extends StatefulWidget {
  // const AsGuestSummery({Key? key}) : super(key: key);
  final HashMap<String, dynamic> selectedRoomdet;
  final HashMap<String, dynamic> guestDetails;
  AsGuestSummery(this.selectedRoomdet, this.guestDetails);
  @override
  _AsGuestSummeryState createState() => _AsGuestSummeryState();
}

var emojiRegexp =
    '   /\uD83C\uDFF4\uDB40\uDC67\uDB40\uDC62(?:\uDB40\uDC77\uDB40\uDC6C\uDB40\uDC73|\uDB40\uDC73\uDB40\uDC63\uDB40\uDC74|\uDB40\uDC65\uDB40\uDC6E\uDB40\uDC67)\uDB40\uDC7F|\uD83D\uDC69\u200D\uD83D\uDC69\u200D(?:\uD83D\uDC66\u200D\uD83D\uDC66|\uD83D\uDC67\u200D(?:\uD83D[\uDC66\uDC67]))|\uD83D\uDC68(?:\uD83C\uDFFF\u200D(?:\uD83E\uDD1D\u200D\uD83D\uDC68(?:\uD83C[\uDFFB-\uDFFE])|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C\uDFFE\u200D(?:\uD83E\uDD1D\u200D\uD83D\uDC68(?:\uD83C[\uDFFB-\uDFFD\uDFFF])|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C\uDFFD\u200D(?:\uD83E\uDD1D\u200D\uD83D\uDC68(?:\uD83C[\uDFFB\uDFFC\uDFFE\uDFFF])|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C\uDFFC\u200D(?:\uD83E\uDD1D\u200D\uD83D\uDC68(?:\uD83C[\uDFFB\uDFFD-\uDFFF])|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C\uDFFB\u200D(?:\uD83E\uDD1D\u200D\uD83D\uDC68(?:\uD83C[\uDFFC-\uDFFF])|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\u200D(?:\u2764\uFE0F\u200D(?:\uD83D\uDC8B\u200D)?\uD83D\uDC68|(?:\uD83D[\uDC68\uDC69])\u200D(?:\uD83D\uDC66\u200D\uD83D\uDC66|\uD83D\uDC67\u200D(?:\uD83D[\uDC66\uDC67]))|\uD83D\uDC66\u200D\uD83D\uDC66|\uD83D\uDC67\u200D(?:\uD83D[\uDC66\uDC67])|(?:\uD83D[\uDC68\uDC69])\u200D(?:\uD83D[\uDC66\uDC67])|[\u2695\u2696\u2708]\uFE0F|\uD83D[\uDC66\uDC67]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|(?:\uD83C\uDFFF\u200D[\u2695\u2696\u2708]|\uD83C\uDFFE\u200D[\u2695\u2696\u2708]|\uD83C\uDFFD\u200D[\u2695\u2696\u2708]|\uD83C\uDFFC\u200D[\u2695\u2696\u2708]|\uD83C\uDFFB\u200D[\u2695\u2696\u2708])\uFE0F|\uD83C\uDFFF|\uD83C\uDFFE|\uD83C\uDFFD|\uD83C\uDFFC|\uD83C\uDFFB)?|\uD83E\uDDD1(?:(?:\uD83C[\uDFFB-\uDFFF])\u200D(?:\uD83E\uDD1D\u200D\uD83E\uDDD1(?:\uD83C[\uDFFB-\uDFFF])|\uD83C[\uDF3E\uDF73\uDF7C\uDF84\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\u200D(?:\uD83E\uDD1D\u200D\uD83E\uDDD1|\uD83C[\uDF3E\uDF73\uDF7C\uDF84\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD]))|\uD83D\uDC69(?:\u200D(?:\u2764\uFE0F\u200D(?:\uD83D\uDC8B\u200D(?:\uD83D[\uDC68\uDC69])|\uD83D[\uDC68\uDC69])|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C\uDFFF\u200D(?:\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C\uDFFE\u200D(?:\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C\uDFFD\u200D(?:\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C\uDFFC\u200D(?:\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C\uDFFB\u200D(?:\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD]))|\uD83D\uDC69\uD83C\uDFFF\u200D\uD83E\uDD1D\u200D(?:\uD83D[\uDC68\uDC69])(?:\uD83C[\uDFFB-\uDFFE])|\uD83D\uDC69\uD83C\uDFFE\u200D\uD83E\uDD1D\u200D(?:\uD83D[\uDC68\uDC69])(?:\uD83C[\uDFFB-\uDFFD\uDFFF])|\uD83D\uDC69\uD83C\uDFFD\u200D\uD83E\uDD1D\u200D(?:\uD83D[\uDC68\uDC69])(?:\uD83C[\uDFFB\uDFFC\uDFFE\uDFFF])|\uD83D\uDC69\uD83C\uDFFC\u200D\uD83E\uDD1D\u200D(?:\uD83D[\uDC68\uDC69])(?:\uD83C[\uDFFB\uDFFD-\uDFFF])|\uD83D\uDC69\uD83C\uDFFB\u200D\uD83E\uDD1D\u200D(?:\uD83D[\uDC68\uDC69])(?:\uD83C[\uDFFC-\uDFFF])|\uD83D\uDC69\u200D\uD83D\uDC66\u200D\uD83D\uDC66|\uD83D\uDC69\u200D\uD83D\uDC69\u200D(?:\uD83D[\uDC66\uDC67])|(?:\uD83D\uDC41\uFE0F\u200D\uD83D\uDDE8|\uD83D\uDC69(?:\uD83C\uDFFF\u200D[\u2695\u2696\u2708]|\uD83C\uDFFE\u200D[\u2695\u2696\u2708]|\uD83C\uDFFD\u200D[\u2695\u2696\u2708]|\uD83C\uDFFC\u200D[\u2695\u2696\u2708]|\uD83C\uDFFB\u200D[\u2695\u2696\u2708]|\u200D[\u2695\u2696\u2708])|\uD83C\uDFF3\uFE0F\u200D\u26A7|\uD83E\uDDD1(?:(?:\uD83C[\uDFFB-\uDFFF])\u200D[\u2695\u2696\u2708]|\u200D[\u2695\u2696\u2708])|\uD83D\uDC3B\u200D\u2744|(?:(?:\uD83C[\uDFC3\uDFC4\uDFCA]|\uD83D[\uDC6E\uDC70\uDC71\uDC73\uDC77\uDC81\uDC82\uDC86\uDC87\uDE45-\uDE47\uDE4B\uDE4D\uDE4E\uDEA3\uDEB4-\uDEB6]|\uD83E[\uDD26\uDD35\uDD37-\uDD39\uDD3D\uDD3E\uDDB8\uDDB9\uDDCD-\uDDCF\uDDD6-\uDDDD])(?:\uD83C[\uDFFB-\uDFFF])|\uD83D\uDC6F|\uD83E[\uDD3C\uDDDE\uDDDF])\u200D[\u2640\u2642]|(?:\u26F9|\uD83C[\uDFCB\uDFCC]|\uD83D\uDD75)(?:\uFE0F|\uD83C[\uDFFB-\uDFFF])\u200D[\u2640\u2642]|\uD83C\uDFF4\u200D\u2620|(?:\uD83C[\uDFC3\uDFC4\uDFCA]|\uD83D[\uDC6E\uDC70\uDC71\uDC73\uDC77\uDC81\uDC82\uDC86\uDC87\uDE45-\uDE47\uDE4B\uDE4D\uDE4E\uDEA3\uDEB4-\uDEB6]|\uD83E[\uDD26\uDD35\uDD37-\uDD39\uDD3D\uDD3E\uDDB8\uDDB9\uDDCD-\uDDCF\uDDD6-\uDDDD])\u200D[\u2640\u2642]|[\xA9\xAE\u203C\u2049\u2122\u2139\u2194-\u2199\u21A9\u21AA\u2328\u23CF\u23ED-\u23EF\u23F1\u23F2\u23F8-\u23FA\u24C2\u25AA\u25AB\u25B6\u25C0\u25FB\u25FC\u2600-\u2604\u260E\u2611\u2618\u2620\u2622\u2623\u2626\u262A\u262E\u262F\u2638-\u263A\u2640\u2642\u265F\u2660\u2663\u2665\u2666\u2668\u267B\u267E\u2692\u2694-\u2697\u2699\u269B\u269C\u26A0\u26A7\u26B0\u26B1\u26C8\u26CF\u26D1\u26D3\u26E9\u26F0\u26F1\u26F4\u26F7\u26F8\u2702\u2708\u2709\u270F\u2712\u2714\u2716\u271D\u2721\u2733\u2734\u2744\u2747\u2763\u2764\u27A1\u2934\u2935\u2B05-\u2B07\u3030\u303D\u3297\u3299]|\uD83C[\uDD70\uDD71\uDD7E\uDD7F\uDE02\uDE37\uDF21\uDF24-\uDF2C\uDF36\uDF7D\uDF96\uDF97\uDF99-\uDF9B\uDF9E\uDF9F\uDFCD\uDFCE\uDFD4-\uDFDF\uDFF5\uDFF7]|\uD83D[\uDC3F\uDCFD\uDD49\uDD4A\uDD6F\uDD70\uDD73\uDD76-\uDD79\uDD87\uDD8A-\uDD8D\uDDA5\uDDA8\uDDB1\uDDB2\uDDBC\uDDC2-\uDDC4\uDDD1-\uDDD3\uDDDC-\uDDDE\uDDE1\uDDE3\uDDE8\uDDEF\uDDF3\uDDFA\uDECB\uDECD-\uDECF\uDEE0-\uDEE5\uDEE9\uDEF0\uDEF3])\uFE0F|\uD83D\uDC69\u200D\uD83D\uDC67\u200D(?:\uD83D[\uDC66\uDC67])|\uD83C\uDFF3\uFE0F\u200D\uD83C\uDF08|\uD83D\uDC69\u200D\uD83D\uDC67|\uD83D\uDC69\u200D\uD83D\uDC66|\uD83D\uDC15\u200D\uD83E\uDDBA|\uD83D\uDC69(?:\uD83C\uDFFF|\uD83C\uDFFE|\uD83C\uDFFD|\uD83C\uDFFC|\uD83C\uDFFB)?|\uD83C\uDDFD\uD83C\uDDF0|\uD83C\uDDF6\uD83C\uDDE6|\uD83C\uDDF4\uD83C\uDDF2|\uD83D\uDC08\u200D\u2B1B|\uD83D\uDC41\uFE0F|\uD83C\uDFF3\uFE0F|\uD83E\uDDD1(?:\uD83C[\uDFFB-\uDFFF])?|\uD83C\uDDFF(?:\uD83C[\uDDE6\uDDF2\uDDFC])|\uD83C\uDDFE(?:\uD83C[\uDDEA\uDDF9])|\uD83C\uDDFC(?:\uD83C[\uDDEB\uDDF8])|\uD83C\uDDFB(?:\uD83C[\uDDE6\uDDE8\uDDEA\uDDEC\uDDEE\uDDF3\uDDFA])|\uD83C\uDDFA(?:\uD83C[\uDDE6\uDDEC\uDDF2\uDDF3\uDDF8\uDDFE\uDDFF])|\uD83C\uDDF9(?:\uD83C[\uDDE6\uDDE8\uDDE9\uDDEB-\uDDED\uDDEF-\uDDF4\uDDF7\uDDF9\uDDFB\uDDFC\uDDFF])|\uD83C\uDDF8(?:\uD83C[\uDDE6-\uDDEA\uDDEC-\uDDF4\uDDF7-\uDDF9\uDDFB\uDDFD-\uDDFF])|\uD83C\uDDF7(?:\uD83C[\uDDEA\uDDF4\uDDF8\uDDFA\uDDFC])|\uD83C\uDDF5(?:\uD83C[\uDDE6\uDDEA-\uDDED\uDDF0-\uDDF3\uDDF7-\uDDF9\uDDFC\uDDFE])|\uD83C\uDDF3(?:\uD83C[\uDDE6\uDDE8\uDDEA-\uDDEC\uDDEE\uDDF1\uDDF4\uDDF5\uDDF7\uDDFA\uDDFF])|\uD83C\uDDF2(?:\uD83C[\uDDE6\uDDE8-\uDDED\uDDF0-\uDDFF])|\uD83C\uDDF1(?:\uD83C[\uDDE6-\uDDE8\uDDEE\uDDF0\uDDF7-\uDDFB\uDDFE])|\uD83C\uDDF0(?:\uD83C[\uDDEA\uDDEC-\uDDEE\uDDF2\uDDF3\uDDF5\uDDF7\uDDFC\uDDFE\uDDFF])|\uD83C\uDDEF(?:\uD83C[\uDDEA\uDDF2\uDDF4\uDDF5])|\uD83C\uDDEE(?:\uD83C[\uDDE8-\uDDEA\uDDF1-\uDDF4\uDDF6-\uDDF9])|\uD83C\uDDED(?:\uD83C[\uDDF0\uDDF2\uDDF3\uDDF7\uDDF9\uDDFA])|\uD83C\uDDEC(?:\uD83C[\uDDE6\uDDE7\uDDE9-\uDDEE\uDDF1-\uDDF3\uDDF5-\uDDFA\uDDFC\uDDFE])|\uD83C\uDDEB(?:\uD83C[\uDDEE-\uDDF0\uDDF2\uDDF4\uDDF7])|\uD83C\uDDEA(?:\uD83C[\uDDE6\uDDE8\uDDEA\uDDEC\uDDED\uDDF7-\uDDFA])|\uD83C\uDDE9(?:\uD83C[\uDDEA\uDDEC\uDDEF\uDDF0\uDDF2\uDDF4\uDDFF])|\uD83C\uDDE8(?:\uD83C[\uDDE6\uDDE8\uDDE9\uDDEB-\uDDEE\uDDF0-\uDDF5\uDDF7\uDDFA-\uDDFF])|\uD83C\uDDE7(?:\uD83C[\uDDE6\uDDE7\uDDE9-\uDDEF\uDDF1-\uDDF4\uDDF6-\uDDF9\uDDFB\uDDFC\uDDFE\uDDFF])|\uD83C\uDDE6(?:\uD83C[\uDDE8-\uDDEC\uDDEE\uDDF1\uDDF2\uDDF4\uDDF6-\uDDFA\uDDFC\uDDFD\uDDFF])|[#\*0-9]\uFE0F\u20E3|(?:\uD83C[\uDFC3\uDFC4\uDFCA]|\uD83D[\uDC6E\uDC70\uDC71\uDC73\uDC77\uDC81\uDC82\uDC86\uDC87\uDE45-\uDE47\uDE4B\uDE4D\uDE4E\uDEA3\uDEB4-\uDEB6]|\uD83E[\uDD26\uDD35\uDD37-\uDD39\uDD3D\uDD3E\uDDB8\uDDB9\uDDCD-\uDDCF\uDDD6-\uDDDD])(?:\uD83C[\uDFFB-\uDFFF])|(?:\u26F9|\uD83C[\uDFCB\uDFCC]|\uD83D\uDD75)(?:\uFE0F|\uD83C[\uDFFB-\uDFFF])|\uD83C\uDFF4|(?:[\u270A\u270B]|\uD83C[\uDF85\uDFC2\uDFC7]|\uD83D[\uDC42\uDC43\uDC46-\uDC50\uDC66\uDC67\uDC6B-\uDC6D\uDC72\uDC74-\uDC76\uDC78\uDC7C\uDC83\uDC85\uDCAA\uDD7A\uDD95\uDD96\uDE4C\uDE4F\uDEC0\uDECC]|\uD83E[\uDD0C\uDD0F\uDD18-\uDD1C\uDD1E\uDD1F\uDD30-\uDD34\uDD36\uDD77\uDDB5\uDDB6\uDDBB\uDDD2-\uDDD5])(?:\uD83C[\uDFFB-\uDFFF])|(?:[\u261D\u270C\u270D]|\uD83D[\uDD74\uDD90])(?:\uFE0F|\uD83C[\uDFFB-\uDFFF])|[\u270A\u270B]|\uD83C[\uDF85\uDFC2\uDFC7]|\uD83D[\uDC08\uDC15\uDC3B\uDC42\uDC43\uDC46-\uDC50\uDC66\uDC67\uDC6B-\uDC6D\uDC72\uDC74-\uDC76\uDC78\uDC7C\uDC83\uDC85\uDCAA\uDD7A\uDD95\uDD96\uDE4C\uDE4F\uDEC0\uDECC]|\uD83E[\uDD0C\uDD0F\uDD18-\uDD1C\uDD1E\uDD1F\uDD30-\uDD34\uDD36\uDD77\uDDB5\uDDB6\uDDBB\uDDD2-\uDDD5]|\uD83C[\uDFC3\uDFC4\uDFCA]|\uD83D[\uDC6E\uDC70\uDC71\uDC73\uDC77\uDC81\uDC82\uDC86\uDC87\uDE45-\uDE47\uDE4B\uDE4D\uDE4E\uDEA3\uDEB4-\uDEB6]|\uD83E[\uDD26\uDD35\uDD37-\uDD39\uDD3D\uDD3E\uDDB8\uDDB9\uDDCD-\uDDCF\uDDD6-\uDDDD]|\uD83D\uDC6F|\uD83E[\uDD3C\uDDDE\uDDDF]|[\u231A\u231B\u23E9-\u23EC\u23F0\u23F3\u25FD\u25FE\u2614\u2615\u2648-\u2653\u267F\u2693\u26A1\u26AA\u26AB\u26BD\u26BE\u26C4\u26C5\u26CE\u26D4\u26EA\u26F2\u26F3\u26F5\u26FA\u26FD\u2705\u2728\u274C\u274E\u2753-\u2755\u2757\u2795-\u2797\u27B0\u27BF\u2B1B\u2B1C\u2B50\u2B55]|\uD83C[\uDC04\uDCCF\uDD8E\uDD91-\uDD9A\uDE01\uDE1A\uDE2F\uDE32-\uDE36\uDE38-\uDE3A\uDE50\uDE51\uDF00-\uDF20\uDF2D-\uDF35\uDF37-\uDF7C\uDF7E-\uDF84\uDF86-\uDF93\uDFA0-\uDFC1\uDFC5\uDFC6\uDFC8\uDFC9\uDFCF-\uDFD3\uDFE0-\uDFF0\uDFF8-\uDFFF]|\uD83D[\uDC00-\uDC07\uDC09-\uDC14\uDC16-\uDC3A\uDC3C-\uDC3E\uDC40\uDC44\uDC45\uDC51-\uDC65\uDC6A\uDC79-\uDC7B\uDC7D-\uDC80\uDC84\uDC88-\uDCA9\uDCAB-\uDCFC\uDCFF-\uDD3D\uDD4B-\uDD4E\uDD50-\uDD67\uDDA4\uDDFB-\uDE44\uDE48-\uDE4A\uDE80-\uDEA2\uDEA4-\uDEB3\uDEB7-\uDEBF\uDEC1-\uDEC5\uDED0-\uDED2\uDED5-\uDED7\uDEEB\uDEEC\uDEF4-\uDEFC\uDFE0-\uDFEB]|\uD83E[\uDD0D\uDD0E\uDD10-\uDD17\uDD1D\uDD20-\uDD25\uDD27-\uDD2F\uDD3A\uDD3F-\uDD45\uDD47-\uDD76\uDD78\uDD7A-\uDDB4\uDDB7\uDDBA\uDDBC-\uDDCB\uDDD0\uDDE0-\uDDFF\uDE70-\uDE74\uDE78-\uDE7A\uDE80-\uDE86\uDE90-\uDEA8\uDEB0-\uDEB6\uDEC0-\uDEC2\uDED0-\uDED6]|(?:[\u231A\u231B\u23E9-\u23EC\u23F0\u23F3\u25FD\u25FE\u2614\u2615\u2648-\u2653\u267F\u2693\u26A1\u26AA\u26AB\u26BD\u26BE\u26C4\u26C5\u26CE\u26D4\u26EA\u26F2\u26F3\u26F5\u26FA\u26FD\u2705\u270A\u270B\u2728\u274C\u274E\u2753-\u2755\u2757\u2795-\u2797\u27B0\u27BF\u2B1B\u2B1C\u2B50\u2B55]|\uD83C[\uDC04\uDCCF\uDD8E\uDD91-\uDD9A\uDDE6-\uDDFF\uDE01\uDE1A\uDE2F\uDE32-\uDE36\uDE38-\uDE3A\uDE50\uDE51\uDF00-\uDF20\uDF2D-\uDF35\uDF37-\uDF7C\uDF7E-\uDF93\uDFA0-\uDFCA\uDFCF-\uDFD3\uDFE0-\uDFF0\uDFF4\uDFF8-\uDFFF]|\uD83D[\uDC00-\uDC3E\uDC40\uDC42-\uDCFC\uDCFF-\uDD3D\uDD4B-\uDD4E\uDD50-\uDD67\uDD7A\uDD95\uDD96\uDDA4\uDDFB-\uDE4F\uDE80-\uDEC5\uDECC\uDED0-\uDED2\uDED5-\uDED7\uDEEB\uDEEC\uDEF4-\uDEFC\uDFE0-\uDFEB]|\uD83E[\uDD0C-\uDD3A\uDD3C-\uDD45\uDD47-\uDD78\uDD7A-\uDDCB\uDDCD-\uDDFF\uDE70-\uDE74\uDE78-\uDE7A\uDE80-\uDE86\uDE90-\uDEA8\uDEB0-\uDEB6\uDEC0-\uDEC2\uDED0-\uDED6])|(?:[#\*0-9\xA9\xAE\u203C\u2049\u2122\u2139\u2194-\u2199\u21A9\u21AA\u231A\u231B\u2328\u23CF\u23E9-\u23F3\u23F8-\u23FA\u24C2\u25AA\u25AB\u25B6\u25C0\u25FB-\u25FE\u2600-\u2604\u260E\u2611\u2614\u2615\u2618\u261D\u2620\u2622\u2623\u2626\u262A\u262E\u262F\u2638-\u263A\u2640\u2642\u2648-\u2653\u265F\u2660\u2663\u2665\u2666\u2668\u267B\u267E\u267F\u2692-\u2697\u2699\u269B\u269C\u26A0\u26A1\u26A7\u26AA\u26AB\u26B0\u26B1\u26BD\u26BE\u26C4\u26C5\u26C8\u26CE\u26CF\u26D1\u26D3\u26D4\u26E9\u26EA\u26F0-\u26F5\u26F7-\u26FA\u26FD\u2702\u2705\u2708-\u270D\u270F\u2712\u2714\u2716\u271D\u2721\u2728\u2733\u2734\u2744\u2747\u274C\u274E\u2753-\u2755\u2757\u2763\u2764\u2795-\u2797\u27A1\u27B0\u27BF\u2934\u2935\u2B05-\u2B07\u2B1B\u2B1C\u2B50\u2B55\u3030\u303D\u3297\u3299]|\uD83C[\uDC04\uDCCF\uDD70\uDD71\uDD7E\uDD7F\uDD8E\uDD91-\uDD9A\uDDE6-\uDDFF\uDE01\uDE02\uDE1A\uDE2F\uDE32-\uDE3A\uDE50\uDE51\uDF00-\uDF21\uDF24-\uDF93\uDF96\uDF97\uDF99-\uDF9B\uDF9E-\uDFF0\uDFF3-\uDFF5\uDFF7-\uDFFF]|\uD83D[\uDC00-\uDCFD\uDCFF-\uDD3D\uDD49-\uDD4E\uDD50-\uDD67\uDD6F\uDD70\uDD73-\uDD7A\uDD87\uDD8A-\uDD8D\uDD90\uDD95\uDD96\uDDA4\uDDA5\uDDA8\uDDB1\uDDB2\uDDBC\uDDC2-\uDDC4\uDDD1-\uDDD3\uDDDC-\uDDDE\uDDE1\uDDE3\uDDE8\uDDEF\uDDF3\uDDFA-\uDE4F\uDE80-\uDEC5\uDECB-\uDED2\uDED5-\uDED7\uDEE0-\uDEE5\uDEE9\uDEEB\uDEEC\uDEF0\uDEF3-\uDEFC\uDFE0-\uDFEB]|\uD83E[\uDD0C-\uDD3A\uDD3C-\uDD45\uDD47-\uDD78\uDD7A-\uDDCB\uDDCD-\uDDFF\uDE70-\uDE74\uDE78-\uDE7A\uDE80-\uDE86\uDE90-\uDEA8\uDEB0-\uDEB6\uDEC0-\uDEC2\uDED0-\uDED6])\uFE0F|(?:[\u261D\u26F9\u270A-\u270D]|\uD83C[\uDF85\uDFC2-\uDFC4\uDFC7\uDFCA-\uDFCC]|\uD83D[\uDC42\uDC43\uDC46-\uDC50\uDC66-\uDC78\uDC7C\uDC81-\uDC83\uDC85-\uDC87\uDC8F\uDC91\uDCAA\uDD74\uDD75\uDD7A\uDD90\uDD95\uDD96\uDE45-\uDE47\uDE4B-\uDE4F\uDEA3\uDEB4-\uDEB6\uDEC0\uDECC]|\uD83E[\uDD0C\uDD0F\uDD18-\uDD1F\uDD26\uDD30-\uDD39\uDD3C-\uDD3E\uDD77\uDDB5\uDDB6\uDDB8\uDDB9\uDDBB\uDDCD-\uDDCF\uDDD1-\uDDDD])/';
final _formKey2 = GlobalKey<FormState>();

class _AsGuestSummeryState extends State<AsGuestSummery> {
  bool isExpanded = true;

  bool validateAndSave() {
    final FormState? form = _formKey2.currentState;
    var details = roomDetails.where((element) => element.roomDetail.isEmpty);
    if (details.length > 0) {
      appUtility.showToastView("Please Select Room.", context);
      return false;
    } else if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  ScrollController _controllerOne = ScrollController();
  TextEditingController _cardName = TextEditingController();
  // TextEditingController _lastName = TextEditingController();
  TextEditingController _cardNo = TextEditingController();
  TextEditingController _expMonth = TextEditingController();
  TextEditingController _expYear = TextEditingController();
  TextEditingController _cvcCode = TextEditingController();

  int isPay = 1;

  bool isSavedCard = false;
  bool checkValidate = false;
  var creditCardNumber;
  late String
      hotelName,
      roomName,
      hotelId;
  var ratePlanCode;
  bool hidePayView = false;
  bool isUsePreviousCard = false;
  bool isShowPreviousCard = false;
  double price = 0.0;
  double convertedPrice = 0.0;


  AppUtility appUtility = AppUtility();
  HttpClient httpClient = HttpClient();

  var userDetails;
  final FirebaseAuth auth = FirebaseAuth.instance;
  UserModel? users;
  List<Room> roomDetails =[];
  String deviceModel = '';

  Future getdeviceModel() async{
    DeviceInfoPlugin deviceInfo =  DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var build = await deviceInfo.androidInfo;
      setState(() {
        deviceModel = build.model!;
      });
      print("DEVICE MODEL--${build.brand!}");
    } else if (Platform.isIOS) {
      var data = await deviceInfo.iosInfo;
      setState(() {
        deviceModel = data.name!;
      });
      print("DEVICE MODEL--${data.name!}");
    }

  @override
  void initState() {
    super.initState();
    appUtility = AppUtility();
    roomDetails = GlobalState.selectedRoomList;
    getdeviceModel();
    }
    // roomName = GlobalState.selectedBookingRoomDet["selectedRoomName"];
    // roomTypeCode = GlobalState.selectedBookingRoomDet["roomTypeCode"];
    // roomRatePlanCode = GlobalState.selectedBookingRoomDet["roomRatePlanCode"];
    // hotelCrsCode = GlobalState.selectedBookingRoomDet["hotelCrsCode"];
    // hotelName = GlobalState.selectedBookingRoomDet["hotelName"];
    // price = GlobalState.selectedBookingRoomDet["price"];
    // ratePlanCode = GlobalState.selectedBookingRoomDet["nonRefundableRatePlan"];
    roomDetails.forEach((element) {
      if(element.roomDetail.isNotEmpty) {
        if (element.roomDetail["nonRefundableRatePlan"] == "NRF") {
          isPay = 0;
          hidePayView = true;
        }
      }
    });
    getUserDetails();
    _controllerOne =
        ScrollController(keepScrollOffset: true, initialScrollOffset: 50.0);
  }
  getPriceDetails(){
    price =0.0;
    convertedPrice = 0.0;
    roomDetails.forEach((element) {
      if(element.roomDetail.isNotEmpty) {
        price = double.parse(element.roomDetail["price"])+price;
        convertedPrice = double.parse(element.roomDetail["convertedPrice"])+convertedPrice;
        if (element.roomDetail["nonRefundableRatePlan"] == "NRF") {
          isPay = 0;
          hidePayView = true;
        }
      }
    });
  }

  Future<void> getUserDetails() async {
    final User? user = auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      var document = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      userDetails = document.data();
      users = UserModel.fromJson(document.data() as Map<String, dynamic>);
      if (users != null) {
        if (users!.paymentCard != null &&
            users!.paymentCard.cardNumber != null &&
            users!.paymentCard.cardNumber != "") {
          this.setState(() {
            isUsePreviousCard = true;
          });
        }
        if (isShowPreviousCard) {
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
        } else {
          _cardName.text = "";
          _cardNo.text = "";
          _expMonth.text = "";
          _expYear.text = "";
        }
      }
    }
  }

  Future<void> updateUserDetails() async {
    var cardCode;
    if (cardType == "MASTERCARD") {
      cardCode = "MC";
    } else if (cardType == "VISA") {
      cardCode = "VI";
    } else if (cardType == "AMEX") {
      cardCode = "AX";
    }
    final User? user = auth.currentUser;
    var payment = new PaymentCard();
    payment.cardHolderName = this._cardName.text;
    //  + this._lastName.text;
    payment.cardNumber = this._cardNo.text.replaceAll(" ", "");
    payment.expireMonth = this._expMonth.text;
    payment.expireYear = this._expYear.text; //.substring(2, 4);
    payment.cardCode = cardCode;

    if (user != null) {
      final userId = user.uid;
      var document = FirebaseFirestore.instance.collection('users').doc(userId);
      document.update({"paymentCard": payment.toJson()});
    }
  }

  String cardType = '';
  bool isValid = false;

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
    print("cardtype");
    print(cardType);
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

  AppBar _appBarData(BuildContext context) {
    return AppBar(
        toolbarHeight:
            AppUtility().isTablet(context) ? 80 : AppBar().preferredSize.height,
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
                      child: Text(Strings.back, style: backStyle),
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.height * 0.015),
                    child: Text(
                      Strings.summaryStr,
                      style: summaryTextStyle,
                    )),
              ),
            ],
          ),
        ));
  }

  Widget _nextButton(BuildContext context) {
    print(isPay);
    String value = "Proceed to Pay";
    var overAllHeight = MediaQuery.of(context).size.height;
    var buttonHeight = overAllHeight * 0.055;
    if (buttonHeight < 40) {
      buttonHeight = 45;
    }
    return Align(
        alignment: Alignment.center,
        child: Container(
            height: buttonHeight,
            width: AppUtility().isTablet(context)
                ? MediaQuery.of(context).size.width * 0.70
                : MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
              color: Uicolors.buttonbg,
              borderRadius:
                  BorderRadius.all(Radius.circular(buttonHeight / 2) //
                      ),
            ),
            child: MaterialButton(
              color: Uicolors.buttonbg,
              child: Text(
                value.toUpperCase(),
                style: buttonStyle,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonHeight / 2),
              ),
              onPressed: () {
                HashMap<String, dynamic> cardDetail = HashMap();
                if (isPay == 0 || isPay == 2) {
                  DateTime now = DateTime.now();
                  DateTime date = new DateTime(now.year, now.month, now.day);
                  print(date.day.toString());
                  cardDetail.putIfAbsent("cardHolderName", () => cardName);
                  //  cardDetail.putIfAbsent("lastName", () => this._lastName.text);
                  cardDetail.putIfAbsent("cardNumber", () => cardNumber);
                  cardDetail.putIfAbsent("cardType", () => cardTypee);
                  cardDetail.putIfAbsent(
                      "expDate",
                      () =>
                          date.month.toString() +
                          date.year.toString().substring(2, 4));
                  cardDetail.putIfAbsent("payType", () => isPay);
                  paymentPageRedirect(cardDetail);
                } else {
                  if (validateAndSave()) {
                    var cardCode = "";
                    if (cardType == "MASTERCARD") {
                      cardCode = "MC";
                    } else if (cardType == "VISA") {
                      cardCode = "VI";
                    } else if (cardType == "AMEX") {
                      cardCode = "AX";
                    }
                    cardDetail.putIfAbsent(
                        "cardHolderName", () => this._cardName.text);
                    //  cardDetail.putIfAbsent("lastName", () => this._lastName.text);
                    cardDetail.putIfAbsent("cardNumber",
                        () => this._cardNo.text.replaceAll(" ", ""));
                    cardDetail.putIfAbsent("cardType", () => cardCode);
                    cardDetail.putIfAbsent(
                        "expDate",
                        () =>
                            this._expMonth.text +
                            this._expYear.text.substring(2, 4));
                    cardDetail.putIfAbsent("payType", () => isPay);
                    print(cardDetail);
                    paymentPageRedirect(cardDetail);
                  }
                }
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (_) => AsGuest2(
                //             widgetBookings: _buildChildren(context),
                //             widgetTerms: _termsAndConditions(context))));
              },
            )));
  }

  paymentPageRedirect(cardDetail) {
    if (isSavedCard) {
      updateUserDetails();
    }
    pushNewScreen(
      context,
      //  [TravellersRoomInput(refIds:roomRefType.map((e) => e.refId!).toList())],
      screen: AsGuest2(
        widgetTerms: TermsAndConditions(Strings.termsStr,roomDetails[0]),
        cardDetail: cardDetail,
        guestDetail: widget.guestDetails,
      ),
      withNavBar: false, // OPTIONAL VALUE. True by default.
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }


  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    final leftPadding = overAllWidth * 0.035;
    final topPadding = overAllHeight * 0.015;
    var boxHeight =
        overAllHeight * (AppUtility().isTablet(context) ? 0.06 : 0.055);
    final boxWidth = overAllWidth * 0.7;
    var borderRadius = fieldBorderRadius;
    var summaryToppadding = overAllHeight * 0.025;
    var saveCardToppadding = overAllHeight * 0.03;
    var nextButtonTopPadding = overAllHeight * 0.02;

    if (boxHeight < 40) {
      boxHeight = 50;
    }
    return Scaffold(
        backgroundColor: Uicolors.backgroundColor,
        appBar: _appBarData(context),
        body: StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            setSelectedRadio(int val) {
              setState(() {
                isPay = val;
              });
            }

            return Form(
                key: _formKey2,
                child: Padding(
                    padding: EdgeInsets.all(0),
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: leftPadding,
                              right: leftPadding,
                              top: summaryToppadding),
                          child: SummaryRoomList(roomDetails,"guest1",summaryCallBack: (selectedRoomList,actionName) async {
                            this.setState(() {
                              roomDetails = selectedRoomList;
                            });
    if(actionName != "remove") {
      int emptyRoomIndex = 0;
      for (int i = 0; i < roomDetails.length; i++) {
        if (roomDetails[i].roomDetail.isEmpty) {
          emptyRoomIndex = i;
        }
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("selectedIndex", emptyRoomIndex);
      String? loginType = prefs.getString("loginType");
      if(loginType == "guest"){
        Navigator.pop(context);
      }
      Navigator.pop(context);
    }
                          }),
                        ),
                        Padding(
                          child: Container(
                              alignment: Alignment.centerLeft,
                              height: boxHeight,
                              //   width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                border: border,
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                                color: isPay == 0 || isPay == 2
                                    ? Colors.grey.withOpacity(0.4)
                                    : Colors.white,
                              ),
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
                                    errorStyle: errorTextStyle,
                                    enabled: isPay == 0||isPay == 2
                                        ? false
                                        : isShowPreviousCard
                                            ? false
                                            : true,
                                    // contentPadding: EdgeInsets.only(bottom: 5),
                                  ),
                                  keyboardType: TextInputType.name,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(emojiRegexp),
                                    ),
                                  ],
                                  validator: (args) {
                                    if (args.toString().isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'Card Holder Name is required';
                                    }
                                  },
                                ),
                                padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.05,
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
                            //  width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              border: border,
                              borderRadius: BorderRadius.circular(borderRadius),
                              color: isPay == 0||isPay == 2
                                  ? Colors.grey.withOpacity(0.4)
                                  : Colors.white,
                            ),
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
                                      errorStyle: errorTextStyle,
                                      enabled: isPay == 0||isPay == 2
                                          ? false
                                          : isShowPreviousCard
                                              ? false
                                              : true,

                                      // contentPadding:
                                      //     EdgeInsets.only(bottom: 5),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                        RegExp(emojiRegexp),
                                      ),
                                      // WhitelistingTextInputFormatter.digitsOnly,
                                      new LengthLimitingTextInputFormatter(16),
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
                                Align(
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  decoration: BoxDecoration(
                                    border: border,
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                    color: isPay == 0||isPay == 2
                                        ? Colors.grey.withOpacity(0.4)
                                        : Colors.white,
                                  ),
                                  child: Padding(
                                    child: TextFormField(
                                      style: guestTextFieldStyle,
                                      autovalidateMode: checkValidate
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.onUserInteraction,
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
                                        errorStyle: errorTextStyle,
                                        enabled: isPay == 0||isPay == 2
                                            ? false
                                            : isShowPreviousCard
                                                ? false
                                                : true,

                                        // contentPadding:
                                        //     EdgeInsets.only(bottom: 5),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                          RegExp(emojiRegexp),
                                        ),
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
                                      left: MediaQuery.of(context).size.width *
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.465,
                                  decoration: BoxDecoration(
                                    border: border,
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                    color: isPay == 0||isPay == 2
                                        ? Colors.grey.withOpacity(0.4)
                                        : Colors.white,
                                  ),
                                  child: Padding(
                                    child: TextFormField(
                                      style: guestTextFieldStyle,
                                      autovalidateMode: checkValidate
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.onUserInteraction,
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
                                        errorStyle: errorTextStyle,
                                        enabled: isPay == 0||isPay == 2
                                            ? false
                                            : isShowPreviousCard
                                                ? false
                                                : true,
                                        // contentPadding:
                                        //     EdgeInsets.only(bottom: 5),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                          RegExp(emojiRegexp),
                                        ),
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
                                      left: MediaQuery.of(context).size.width *
                                          0.05,
                                    ),
                                  )),
                              padding: EdgeInsets.only(
                                  top: topPadding,
                                  left:
                                      MediaQuery.of(context).size.width * 0.50,
                                  right: leftPadding),
                            ),
                          ],
                        ),
                        if (!hidePayView)
                          Padding(
                            child: Container(
                              // height: MediaQuery.of(context).size.height * 0.16,
                              //  width: MediaQuery.of(context).size.width * 1,
                              padding: EdgeInsets.only(bottom: topPadding),
                              decoration: BoxDecoration(
                                boxShadow: boxShadow,
                                // borderRadius:
                                //     BorderRadius.circular(borderRadius),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  RadioListTile(
                                    contentPadding: EdgeInsets.only(left: 6,top:10),

                                    activeColor: Uicolors.buttonbg,
                                    // tileColor: Uicolors.desText,
                                    selectedTileColor: Uicolors.desText,
                                    value: 1,
                                    groupValue: isPay,
                                    subtitle: Text(Strings.payAtTheHotelDesc,
                                        style: creditCardTextStyle),
                                    title: Text(
                                      Strings.hotelStr,
                                      style: payNowStyle,
                                    ),
                                    onChanged: (val) {
                                      print(val.hashCode);
                                      setSelectedRadio(val.hashCode);
                                    },
                                  ),
                                  RadioListTile(
                                    contentPadding: EdgeInsets.only(left: 6),
                                    activeColor: Uicolors.buttonbg,
                                    //  tileColor: Uicolors.desText,
                                    selectedTileColor: Uicolors.desText,
                                    value: 0,
                                    groupValue: isPay,
                                    subtitle: Text(Strings.payNowDescription,
                                        style: creditCardTextStyle),
                                    title: Text(Strings.payStr,
                                        style: payNowStyle),
                                    onChanged: (val) {
                                      print(val.hashCode);
                                      setSelectedRadio(val.hashCode);
                                    },
                                  ),
                              if((deviceModel.contains("samsung")&&Platform.isAndroid)||Platform.isIOS)
                                  RadioListTile(
                                    contentPadding: EdgeInsets.only(left: 6),
                                    activeColor: Uicolors.buttonbg,
                                    //  tileColor: Uicolors.desText,
                                    selectedTileColor: Uicolors.desText,
                                    value: 2,
                                    groupValue: isPay,
                                    subtitle: Text("",
                                        style: creditCardTextStyle),
                                    title: Image.asset(
                                        Platform.isIOS?"assets/images/Apple_pay_icon.png":"assets/images/Samsung_pay_icon.png",
                                        width: textFieldIconSize40,
                                        height: textFieldIconSize40,
                                    alignment: Alignment.centerLeft),
                                    // Text(Platform.isIOS?"Apple Pay":"Samsung Pay",
                                    //     style: payNowStyle),
                                    onChanged: (val) {
                                      print(val.hashCode);
                                      setSelectedRadio(val.hashCode);
                                    },
                                  )
                                  // Container(
                                  //   alignment:Alignment.topLeft,
                                  //   padding: EdgeInsets.only(
                                  //       top: MediaQuery.of(context)
                                  //           .size
                                  //           .height *
                                  //           0.09 +
                                  //           2,
                                  //       left: MediaQuery.of(context).size.width * 0.08,
                                  //       right: 10),
                                  //   child: Text(Strings.notesStr,
                                  //       style: creditCardTextStyle,textAlign: TextAlign.left,),
                                  // )
                                ],
                              ),
                            ),
                            padding: EdgeInsets.only(
                                top: topPadding,
                                left: leftPadding,
                                right: leftPadding),
                          ),
                        if (widget.guestDetails.length == 0 && isPay == 1 )
                          Align(
                            child: Padding(
                              child: Row(
                                children: [
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Uicolors.desText,
                                    ),
                                    child: Transform.scale(
                                        scale: (AppUtility().isTablet(context)
                                            ? 1.8
                                            : 1.0),
                                        child: Checkbox(
                                          checkColor: Colors.white,
                                          activeColor: Uicolors.buttonbg,
                                          value: isUsePreviousCard
                                              ? isShowPreviousCard
                                              : isSavedCard,
                                          onChanged: (value) {
                                            setState(() {
                                              if (isUsePreviousCard) {
                                                isShowPreviousCard = value!;
                                                getUserDetails();
                                              } else {
                                                isSavedCard = value!;
                                              }
                                            });
                                          },
                                        )),
                                  ),
                                  Text(
                                    isUsePreviousCard
                                        ? Strings.savedCardStr
                                        : Strings.saveCardStr,
                                    style: descTextStyle,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.only(
                                  top: saveCardToppadding,
                                  left: leftPadding,
                                  right: leftPadding,
                                  bottom: saveCardToppadding),
                            ),
                            alignment: Alignment.topLeft,
                          ),
                          if (widget.guestDetails.length > 0 || isPay == 0 || isPay == 2)
                          Padding(
                            padding: EdgeInsets.only(top: saveCardToppadding),
                          ),
                        _nextButton(context),
                        Padding(
                          padding: EdgeInsets.only(
                              left: leftPadding, right: leftPadding),
                          child: TermsAndConditions(Strings.policyStr,roomDetails[0]),
                        )
                      ],
                    )));
          },
        ));
  }
}
