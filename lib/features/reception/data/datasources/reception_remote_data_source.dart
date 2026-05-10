import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/appointment/data/models/appointment_model.dart';
import 'package:mobile1_app/features/reception/data/models/reception_model.dart';

abstract class ReceptionRemoteDataSource {
  Future<ReceptionModel> createReception(Map<String, dynamic> data);
  Future<List<ReceptionModel>> getReceptions();
  Future<ReceptionModel> getReceptionDetail(String id);
  Future<List<AppointmentModel>> getCitasPendientes();
}

class ReceptionRemoteDataSourceImpl implements ReceptionRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const ReceptionRemoteDataSourceImpl({
    required this.apiClient,
    required this.sessionStorage,
  });

  String get _slug {
    final userData = sessionStorage.userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      final slug = tenant['slug'] as String?;
      if (slug != null && slug.isNotEmpty) return slug;
    }
    return EnvConfig.tenantSlug;
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final List<dynamic> rows;
    if (data is Map<String, dynamic> && data['results'] is List) {
      rows = data['results'] as List<dynamic>;
    } else if (data is List<dynamic>) {
      rows = data;
    } else {
      rows = const [];
    }
    return rows.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  @override
  Future<ReceptionModel> createReception(Map<String, dynamic> data) async {
    try {
      final response =
          await apiClient.post(ApiConstants.recepciones(_slug), data: data);
      return ReceptionModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ReceptionModel>> getReceptions() async {
    try {
      final response = await apiClient.get(ApiConstants.recepciones(_slug));
      return _parseList(response.data, ReceptionModel.fromJson);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ReceptionModel> getReceptionDetail(String id) async {
    try {
      final response =
          await apiClient.get(ApiConstants.recepcion(_slug, id));
      return ReceptionModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AppointmentModel>> getCitasPendientes() async {
    try {
      final response =
          await apiClient.get(ApiConstants.citasPendientesRecepcion(_slug));
      return _parseList(response.data, AppointmentModel.fromJson);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
