import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test_app/mvvm/model/user_model.dart';
import 'package:test_app/mvvm/services/constant.dart';

class ApiService {

  Future<List<UserModel>> getUserList() async {
    final response = await http.get(Uri.parse(ApiStrings.baseUrl+ApiStrings.fetchUrl));
    print("statuscode------${response.statusCode}");
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final data = result['data'];
      return data.map<UserModel>((users) => UserModel.fromJson(users)).toList();
    }
    else {
      throw ApiStrings.errorFetch;
    }
  }

  Future<bool> addingUser(String name, String routine) async {
    var postData = {"name":name,"job":routine};
    final response = await http.post(Uri.parse(ApiStrings.baseUrl+ApiStrings.endUrl),body: jsonEncode(postData));
    print("statuscode------${response.statusCode}");
    if (response.statusCode == 201) {
      return true;
    }
    else {
      //throw ApiStrings.errorAdd;
      return false;
    }
  }

  Future<bool> updateUser(int id,String name, String routine) async {
    final response = await http.put(Uri.parse(ApiStrings.baseUrl+ApiStrings.endUrl+"/$id"));
    print("Updatestatuscode------${response.statusCode}");
    if (response.statusCode == 200) {
      return true;
    }
    else {
      throw ApiStrings.errorUpdate;
    }
  }

  Future<bool> deletingUser(int id) async {
    final response = await http.delete(Uri.parse(ApiStrings.baseUrl+ApiStrings.endUrl+"/$id"));
    print("Deletestatuscode------${response.statusCode}");
    if (response.statusCode == 204) {
      return true;
    }
    else {
      throw ApiStrings.errorDelete;
    }
  }

}