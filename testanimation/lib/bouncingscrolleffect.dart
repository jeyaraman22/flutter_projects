import 'package:flutter/material.dart';

class BouncingscrollEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            /*bottom: PreferredSize(
              child: Container(),
              preferredSize: const Size(0, 20),
            ),*/
            stretch: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            flexibleSpace: Stack(
              children: [
                const Positioned(
                    child: Image(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        "https://images.pexels.com/photos/62389/pexels-photo-62389.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
                      ),
                    ),
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0),
                Positioned(
                  child: Container(
                    height: 30,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                            offset: Offset(0,2),
                          ),
                        ]
                      // borderRadius: const BorderRadius.vertical(
                      //   top: Radius.circular(50),
                      // ),
                    ),
                  ),
                  bottom: -1,
                  left: 10,
                  right: 10,
                ),
              ],
            ),
          ),
          /*SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.lightBlue[100 * (index + 1 % 9)],
                    child: Text('List Item $index'),
                  ),
                );
              },
            ),
          ),*/
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                color: Colors.white,
                height: 50,
                child: const Center(
                  child: Text("Flutter Animation"),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}