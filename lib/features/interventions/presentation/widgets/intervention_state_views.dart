import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:flutter/material.dart';

final class InterventionsLoadingView extends StatelessWidget {
  const InterventionsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Chargement des interventions…'),
        ],
      ),
    );
  }
}

final class InterventionsErrorView extends StatelessWidget {
  const InterventionsErrorView({
    required this.error,
    required this.onRetry,
    super.key,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(messageForFailure(error), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

final class InterventionsEmptyView extends StatelessWidget {
  const InterventionsEmptyView({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

String messageForFailure(Object error) => switch (error) {
  NetworkFailure() => 'Impossible de contacter le serveur.',
  RequestTimeoutFailure() => 'Le serveur met trop de temps à répondre.',
  HttpFailure() => 'Le serveur a retourné une erreur.',
  DataParsingFailure() => 'Les données reçues sont invalides.',
  LocalStorageFailure() =>
    'Impossible de lire les données enregistrées localement.',
  _ => 'Une erreur inattendue est survenue.',
};
