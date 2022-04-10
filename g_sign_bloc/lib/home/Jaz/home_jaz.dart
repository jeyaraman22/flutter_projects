import 'package:carousel_pro_nullsafety/carousel_pro_nullsafety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:g_sign_bloc/datalist/Hotelbloc/hotelstate.dart';
import 'package:g_sign_bloc/datalist/hotel_provider.dart';
import 'package:g_sign_bloc/datalist/listbloc/listbloc.dart';
import 'package:g_sign_bloc/datalist/listbloc/listevent.dart';
import 'package:g_sign_bloc/datalist/listbloc/liststate.dart';
import 'package:g_sign_bloc/home/Jaz/photogallery.dart';
import 'package:g_sign_bloc/datalist/Hotelbloc/hotelbloc.dart';
import 'package:g_sign_bloc/datalist/modelclass.dart';
import 'package:g_sign_bloc/constatnts/spaces.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_sign_bloc/datalist/Hotelbloc/hotelevent.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  final HotelBloc hotelbloc = HotelBloc(provider: HotelProvider());
  final listBloc listbloc = listBloc(provider: HotelProvider());
  List<Hotellist> filterList = [];
  @override
  void initState() {
    super.initState();
    hotelbloc.add(FetchdisplayEvent());
    listbloc.add(Filterlistfetchevent());
  }

  TextEditingController textcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            titleSpacing: 5.0,
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Container(
              height: 55,
              width: 120,
              child: Image.asset(
                'images/jazlogo.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Scrollbar(
          child: Padding(
            padding: Paddings.wholePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BlocProvider(
                  create: (_) => listbloc,
                  child: BlocListener<listBloc, listState>(
                    listener: (context, state) {
                      if (state is listErrorstate) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<listBloc, listState>(
                        builder: (context, state) {
                      if (state is FetchlistState) {
                        return filterHotellist(context, state.fetchList);
                      } else {
                        return Center(
                            child: CircularProgressIndicator(
                          color: Colors.white,
                        ));
                      }
                    }),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: BlocProvider(
                    create: (_) => hotelbloc,
                    child: BlocListener<HotelBloc, HotelState>(
                      listener: (context, state) {
                        if (state is FetchErrorState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                            ),
                          );
                        }
                      },
                      child: BlocBuilder<HotelBloc, HotelState>(
                          builder: (context, state) {
                        if (state is FetchLoadedState) {
                          return displayhotellist(context, state.hotellist);
                        } else {
                          return Center(
                              child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            color: Colors.black26,
                            strokeWidth: 3.0,
                          ));
                        }
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget filterHotellist(BuildContext context, List<Hotellist> listmodel) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: textcontroller,
        decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black12,
            size: 30,
          ),
          hintText: "What are you looking for?",
          hintStyle: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              color: Colors.black54),
          fillColor: Color(0xffDFEDEC),
          filled: true,
        ),
      ),
      getImmediateSuggestions: true,
      hideSuggestionsOnKeyboardHide: false,
      hideOnEmpty: false,
      suggestionsCallback: (pattern) {
        return listmodel
            .where(
              (item) => item.module!.result!.header!
                  .toString()
                  .toLowerCase()
                  .contains(pattern.toLowerCase()),
            )
            .toList();
      },
      itemBuilder: (context, Hotellist item) {
        return Container(
          child: ListTile(
            title: Text(item.module!.result!.header.toString()),
          ),
        );
      },
      onSuggestionSelected: (Hotellist value) {
        this.textcontroller.text = value.module!.result!.header!;
      },
    );
  }

  Widget displayhotellist(BuildContext context, List<Hotellist> model) {
    return ListView.builder(
      //shrinkWrap: true,
      itemCount: model.length,
      itemBuilder: (BuildContext context, int index) {
        int photoindex = 0;
        List<String> url = [];
        model[index].module!.result!.images!.forEach((element) {
          url.add(element.image!.previewImage![2]['normal']['url']);
        });
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GalleryView(
                      url: url,
                      photoindex: photoindex,
                    )));
          },
          child: Column(
            children: [
              Container(
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Container(
                      height: 253,
                      child: Carousel(
                          dotBgColor: Colors.transparent,
                          dotSize: 6.0,
                          dotColor: Colors.black12,
                          dotPosition: DotPosition.bottomRight,
                          dotVerticalPadding: -12,
                          dotHorizontalPadding: -12,
                          dotSpacing: 14,
                          autoplay: false,
                          images: model[index]
                              .module!
                              .result!
                              .images!
                              .map((e) => Image.network(
                                  e.image!.previewImage![2]['normal']['url']
                                      .toString(),
                                  fit: BoxFit.cover))
                              .toList(),
                          onImageTap: (currentindex) {
                            photoindex = currentindex;
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => GalleryView(
                                      url: url,
                                      photoindex: currentindex,
                                    )));
                          }),
                    ),
                    Container(
                      height: 65,
                      color: Colors.black38,
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model[index].module!.result!.header!,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5),
                            ),
                            SizedBox(height: 3.5),
                            Text(
                              model[index].module!.result!.headline!,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.25),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10)
            ],
          ),
        );
      },
    );
  }
}
