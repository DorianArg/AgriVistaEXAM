import 'dart:convert';
import 'dart:typed_data';

import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/core/network/dio_client.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioInterventionRemoteDataSource', () {
    test('désérialise une réponse valide', () async {
      final dataSource = _dataSourceWithResponse(_validJson());

      final result = await dataSource.recupererDonnees();

      expect(result.technicien.id, 't-01');
      expect(result.interventions, hasLength(1));
    });

    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.transformTimeout,
    ]) {
      test('traduit $type en RequestTimeoutFailure', () {
        expect(
          _dataSourceThrowing(type).recupererDonnees,
          throwsA(isA<RequestTimeoutFailure>()),
        );
      });
    }

    test('traduit une absence de réseau en NetworkFailure', () {
      expect(
        _dataSourceThrowing(DioExceptionType.connectionError).recupererDonnees,
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('traduit une erreur HTTP et conserve son statut', () async {
      final dataSource = _dataSourceWithResponse(<String, Object?>{
        'error': 'indisponible',
      }, statusCode: 503);

      await expectLater(
        dataSource.recupererDonnees(),
        throwsA(
          isA<HttpFailure>().having(
            (failure) => failure.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
    });

    test('traduit une erreur Dio inconnue en UnknownFailure', () {
      expect(
        _dataSourceThrowing(DioExceptionType.unknown).recupererDonnees,
        throwsA(isA<UnknownFailure>()),
      );
    });

    for (final testCase in <(String, Object?)>[
      ('racine non objet', <Object?>[]),
      ('technicien absent', <String, Object?>{'interventions': <Object?>[]}),
      (
        'interventions non liste',
        <String, Object?>{
          'technicien': <String, Object?>{'id': 't-01', 'nom': 'Marie Santini'},
          'interventions': 'invalides',
        },
      ),
      ('coordonnée invalide', _validJson(latitude: 'nord')),
      (
        'historique incomplet',
        _validJson(
          history: <Object?>[
            <String, Object?>{'date': '2026-06-10'},
          ],
        ),
      ),
    ]) {
      test('traduit ${testCase.$1} en DataParsingFailure', () {
        expect(
          _dataSourceWithResponse(testCase.$2).recupererDonnees,
          throwsA(isA<DataParsingFailure>()),
        );
      });
    }
  });
}

DioInterventionRemoteDataSource _dataSourceWithResponse(
  Object? body, {
  int statusCode = 200,
}) {
  final dio = createDioClient();
  dio.httpClientAdapter = _StubHttpClientAdapter(
    (_) async => ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    ),
  );
  return DioInterventionRemoteDataSource(dio);
}

DioInterventionRemoteDataSource _dataSourceThrowing(DioExceptionType type) {
  final dio = createDioClient();
  dio.httpClientAdapter = _StubHttpClientAdapter((options) async {
    throw DioException(requestOptions: options, type: type);
  });
  return DioInterventionRemoteDataSource(dio);
}

Map<String, Object?> _validJson({
  Object? latitude = 42.703,
  List<Object?>? history,
}) {
  return <String, Object?>{
    'technicien': <String, Object?>{'id': 't-01', 'nom': 'Marie Santini'},
    'interventions': <Object?>[
      <String, Object?>{
        'id': 'itv-1001',
        'station': 'Station Nord',
        'domaine': 'Vignoble Patrimonio',
        'latitude': latitude,
        'longitude': 9.347,
        'priorite': 'haute',
        'statut': 'planifiee',
        'datePrevue': '2026-06-15',
        'description': 'Remplacement du capteur.',
        'historique':
            history ??
            <Object?>[
              <String, Object?>{
                'date': '2026-06-10',
                'action': 'Intervention créée',
              },
            ],
      },
    ],
  };
}

typedef _RequestHandler = Future<ResponseBody> Function(RequestOptions options);

final class _StubHttpClientAdapter implements HttpClientAdapter {
  const _StubHttpClientAdapter(this.handler);

  final _RequestHandler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
