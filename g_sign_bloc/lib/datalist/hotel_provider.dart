import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:g_sign_bloc/datalist/modelclass.dart';


class HotelProvider {
  List<Hotellist> filteredList=[];
  List<String?> hotelhead=[];
  Future gethotellist() async {
    List<Hotellist> listofHotels=[];
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent("renderPage", () => "/destinations");
    params.putIfAbsent("_locale", () => "en-gb");
    var response = await getRenderData(params, "/api/renders", null);
    if (response.statusCode == 200) {
     var result = json.decode(response.body);
     result["content"]["main"]["children"].forEach((destination) {
       if (destination["module"]["result"]["headlines"] == null) {
         listofHotels.add(Hotellist.fromJson(destination));
       }
     });
    } else {
      throw Exception();
    }
    filteredList= listofHotels;
    return  listofHotels;
  }

  Future<http.Response> getRenderData(dynamic queryParam,
      String path,
      dynamic header,) async {
    dynamic headerWithToken = {
      "Content-type": "application/json",
      "Accept": "*/*",
      //   'Authorization': 'Bearer $token',
      'Access-Control-Allow-Origin': "*",
    };
    var url = Uri.https("www.jazhotels.com", path, queryParam);
    print('urls:$url');
    return http.get(url, headers: header == null ? headerWithToken : header);
  }

}
