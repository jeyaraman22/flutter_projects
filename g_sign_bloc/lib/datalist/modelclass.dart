
class Hotellist{
   Module? module;
   Hotellist({this.module});

   Hotellist.fromJson(Map<String, dynamic> json) {
      module = (json['module'] != null ? Module.fromJson(json['module']) : null)!;

   }

   Map<String, dynamic> toJson() {
      final Map<String, dynamic> data =  Map<String, dynamic>();
      if (module != null) {
         data['module'] = module!.toJson();
      }
      return data;
   }

}

class Module {
   Result? result;

   Module({this.result});

   Module.fromJson(Map<String, dynamic> json) {
      result= (json['result'] != null ? Result.fromJson(json['result']) : null)!;
   }

   Map<String, dynamic> toJson() {
      final Map<String, dynamic> data =  Map<String, dynamic>();
       data['result'] = result!.toJson();
       return data;
   }
}

class Result {
   String? headline;
   String? header;
   List<Images>? images;

   Result({this.headline, this.header});

   Result.fromJson(Map<String, dynamic> json) {
      header= json['header'];
      headline = json['headline'];
      images =  <Images>[];
      json['images'].forEach((v) { images!.add( Images.fromJson(v)); });


   }

   Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = Map<String, dynamic>();
      data['headline'] = headline;
      data['header'] = header;
      if (images != null) {
         data['images'] = images!.map((v) => v.toJson()).toList();
      }
      return data;
   }
}

class Images{
   Img? image;

   Images({this.image});

   Images.fromJson(Map<String, dynamic> json){
      image=  (json['image'] != null ?  Img.fromJson(json['image']) : null)!;
   }

   Map<String, dynamic> toJson() {
      final Map<String, dynamic> data =  Map<String, dynamic>();
       data['image'] = image!.toJson();
      return data;
   }

}

class Img{
   String? url;
  List? previewImage;

   Img({this.url,this.previewImage});

   Img.fromJson(Map<String, dynamic> json){
   url= json['url'];
   previewImage= json['proxy_images'];

   }

   Map<String, dynamic> toJson(){
      final Map<String, dynamic> data= Map<String, dynamic>();
      data['url']= url;
     data['proxy_images']= previewImage;
      return data;
   }
}

// class proxyImage{
//    normalClass? normal;
//
//    proxyImage({this.normal});
//
//    proxyImage.fromJson(Map<String, dynamic> json){
//       normal=(json['normal'] !=null? normalClass.fromJson(json['normal']):null)!;
//    }
//
//    Map<String, dynamic> toJson(){
//       final Map<String, dynamic> data= Map<String, dynamic>();
//       data['normal']= normal;
//       return data;
//    }
// }
//
// class normalClass{
//
//    String? phoneUrl;
//
//    normalClass({this.phoneUrl});
//
//    normalClass.fromJson(Map<String, dynamic> json){
//       phoneUrl=json['url'];
//       print("TTTTT:::$phoneUrl");
//    }
//
//    Map<String, dynamic> toJson() {
//       final Map<String, dynamic> data = Map<String, dynamic>();
//       data['url']= phoneUrl;
//       return data;
//    }
// }


// class Content {
//
//    Main? main;
//
//    Content({this.main});
//
//    Content.fromJson(Map<String, dynamic> json) {
//       main = json['main'] != null ?  Main.fromJson(json['main']) : null;
//    }
//
//    Map<String, dynamic> toJson() {
//       final Map<String, dynamic> data =  Map<String, dynamic>();
//       if (main != null) {
//          data['main'] = main!.toJson();
//       }
//       return data;
//    }
// }
//
// class Main {
//    List<Children>? children;
//
//    Main({this.children});
//
//    Main.fromJson(Map<String, dynamic> json) {
//       if (json['children'] != null) {
//          children =  <Children>[];
//          json['children'].forEach((v) { children!.add( Children.fromJson(v)); });
//       }
//    }
//
//    Map<String, dynamic> toJson() {
//       final Map<String, dynamic> data =  Map<String, dynamic>();
//       if (children != null) {
//          data['children'] = children!.map((v) => v.toJson()).toList();
//       }
//       return data;
//    }
// }
//
// class Children {
//
//    Module? module;
//
//    Children({this.module});
//
//    Children.fromJson(Map<String, dynamic> json) {
//       module = (json['module'] != null ? Module.fromJson(json['module']) : null)!;
//    }
//
//    Map<String, dynamic> toJson() {
//       final Map<String, dynamic> data =  Map<String, dynamic>();
//       if (module != null) {
//          data['module'] = module!.toJson();
//       }
//       return data;
//    }
// }