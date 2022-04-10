class apiData {
  int? id;
  String? email;
  String? firstName;
  String? lastName;
  String? photoUrl;

  apiData(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.photoUrl});

  apiData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    photoUrl = json['avatar'];
  }
}
