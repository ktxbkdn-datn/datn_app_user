import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

class ApiException implements Exception {
  final String message;
  final bool isNetworkError;

  ApiException(this.message, {this.isNetworkError = false});

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  String? _accessToken;
  String? _refreshToken;
  bool _isInitialized = false;
  final _secureStorage = const FlutterSecureStorage();
  static const _publicEndpoints = [
    '/rooms',
    '/rooms/images',
    '/public/areas',
    '/registrations',
    '/auth/user/login',
    '/auth/logout',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/public/notifications/general',
    '/notification-types',
    '/auth/refresh',
  ];

  ApiService({required this.baseUrl}) {
    print('Creating new ApiService instance: $this');
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _initializeTokens();
      _isInitialized = true;
    }
  }

  String? get token => _accessToken;

  Future<void> _initializeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');
    print('Access token from shared preferences: $_accessToken');
    print('Refresh token from shared preferences: $_refreshToken');

    if (_accessToken == null || _refreshToken == null) {
      const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
      if (!kIsWeb) {
        _accessToken = await _secureStorage.read(key: 'auth_token');
        _refreshToken = await _secureStorage.read(key: 'refresh_token');
        print('Access token from secure storage: $_accessToken');
        print('Refresh token from secure storage: $_refreshToken');
        if (_accessToken != null && _refreshToken != null) {
          await prefs.setString('auth_token', _accessToken!);
          await prefs.setString('refresh_token', _refreshToken!);
          print('Saved tokens to shared preferences from secure storage');
        }
      }
    }
  }

  Future<void> setToken(String? accessToken, {String? refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken ?? _refreshToken;
    final prefs = await SharedPreferences.getInstance();
    const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

    if (accessToken != null) {
      await prefs.setString('auth_token', accessToken);
      print('Saved access token to shared preferences: $accessToken');
    } else {
      await prefs.remove('auth_token');
      print('Removed access token from shared preferences');
    }

    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
      print('Saved refresh token to shared preferences: $refreshToken');
    } else if (accessToken == null) {
      await prefs.remove('refresh_token');
      print('Removed refresh token from shared preferences');
    }

    if (!kIsWeb) {
      if (accessToken != null) {
        await _secureStorage.write(key: 'auth_token', value: accessToken);
        print('Saved access token to secure storage: $accessToken');
      } else {
        await _secureStorage.delete(key: 'auth_token');
        print('Removed access token from secure storage');
      }

      if (refreshToken != null) {
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        print('Saved refresh token to secure storage: $refreshToken');
      } else if (accessToken == null) {
        await _secureStorage.delete(key: 'refresh_token');
        print('Removed refresh token from secure storage');
      }
    }
  }

  Future<void> clearToken() async {
    await setToken(null);
  }

  Future<String?> getUserIdFromToken() async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_accessToken == null) return null;
    try {
      final decodedToken = JwtDecoder.decode(_accessToken!);
      final userId = decodedToken['sub'] as String?;
      print('Extracted user ID from token: $userId');
      return userId;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<void> updateFcmToken(String fcmToken, String jwtToken) async {
    print('Updating FCM token: $fcmToken');
    try {
      final response = await put(
        '/me/update-fcm-token',
        {'fcm_token': fcmToken},
        headers: {'Authorization': 'Bearer $jwtToken'},
      );
      print('FCM token update response: $response');
    } catch (e) {
      print('Error updating FCM token: $e');
      throw ApiException('Failed to update FCM token: $e');
    }
  }

  void _checkToken() {
    print('Checking access token: $_accessToken');
    if (_accessToken == null) {
      print('Access token is null');
      throw ApiException('Token không tồn tại. Vui lòng đăng nhập lại.');
    }
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Sửa typo từ getStringOD
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<bool> refreshAccessToken() async {
    print('Attempting to refresh access token');
    if (_refreshToken == null) {
      print('No refresh token available');
      return false;
    }

    final uri = Uri.parse('$baseUrl/auth/refresh');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'refresh_token=$_refreshToken',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException('Refresh token request timed out after 30 seconds', isNetworkError: true);
        },
      );

      print('Refresh token response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access_token'] as String?;
        if (newAccessToken != null) {
          String? newRefreshToken;
          final setCookieHeader = response.headers['set-cookie'];
          if (setCookieHeader != null) {
            final cookies = setCookieHeader.split(';');
            for (var cookie in cookies) {
              if (cookie.trim().startsWith('refresh_token=')) {
                newRefreshToken = cookie.trim().split('=')[1];
                break;
              }
            }
          }
          newRefreshToken ??= _refreshToken;

          await setToken(newAccessToken, refreshToken: newRefreshToken);
          print('Access token refreshed successfully');
          return true;
        } else {
          print('No access token in refresh response');
          return false;
        }
      } else {
        print('Failed to refresh token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  Future<dynamic> _parseResponseBody(http.Response response) async {
    try {
      final bodyString = response.body;
      if (bodyString.isEmpty) {
        return null;
      }
      final responseBody = jsonDecode(bodyString);
      return responseBody;
    } catch (e) {
      print('Error parsing response body: $e');
      throw ApiException('Lỗi parse JSON: $e');
    }
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    print('Starting GET request to $endpoint');
    return _performRequestWithRefresh(
      () async {
        final requestHeaders = {
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        };

        bool isPublic = _publicEndpoints.any((publicEndpoint) =>
            endpoint == publicEndpoint ||
            endpoint.startsWith(publicEndpoint.endsWith('/') ? publicEndpoint : '$publicEndpoint/'));
        if (!isPublic) {
          _checkToken();
          requestHeaders['Authorization'] = 'Bearer $_accessToken';
        }

        final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

        print('Sending GET request...');
        final response = await http.get(
          uri,
          headers: requestHeaders,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw ApiException('GET request timed out after 30 seconds: $uri', isNetworkError: true);
          },
        );
        return response;
      },
      endpoint,
      (response) async => await _parseResponseBody(response),
      (response) => response.statusCode >= 200 && response.statusCode < 300,
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    print('Starting POST request to $endpoint');
    return _performRequestWithRefresh(
      () async {
        final requestHeaders = {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        };
        print('POST request headers: $requestHeaders');

        final uri = Uri.parse('$baseUrl$endpoint');

        print('Sending POST request...');
        final response = await http.post(
          uri,
          headers: requestHeaders,
          body: jsonEncode(body),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw ApiException('POST request timed out after 30 seconds: $uri', isNetworkError: true);
          },
        );
        return response;
      },
      endpoint,
      (response) async => await _parseResponseBody(response),
      (response) => response.statusCode >= 200 && response.statusCode < 300,
    );
  }

  Future<dynamic> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    required List<http.MultipartFile> files,
  }) async {
    print('Starting POST Multipart request to $endpoint');
    return _performRequestWithRefresh(
      () async {
        final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
        if (fields != null) {
          request.fields.addAll(fields);
        }
        request.files.addAll(files);
        request.headers['Authorization'] = 'Bearer $_accessToken';
        print('Request headers: ${request.headers}');

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            print('Timeout in POST Multipart: $endpoint');
            throw ApiException('POST Multipart request timed out after 60 seconds: $endpoint',
                isNetworkError: true);
          },
        );

        final response = await http.Response.fromStream(streamedResponse);
        return response;
      },
      endpoint,
      (response) async => await _parseResponseBody(response),
      (response) => response.statusCode == 200 || response.statusCode == 201,
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    print('Starting PUT request to $endpoint');
    return _performRequestWithRefresh(
      () async {
        _checkToken();
        final requestHeaders = {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        };
        print('PUT request headers: $requestHeaders');

        final uri = Uri.parse('$baseUrl$endpoint');

        print('Sending PUT request...');
        final response = await http.put(
          uri,
          headers: requestHeaders,
          body: jsonEncode(body),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw ApiException('PUT request timed out after 30 seconds: $uri', isNetworkError: true);
          },
        );
        return response;
      },
      endpoint,
      (response) async => await _parseResponseBody(response),
      (response) => response.statusCode >= 200 && response.statusCode < 300,
    );
  }

  Future<dynamic> putMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Uint8List? fileBytes,
    String fileFieldName = 'file',
    String fileName = 'avatar.jpg',
    String? mimeType,
    Map<String, String>? headers,
  }) async {
    print('Starting PUT Multipart request to $endpoint');
    return _performRequestWithRefresh(
      () async {
        final uri = Uri.parse('$baseUrl$endpoint');
        print('PUT Multipart Request URL: $uri');

        var request = http.MultipartRequest('PUT', uri);

        final token = await _getAuthToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        } else {
          print('PUT Multipart Warning: No auth token found');
        }

        if (headers != null) {
          request.headers.addAll(headers);
        }
        print('PUT Multipart Request Headers: ${request.headers}');

        if (fields != null) {
          request.fields.addAll(fields);
          print('PUT Multipart Request Fields: $fields');
        } else {
          print('PUT Multipart Request Fields: None');
        }

        if (files != null) {
          request.files.addAll(files);
          print('PUT Multipart Request Files: ${files.map((f) => f.filename).toList()}');
        } else if (fileBytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            fileFieldName,
            fileBytes,
            filename: fileName,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
          print('PUT Multipart Request File (bytes): $fileName');
          print('File bytes length: ${fileBytes.length} bytes');
          print('File MIME type: $mimeType');
        } else {
          print('PUT Multipart Request Files: None');
        }

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            print('Timeout in PUT Multipart: $uri');
            throw ApiException('PUT Multipart request timed out after 60 seconds: $uri',
                isNetworkError: true);
          },
        );

        print('PUT Multipart Response Status: ${streamedResponse.statusCode}');

        final response = await http.Response.fromStream(streamedResponse);
        return response;
      },
      endpoint,
      (response) async {
        try {
          final decodedResponse = await _parseResponseBody(response);
          print('PUT Multipart Decoded Response: $decodedResponse');
          return decodedResponse;
        } catch (e) {
          print('PUT Multipart JSON Decode Error: $e');
          throw ApiException('Failed to decode JSON response: ${response.body}');
        }
      },
      (response) => response.statusCode == 200 || response.statusCode == 201,
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    print('Starting DELETE request to $endpoint');
    return _performRequestWithRefresh(
      () async {
        if (!_isInitialized) {
          await initialize();
        }
        final requestHeaders = {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        };
        print('DELETE request headers in ApiService $this: $requestHeaders');

        final uri = Uri.parse('$baseUrl$endpoint');

        final encodedBody = data != null ? jsonEncode(data) : null;
        print('DELETE request body in ApiService $this: $encodedBody');
        final response = await http.delete(
          uri,
          headers: requestHeaders,
          body: encodedBody,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw ApiException('DELETE request timed out after 30 seconds: $uri', isNetworkError: true);
          },
        );
        return response;
      },
      endpoint,
      (response) async {
        if (response.statusCode == 204) {
          return {};
        }
        return await _parseResponseBody(response);
      },
      (response) => response.statusCode >= 200 && response.statusCode < 300,
    );
  }

  Future<T> _performRequestWithRefresh<T>(
    Future<http.Response> Function() requestFunction,
    String endpoint,
    Future<T> Function(http.Response) parseResponse,
    bool Function(http.Response) isSuccess,
  ) async {
    const int maxRetries = 2;
    int retryCount = 0;
    bool isPublic = _publicEndpoints.any((publicEndpoint) =>
        endpoint == publicEndpoint ||
        endpoint.startsWith(publicEndpoint.endsWith('/') ? publicEndpoint : '$publicEndpoint/'));

    while (retryCount < maxRetries) {
      try {
        final response = await requestFunction();
        print('Response status for $endpoint: ${response.statusCode} - ${response.body}');

        if (isSuccess(response)) {
          return await parseResponse(response);
        }

        if (response.statusCode == 401 && !isPublic) {
          print('Received 401 Unauthorized for $endpoint, attempting to refresh token');
          final refreshed = await refreshAccessToken();
          if (refreshed) {
            retryCount++;
            print('Retrying request with new access token ($retryCount/$maxRetries) for $endpoint');
            continue;
          } else {
            print('Failed to refresh token for $endpoint, logging out');
            await clearToken();
            throw ApiException('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
          }
        }

        if (response.statusCode == 429) {
          throw ApiException('Quá nhiều yêu cầu, vui lòng thử lại sau.');
        }

        final responseData = await _parseResponseBody(response);
        throw ApiException(
            responseData['message'] ?? 'Lỗi server: ${response.statusCode}');
      } on SocketException catch (e) {
        print('SocketException for $endpoint: $e');
        throw ApiException('Lỗi kết nối: Không thể kết nối đến server',
            isNetworkError: true);
      } catch (e) {
        print('Unexpected error for $endpoint: $e');
        throw ApiException('Lỗi không xác định: $e');
      }
    }

    throw ApiException('Failed to complete request after $maxRetries retries for $endpoint');
  }
}