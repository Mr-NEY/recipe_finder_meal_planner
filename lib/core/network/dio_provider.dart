import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/core/utils/app_logger.dart';
import 'api_config.dart';
import 'api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final logger = ref.watch(loggerProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      queryParameters: ApiConfig.hasApiKey
          ? {'apiKey': ApiConfig.apiKey}
          : const {},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          logger.i('${options.method} ${options.uri}');
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final status = error.response?.statusCode;
        final message = error.response?.data is Map
            ? (error.response?.data['message']?.toString() ?? error.message)
            : error.message;
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            error: ApiException(
              message ?? 'Network request failed',
              statusCode: status,
            ),
            type: error.type,
          ),
        );
      },
    ),
  );

  return dio;
});
