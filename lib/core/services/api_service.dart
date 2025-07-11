import 'dart:io';

import 'package:app_t/core/constants/url_path.dart';
import 'package:app_t/core/model/api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static ApiService? _apiService;

  ApiService._();

  static ApiService? get instance {
    _apiService ??= ApiService._();
    return _apiService;
  }

  Dio dio = Dio();

  // Update Cookie for API calls
  updateCookie(Headers headers) {
    //Get the value of the cookie passed in the response
    final rawCookie = headers['set-cookie'];

    if (rawCookie != null) {
      debugPrint("Cookies: $rawCookie");

      //Get the index of the equals symbol
      int indexOfEquals = rawCookie[0].indexOf('=');
      //Get index of the first semiColon symbol
      int indexOfSemiColon = rawCookie[0].indexOf(';');

      //Stores the value of the token
      String token = "";

      // Handle cases where the string might not contain an equals symbol
      if (indexOfEquals != -1 &&
          indexOfSemiColon != -1 &&
          indexOfEquals < indexOfSemiColon) {
        //Get the string after the first equals symbol
        token = rawCookie[0].substring(indexOfEquals + 1, indexOfSemiColon);

        //Store the token in the localStorage
        // LocalStorageHelper().setUserToken(token);

        debugPrint("Auth: $token");
      } else {
        // Optionally handle cases where the string doesn't have an equals symbol
        token = "";

        //Store the token in the localStorage
        // LocalStorageHelper().setUserToken(token);

        debugPrint("Auth: $token");
      }
    }
  }

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

    debugPrint("Request Path $baseUrl$url");
    debugPrint("Request body $body");

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

      debugPrint("Authorization: $accessToken ");

      final res =
          await dio.post("$baseUrl$url", data: body, options: requestOptions);
      final dynamic data = res.data;

      debugPrint("Response body $data");

      if (res.statusCode == 200 || res.statusCode == 201) {
        //Call the update Cookie function
        await updateCookie(res.headers);

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
      debugPrint("Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Response Message: ${apiResponse.responseMessage}");

      if (apiResponse.responseMessage
              ?.contains("Session expired, log in again") ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      debugPrint("Dio Response Full Message: ${e.response?.data}");
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      // //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';

      debugPrint("Dio Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Dio Response Message: ${apiResponse.responseMessage}");
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";

      debugPrint(
          "Socket Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Socket Response Successful: ${apiResponse.responseMessage}");
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

    debugPrint("Request Path $baseUrl$url");
    debugPrint("Request body $body");

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
      debugPrint("Authorization: $accessToken");

      final res =
          await dio.post("$baseUrl$url", data: body, options: requestOptions);
      final dynamic data = res.data;

      debugPrint("Response body $data");

      if (res.statusCode == 200 || res.statusCode == 201) {
        //Call the update Cookie function
        await updateCookie(res.headers);

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

      debugPrint("Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Response Message: ${apiResponse.responseMessage}");
      debugPrint("Response Body: ${apiResponse.responseBody}");

      if (apiResponse.responseMessage
              ?.contains("Session expired, log in again") ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      debugPrint("Dio Response Full Message: ${e.response?.data}");
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      // //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';

      debugPrint("Dio Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Dio Response Message: ${apiResponse.responseMessage}");
      // debugPrint("Dio Response Body: ${apiResponse.responseBody}");
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";

      debugPrint(
          "Socket Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Socket Response Successful: ${apiResponse.responseMessage}");
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

    debugPrint("Request Path $baseUrl$url");

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

      debugPrint("Authorization: $accessToken");

      final res = await dio.get("$baseUrl$url", options: requestOptions);
      final dynamic data = res.data;

      debugPrint("Response body $data");
      debugPrint("Response body ${res.statusMessage}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        //Call the update Cookie function
        await updateCookie(res.headers);

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

      debugPrint("Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Response Message: ${apiResponse.responseMessage}");

      if (apiResponse.responseMessage
              ?.contains("Session expired, log in again") ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      debugPrint("Dio Response Full Message: ${e.response?.data}");
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';

      debugPrint("Dio Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Dio Response Message: ${apiResponse.responseMessage}");
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";

      debugPrint(
          "Socket Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Socket Response Successful: ${apiResponse.responseMessage}");
    }
    return apiResponse;
  }

  Future<ApiResponse> getRequest(
    String url, {
    Options? options,
    String? accessToken,
  }) async {
    final ApiResponse apiResponse = ApiResponse();

    debugPrint("Request Path $baseUrl$url");

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

      debugPrint("Authorization: $accessToken");

      final res = await dio.get("$baseUrl$url", options: requestOptions);
      final dynamic data = res.data;

      debugPrint("Response body $data");

      if (res.statusCode == 200 || res.statusCode == 201) {
        //Call the update Cookie function
        await updateCookie(res.headers);

        apiResponse.responseSuccessful = data['success'] ?? true;
        apiResponse.responseMessage = data['responseMessage'] ?? '';
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
      }
      debugPrint("Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Response Message: ${apiResponse.responseMessage}");

      if (apiResponse.responseMessage
              ?.contains("Session expired, log in again") ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      debugPrint("Dio Response Full Message: ${e.response?.data}");
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';

      debugPrint("Dio Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Dio Response Message: ${apiResponse.responseMessage}");
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";

      debugPrint(
          "Socket Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Socket Response Successful: ${apiResponse.responseMessage}");
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

    debugPrint("Request Path $baseUrl$url");
    debugPrint("Request Body $body");

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

      debugPrint("Authorization: $accessToken");

      final res =
          await dio.post("$baseUrl$url", data: body, options: requestOptions);
      final dynamic data = res.data;

      debugPrint("Response body $data");

      if (res.statusCode == 200 || res.statusCode == 201) {
        //Call the update Cookie function
        await updateCookie(res.headers);

        apiResponse.responseSuccessful = data['success'] ?? true;
        apiResponse.responseMessage = data['responseMessage'] ?? '';
        apiResponse.responseBody = data['url'] ?? '';
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
      }
      debugPrint("Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Response Message: ${apiResponse.responseMessage}");
      debugPrint("Response Body: ${apiResponse.responseBody}");

      if (apiResponse.responseMessage
              ?.contains("Session expired, log in again") ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      debugPrint("Dio Response Full Message: ${e.response?.data}");
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';

      debugPrint("Dio Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Dio Response Message: ${apiResponse.responseMessage}");
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";

      debugPrint(
          "Socket Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Socket Response Successful: ${apiResponse.responseMessage}");
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

    // print();
    debugPrint("Request Path $baseUrl$url");
    debugPrint("Request body $body");

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

      debugPrint("Authorization: $accessToken");

      final res =
          await dio.patch("$baseUrl$url", data: body, options: requestOptions);
      final dynamic data = res.data;

      debugPrint("Response body $data");

      if (res.statusCode == 200 || res.statusCode == 201) {
        //Call the update Token function
        await updateCookie(res.headers);

        apiResponse.responseSuccessful = data['success'] ?? true;
        apiResponse.responseMessage =
            data['responseMessage'] ?? 'Request completed';
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
      }
      debugPrint("Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Response Message: ${apiResponse.responseMessage}");
      debugPrint("Response Body: ${apiResponse.responseBody}");

      if (apiResponse.responseMessage
              ?.contains("Session expired, log in again") ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      debugPrint("Dio Response Full Message: ${e.response?.data}");
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';

      debugPrint("Dio Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Dio Response Message: ${apiResponse.responseMessage}");
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";

      debugPrint(
          "Socket Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Socket Response Successful: ${apiResponse.responseMessage}");
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

    // print();
    debugPrint("Request Path $baseUrl$url");
    debugPrint("Request body $body");

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

      debugPrint("Authorization: $accessToken");

      final res =
          await dio.put("$baseUrl$url", data: body, options: requestOptions);
      final dynamic data = res.data;

      debugPrint("Response body $data");

      if (res.statusCode == 200 || res.statusCode == 201) {
        //Call the update Token function
        await updateCookie(res.headers);

        apiResponse.responseSuccessful = data['success'] ?? true;
        apiResponse.responseMessage =
            data['responseMessage'] ?? 'Request completed';
      } else {
        apiResponse.responseSuccessful = false;
        apiResponse.responseMessage =
            (data['responseMessage'] ?? 'Error encountered');
      }
      debugPrint("Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Response Message: ${apiResponse.responseMessage}");
      debugPrint("Response Body: ${apiResponse.responseBody}");

      if (apiResponse.responseMessage
              ?.contains("Session expired, log in again") ??
          false) {
        // sessionTimeoutDialog();
      }
    } on DioException catch (e) {
      debugPrint("Dio Response Full Message: ${e.response?.data}");
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage =
          e.response?.data['responseMessage'] ?? 'An error occurred';
      //apiResponse.responseBody = e.response?.data['responseBody'] ?? 'No Body';

      debugPrint("Dio Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Dio Response Message: ${apiResponse.responseMessage}");
    } on SocketException catch (_) {
      apiResponse.responseSuccessful = false;
      apiResponse.responseMessage = "An Error occurred";

      debugPrint(
          "Socket Response Successful: ${apiResponse.responseSuccessful}");
      debugPrint("Socket Response Successful: ${apiResponse.responseMessage}");
    }
    return apiResponse;
  }

//
// Future<ApiResponse<T>> putRequestHandler<T>(
//   String url,
//   dynamic body, {
//   T Function(dynamic)? transform,
//   required String accessToken,
//   String? profileType,
//   Options? options,
// }) async {
//   transform ??= (dynamic r) => r.body as T;
//   final ApiResponse<T> apiResponse = ApiResponse<T>();
//
//   log(body);
//   log(baseUrl + url);
//   try {
//     var headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $accessToken'
//     };
//     final res = await dio.put(
//       baseUrl + url,
//       data: body,
//       options: Options(
//         method: 'PUT',
//         headers: headers,
//       ),
//     );
//     final dynamic data = res.data;
//
//     if (res.statusCode == 200) {
//       apiResponse.responseBody = transform(data);
//       apiResponse.responseSuccessful = data['success'] ?? true;
//
//       apiResponse.responseMessage = data['responseMessage'];
//     } else {
//       apiResponse.responseSuccessful = false;
//       apiResponse.responseMessage =
//           (data['responseMessage'] ?? 'Error encountered');
//     }
//   } on DioException catch (e) {
//     if (kDebugMode) {
//       print(e.response?.data);
//     }
//     apiResponse.responseSuccessful = false;
//     apiResponse.responseMessage = e.response?.data['responseMessage'];
//   } on SocketException catch (_) {
//     apiResponse.responseSuccessful = false;
//     apiResponse.responseMessage = "An Error occurred";
//   }
//   return apiResponse;
// }
//
// Future<ApiResponse<T>> patchRequestHandler<T>(
//   String url,
//   dynamic body, {
//   T Function(dynamic)? transform,
//   String? accessToken,
//   String? profileType,
//   Options? options,
// }) async {
//   transform ??= (dynamic r) => r.body as T;
//   final ApiResponse<T> apiResponse = ApiResponse<T>();
//
//   try {
//     dio.options.headers['accept'] = 'application/json';
//     dio.options.headers['ProfileType'] = profileType;
//     dio.options.headers['Authorization'] = 'Bearer $accessToken';
//     final res = await dio.patch(baseUrl + url, data: body, options: options);
//     final dynamic data = res.data;
//
//     if (kDebugMode) {
//       print(data);
//     }
//     if (res.statusCode == 200) {
//       apiResponse.responseBody = transform(data);
//       apiResponse.responseSuccessful = data['success'] ?? true;
//       apiResponse.responseMessage = data['responseMessage'];
//     } else {
//       apiResponse.responseSuccessful = false;
//       apiResponse.responseMessage =
//           (data['responseMessage'] ?? 'Error encountered');
//     }
//   } on DioException catch (e) {
//     if (kDebugMode) {
//       print(e.response?.data);
//     }
//     apiResponse.responseSuccessful = false;
//     apiResponse.responseMessage = e.response?.data['responseMessage'];
//   } on SocketException catch (_) {
//     apiResponse.responseSuccessful = false;
//     apiResponse.responseMessage = "An Error occurred";
//   }
//   return apiResponse;
// }

//
// Future<ApiResponse<T>> deleteRequestHandler<T>(
//   String url,
//   dynamic body, {
//   T Function(dynamic)? transform,
//   required String accessToken,
//   String? profileType,
//   Options? options,
// }) async {
//   transform ??= (dynamic r) => r.body as T;
//   final ApiResponse<T> apiResponse = ApiResponse<T>();
//
//   try {
//     dio.options.headers['accept'] = 'application/json';
//     dio.options.headers['ProfileType'] = profileType;
//     dio.options.headers['Authorization'] = 'Bearer $accessToken';
//     final res = await dio.delete(baseUrl + url, data: body, options: options);
//     final dynamic data = res.data;
//
//     if (res.statusCode == 200) {
//       apiResponse.responseBody = transform(data);
//       apiResponse.responseSuccessful = true;
//       apiResponse.responseMessage = data['responseMessage'];
//     } else {
//       apiResponse.responseSuccessful = false;
//       apiResponse.responseMessage =
//           (data['responseMessage'] ?? 'Error encountered');
//     }
//   } on DioException catch (e) {
//     if (kDebugMode) {
//       print(e.response?.data);
//     }
//     apiResponse.responseSuccessful = false;
//     apiResponse.responseMessage = e.response?.data['responseMessage'];
//   } on SocketException catch (_) {
//     apiResponse.responseSuccessful = false;
//     apiResponse.responseMessage = "An Error occurred";
//   }
//   return apiResponse;
// }
}
