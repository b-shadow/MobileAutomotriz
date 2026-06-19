/// Result model returned by the AI reports endpoint.
///
/// Contains the tabular data, an optional Plotly figure description,
/// and the generated SQL for debugging.
class IaReportResult {
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic>? plotlyFig;
  final String? sql;

  IaReportResult({
    required this.data,
    this.plotlyFig,
    this.sql,
  });

  factory IaReportResult.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<Map<String, dynamic>> parsedData;

    if (rawData is List) {
      parsedData = rawData
          .map((e) => e is Map<String, dynamic>
              ? e
              : <String, dynamic>{})
          .toList();
    } else {
      parsedData = [];
    }

    return IaReportResult(
      data: parsedData,
      plotlyFig: json['plotly_fig'] is Map<String, dynamic>
          ? json['plotly_fig'] as Map<String, dynamic>
          : null,
      sql: json['sql'] as String?,
    );
  }

  bool get hasData => data.isNotEmpty;
  bool get hasChart => plotlyFig != null;
}
