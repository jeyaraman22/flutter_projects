import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:graphql_flutter_bloc/graphql_flutter_bloc.dart';
import 'package:jaz_app/bloc/destinations_bloc.dart';
import 'package:jaz_app/bloc/get_hotel_autocomplete_bloc.dart';
import 'package:jaz_app/bloc/global_types_bloc.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/graphql_provider.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/utils/fontText.dart';

class ThemeList extends StatefulWidget {
  final double width;
  final double height;
  final Function(String) themeValue;
  final bool clearTheme;
  ThemeList(this.clearTheme,this.width,this.height,{required this.themeValue});
  @override
  _ThemeListState createState() => _ThemeListState();
}

class _ThemeListState extends State<ThemeList> {
  double width=0.0;
  double height = 0.0;
  bool isClearTheme = false;
  late GlobalTypesBloc bloc;
  final TextEditingController _typeAheadController = TextEditingController();
  late String? _chooseTheme;
  late String? _chooseThemeValue;
  int index = 1;
  void initState() {
    super.initState();
    isClearTheme = widget.clearTheme;
    _chooseTheme = null;
    width = widget.width;
    height=widget.height;
    bloc = GlobalTypesBloc(client: client)..run();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isClearTheme) {
      _typeAheadController.value = TextEditingValue(
        text: "",
        selection: TextSelection.fromPosition(
          TextPosition(offset: 0),
        ),
      );
    }
    return Container(
      child: BlocBuilder<GlobalTypesBloc, QueryState<GlobalTypes$Query>>(
        bloc: bloc,
        builder: (_, state) {
          return state.when(
            initial: () => Container(),
            loading: (_) => TextFormField(
                style: textFieldStyle,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Theme',
                  contentPadding: EdgeInsets.fromLTRB(width, 0,width+20,0),

                  hintStyle: placeHolderStyle,
                )),
            error: (error, __) {
              print(error.toString());
              return TextFormField(
                style: textFieldStyle,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Theme',
                  contentPadding: EdgeInsets.fromLTRB(width, 0,width+20,0),

                  hintStyle: placeHolderStyle,
                ));},
            loaded: _themeDisplayResult,
            refetch: _themeDisplayResult,
            fetchMore: _themeDisplayResult,
          );
        },
      ),
    );
  }

  Widget _themeDisplayResult(
    GlobalTypes$Query? data,
    QueryResult? result,
  ) {
    return
        // Row(children: <Widget>[
        // Container(
        //     width: MediaQuery.of(context).size.width * 0.56,
        TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
          controller: this._typeAheadController,
          style: textFieldStyle,
          onChanged: (content) {
            print("content"+content);
            widget.themeValue.call("");
          },
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: 'Theme',
            contentPadding: EdgeInsets.fromLTRB(width, 0,width+20, 0),
            hintStyle: placeHolderStyle,
          )),
      itemBuilder:
          (context, GlobalTypes$Query$Options$GlobalTypesStatic? itemData) {
        return ListTile(
          // leading: Icon(),
          title: Text(
            itemData!.label ?? "No Options",
            style: textFieldStyle,
          ),
        );
      },
      onSuggestionSelected:
          (GlobalTypes$Query$Options$GlobalTypesStatic items) {
        this._typeAheadController.text = items.label!;
        setState(() {
          isClearTheme = false;
        });
        widget.themeValue.call(items.value.toString());
      },
      suggestionsCallback: (pattern) {
        if (pattern.length > 0) {
          return data!.options!.globalTypesStatic!
              .where((element) =>
                  element.label!.toLowerCase().contains(pattern.toLowerCase()))
              .toList();
        } else {
          return data!.options!.globalTypesStatic!;
        }
      },
            transitionBuilder: (context, suggestionsBox, animationController) =>
            suggestionsBox
    );
  }

  @override
  void didUpdateWidget(covariant ThemeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isClearTheme != oldWidget.clearTheme) {
      setState(() {
        isClearTheme = widget.clearTheme;
      });
    }
  }
}
