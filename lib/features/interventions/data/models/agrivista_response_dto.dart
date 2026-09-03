import 'package:freezed_annotation/freezed_annotation.dart';

part 'agrivista_response_dto.freezed.dart';
part 'agrivista_response_dto.g.dart';

@freezed
abstract class AgriVistaResponseDto with _$AgriVistaResponseDto {
  const factory AgriVistaResponseDto({
    required TechnicienDto technicien,
    required List<InterventionDto> interventions,
  }) = _AgriVistaResponseDto;

  factory AgriVistaResponseDto.fromJson(Map<String, Object?> json) =>
      _$AgriVistaResponseDtoFromJson(json);
}

@freezed
abstract class TechnicienDto with _$TechnicienDto {
  const factory TechnicienDto({required String id, required String nom}) =
      _TechnicienDto;

  factory TechnicienDto.fromJson(Map<String, Object?> json) =>
      _$TechnicienDtoFromJson(json);
}

@freezed
abstract class InterventionDto with _$InterventionDto {
  const factory InterventionDto({
    required String id,
    required String station,
    required String domaine,
    required double latitude,
    required double longitude,
    required String priorite,
    required String statut,
    required String datePrevue,
    required String description,
    required List<ActionHistoriqueDto> historique,
  }) = _InterventionDto;

  factory InterventionDto.fromJson(Map<String, Object?> json) =>
      _$InterventionDtoFromJson(json);
}

@freezed
abstract class ActionHistoriqueDto with _$ActionHistoriqueDto {
  const factory ActionHistoriqueDto({
    required String date,
    required String action,
  }) = _ActionHistoriqueDto;

  factory ActionHistoriqueDto.fromJson(Map<String, Object?> json) =>
      _$ActionHistoriqueDtoFromJson(json);
}
