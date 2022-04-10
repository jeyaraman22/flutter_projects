import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryView extends StatefulWidget {
   List<String> url;
   final int photoindex;
   PageController pageController;
   GalleryView({required this.url, this.photoindex=0}):
         pageController = PageController();

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
 late int galleryindex = widget.photoindex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: ()=> Navigator.of(context).pop(),
              icon: Icon(Icons.close))
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.url.length,
            pageController: widget.pageController,
            scrollDirection: Axis.horizontal,
            builder:(context, index){
            return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.url[galleryindex]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.contained*3,
            );
            },
            onPageChanged: (index)=> setState(()=>this.galleryindex = widget.photoindex),
        ),
          Container(
            child: Text('${galleryindex+1}/${widget.url.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
            ),
          )
      ],
      ),
    );
  }
}
