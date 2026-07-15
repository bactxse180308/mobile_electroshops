double parseNum(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

class ApiWrapper<T> {
  final int status;
  final String message;
  final T? data;

  const ApiWrapper({required this.status, required this.message, this.data});

  factory ApiWrapper.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromData,
  ) {
    return ApiWrapper(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? fromData(json['data']) : null,
    );
  }
}

class ApiPage<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int number; // current page (0-based)
  final bool last;

  const ApiPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.last,
  });

  factory ApiPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawContent = json['content'] as List<dynamic>? ?? [];

    int parseCount(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return ApiPage(
      content:
          rawContent.map((e) => fromItem(e as Map<String, dynamic>)).toList(),
      totalElements: parseCount(json['totalElements']),
      totalPages: parseCount(json['totalPages'] ?? 1),
      number: parseCount(json['number'] ?? 0),
      last: json['last'] as bool? ?? true,
    );
  }
}
