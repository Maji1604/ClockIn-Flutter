import 'package:equatable/equatable.dart';
import 'user_model.dart';

class LoginResponseModel extends Equatable {
  final String token;
  final UserModel user;

  const LoginResponseModel({required this.token, required this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponseModel(
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson()};
  }

  @override
  List<Object?> get props => [token, user];
}
