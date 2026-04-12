import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  final String message;
  final UsuarioModel? updatedUser;

  const ProfileSuccess({required this.message, this.updatedUser});
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});
}
