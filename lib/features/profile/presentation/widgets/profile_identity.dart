import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';
import 'package:flutter/material.dart';

final class ProfileIdentity extends StatelessWidget {
  const ProfileIdentity({required this.technicien, super.key});

  static const _role = 'Technicienne terrain';
  static const _applicationName = 'AgriVista Field';

  final Technicien technicien;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = initialsForName(technicien.nom);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          children: [
            Center(
              child: Semantics(
                label: 'Initiales du technicien : $initials',
                child: ExcludeSemantics(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: Text(
                      initials,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              technicien.nom,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              _role,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Identifiant',
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          SelectableText(technicien.id),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                minTileHeight: 72,
                leading: Icon(
                  Icons.eco_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text(_applicationName),
                subtitle: const Text('Application de suivi des interventions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
