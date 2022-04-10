import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/widgets/appbar.dart';
import 'package:jaz_app/widgets/member_list.dart';

class Booking extends StatefulWidget {
  final Function(String) onBack;

  Booking({required this.onBack});

  _Booking createState() => _Booking();
}

class _Booking extends State<Booking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        child: ListView.builder(
            itemCount: 1,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return MemberListScreen(onBack: widget.onBack,);
            }),
      ),
    );
  }
}



// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graphql_flutter_bloc/graphql_flutter_bloc.dart';
// import 'package:jaz_app/bloc/get_favorites_bloc.dart';
// import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
// import 'package:jaz_app/utils/colors.dart' as Uicolors;
// import 'package:jaz_app/utils/strings.dart';
// import 'package:jaz_app/graphql_provider.dart';
// import 'package:graphql/client.dart';
// import 'package:jaz_app/bloc/global_types_bloc.dart';
// import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
//
// class Offers extends StatefulWidget
// {
//   @override
//   _OfferState createState() => _OfferState();
// }
//
// class _OfferState extends State<Offers>
// {
//   late GetFavoritesBloc bloc;
//   void initState() {
//     super.initState();
//     //getCookie();
//     bloc = GetFavoritesBloc(client: client)
//       ..run();
//   }
//
//   // Future<String> getCookie() async {
//   //   Map<String, String> cookie = await Requests.getStoredCookies(
//   //       Requests.getHostname(uri));
//   //   try {
//   //     return cookie.keys.first + "=" + cookie.values.first;
//   //   } catch (e) {
//   //     print(e);
//   //     return '';
//   //   }
//   // }
//
//   Widget _displayResult(
//       FavoritesInfo$Query? data,
//       QueryResult? result,
//       ) {
//     if (data == null) {
//       return Container();
//     }
//     // print(data.options!.globalTypesStatic!.length);
//     //  print(data.options!.globalTypesStatic!);
//     final itemCount = data.favorites!.count;
//     if (itemCount == 0) {
//       return ListView(children: [
//         Row(
//           children: <Widget>[
//             Icon(Icons.inbox),
//             SizedBox(width: 8),
//             Text('No data'),
//           ],
//         )
//       ]
//       );
//     } else {
//       return ListView.separated(
//         separatorBuilder: (_, __) => SizedBox(
//           height: 8.0,
//         ),
//         key: PageStorageKey('reports'),
//         itemCount: itemCount!.toInt(),
//         itemBuilder: (BuildContext context, int index) {
//           // if (bloc.shouldFetchMore(index, 5)) {
//           //   bloc.fetchMore(limit: 25, offset: itemCount);
//           // }
//           final amentitiesList = data.favoriteIds![index];
//           //  print(amentitiesList.label);
//           Widget tile = ListTile(
//             title: Text(amentitiesList.toString()),
//           );
//           //  final isLast = index == data..length - 1;
//           if (bloc.isFetchingMore) {
//             tile = Column(
//               children: [
//                 tile,
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: CircularProgressIndicator(),
//                 ),
//               ],
//             );
//           }
//
//           return tile;
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('BLOC query'),
//       ),
//       body: Container(
//         //   onRefresh: () async => _handleRefreshStart(bloc),
//         child: BlocBuilder<GetFavoritesBloc,
//             QueryState<FavoritesInfo$Query>>(
//           bloc: bloc,
//           builder: (_, state) {
//             // if (state is! QueryStateRefetch) {
//             //   _handleRefreshEnd();
//             // }
//
//             return state.when(
//               initial: () => Container(),
//               loading: (_) => Center(child: CircularProgressIndicator()),
//               error: (error, __) => ListView(children: [
//                 Text(
//                   parseOperationException(error),
//                   style: TextStyle(color: Theme.of(context).errorColor),
//                 )
//               ]),
//               loaded: _displayResult,
//               refetch: _displayResult,
//               fetchMore: _displayResult,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }