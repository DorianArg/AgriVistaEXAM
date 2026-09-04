import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/core/widgets/async_state_views.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('associe chaque Failure technique à un message utilisateur', () {
    expect(
      messageForFailure(const NetworkFailure()),
      'Impossible de contacter le serveur.',
    );
    expect(
      messageForFailure(const RequestTimeoutFailure()),
      'Le serveur met trop de temps à répondre.',
    );
    expect(
      messageForFailure(const HttpFailure(statusCode: 500)),
      'Le serveur a retourné une erreur.',
    );
    expect(
      messageForFailure(const DataParsingFailure()),
      'Les données reçues sont invalides.',
    );
    expect(
      messageForFailure(const LocalStorageFailure()),
      'Impossible de lire les données enregistrées localement.',
    );
    expect(
      messageForFailure(const UnknownFailure()),
      'Une erreur inattendue est survenue.',
    );
  });
}
