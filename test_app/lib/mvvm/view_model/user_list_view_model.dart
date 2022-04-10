import 'package:flutter/material.dart';
import 'package:test_app/mvvm/model/user_model.dart';
import 'package:test_app/mvvm/services/api_service.dart';

class ViewModel extends ChangeNotifier{
  List<UserModel> userList = [];
  bool? isSuccess;

  Future<void> fetchUsers() async{
    userList = await ApiService().getUserList();
    notifyListeners();
  }

  Future<void> addUsers(String name, String routine) async{
    isSuccess = await ApiService().addingUser(name, routine);
    notifyListeners();
  }

  Future<void> updateUsers(int id,String name, String routine) async{
    isSuccess = await ApiService().updateUser(id, name, routine);
    notifyListeners();
  }

  Future<void> deleteUsers(int id) async{
    isSuccess = await ApiService().deletingUser(id);
    notifyListeners();
  }

}
