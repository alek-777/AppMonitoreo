class UserEntity {
  final String email;
  final String? username;
  final String password;
  final int? idCompany;

  UserEntity({
    required this.email,
    this.username,
    required this.password,
    this.idCompany,
  });
}
