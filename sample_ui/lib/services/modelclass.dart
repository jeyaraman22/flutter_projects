import 'dart:convert';

class HotelRoom {
  String? name;
  String? price;
  String? image1;
  String? image2;

  HotelRoom(
      {required this.name,
      required this.price,
      required this.image1,
      required this.image2});

  HotelRoom.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    image1 = json['image1'];
    image2 = json['image2'];
  }

 static Map<String, dynamic> toJson(HotelRoom data) => {
        'name': data.name,
        'price': data.price,
      };

  static String encode(List<HotelRoom> dataList) => json.encode(
        dataList.map<Map<String, dynamic>>((v) => HotelRoom.toJson(v)).toList(),
      );

  static List<HotelRoom> decode(String dataList) =>
      (json.decode(dataList) as List<dynamic>)
          .map<HotelRoom>((item) => HotelRoom.fromJson(item))
          .toList();
}
