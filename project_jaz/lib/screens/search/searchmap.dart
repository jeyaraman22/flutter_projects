import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/product_overview/mappage.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/strings.dart';

class SearchMap extends StatefulWidget {
  final List<ProductsQuery$Query$Products$PackageProducts> list;
  final String pageName;

  SearchMap(this.list, this.pageName);

  @override
  _SearchMapState createState() => _SearchMapState();
}

class _SearchMapState extends State<SearchMap> {
  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidht = MediaQuery.of(context).size.width;
    var buttonLeftPadding = overAllWidht * 0.28;
    var buttonContentLeftPadding = overAllWidht * 0.04;

    return Scaffold(
        body: Stack(
          children: [
            MapPage(widget.list, widget.pageName, overAllHeight * 0.30),
            Positioned(
                top: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
                child: Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 45,
                      padding: EdgeInsets.only(
                          top: (AppUtility().isTablet(context) ? 0 : 0),
                          bottom: (AppUtility().isTablet(context) ? 0 : 0)),
                      /*margin: EdgeInsets.only(right: buttonContentLeftPadding,
                        top: (AppUtility().isTablet(context)
                            ? buttonContentLeftPadding
                            : 0)),*/
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              (AppUtility().isTablet(context) ? 25 : 25)),
                          color: Uicolors.buttonbg),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: textFieldIconSize,
                            ),
                            margin: EdgeInsets.only(
                                left: (AppUtility().isTablet(context) ? 20 : 10),
                                right: (AppUtility().isTablet(context) ? 10 : 5)),
                          ),
                          Container(
                            child: Text(
                              Strings.closeMap,
                              style: closeMapButtonStyle,
                            ),
                            padding:
                            EdgeInsets.only(right: buttonContentLeftPadding),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ));
  }
}
