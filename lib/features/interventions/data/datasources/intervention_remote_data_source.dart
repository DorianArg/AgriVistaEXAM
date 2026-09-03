import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/core/network/dio_client.dart';
import 'package:agrivista_field/features/interventions/data/models/agrivista_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

abstract interface class InterventionRemoteDataSource {
  Future<AgriVistaResponseDto> recupererDonnees();
}

final class DioInterventionRemoteDataSource
    implements InterventionRemoteDataSource {
  const DioInterventionRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<AgriVistaResponseDto> recupererDonnees() async {
    try {
      final response = await _dio.get<Object?>(
        ApiConfiguration.interventionsPath,
      );
      final statusCode = response.statusCode;
      if (statusCode == null || statusCode < 200 || statusCode >= 300) {
        throw HttpFailure(statusCode: statusCode);
      }

      final data = response.data;
      if (data is! Map) {
        throw const DataParsingFailure(
          'La racine de la réponse JSON doit être un objet.',
        );
      }

      return AgriVistaResponseDto.fromJson(Map<String, Object?>.from(data));
    } on DioException catch (error) {
      throw _mapDioFailure(error);
    } on AppFailure {
      rethrow;
    } on CheckedFromJsonException catch (error) {
      throw DataParsingFailure('Champ JSON invalide : ${error.key}.');
    } on FormatException {
      throw const DataParsingFailure();
    } on TypeError {
      throw const DataParsingFailure();
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}

AppFailure _mapDioFailure(DioException error) {
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => const RequestTimeoutFailure(),
    DioExceptionType.badResponse => HttpFailure(
      statusCode: error.response?.statusCode,
    ),
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate => const NetworkFailure(),
    DioExceptionType.cancel ||
    DioExceptionType.unknown => const UnknownFailure(),
  };
}
