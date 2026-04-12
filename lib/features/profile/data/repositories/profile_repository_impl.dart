import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';

import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<UsuarioModel>> updatePersonalInfo({
    required String id,
    required String nombres,
    required String apellidos,
    required String? telefono,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final updatedUser = await remoteDataSource.updatePersonalInfo(
        id: id,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
      );
      return Success(updatedUser);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String id,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      await remoteDataSource.changePassword(
        id: id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<UsuarioModel>> updateNotificationPrefs({
    required String id,
    required bool notiEmail,
    required bool notiPush,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final updatedUser = await remoteDataSource.updateNotificationPrefs(
        id: id,
        notiEmail: notiEmail,
        notiPush: notiPush,
      );
      return Success(updatedUser);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
