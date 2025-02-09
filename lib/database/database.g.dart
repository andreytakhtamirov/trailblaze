// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SearchFeaturesTable extends SearchFeatures
    with TableInfo<$SearchFeaturesTable, SearchFeature> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchFeaturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mapboxIdMeta =
      const VerificationMeta('mapboxId');
  @override
  late final GeneratedColumn<String> mapboxId = GeneratedColumn<String>(
      'mapbox_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _placeNameMeta =
      const VerificationMeta('placeName');
  @override
  late final GeneratedColumn<String> placeName = GeneratedColumn<String>(
      'place_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _geometryJsonMeta =
      const VerificationMeta('geometryJson');
  @override
  late final GeneratedColumn<String> geometryJson = GeneratedColumn<String>(
      'geometry_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
      'hidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("hidden" IN (0, 1))'));
  static const VerificationMeta _lastUsedMeta =
      const VerificationMeta('lastUsed');
  @override
  late final GeneratedColumn<int> lastUsed = GeneratedColumn<int>(
      'last_used', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, mapboxId, placeName, subtitle, geometryJson, hidden, lastUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_features';
  @override
  VerificationContext validateIntegrity(Insertable<SearchFeature> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mapbox_id')) {
      context.handle(_mapboxIdMeta,
          mapboxId.isAcceptableOrUnknown(data['mapbox_id']!, _mapboxIdMeta));
    } else if (isInserting) {
      context.missing(_mapboxIdMeta);
    }
    if (data.containsKey('place_name')) {
      context.handle(_placeNameMeta,
          placeName.isAcceptableOrUnknown(data['place_name']!, _placeNameMeta));
    } else if (isInserting) {
      context.missing(_placeNameMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('geometry_json')) {
      context.handle(
          _geometryJsonMeta,
          geometryJson.isAcceptableOrUnknown(
              data['geometry_json']!, _geometryJsonMeta));
    } else if (isInserting) {
      context.missing(_geometryJsonMeta);
    }
    if (data.containsKey('hidden')) {
      context.handle(_hiddenMeta,
          hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta));
    } else if (isInserting) {
      context.missing(_hiddenMeta);
    }
    if (data.containsKey('last_used')) {
      context.handle(_lastUsedMeta,
          lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta));
    } else if (isInserting) {
      context.missing(_lastUsedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchFeature map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchFeature(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mapboxId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mapbox_id'])!,
      placeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place_name'])!,
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle'])!,
      geometryJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}geometry_json'])!,
      hidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hidden'])!,
      lastUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_used'])!,
    );
  }

  @override
  $SearchFeaturesTable createAlias(String alias) {
    return $SearchFeaturesTable(attachedDatabase, alias);
  }
}

