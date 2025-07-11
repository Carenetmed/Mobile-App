class ApiResponse<T> {
  ApiResponse({
    this.responseSuccessful,
    this.responseMessage,
    this.responseBody,
  });

  bool? responseSuccessful;
  String? responseMessage;
  T? responseBody;
}
