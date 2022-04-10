import 'dart:convert';

class AuthenticationDetail {
  final bool? isValid;
  final String? uid;
  final String? photoUrl;
  final String? email;
  final String? name;
  final String? phno;

  AuthenticationDetail({
    required this.isValid,
    this.uid,
    this.photoUrl,
    this.email,
    this.name,
    this.phno,
  });

  AuthenticationDetail copyWith({
    bool? isValid,
    String? uid,
    String? photoUrl,
    String? email,
    String? name,
    String? phno,
  }) {
    return AuthenticationDetail(
      isValid: isValid ?? this.isValid,
      uid: uid ?? this.uid,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
      name: name ?? this.name,
      phno: phno ?? this.phno,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'uid': uid,
      'photoUrl': photoUrl,
      'email': email,
      'name': name,
      'phno': phno,
    };
  }

  factory AuthenticationDetail.fromMap(Map<String, dynamic>? map) {
    return AuthenticationDetail(
      isValid: map?['isValid'],
      uid: map?['uid'],
      photoUrl: map?['photoUrl'],
      email: map?['email'],
      name: map?['name'],
      phno: map?['phno'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthenticationDetail.fromJson(String source) =>
      AuthenticationDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AuthenticationDetail(isValid: $isValid, uid: $uid, photoUrl: $photoUrl, email: $email, name: $name, phno: $phno)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AuthenticationDetail &&
        o.isValid == isValid &&
        o.uid == uid &&
        o.photoUrl == photoUrl &&
        o.email == email &&
        o.name == name &&
        o.phno == phno;
  }

  @override
  int get hashCode {
    return isValid.hashCode ^
        uid.hashCode ^
        photoUrl.hashCode ^
        email.hashCode ^
        name.hashCode^
        phno.hashCode;
  }
}
