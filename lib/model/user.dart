import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role = '',
  });

  @override
  // TODO: implement props
  List<Object?> get props => [id, email, name, role,];
}