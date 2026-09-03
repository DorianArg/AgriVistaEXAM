// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agrivista_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AgriVistaResponseDto {

 TechnicienDto get technicien; List<InterventionDto> get interventions;
/// Create a copy of AgriVistaResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgriVistaResponseDtoCopyWith<AgriVistaResponseDto> get copyWith => _$AgriVistaResponseDtoCopyWithImpl<AgriVistaResponseDto>(this as AgriVistaResponseDto, _$identity);

  /// Serializes this AgriVistaResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgriVistaResponseDto&&(identical(other.technicien, technicien) || other.technicien == technicien)&&const DeepCollectionEquality().equals(other.interventions, interventions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,technicien,const DeepCollectionEquality().hash(interventions));

@override
String toString() {
  return 'AgriVistaResponseDto(technicien: $technicien, interventions: $interventions)';
}


}

/// @nodoc
abstract mixin class $AgriVistaResponseDtoCopyWith<$Res>  {
  factory $AgriVistaResponseDtoCopyWith(AgriVistaResponseDto value, $Res Function(AgriVistaResponseDto) _then) = _$AgriVistaResponseDtoCopyWithImpl;
@useResult
$Res call({
 TechnicienDto technicien, List<InterventionDto> interventions
});


$TechnicienDtoCopyWith<$Res> get technicien;

}
/// @nodoc
class _$AgriVistaResponseDtoCopyWithImpl<$Res>
    implements $AgriVistaResponseDtoCopyWith<$Res> {
  _$AgriVistaResponseDtoCopyWithImpl(this._self, this._then);

  final AgriVistaResponseDto _self;
  final $Res Function(AgriVistaResponseDto) _then;

/// Create a copy of AgriVistaResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? technicien = null,Object? interventions = null,}) {
  return _then(_self.copyWith(
technicien: null == technicien ? _self.technicien : technicien // ignore: cast_nullable_to_non_nullable
as TechnicienDto,interventions: null == interventions ? _self.interventions : interventions // ignore: cast_nullable_to_non_nullable
as List<InterventionDto>,
  ));
}
/// Create a copy of AgriVistaResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TechnicienDtoCopyWith<$Res> get technicien {
  
  return $TechnicienDtoCopyWith<$Res>(_self.technicien, (value) {
    return _then(_self.copyWith(technicien: value));
  });
}
}


