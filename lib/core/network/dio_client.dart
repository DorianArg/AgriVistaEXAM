import 'package:dio/dio.dart';

abstract final class ApiConfiguration {
  static const baseUrl = 'https://utrera.ludovic.aflokkat-projet.fr';
  static const interventionsPath = '/getInterventions.json';

  static const connectTimeout = Duration(seconds: 10);
  static const sendTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);
}

Dio createDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfiguration.baseUrl,
      connectTimeout: ApiConfiguration.connectTimeout,
      sendTimeout: ApiConfiguration.sendTimeout,
      receiveTimeout: ApiConfiguration.receiveTimeout,
      responseType: ResponseType.json,
    ),
  );
}
