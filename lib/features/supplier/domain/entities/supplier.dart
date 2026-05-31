import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? contacto;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Supplier({
    required this.id,
    required this.nombre,
    this.telefono,
    this.email,
    this.direccion,
    this.contacto,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        telefono,
        email,
        direccion,
        contacto,
        activo,
        createdAt,
        updatedAt,
      ];
}