/// Adds pattern-matching-related methods to [AgriVistaResponseDto].
extension AgriVistaResponseDtoPatterns on AgriVistaResponseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgriVistaResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgriVistaResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgriVistaResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _AgriVistaResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgriVistaResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _AgriVistaResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TechnicienDto technicien,  List<InterventionDto> interventions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgriVistaResponseDto() when $default != null:
return $default(_that.technicien,_that.interventions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TechnicienDto technicien,  List<InterventionDto> interventions)  $default,) {final _that = this;
switch (_that) {
case _AgriVistaResponseDto():
return $default(_that.technicien,_that.interventions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TechnicienDto technicien,  List<InterventionDto> interventions)?  $default,) {final _that = this;
switch (_that) {
case _AgriVistaResponseDto() when $default != null:
return $default(_that.technicien,_that.interventions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgriVistaResponseDto implements AgriVistaResponseDto {
  const _AgriVistaResponseDto({required this.technicien, required final  List<InterventionDto> interventions}): _interventions = interventions;
  factory _AgriVistaResponseDto.fromJson(Map<String, dynamic> json) => _$AgriVistaResponseDtoFromJson(json);

@override final  TechnicienDto technicien;
 final  List<InterventionDto> _interventions;
@override List<InterventionDto> get interventions {
  if (_interventions is EqualUnmodifiableListView) return _interventions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interventions);
}


/// Create a copy of AgriVistaResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgriVistaResponseDtoCopyWith<_AgriVistaResponseDto> get copyWith => __$AgriVistaResponseDtoCopyWithImpl<_AgriVistaResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgriVistaResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgriVistaResponseDto&&(identical(other.technicien, technicien) || other.technicien == technicien)&&const DeepCollectionEquality().equals(other._interventions, _interventions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,technicien,const DeepCollectionEquality().hash(_interventions));

@override
String toString() {
  return 'AgriVistaResponseDto(technicien: $technicien, interventions: $interventions)';
}


}

/// @nodoc
abstract mixin class _$AgriVistaResponseDtoCopyWith<$Res> implements $AgriVistaResponseDtoCopyWith<$Res> {
  factory _$AgriVistaResponseDtoCopyWith(_AgriVistaResponseDto value, $Res Function(_AgriVistaResponseDto) _then) = __$AgriVistaResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 TechnicienDto technicien, List<InterventionDto> interventions
});


@override $TechnicienDtoCopyWith<$Res> get technicien;

}
/// @nodoc
class __$AgriVistaResponseDtoCopyWithImpl<$Res>
    implements _$AgriVistaResponseDtoCopyWith<$Res> {
  __$AgriVistaResponseDtoCopyWithImpl(this._self, this._then);

  final _AgriVistaResponseDto _self;
  final $Res Function(_AgriVistaResponseDto) _then;

/// Create a copy of AgriVistaResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? technicien = null,Object? interventions = null,}) {
  return _then(_AgriVistaResponseDto(
technicien: null == technicien ? _self.technicien : technicien // ignore: cast_nullable_to_non_nullable
as TechnicienDto,interventions: null == interventions ? _self._interventions : interventions // ignore: cast_nullable_to_non_nullable
as List<InterventionDto>,
  ));
}

/// Create a copy of AgriVistaResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TechnicienDtoCopyWith<$Res> get technicien {
  
  return $TechnicienDtoCopyWith<$Res>(_self.technicien, (value) {
    return _then(_self.copyWith(technicien: value));
  });
}
}


/// @nodoc
mixin _$TechnicienDto {

 String get id; String get nom;
/// Create a copy of TechnicienDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TechnicienDtoCopyWith<TechnicienDto> get copyWith => _$TechnicienDtoCopyWithImpl<TechnicienDto>(this as TechnicienDto, _$identity);

  /// Serializes this TechnicienDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TechnicienDto&&(identical(other.id, id) || other.id == id)&&(identical(other.nom, nom) || other.nom == nom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nom);

@override
String toString() {
  return 'TechnicienDto(id: $id, nom: $nom)';
}


}

