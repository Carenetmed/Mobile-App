import 'package:dio/dio.dart';

class CareNetHttpClient {
  CareNetHttpClient._();

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration uploadSendTimeout = Duration(seconds: 45);
  static const Duration uploadReceiveTimeout = Duration(seconds: 45);

  static Dio create() => Dio(
    BaseOptions(
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    ),
  );

  static Dio createUpload() => Dio(
    BaseOptions(
      connectTimeout: connectTimeout,
      sendTimeout: uploadSendTimeout,
      receiveTimeout: uploadReceiveTimeout,
    ),
  );
}
