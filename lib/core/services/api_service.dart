import 'dart:io';

import 'package:app_t/core/constants/url_path.dart';
import 'package:app_t/core/model/api_model.dart';
import 'package:dio/dio.dart';

class ApiService {
  static ApiService? _apiService;

  ApiService._();

  static ApiService? get instance {
    _apiService ??= ApiService._();
    return _apiService;
  }

  Dio dio = Dio();

  Future<ApiResponse<T>> postRequestHandler<T>(
    String url,
    dynamic body, {
    T Function(dynamic)? transform,
    Options? options,
    String? accessToken,
    bool interchange = false,
  }) async {
    transform ??= (dynamic r) => r.body as T;
    final ApiResponse<T> apiResponse = ApiResponse<T>();

    try {
      // Set headers locally for this request
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Cookie': 'auth=$accessToken',
      };

      final requestOptions =
          options?.copyWith(headers: headers) ?? Options(headers: headers);

      /*dio.options.headers['Authorization'] = 'Bearer $accessToken';
      dio.options.headers['Cookie'] = 'auth=$accessToken';*/

      final res = await dio.post(
        "$baseUrl$url",
        data: body,
        options: requestOptions,
      );
      final dynamic data = res.data;

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (data.isEmpty == true) {
          apiResponse.responseSuccessful = data['success'] ?? true;
          apiResponse.responseMessage = 'Request completed';
        } else {
          apiResponse.responseSuccessful = data['success'] ?? true;
          if (interchange) {
            apiResponse.responseMessage = 'Request completed';
            apiResponse.responseBody = transform(data['responseMessage']);
          } else {
            apiResponse.responseMessage =
                data['responseMessage'] ?? 'Request completed';

            apiResponse.responseBody = transform(data['responseBody']);
          }
        }
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
      }

