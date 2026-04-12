import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/profile/domain/usecases/change_password.dart';
import 'package:mobile1_app/features/profile/domain/usecases/update_notification_prefs.dart';
import 'package:mobile1_app/features/profile/domain/usecases/update_personal_info.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UpdatePersonalInfo _updatePersonalInfo;
  final ChangePassword _changePassword;
  final UpdateNotificationPrefs _updateNotificationPrefs;

  ProfileCubit({
    required UpdatePersonalInfo updatePersonalInfo,
    required ChangePassword changePassword,
    required UpdateNotificationPrefs updateNotificationPrefs,
  })  : _updatePersonalInfo = updatePersonalInfo,
        _changePassword = changePassword,
        _updateNotificationPrefs = updateNotificationPrefs,
        super(const ProfileInitial());

  Future<void> updateInfo({
    required String id,
    required String nombres,
    required String apellidos,
    String? telefono,
  }) async {
    emit(const ProfileLoading());
    final result = await _updatePersonalInfo(
      UpdatePersonalInfoParams(
        id: id,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
      ),
    );

    switch (result) {
      case Success(:final data):
        emit(ProfileSuccess(
          message: 'Información personal actualizada',
          updatedUser: data,
        ));
      case Err(:final failure):
        emit(ProfileError(message: failure.message));
    }
  }

  Future<void> changePassword({
    required String id,
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const ProfileLoading());
    final result = await _changePassword(
      ChangePasswordParams(
        id: id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );

    switch (result) {
      case Success():
        emit(const ProfileSuccess(
          message: 'Contraseña actualizada exitosamente',
        ));
      case Err(:final failure):
        emit(ProfileError(message: failure.message));
    }
  }

  Future<void> updatePreferences({
    required String id,
    required bool notiEmail,
    required bool notiPush,
  }) async {
    // Para las preferencias (switches), tal vez no queramos bloquear toda la UI con ProfileLoading.
    // Pero lo haremos simple.
    final result = await _updateNotificationPrefs(
      UpdateNotificationPrefsParams(
        id: id,
        notiEmail: notiEmail,
        notiPush: notiPush,
      ),
    );

    switch (result) {
      case Success(:final data):
        emit(ProfileSuccess(
          message: 'Preferencias actualizadas',
          updatedUser: data,
        ));
      case Err(:final failure):
        emit(ProfileError(message: failure.message));
    }
  }
}