/// @nodoc
abstract mixin class $TechnicienDtoCopyWith<$Res>  {
  factory $TechnicienDtoCopyWith(TechnicienDto value, $Res Function(TechnicienDto) _then) = _$TechnicienDtoCopyWithImpl;
@useResult
$Res call({
 String id, String nom
});




}
/// @nodoc
class _$TechnicienDtoCopyWithImpl<$Res>
    implements $TechnicienDtoCopyWith<$Res> {
  _$TechnicienDtoCopyWithImpl(this._self, this._then);

  final TechnicienDto _self;
  final $Res Function(TechnicienDto) _then;

/// Create a copy of TechnicienDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nom = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TechnicienDto].
extension TechnicienDtoPatterns on TechnicienDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TechnicienDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TechnicienDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TechnicienDto value)  $default,){
final _that = this;
switch (_that) {
case _TechnicienDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TechnicienDto value)?  $default,){
final _that = this;
switch (_that) {
case _TechnicienDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TechnicienDto() when $default != null:
return $default(_that.id,_that.nom);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nom)  $default,) {final _that = this;
switch (_that) {
case _TechnicienDto():
return $default(_that.id,_that.nom);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nom)?  $default,) {final _that = this;
switch (_that) {
case _TechnicienDto() when $default != null:
return $default(_that.id,_that.nom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TechnicienDto implements TechnicienDto {
  const _TechnicienDto({required this.id, required this.nom});
  factory _TechnicienDto.fromJson(Map<String, dynamic> json) => _$TechnicienDtoFromJson(json);

@override final  String id;
@override final  String nom;

/// Create a copy of TechnicienDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TechnicienDtoCopyWith<_TechnicienDto> get copyWith => __$TechnicienDtoCopyWithImpl<_TechnicienDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TechnicienDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TechnicienDto&&(identical(other.id, id) || other.id == id)&&(identical(other.nom, nom) || other.nom == nom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nom);

@override
String toString() {
  return 'TechnicienDto(id: $id, nom: $nom)';
}


}

/// @nodoc
abstract mixin class _$TechnicienDtoCopyWith<$Res> implements $TechnicienDtoCopyWith<$Res> {
  factory _$TechnicienDtoCopyWith(_TechnicienDto value, $Res Function(_TechnicienDto) _then) = __$TechnicienDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String nom
});




}
/// @nodoc
class __$TechnicienDtoCopyWithImpl<$Res>
    implements _$TechnicienDtoCopyWith<$Res> {
  __$TechnicienDtoCopyWithImpl(this._self, this._then);

  final _TechnicienDto _self;
  final $Res Function(_TechnicienDto) _then;

/// Create a copy of TechnicienDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nom = null,}) {
  return _then(_TechnicienDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$InterventionDto {

 String get id; String get station; String get domaine; double get latitude; double get longitude; String get priorite; String get statut; String get datePrevue; String get description; List<ActionHistoriqueDto> get historique;
/// Create a copy of InterventionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterventionDtoCopyWith<InterventionDto> get copyWith => _$InterventionDtoCopyWithImpl<InterventionDto>(this as InterventionDto, _$identity);

  /// Serializes this InterventionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterventionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.station, station) || other.station == station)&&(identical(other.domaine, domaine) || other.domaine == domaine)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.priorite, priorite) || other.priorite == priorite)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.datePrevue, datePrevue) || other.datePrevue == datePrevue)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.historique, historique));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,station,domaine,latitude,longitude,priorite,statut,datePrevue,description,const DeepCollectionEquality().hash(historique));

@override
String toString() {
  return 'InterventionDto(id: $id, station: $station, domaine: $domaine, latitude: $latitude, longitude: $longitude, priorite: $priorite, statut: $statut, datePrevue: $datePrevue, description: $description, historique: $historique)';
}


}

/// @nodoc
abstract mixin class $InterventionDtoCopyWith<$Res>  {
  factory $InterventionDtoCopyWith(InterventionDto value, $Res Function(InterventionDto) _then) = _$InterventionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String station, String domaine, double latitude, double longitude, String priorite, String statut, String datePrevue, String description, List<ActionHistoriqueDto> historique
});




}
/// @nodoc
class _$InterventionDtoCopyWithImpl<$Res>
    implements $InterventionDtoCopyWith<$Res> {
  _$InterventionDtoCopyWithImpl(this._self, this._then);

  final InterventionDto _self;
  final $Res Function(InterventionDto) _then;

/// Create a copy of InterventionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? station = null,Object? domaine = null,Object? latitude = null,Object? longitude = null,Object? priorite = null,Object? statut = null,Object? datePrevue = null,Object? description = null,Object? historique = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,station: null == station ? _self.station : station // ignore: cast_nullable_to_non_nullable
as String,domaine: null == domaine ? _self.domaine : domaine // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,priorite: null == priorite ? _self.priorite : priorite // ignore: cast_nullable_to_non_nullable
as String,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,datePrevue: null == datePrevue ? _self.datePrevue : datePrevue // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,historique: null == historique ? _self.historique : historique // ignore: cast_nullable_to_non_nullable
as List<ActionHistoriqueDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [InterventionDto].
extension InterventionDtoPatterns on InterventionDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterventionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterventionDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterventionDto value)  $default,){
final _that = this;
switch (_that) {
case _InterventionDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterventionDto value)?  $default,){
final _that = this;
switch (_that) {
case _InterventionDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String station,  String domaine,  double latitude,  double longitude,  String priorite,  String statut,  String datePrevue,  String description,  List<ActionHistoriqueDto> historique)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterventionDto() when $default != null:
return $default(_that.id,_that.station,_that.domaine,_that.latitude,_that.longitude,_that.priorite,_that.statut,_that.datePrevue,_that.description,_that.historique);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String station,  String domaine,  double latitude,  double longitude,  String priorite,  String statut,  String datePrevue,  String description,  List<ActionHistoriqueDto> historique)  $default,) {final _that = this;
switch (_that) {
case _InterventionDto():
return $default(_that.id,_that.station,_that.domaine,_that.latitude,_that.longitude,_that.priorite,_that.statut,_that.datePrevue,_that.description,_that.historique);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String station,  String domaine,  double latitude,  double longitude,  String priorite,  String statut,  String datePrevue,  String description,  List<ActionHistoriqueDto> historique)?  $default,) {final _that = this;
switch (_that) {
case _InterventionDto() when $default != null:
return $default(_that.id,_that.station,_that.domaine,_that.latitude,_that.longitude,_that.priorite,_that.statut,_that.datePrevue,_that.description,_that.historique);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InterventionDto implements InterventionDto {
  const _InterventionDto({required this.id, required this.station, required this.domaine, required this.latitude, required this.longitude, required this.priorite, required this.statut, required this.datePrevue, required this.description, required final  List<ActionHistoriqueDto> historique}): _historique = historique;
  factory _InterventionDto.fromJson(Map<String, dynamic> json) => _$InterventionDtoFromJson(json);

@override final  String id;
@override final  String station;
@override final  String domaine;
@override final  double latitude;
@override final  double longitude;
@override final  String priorite;
@override final  String statut;
@override final  String datePrevue;
@override final  String description;
 final  List<ActionHistoriqueDto> _historique;
@override List<ActionHistoriqueDto> get historique {
  if (_historique is EqualUnmodifiableListView) return _historique;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_historique);
}


/// Create a copy of InterventionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterventionDtoCopyWith<_InterventionDto> get copyWith => __$InterventionDtoCopyWithImpl<_InterventionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterventionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterventionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.station, station) || other.station == station)&&(identical(other.domaine, domaine) || other.domaine == domaine)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.priorite, priorite) || other.priorite == priorite)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.datePrevue, datePrevue) || other.datePrevue == datePrevue)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._historique, _historique));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,station,domaine,latitude,longitude,priorite,statut,datePrevue,description,const DeepCollectionEquality().hash(_historique));

@override
String toString() {
  return 'InterventionDto(id: $id, station: $station, domaine: $domaine, latitude: $latitude, longitude: $longitude, priorite: $priorite, statut: $statut, datePrevue: $datePrevue, description: $description, historique: $historique)';
}


}

/// @nodoc
abstract mixin class _$InterventionDtoCopyWith<$Res> implements $InterventionDtoCopyWith<$Res> {
  factory _$InterventionDtoCopyWith(_InterventionDto value, $Res Function(_InterventionDto) _then) = __$InterventionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String station, String domaine, double latitude, double longitude, String priorite, String statut, String datePrevue, String description, List<ActionHistoriqueDto> historique
});




}
/// @nodoc
class __$InterventionDtoCopyWithImpl<$Res>
    implements _$InterventionDtoCopyWith<$Res> {
  __$InterventionDtoCopyWithImpl(this._self, this._then);

  final _InterventionDto _self;
  final $Res Function(_InterventionDto) _then;

/// Create a copy of InterventionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? station = null,Object? domaine = null,Object? latitude = null,Object? longitude = null,Object? priorite = null,Object? statut = null,Object? datePrevue = null,Object? description = null,Object? historique = null,}) {
  return _then(_InterventionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,station: null == station ? _self.station : station // ignore: cast_nullable_to_non_nullable
as String,domaine: null == domaine ? _self.domaine : domaine // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,priorite: null == priorite ? _self.priorite : priorite // ignore: cast_nullable_to_non_nullable
as String,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,datePrevue: null == datePrevue ? _self.datePrevue : datePrevue // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,historique: null == historique ? _self._historique : historique // ignore: cast_nullable_to_non_nullable
as List<ActionHistoriqueDto>,
  ));
}


}


