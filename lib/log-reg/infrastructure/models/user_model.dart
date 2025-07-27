import 'package:flutter_application_2/log-reg/domain/entities/user_entitie.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.email,
    required super.password,
    super.username,
    super.idCompany
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'idCompany': idCompany
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      username: json['username'],
      password: json['password'],
      idCompany: json['idCompany'], 
    );
  }
}
