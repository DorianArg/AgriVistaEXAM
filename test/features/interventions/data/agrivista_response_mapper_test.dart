import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/mappers/agrivista_response_mapper.dart';
import 'package:agrivista_field/features/interventions/data/models/agrivista_response_dto.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgriVistaResponseDto', () {
    test('parse un JSON valide avec sa racine complète', () {
      final dto = AgriVistaResponseDto.fromJson(_validJson());

      expect(dto.technicien.id, 't-01');
      expect(dto.technicien.nom, 'Marie Santini');
      expect(dto.interventions, hasLength(1));
      expect(dto.interventions.single.station, 'Station Nord');
      expect(dto.interventions.single.latitude, 42.703);
    });

    test('parse puis mappe l historique', () {
      final domain = AgriVistaResponseDto.fromJson(_validJson()).toDomain();

      final historique = domain.interventions.single.historique;
      expect(historique, hasLength(1));
      expect(historique.single.date, DateTime(2026, 6, 10));
      expect(historique.single.action, 'Intervention creee');
    });

    test('convertit la date prévue ISO en DateTime', () {
      final domain = AgriVistaResponseDto.fromJson(_validJson()).toDomain();

      expect(domain.interventions.single.datePrevue, DateTime(2026, 6, 15));
    });
  });

  group('mapping des statuts', () {
    final cases = <String, StatutIntervention>{
      'planifiee': StatutIntervention.planifiee,
      'en_cours': StatutIntervention.enCours,
      'terminee': StatutIntervention.terminee,
    };

    for (final entry in cases.entries) {
      test('${entry.key} vers ${entry.value.name}', () {
        final dto = AgriVistaResponseDto.fromJson(
          _validJson(statut: entry.key),
        );

        expect(dto.toDomain().interventions.single.statut, entry.value);
      });
    }

    test('rejette un statut inconnu avec une erreur contrôlée', () {
      final dto = AgriVistaResponseDto.fromJson(_validJson(statut: 'annulee'));

      expect(dto.toDomain, throwsA(isA<DataParsingFailure>()));
    });
  });

  group('mapping des priorités', () {
    final cases = <String, Priorite>{
      'haute': Priorite.haute,
      'moyenne': Priorite.moyenne,
      'basse': Priorite.basse,
    };

    for (final entry in cases.entries) {
      test('${entry.key} vers ${entry.value.name}', () {
        final dto = AgriVistaResponseDto.fromJson(
          _validJson(priorite: entry.key),
        );

        expect(dto.toDomain().interventions.single.priorite, entry.value);
      });
    }

    test('rejette une priorité inconnue avec une erreur contrôlée', () {
      final dto = AgriVistaResponseDto.fromJson(
        _validJson(priorite: 'urgente'),
      );

      expect(dto.toDomain, throwsA(isA<DataParsingFailure>()));
    });
  });

  test('rejette une date invalide avec une erreur contrôlée', () {
    final dto = AgriVistaResponseDto.fromJson(
      _validJson(datePrevue: 'date-invalide'),
    );

    expect(dto.toDomain, throwsA(isA<DataParsingFailure>()));
  });

  test('rejette un technicien dont un champ obligatoire est vide', () {
    final dto = AgriVistaResponseDto.fromJson(
      _validJson()
        ..['technicien'] = <String, Object?>{'id': ' ', 'nom': 'Marie Santini'},
    );

    expect(dto.toDomain, throwsA(isA<DataParsingFailure>()));
  });

  test('rejette des coordonnées hors limites géographiques', () {
    final json = _validJson();
    final intervention =
        (json['interventions']! as List<Object?>).single
            as Map<String, Object?>;
    intervention['latitude'] = 91.0;
    final dto = AgriVistaResponseDto.fromJson(json);

    expect(dto.toDomain, throwsA(isA<DataParsingFailure>()));
  });

  test('rejette un historique dont un champ obligatoire est vide', () {
    final json = _validJson();
    final intervention =
        (json['interventions']! as List<Object?>).single
            as Map<String, Object?>;
    intervention['historique'] = <Object?>[
      <String, Object?>{'date': '2026-06-10', 'action': ' '},
    ];
    final dto = AgriVistaResponseDto.fromJson(json);

    expect(dto.toDomain, throwsA(isA<DataParsingFailure>()));
  });
}

Map<String, Object?> _validJson({
  String statut = 'planifiee',
  String priorite = 'haute',
  String datePrevue = '2026-06-15',
}) {
  return <String, Object?>{
    'technicien': <String, Object?>{'id': 't-01', 'nom': 'Marie Santini'},
    'interventions': <Object?>[
      <String, Object?>{
        'id': 'itv-1001',
        'station': 'Station Nord',
        'domaine': 'Vignoble Patrimonio',
        'latitude': 42.703,
        'longitude': 9.347,
        'priorite': priorite,
        'statut': statut,
        'datePrevue': datePrevue,
        'description': "Remplacement du capteur d'humidite defectueux.",
        'historique': <Object?>[
          <String, Object?>{
            'date': '2026-06-10',
            'action': 'Intervention creee',
          },
        ],
      },
    ],
  };
}