      if (apiResponse.responseMessage?.contains(
            "Session expired, log in again",
          ) ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      // //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";
    }
    return apiResponse;
  }

  Future<ApiResponse> postRequest(
    String url,
    dynamic body, {
    Options? options,
    String? accessToken,
  }) async {
    final ApiResponse apiResponse = ApiResponse();

    try {
      // Set headers locally for this request
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Cookie': 'auth=$accessToken',
      };

      final requestOptions =
          options?.copyWith(headers: headers) ?? Options(headers: headers);

      /* dio.options.headers['Authorization'] = 'Bearer $accessToken';
      dio.options.headers['Cookie'] = 'auth=$accessToken';
*/
      final res = await dio.post(
        "$baseUrl$url",
        data: body,
        options: requestOptions,
      );
      final dynamic data = res.data;

      if (res.statusCode == 200 || res.statusCode == 201) {
        apiResponse.responseSuccessful = data['success'] ?? true;
        apiResponse.responseMessage =
            data['responseMessage'] ?? 'Request completed';
        apiResponse.responseBody = data['responseBody'] ?? 'No Body';
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
        apiResponse.responseBody = data['responseBody'] ?? 'No Body';
      }

      if (apiResponse.responseMessage?.contains(
            "Session expired, log in again",
          ) ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      // //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";
    }
    return apiResponse;
  }

  Future<ApiResponse<T>> getRequestHandler<T>(
    String url, {
    T Function(dynamic)? transform,
    Options? options,
    String? accessToken,
  }) async {
    transform ??= (dynamic r) => r as T;
    final ApiResponse<T> apiResponse = ApiResponse<T>();

    try {
      // Set headers locally for this request
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Cookie': 'auth=$accessToken',
      };

      final requestOptions =
          options?.copyWith(headers: headers) ?? Options(headers: headers);

      /*dio.options.headers['Authorization'] = 'Bearer $accessToken';
      dio.options.headers['Cookie'] = 'auth=$accessToken';*/

      final res = await dio.get("$baseUrl$url", options: requestOptions);
      final dynamic data = res.data;

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (data.isEmpty == true) {
          apiResponse.responseSuccessful = data['success'] ?? true;
          apiResponse.responseMessage = 'Request completed';
        } else {
          apiResponse.responseSuccessful = data['success'] ?? true;
          apiResponse.responseMessage =
              data['responseMessage'] ?? 'Request completed';
          apiResponse.responseBody = transform(data['responseBody']);
        }
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            data['responseMessage'] ?? 'Error encountered';
      }

      if (apiResponse.responseMessage?.contains(
            "Session expired, log in again",
          ) ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";
    }
    return apiResponse;
  }

  Future<ApiResponse> getRequest(
    String url, {
    Options? options,
    String? accessToken,
  }) async {
    final ApiResponse apiResponse = ApiResponse();

    try {
      // Set headers locally for this request
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Cookie': 'auth=$accessToken',
      };

      final requestOptions =
          options?.copyWith(headers: headers) ?? Options(headers: headers);

      /*dio.options.headers['Authorization'] = 'Bearer $accessToken';
      dio.options.headers['Cookie'] = 'auth=$accessToken';*/

      final res = await dio.get("$baseUrl$url", options: requestOptions);
      final dynamic data = res.data;

      if (res.statusCode == 200 || res.statusCode == 201) {
        apiResponse.responseSuccessful = data['success'] ?? true;
        apiResponse.responseMessage = data['responseMessage'] ?? '';
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
      }

      if (apiResponse.responseMessage?.contains(
            "Session expired, log in again",
          ) ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";
    }
    return apiResponse;
  }

  Future<ApiResponse> paymentRequest(
    String url,
    dynamic body, {
    Options? options,
    String? accessToken,
  }) async {
    final ApiResponse apiResponse = ApiResponse();

    try {
      // Set headers locally for this request
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Cookie': 'auth=$accessToken',
      };

      final requestOptions =
          options?.copyWith(headers: headers) ?? Options(headers: headers);

      /*dio.options.headers['Authorization'] = 'Bearer $accessToken';
      dio.options.headers['Cookie'] = 'auth=$accessToken';*/

      final res = await dio.post(
        "$baseUrl$url",
        data: body,
        options: requestOptions,
      );
      final dynamic data = res.data;

      if (res.statusCode == 200 || res.statusCode == 201) {
        apiResponse.responseSuccessful = data['success'] ?? true;
        apiResponse.responseMessage = data['responseMessage'] ?? '';
        apiResponse.responseBody = data['url'] ?? '';
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
      }

      if (apiResponse.responseMessage?.contains(
            "Session expired, log in again",
          ) ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";
    }
    return apiResponse;
  }

  Future<ApiResponse> patchRequest(
    String url,
    dynamic body, {
    Options? options,
    String? accessToken,
  }) async {
    final ApiResponse apiResponse = ApiResponse();

    try {
      // Set headers locally for this request
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Cookie': 'auth=$accessToken',
      };

      final requestOptions =
          options?.copyWith(headers: headers) ?? Options(headers: headers);

      /*dio.options.headers['Authorization'] = 'Bearer $accessToken';
      dio.options.headers['Cookie'] = 'auth=$accessToken';*/

      final res = await dio.patch(
        "$baseUrl$url",
        data: body,
        options: requestOptions,
      );
      final dynamic data = res.data;

      if (res.statusCode == 200 || res.statusCode == 201) {
        apiResponse.responseSuccessful = data['success'] ?? true;
        apiResponse.responseMessage =
            data['responseMessage'] ?? 'Request completed';
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
      }

      if (apiResponse.responseMessage?.contains(
            "Session expired, log in again",
          ) ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";
    }
    return apiResponse;
  }

  Future<ApiResponse> putRequest(
    String url,
    dynamic body, {
    Options? options,
    String? accessToken,
  }) async {
    final ApiResponse apiResponse = ApiResponse();

    try {
      // Set headers locally for this request
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Cookie': 'auth=$accessToken',
      };

      final requestOptions =
          options?.copyWith(headers: headers) ?? Options(headers: headers);

      /*dio.options.headers['Authorization'] = 'Bearer $accessToken';
      dio.options.headers['Cookie'] = 'auth=$accessToken';*/

      final res = await dio.put(
        "$baseUrl$url",
        data: body,
        options: requestOptions,
      );
      final dynamic data = res.data;

      if (res.statusCode == 200 || res.statusCode == 201) {
        apiResponse.responseSuccessful = data['success'] ?? true;
        apiResponse.responseMessage =
            data['responseMessage'] ?? 'Request completed';
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
      }

      if (apiResponse.responseMessage?.contains(
            "Session expired, log in again",
          ) ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";
    }
    return apiResponse;
  }
}