class SearchFeature extends DataClass implements Insertable<SearchFeature> {
  final int id;
  final String mapboxId;
  final String placeName;
  final String subtitle;
  final String geometryJson;
  final bool hidden;
  final int lastUsed;
  const SearchFeature(
      {required this.id,
      required this.mapboxId,
      required this.placeName,
      required this.subtitle,
      required this.geometryJson,
      required this.hidden,
      required this.lastUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mapbox_id'] = Variable<String>(mapboxId);
    map['place_name'] = Variable<String>(placeName);
    map['subtitle'] = Variable<String>(subtitle);
    map['geometry_json'] = Variable<String>(geometryJson);
    map['hidden'] = Variable<bool>(hidden);
    map['last_used'] = Variable<int>(lastUsed);
    return map;
  }

  SearchFeaturesCompanion toCompanion(bool nullToAbsent) {
    return SearchFeaturesCompanion(
      id: Value(id),
      mapboxId: Value(mapboxId),
      placeName: Value(placeName),
      subtitle: Value(subtitle),
      geometryJson: Value(geometryJson),
      hidden: Value(hidden),
      lastUsed: Value(lastUsed),
    );
  }

  factory SearchFeature.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchFeature(
      id: serializer.fromJson<int>(json['id']),
      mapboxId: serializer.fromJson<String>(json['mapboxId']),
      placeName: serializer.fromJson<String>(json['placeName']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      geometryJson: serializer.fromJson<String>(json['geometryJson']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      lastUsed: serializer.fromJson<int>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mapboxId': serializer.toJson<String>(mapboxId),
      'placeName': serializer.toJson<String>(placeName),
      'subtitle': serializer.toJson<String>(subtitle),
      'geometryJson': serializer.toJson<String>(geometryJson),
      'hidden': serializer.toJson<bool>(hidden),
      'lastUsed': serializer.toJson<int>(lastUsed),
    };
  }

  SearchFeature copyWith(
          {int? id,
          String? mapboxId,
          String? placeName,
          String? subtitle,
          String? geometryJson,
          bool? hidden,
          int? lastUsed}) =>
      SearchFeature(
        id: id ?? this.id,
        mapboxId: mapboxId ?? this.mapboxId,
        placeName: placeName ?? this.placeName,
        subtitle: subtitle ?? this.subtitle,
        geometryJson: geometryJson ?? this.geometryJson,
        hidden: hidden ?? this.hidden,
        lastUsed: lastUsed ?? this.lastUsed,
      );
  SearchFeature copyWithCompanion(SearchFeaturesCompanion data) {
    return SearchFeature(
      id: data.id.present ? data.id.value : this.id,
      mapboxId: data.mapboxId.present ? data.mapboxId.value : this.mapboxId,
      placeName: data.placeName.present ? data.placeName.value : this.placeName,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      geometryJson: data.geometryJson.present
          ? data.geometryJson.value
          : this.geometryJson,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchFeature(')
          ..write('id: $id, ')
          ..write('mapboxId: $mapboxId, ')
          ..write('placeName: $placeName, ')
          ..write('subtitle: $subtitle, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('hidden: $hidden, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, mapboxId, placeName, subtitle, geometryJson, hidden, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchFeature &&
          other.id == this.id &&
          other.mapboxId == this.mapboxId &&
          other.placeName == this.placeName &&
          other.subtitle == this.subtitle &&
          other.geometryJson == this.geometryJson &&
          other.hidden == this.hidden &&
          other.lastUsed == this.lastUsed);
}

class SearchFeaturesCompanion extends UpdateCompanion<SearchFeature> {
  final Value<int> id;
  final Value<String> mapboxId;
  final Value<String> placeName;
  final Value<String> subtitle;
  final Value<String> geometryJson;
  final Value<bool> hidden;
  final Value<int> lastUsed;
  const SearchFeaturesCompanion({
    this.id = const Value.absent(),
    this.mapboxId = const Value.absent(),
    this.placeName = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.geometryJson = const Value.absent(),
    this.hidden = const Value.absent(),
    this.lastUsed = const Value.absent(),
  });
  SearchFeaturesCompanion.insert({
    this.id = const Value.absent(),
    required String mapboxId,
    required String placeName,
    required String subtitle,
    required String geometryJson,
    required bool hidden,
    required int lastUsed,
  })  : mapboxId = Value(mapboxId),
        placeName = Value(placeName),
        subtitle = Value(subtitle),
        geometryJson = Value(geometryJson),
        hidden = Value(hidden),
        lastUsed = Value(lastUsed);
  static Insertable<SearchFeature> custom({
    Expression<int>? id,
    Expression<String>? mapboxId,
    Expression<String>? placeName,
    Expression<String>? subtitle,
    Expression<String>? geometryJson,
    Expression<bool>? hidden,
    Expression<int>? lastUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mapboxId != null) 'mapbox_id': mapboxId,
      if (placeName != null) 'place_name': placeName,
      if (subtitle != null) 'subtitle': subtitle,
      if (geometryJson != null) 'geometry_json': geometryJson,
      if (hidden != null) 'hidden': hidden,
      if (lastUsed != null) 'last_used': lastUsed,
    });
  }

  SearchFeaturesCompanion copyWith(
      {Value<int>? id,
      Value<String>? mapboxId,
      Value<String>? placeName,
      Value<String>? subtitle,
      Value<String>? geometryJson,
      Value<bool>? hidden,
      Value<int>? lastUsed}) {
    return SearchFeaturesCompanion(
      id: id ?? this.id,
      mapboxId: mapboxId ?? this.mapboxId,
      placeName: placeName ?? this.placeName,
      subtitle: subtitle ?? this.subtitle,
      geometryJson: geometryJson ?? this.geometryJson,
      hidden: hidden ?? this.hidden,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mapboxId.present) {
      map['mapbox_id'] = Variable<String>(mapboxId.value);
    }
    if (placeName.present) {
      map['place_name'] = Variable<String>(placeName.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (geometryJson.present) {
      map['geometry_json'] = Variable<String>(geometryJson.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<int>(lastUsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchFeaturesCompanion(')
          ..write('id: $id, ')
          ..write('mapboxId: $mapboxId, ')
          ..write('placeName: $placeName, ')
          ..write('subtitle: $subtitle, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('hidden: $hidden, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }
}

class $NearbyParksTable extends NearbyParks
    with TableInfo<$NearbyParksTable, NearbyPark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NearbyParksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _distanceMetersMeta =
      const VerificationMeta('distanceMeters');
  @override
  late final GeneratedColumn<int> distanceMeters = GeneratedColumn<int>(
      'distance_meters', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _featuresMeta =
      const VerificationMeta('features');
  @override
  late final GeneratedColumn<String> features = GeneratedColumn<String>(
      'features', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUsedMeta =
      const VerificationMeta('lastUsed');
  @override
  late final GeneratedColumn<int> lastUsed = GeneratedColumn<int>(
      'last_used', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, distanceMeters, latitude, longitude, features, lastUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nearby_parks';
  @override
  VerificationContext validateIntegrity(Insertable<NearbyPark> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
          _distanceMetersMeta,
          distanceMeters.isAcceptableOrUnknown(
              data['distance_meters']!, _distanceMetersMeta));
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('features')) {
      context.handle(_featuresMeta,
          features.isAcceptableOrUnknown(data['features']!, _featuresMeta));
    } else if (isInserting) {
      context.missing(_featuresMeta);
    }
    if (data.containsKey('last_used')) {
      context.handle(_lastUsedMeta,
          lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta));
    } else if (isInserting) {
      context.missing(_lastUsedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NearbyPark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NearbyPark(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      distanceMeters: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}distance_meters'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      features: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}features'])!,
      lastUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_used'])!,
    );
  }

  @override
  $NearbyParksTable createAlias(String alias) {
    return $NearbyParksTable(attachedDatabase, alias);
  }
}

class NearbyPark extends DataClass implements Insertable<NearbyPark> {
  final int id;
  final int distanceMeters;
  final double latitude;
  final double longitude;
  final String features;
  final int lastUsed;
  const NearbyPark(
      {required this.id,
      required this.distanceMeters,
      required this.latitude,
      required this.longitude,
      required this.features,
      required this.lastUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['distance_meters'] = Variable<int>(distanceMeters);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['features'] = Variable<String>(features);
    map['last_used'] = Variable<int>(lastUsed);
    return map;
  }

  NearbyParksCompanion toCompanion(bool nullToAbsent) {
    return NearbyParksCompanion(
      id: Value(id),
      distanceMeters: Value(distanceMeters),
      latitude: Value(latitude),
      longitude: Value(longitude),
      features: Value(features),
      lastUsed: Value(lastUsed),
    );
  }

  factory NearbyPark.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NearbyPark(
      id: serializer.fromJson<int>(json['id']),
      distanceMeters: serializer.fromJson<int>(json['distanceMeters']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      features: serializer.fromJson<String>(json['features']),
      lastUsed: serializer.fromJson<int>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'distanceMeters': serializer.toJson<int>(distanceMeters),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'features': serializer.toJson<String>(features),
      'lastUsed': serializer.toJson<int>(lastUsed),
    };
  }

  NearbyPark copyWith(
          {int? id,
          int? distanceMeters,
          double? latitude,
          double? longitude,
          String? features,
          int? lastUsed}) =>
      NearbyPark(
        id: id ?? this.id,
        distanceMeters: distanceMeters ?? this.distanceMeters,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        features: features ?? this.features,
        lastUsed: lastUsed ?? this.lastUsed,
      );
  NearbyPark copyWithCompanion(NearbyParksCompanion data) {
    return NearbyPark(
      id: data.id.present ? data.id.value : this.id,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      features: data.features.present ? data.features.value : this.features,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NearbyPark(')
          ..write('id: $id, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('features: $features, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, distanceMeters, latitude, longitude, features, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NearbyPark &&
          other.id == this.id &&
          other.distanceMeters == this.distanceMeters &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.features == this.features &&
          other.lastUsed == this.lastUsed);
}

class NearbyParksCompanion extends UpdateCompanion<NearbyPark> {
  final Value<int> id;
  final Value<int> distanceMeters;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> features;
  final Value<int> lastUsed;
  const NearbyParksCompanion({
    this.id = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.features = const Value.absent(),
    this.lastUsed = const Value.absent(),
  });
  NearbyParksCompanion.insert({
    this.id = const Value.absent(),
    required int distanceMeters,
    required double latitude,
    required double longitude,
    required String features,
    required int lastUsed,
  })  : distanceMeters = Value(distanceMeters),
        latitude = Value(latitude),
        longitude = Value(longitude),
        features = Value(features),
        lastUsed = Value(lastUsed);
  static Insertable<NearbyPark> custom({
    Expression<int>? id,
    Expression<int>? distanceMeters,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? features,
    Expression<int>? lastUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (features != null) 'features': features,
      if (lastUsed != null) 'last_used': lastUsed,
    });
  }

  NearbyParksCompanion copyWith(
      {Value<int>? id,
      Value<int>? distanceMeters,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<String>? features,
      Value<int>? lastUsed}) {
    return NearbyParksCompanion(
      id: id ?? this.id,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      features: features ?? this.features,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<int>(distanceMeters.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (features.present) {
      map['features'] = Variable<String>(features.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<int>(lastUsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NearbyParksCompanion(')
          ..write('id: $id, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('features: $features, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SearchFeaturesTable searchFeatures = $SearchFeaturesTable(this);
  late final $NearbyParksTable nearbyParks = $NearbyParksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [searchFeatures, nearbyParks];
}

typedef $$SearchFeaturesTableCreateCompanionBuilder = SearchFeaturesCompanion
    Function({
  Value<int> id,
  required String mapboxId,
  required String placeName,
  required String subtitle,
  required String geometryJson,
  required bool hidden,
  required int lastUsed,
});
typedef $$SearchFeaturesTableUpdateCompanionBuilder = SearchFeaturesCompanion
    Function({
  Value<int> id,
  Value<String> mapboxId,
  Value<String> placeName,
  Value<String> subtitle,
  Value<String> geometryJson,
  Value<bool> hidden,
  Value<int> lastUsed,
});

class $$SearchFeaturesTableFilterComposer
    extends Composer<_$AppDatabase, $SearchFeaturesTable> {
  $$SearchFeaturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mapboxId => $composableBuilder(
      column: $table.mapboxId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeName => $composableBuilder(
      column: $table.placeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geometryJson => $composableBuilder(
      column: $table.geometryJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hidden => $composableBuilder(
      column: $table.hidden, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnFilters(column));
}

class $$SearchFeaturesTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchFeaturesTable> {
  $$SearchFeaturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mapboxId => $composableBuilder(
      column: $table.mapboxId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeName => $composableBuilder(
      column: $table.placeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geometryJson => $composableBuilder(
      column: $table.geometryJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hidden => $composableBuilder(
      column: $table.hidden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnOrderings(column));
}

class $$SearchFeaturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchFeaturesTable> {
  $$SearchFeaturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mapboxId =>
      $composableBuilder(column: $table.mapboxId, builder: (column) => column);

  GeneratedColumn<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get geometryJson => $composableBuilder(
      column: $table.geometryJson, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<int> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);
}

class $$SearchFeaturesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SearchFeaturesTable,
    SearchFeature,
    $$SearchFeaturesTableFilterComposer,
    $$SearchFeaturesTableOrderingComposer,
    $$SearchFeaturesTableAnnotationComposer,
    $$SearchFeaturesTableCreateCompanionBuilder,
    $$SearchFeaturesTableUpdateCompanionBuilder,
    (
      SearchFeature,
      BaseReferences<_$AppDatabase, $SearchFeaturesTable, SearchFeature>
    ),
    SearchFeature,
    PrefetchHooks Function()> {
  $$SearchFeaturesTableTableManager(
      _$AppDatabase db, $SearchFeaturesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchFeaturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchFeaturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchFeaturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> mapboxId = const Value.absent(),
            Value<String> placeName = const Value.absent(),
            Value<String> subtitle = const Value.absent(),
            Value<String> geometryJson = const Value.absent(),
            Value<bool> hidden = const Value.absent(),
            Value<int> lastUsed = const Value.absent(),
          }) =>
              SearchFeaturesCompanion(
            id: id,
            mapboxId: mapboxId,
            placeName: placeName,
            subtitle: subtitle,
            geometryJson: geometryJson,
            hidden: hidden,
            lastUsed: lastUsed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String mapboxId,
            required String placeName,
            required String subtitle,
            required String geometryJson,
            required bool hidden,
            required int lastUsed,
          }) =>
              SearchFeaturesCompanion.insert(
            id: id,
            mapboxId: mapboxId,
            placeName: placeName,
            subtitle: subtitle,
            geometryJson: geometryJson,
            hidden: hidden,
            lastUsed: lastUsed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SearchFeaturesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SearchFeaturesTable,
    SearchFeature,
    $$SearchFeaturesTableFilterComposer,
    $$SearchFeaturesTableOrderingComposer,
    $$SearchFeaturesTableAnnotationComposer,
    $$SearchFeaturesTableCreateCompanionBuilder,
    $$SearchFeaturesTableUpdateCompanionBuilder,
    (
      SearchFeature,
      BaseReferences<_$AppDatabase, $SearchFeaturesTable, SearchFeature>
    ),
    SearchFeature,
    PrefetchHooks Function()>;
typedef $$NearbyParksTableCreateCompanionBuilder = NearbyParksCompanion
    Function({
  Value<int> id,
  required int distanceMeters,
  required double latitude,
  required double longitude,
  required String features,
  required int lastUsed,
});
typedef $$NearbyParksTableUpdateCompanionBuilder = NearbyParksCompanion
    Function({
  Value<int> id,
  Value<int> distanceMeters,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> features,
  Value<int> lastUsed,
});

class $$NearbyParksTableFilterComposer
    extends Composer<_$AppDatabase, $NearbyParksTable> {
  $$NearbyParksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get distanceMeters => $composableBuilder(
      column: $table.distanceMeters,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get features => $composableBuilder(
      column: $table.features, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnFilters(column));
}

class $$NearbyParksTableOrderingComposer
    extends Composer<_$AppDatabase, $NearbyParksTable> {
  $$NearbyParksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get distanceMeters => $composableBuilder(
      column: $table.distanceMeters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get features => $composableBuilder(
      column: $table.features, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnOrderings(column));
}

class $$NearbyParksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NearbyParksTable> {
  $$NearbyParksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get distanceMeters => $composableBuilder(
      column: $table.distanceMeters, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get features =>
      $composableBuilder(column: $table.features, builder: (column) => column);

  GeneratedColumn<int> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);
}

class $$NearbyParksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NearbyParksTable,
    NearbyPark,
    $$NearbyParksTableFilterComposer,
    $$NearbyParksTableOrderingComposer,
    $$NearbyParksTableAnnotationComposer,
    $$NearbyParksTableCreateCompanionBuilder,
    $$NearbyParksTableUpdateCompanionBuilder,
    (NearbyPark, BaseReferences<_$AppDatabase, $NearbyParksTable, NearbyPark>),
    NearbyPark,
    PrefetchHooks Function()> {
  $$NearbyParksTableTableManager(_$AppDatabase db, $NearbyParksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NearbyParksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NearbyParksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NearbyParksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> distanceMeters = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<String> features = const Value.absent(),
            Value<int> lastUsed = const Value.absent(),
          }) =>
              NearbyParksCompanion(
            id: id,
            distanceMeters: distanceMeters,
            latitude: latitude,
            longitude: longitude,
            features: features,
            lastUsed: lastUsed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int distanceMeters,
            required double latitude,
            required double longitude,
            required String features,
            required int lastUsed,
          }) =>
              NearbyParksCompanion.insert(
            id: id,
            distanceMeters: distanceMeters,
            latitude: latitude,
            longitude: longitude,
            features: features,
            lastUsed: lastUsed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NearbyParksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NearbyParksTable,
    NearbyPark,
    $$NearbyParksTableFilterComposer,
    $$NearbyParksTableOrderingComposer,
    $$NearbyParksTableAnnotationComposer,
    $$NearbyParksTableCreateCompanionBuilder,
    $$NearbyParksTableUpdateCompanionBuilder,
    (NearbyPark, BaseReferences<_$AppDatabase, $NearbyParksTable, NearbyPark>),
    NearbyPark,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SearchFeaturesTableTableManager get searchFeatures =>
      $$SearchFeaturesTableTableManager(_db, _db.searchFeatures);
  $$NearbyParksTableTableManager get nearbyParks =>
      $$NearbyParksTableTableManager(_db, _db.nearbyParks);
}
