import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/invoices/data/models/invoice_model.dart';

abstract class InvoicesRemoteDataSource {
  Future<List<InvoiceModel>> getInvoices();
}

class InvoicesRemoteDataSourceImpl implements InvoicesRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const InvoicesRemoteDataSourceImpl({
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

  List<InvoiceModel> _parseList(dynamic data) {
    final List<dynamic> rows;
    if (data is Map<String, dynamic> && data['results'] is List) {
      rows = data['results'] as List<dynamic>;
    } else if (data is List<dynamic>) {
      rows = data;
    } else {
      rows = const [];
    }
    return rows
        .whereType<Map<String, dynamic>>()
        .map(InvoiceModel.fromJson)
        .toList();
  }

  @override
  Future<List<InvoiceModel>> getInvoices() async {
    try {
      final response = await apiClient.get(ApiConstants.listInvoices(_slug));
      return _parseList(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
