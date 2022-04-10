import 'package:flutter/material.dart';

class collapse extends StatefulWidget {

  @override
  collapseState createState() => new collapseState();
}
class collapseState extends State<collapse> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          physics: const BouncingScrollPhysics(parent: const AlwaysScrollableScrollPhysics()),
          headerSliverBuilder: (BuildContext c, bool f) => <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 200.0,
              stretch: true,
              stretchTriggerOffset: 1.0,
              title: const Text('SliverAppBar stretch'),
              flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  stretchModes: [StretchMode.blurBackground, StretchMode.zoomBackground],
                  background: Image.asset(
                    'assets/take_down.jpg',
                    fit: BoxFit.cover,
                  )),
            )
          ],
          // IMPORTANT: allow app bar to stretch
         // stretchHeaderSlivers: true,
          body: Column(
            children: [
              TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Tab 1'),
                  Tab(text: 'Tab 2'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                   Text("sjdhfgdj")
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorBox extends StatelessWidget {
  final Color color;

  const ColorBox(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      color: color,
    );
  }


  Widget _myListView(int index) => ListView.builder(
    // Stores tabview state
    key: PageStorageKey<String>('Tab$index'),
    physics: const BouncingScrollPhysics(parent: const AlwaysScrollableScrollPhysics()),
    itemBuilder: (BuildContext c, int i) {
      return Container(
        alignment: Alignment.center,
        color: i % 2 == 0 ? Colors.black12 : null,
        height: 60.0,
        child: Text('Tab$index: ListView$i'),
      );
    },
    itemCount: 50,
  );
}
