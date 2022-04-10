
class UserModel{
  String? firstName, lastName;
  int? id;
  String? image;

  UserModel({this.firstName,this.lastName,this.id,this.image});

   UserModel.fromJson(Map<String,dynamic> data){
      firstName= data['first_name'];
      lastName= data['last_name'];
      id= data['id'];
      image= data['avatar'];
  }

}