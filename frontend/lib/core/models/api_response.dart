/// Standard wrapper for all API responses
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  /// Factory constructor to parse standard JSON response from the backend.
  /// [fromData] is a function that converts the JSON `data` payload into type [T].
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic)? fromData
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: fromData != null 
          ? (json.containsKey('data') && json['data'] != null 
              ? fromData(json['data']) 
              : fromData(json))
          : null,
    );
  }
}
