import 'package:equatable/equatable.dart';

class CreateUserPayload extends Equatable {
  final String nombres;
  final String apellidos;
  final String email;
  final String password;
  final String? telefono;

  const CreateUserPayload({
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.password,
    this.telefono,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nombres': nombres,
      'apellidos': apellidos,
      'email': email,
      'password': password,
    };
    if ((telefono ?? '').trim().isNotEmpty) {
      data['telefono'] = telefono!.trim();
    }
    return data;
  }

  @override
  List<Object?> get props => [nombres, apellidos, email, password, telefono];
}

