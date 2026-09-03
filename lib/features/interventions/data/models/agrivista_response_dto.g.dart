// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agrivista_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AgriVistaResponseDto _$AgriVistaResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AgriVistaResponseDto', json, ($checkedConvert) {
  final val = _AgriVistaResponseDto(
    technicien: $checkedConvert(
      'technicien',
      (v) => TechnicienDto.fromJson(v as Map<String, dynamic>),
    ),
    interventions: $checkedConvert(
      'interventions',
      (v) => (v as List<dynamic>)
          .map((e) => InterventionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AgriVistaResponseDtoToJson(
  _AgriVistaResponseDto instance,
) => <String, dynamic>{
  'technicien': instance.technicien,
  'interventions': instance.interventions,
};

_TechnicienDto _$TechnicienDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TechnicienDto', json, ($checkedConvert) {
      final val = _TechnicienDto(
        id: $checkedConvert('id', (v) => v as String),
        nom: $checkedConvert('nom', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TechnicienDtoToJson(_TechnicienDto instance) =>
    <String, dynamic>{'id': instance.id, 'nom': instance.nom};

_InterventionDto _$InterventionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_InterventionDto', json, ($checkedConvert) {
      final val = _InterventionDto(
        id: $checkedConvert('id', (v) => v as String),
        station: $checkedConvert('station', (v) => v as String),
        domaine: $checkedConvert('domaine', (v) => v as String),
        latitude: $checkedConvert('latitude', (v) => (v as num).toDouble()),
        longitude: $checkedConvert('longitude', (v) => (v as num).toDouble()),
        priorite: $checkedConvert('priorite', (v) => v as String),
        statut: $checkedConvert('statut', (v) => v as String),
        datePrevue: $checkedConvert('datePrevue', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        historique: $checkedConvert(
          'historique',
          (v) => (v as List<dynamic>)
              .map(
                (e) => ActionHistoriqueDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$InterventionDtoToJson(_InterventionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'station': instance.station,
      'domaine': instance.domaine,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'priorite': instance.priorite,
      'statut': instance.statut,
      'datePrevue': instance.datePrevue,
      'description': instance.description,
      'historique': instance.historique,
    };

_ActionHistoriqueDto _$ActionHistoriqueDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ActionHistoriqueDto', json, ($checkedConvert) {
      final val = _ActionHistoriqueDto(
        date: $checkedConvert('date', (v) => v as String),
        action: $checkedConvert('action', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ActionHistoriqueDtoToJson(
  _ActionHistoriqueDto instance,
) => <String, dynamic>{'date': instance.date, 'action': instance.action};
