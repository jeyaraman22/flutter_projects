// import 'package:flutter/material.dart';
// import 'package:g_sign_bloc/datalist/Hotelbloc/hotelstate.dart';
// import 'package:g_sign_bloc/datalist/demomodel.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:g_sign_bloc/datalist/Hotelbloc/hotelbloc.dart';
// import 'package:g_sign_bloc/datalist/hotel_provider.dart';
// import 'package:g_sign_bloc/datalist/modelclass.dart';
// import 'package:g_sign_bloc/datalist/Hotelbloc/hotelevent.dart';
//
// class ListingHotel extends StatefulWidget {
//   @override
//   _ListingHotelState createState() => _ListingHotelState();
// }
//
// class _ListingHotelState extends State<ListingHotel> {
//
//   final HotelBloc hotelbloc = HotelBloc(provider: HotelProvider());
//
//  static List<Hotellist> filterList =[];
//   @override
//   void initState() {
//     hotelbloc.add(FetchdisplayEvent());
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//         create: (_)=> hotelbloc,
//         child: BlocListener<HotelBloc,HotelState>(
//         listener: (context, state) {
//           if (state is FetchErrorState) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//               ),
//             );
//           }
//         },
//         child: BlocBuilder<HotelBloc,HotelState>(
//         builder: (context, state){
//           if(state is FetchLoadedState){
//             return displayhotellist(context, state.hotellist);
//           }
//           else{
//             return Center(child: CircularProgressIndicator());
//           }
//         }
//
//         ),
//
//         ),
//     );
//   }
//   Widget displayhotellist(BuildContext context, List<Hotellist> model){
//     filterList = model;
//     return ListView.builder(
//       //shrinkWrap: true,
//       itemCount: model.length,
//       itemBuilder: (BuildContext context,int index){
//         return Column(
//           children: [
//             Container(
//               child: Stack(
//                 alignment: AlignmentDirectional.bottomStart,
//                 children: [
//                   Container(
//                     height: 253,
//                     child: Image.network(model[index].module!.result!.images![0].image!.previewImage![2]
//                     ['normal']['url'],
//                      fit: BoxFit.cover,
//                     ),
//                   ),
//                   Container(
//                     height: 65,
//                     color: Colors.black38,
//                     alignment: Alignment.bottomLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 10.0,top: 4.0 ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(model[index].module!.result!.header!,
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w500,
//                                 letterSpacing: 0.5
//                             ),),
//                           SizedBox(height: 3.5),
//                           Text(model[index].module!.result!.headline!,
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 letterSpacing: 0.25),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//            SizedBox(height: 10)
//           ],
//         );
//
//       },
//     );
//   }
// }
//
