/// Generic wrapper for Django REST Framework paginated responses.
///
/// Handles the standard format:
/// ```json
/// { "count": 25, "next": "...?page=2", "previous": null, "results": [...] }
/// ```
///
/// Usage:
/// ```dart
/// final response = PaginatedResponse.fromJson(
///   json,
///   (item) => VehiculoModel.fromJson(item),
/// );
/// ```
class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  const PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
  bool get isEmpty => results.isEmpty;
}
