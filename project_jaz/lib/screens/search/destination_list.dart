import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:graphql_flutter_bloc/graphql_flutter_bloc.dart';
import 'package:jaz_app/bloc/destinations_bloc.dart';
import 'package:jaz_app/bloc/get_hotel_autocomplete_bloc.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/search/recent_searchPage.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/graphql_provider.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:textfield_search/textfield_search.dart';

class DestinationList extends StatefulWidget {
  final double width;
  final double height;
  final Function(String,String,Destinations$Query$Options$Destinations) destinationValue;
  final bool clearDestination;
  final TextEditingController typeAheadController;

  DestinationList(this.clearDestination, this.width, this.height,
      {required this.destinationValue,required this.typeAheadController});
  @override
  _DestinationListState createState() => _DestinationListState(typeAheadController);
}

class _DestinationListState extends State<DestinationList> {
  double width = 0.0;
  double height = 0.0;
  bool isClearDestination = false;
  late DestinationsBloc bloc;
  late GetHotelsAutocompleteBloc hotelBloc;
  late String? _chooseDestination;
  late String? _chooseDestinationValue;
  late final TextEditingController typeAheadController;
  _DestinationListState(TextEditingController typeAheadController){
    this.typeAheadController = typeAheadController;
  }

  void initState() {
    super.initState();
    width = widget.width;
    height = widget.height;
    isClearDestination = widget.clearDestination;
    _chooseDestination = null;
    _chooseDestinationValue = "";
    bloc = DestinationsBloc(client: client)
      ..run(
          variables:
              DestinationsArguments(bookingType: BookingTypeEnum.hotelOnly)
                  .toJson());
    hotelBloc = GetHotelsAutocompleteBloc(client: client);


  }

  @override
  void dispose() {
    hotelBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isClearDestination) {
      typeAheadController.value = TextEditingValue(
        text: "",
        selection: TextSelection.fromPosition(
          TextPosition(offset: 0),
        ),
      );
    }

    return BlocBuilder<DestinationsBloc, QueryState<Destinations$Query>>(
      bloc: bloc,
      builder: (_, state) {
        // if (state is! QueryStateRefetch) {
        //   _handleRefreshEnd();
        // }
        return state.when(
          initial: () => Container(),
          loading: (_) => TextFormField(
              style: textFieldStyle,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: Strings.whereDoYouString,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.fromLTRB(width, 0, width , 0),
                  hintStyle: placeHolderStyle)),
          error: (error, __) {
            print(error.toString());
            return TextFormField(
                style: textFieldStyle,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: Strings.whereDoYouString,
                    //  hintText: error.toString(),
                    isCollapsed: true,
                    contentPadding:
                        EdgeInsets.fromLTRB(width, 0, width , 0),
                    hintStyle: placeHolderStyle));
          },
          loaded: _destinationDisplayResult,
          refetch: _destinationDisplayResult,
          fetchMore: _destinationDisplayResult,
        );
      },
    );
  }

  Widget _destinationDisplayResult(
    Destinations$Query? data,
    QueryResult? result,
  ) {
    List<Destinations$Query$Options$Destinations> list = [];
    data!.options!.destinations!.forEach((country) {
      country.children!.forEach((city) {
        Destinations$Query$Options$Destinations dest =
            Destinations$Query$Options$Destinations();
        dest.label = '${city.label}, ${country.label}';
        dest.value = city.value;
        if(city.children!.length==1){
          dest.nodeCode = city.children![0].value;
        }
        list.add(dest);
        city.children!.forEach((e) {
          Destinations$Query$Options$Destinations dest =
              Destinations$Query$Options$Destinations();
          dest.label = '${e.label}, ${city.label}, ${country.label}';
          dest.value = e.value;
          dest.nodeCode = e.value;
          list.add(dest);
        });
      });
    });
    // if (GlobalState.destinationString!=null) {
    //     list.forEach((e) {
    //       if (GlobalState.destinationString.isNotEmpty && e.label!.contains(GlobalState.destinationString)) {
    //         this.typeAheadController.text = e.label.toString();
    //       // GlobalState.destinationValue = e.value.toString();
    //         _chooseDestinationValue = e.value.toString();
    //         GlobalState.destinationString = "";
    //       }
    //     });
    // }

    return TypeAheadFormField(
        noItemsFoundBuilder: (context)=> ListTile(title: Text(Strings.noOption,
          textAlign: TextAlign.center,style: placeHolderStyle,)),
        textFieldConfiguration: TextFieldConfiguration(
          // autofocus: true,
          controller: this.typeAheadController,
          style: textFieldStyle,
          onChanged: (content) {

            list.forEach((e) {
              if(!e.label!.contains(typeAheadController.text)){
               // print("content" + e.label.toString());
                // GlobalState.destinationValue = "";
            //    widget.destinationValue.call("","",Destinations$Query$Options$Destinations());
              }
            });
          },
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: Strings.whereDoYouString,
            contentPadding: EdgeInsets.fromLTRB(AppUtility().isTablet(context)? 70 :width , 0, width, 0),
            hintStyle: placeHolderStyle,
          )),
      itemBuilder:
          (context, Destinations$Query$Options$Destinations? itemData) {
        return
          Container(
          width: 500,
          child: ListTile(
            title: Text(
              itemData!.label ?? "No Options",
              style: textFieldStyle,
            ),
          ),
        );
      },
      onSuggestionSelected: (Destinations$Query$Options$Destinations items) {
        this.typeAheadController.text = items.label!;
        setState(() {
          isClearDestination = false;
        });
        widget.destinationValue.call(items.value.toString(),items.nodeCode.toString(),items);
      },
      suggestionsCallback: (pattern) {
        List<Destinations$Query$Options$Destinations> a = [];
        if (pattern.length > 0) {
          return list
              .where((element) =>
                  element.label!.toLowerCase().contains(pattern.toLowerCase()))
              .toList();
        } else {
          return a;
        }
      },
        transitionBuilder: (context, suggestionsBox, animationController) =>
            suggestionsBox,

    );
  }

  @override
  void didUpdateWidget(covariant DestinationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // print(isClearDestination);
    // print(oldWidget.clearDestination);

    if (isClearDestination != oldWidget.clearDestination) {
      setState(() {
        isClearDestination = widget.clearDestination;
      });
    }
  }
}
