sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Connexion réseau impossible.']);
}

final class RequestTimeoutFailure extends AppFailure {
  const RequestTimeoutFailure([super.message = 'La requête a expiré.']);
}

final class HttpFailure extends AppFailure {
  const HttpFailure({
    required this.statusCode,
    String message = 'Le serveur a retourné une erreur.',
  }) : super(message);

  final int? statusCode;
}

final class DataParsingFailure extends AppFailure {
  const DataParsingFailure([
    super.message = 'Les données reçues sont invalides.',
  ]);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Une erreur inattendue est survenue.']);
}

final class LocalStorageFailure extends AppFailure {
  const LocalStorageFailure([
    super.message = 'Le stockage local est indisponible.',
  ]);
}

final class InvalidStatusTransitionFailure extends AppFailure {
  const InvalidStatusTransitionFailure([
    super.message = 'Cette intervention ne peut plus changer de statut.',
  ]);
}
