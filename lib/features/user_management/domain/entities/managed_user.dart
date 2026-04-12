import 'package:equatable/equatable.dart';

class ManagedUser extends Equatable {
  final String id;
  final String email;
  final String nombres;
  final String apellidos;
  final String? telefono;
  final String rolId;
  final String rolNombre;
  final bool activo;

  const ManagedUser({
    required this.id,
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.rolId,
    required this.rolNombre,
    required this.activo,
  });

  String get fullName => '$nombres $apellidos'.trim();

  @override
  List<Object?> get props => [
        id,
        email,
        nombres,
        apellidos,
        telefono,
        rolId,
        rolNombre,
        activo,
      ];
}

