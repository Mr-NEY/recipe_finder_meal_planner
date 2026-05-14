class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() {
    final suffix = statusCode == null ? '' : ' ($statusCode)';
    return '$message$suffix';
  }
}