/// @nodoc
mixin _$ActionHistoriqueDto {

 String get date; String get action;
/// Create a copy of ActionHistoriqueDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionHistoriqueDtoCopyWith<ActionHistoriqueDto> get copyWith => _$ActionHistoriqueDtoCopyWithImpl<ActionHistoriqueDto>(this as ActionHistoriqueDto, _$identity);

  /// Serializes this ActionHistoriqueDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionHistoriqueDto&&(identical(other.date, date) || other.date == date)&&(identical(other.action, action) || other.action == action));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,action);

@override
String toString() {
  return 'ActionHistoriqueDto(date: $date, action: $action)';
}


}

/// @nodoc
abstract mixin class $ActionHistoriqueDtoCopyWith<$Res>  {
  factory $ActionHistoriqueDtoCopyWith(ActionHistoriqueDto value, $Res Function(ActionHistoriqueDto) _then) = _$ActionHistoriqueDtoCopyWithImpl;
@useResult
$Res call({
 String date, String action
});




}
/// @nodoc
class _$ActionHistoriqueDtoCopyWithImpl<$Res>
    implements $ActionHistoriqueDtoCopyWith<$Res> {
  _$ActionHistoriqueDtoCopyWithImpl(this._self, this._then);

  final ActionHistoriqueDto _self;
  final $Res Function(ActionHistoriqueDto) _then;

/// Create a copy of ActionHistoriqueDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? action = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ActionHistoriqueDto].
extension ActionHistoriqueDtoPatterns on ActionHistoriqueDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActionHistoriqueDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActionHistoriqueDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActionHistoriqueDto value)  $default,){
final _that = this;
switch (_that) {
case _ActionHistoriqueDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActionHistoriqueDto value)?  $default,){
final _that = this;
switch (_that) {
case _ActionHistoriqueDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String action)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActionHistoriqueDto() when $default != null:
return $default(_that.date,_that.action);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String action)  $default,) {final _that = this;
switch (_that) {
case _ActionHistoriqueDto():
return $default(_that.date,_that.action);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String action)?  $default,) {final _that = this;
switch (_that) {
case _ActionHistoriqueDto() when $default != null:
return $default(_that.date,_that.action);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActionHistoriqueDto implements ActionHistoriqueDto {
  const _ActionHistoriqueDto({required this.date, required this.action});
  factory _ActionHistoriqueDto.fromJson(Map<String, dynamic> json) => _$ActionHistoriqueDtoFromJson(json);

@override final  String date;
@override final  String action;

/// Create a copy of ActionHistoriqueDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionHistoriqueDtoCopyWith<_ActionHistoriqueDto> get copyWith => __$ActionHistoriqueDtoCopyWithImpl<_ActionHistoriqueDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActionHistoriqueDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionHistoriqueDto&&(identical(other.date, date) || other.date == date)&&(identical(other.action, action) || other.action == action));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,action);

@override
String toString() {
  return 'ActionHistoriqueDto(date: $date, action: $action)';
}


}

/// @nodoc
abstract mixin class _$ActionHistoriqueDtoCopyWith<$Res> implements $ActionHistoriqueDtoCopyWith<$Res> {
  factory _$ActionHistoriqueDtoCopyWith(_ActionHistoriqueDto value, $Res Function(_ActionHistoriqueDto) _then) = __$ActionHistoriqueDtoCopyWithImpl;
@override @useResult
$Res call({
 String date, String action
});




}
/// @nodoc
class __$ActionHistoriqueDtoCopyWithImpl<$Res>
    implements _$ActionHistoriqueDtoCopyWith<$Res> {
  __$ActionHistoriqueDtoCopyWithImpl(this._self, this._then);

  final _ActionHistoriqueDto _self;
  final $Res Function(_ActionHistoriqueDto) _then;

/// Create a copy of ActionHistoriqueDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? action = null,}) {
  return _then(_ActionHistoriqueDto(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
