import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

String _defaultBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8080';
  }
  if (Platform.isAndroid) {
    // Android emulator'dan host makineye erişim.
    return 'http://10.0.2.2:8080';
  }
  // iOS simulator veya gerçek cihaz için (lokal backend).
  return 'http://localhost:8080';
}

class ApiClient {
  ApiClient({
    Dio? dio,
    String? baseUrl,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? _defaultBaseUrl(),
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final Dio _dio;
  final String baseUrl;

  Dio get raw => _dio;

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

