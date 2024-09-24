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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabaseManager get managers => _$AppDatabaseManager(this);
  late final $SearchFeaturesTable searchFeatures = $SearchFeaturesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [searchFeatures];
}

typedef $$SearchFeaturesTableInsertCompanionBuilder = SearchFeaturesCompanion
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

class $$SearchFeaturesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SearchFeaturesTable,
    SearchFeature,
    $$SearchFeaturesTableFilterComposer,
    $$SearchFeaturesTableOrderingComposer,
    $$SearchFeaturesTableProcessedTableManager,
    $$SearchFeaturesTableInsertCompanionBuilder,
    $$SearchFeaturesTableUpdateCompanionBuilder> {
  $$SearchFeaturesTableTableManager(
      _$AppDatabase db, $SearchFeaturesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SearchFeaturesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SearchFeaturesTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$SearchFeaturesTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
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
          getInsertCompanionBuilder: ({
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
        ));
}

class $$SearchFeaturesTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $SearchFeaturesTable,
    SearchFeature,
    $$SearchFeaturesTableFilterComposer,
    $$SearchFeaturesTableOrderingComposer,
    $$SearchFeaturesTableProcessedTableManager,
    $$SearchFeaturesTableInsertCompanionBuilder,
    $$SearchFeaturesTableUpdateCompanionBuilder> {
  $$SearchFeaturesTableProcessedTableManager(super.$state);
}

class $$SearchFeaturesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SearchFeaturesTable> {
  $$SearchFeaturesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mapboxId => $state.composableBuilder(
      column: $state.table.mapboxId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get placeName => $state.composableBuilder(
      column: $state.table.placeName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get subtitle => $state.composableBuilder(
      column: $state.table.subtitle,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get geometryJson => $state.composableBuilder(
      column: $state.table.geometryJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get hidden => $state.composableBuilder(
      column: $state.table.hidden,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get lastUsed => $state.composableBuilder(
      column: $state.table.lastUsed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SearchFeaturesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SearchFeaturesTable> {
  $$SearchFeaturesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mapboxId => $state.composableBuilder(
      column: $state.table.mapboxId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get placeName => $state.composableBuilder(
      column: $state.table.placeName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get subtitle => $state.composableBuilder(
      column: $state.table.subtitle,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get geometryJson => $state.composableBuilder(
      column: $state.table.geometryJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get hidden => $state.composableBuilder(
      column: $state.table.hidden,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get lastUsed => $state.composableBuilder(
      column: $state.table.lastUsed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$AppDatabaseManager {
  final _$AppDatabase _db;
  _$AppDatabaseManager(this._db);
  $$SearchFeaturesTableTableManager get searchFeatures =>
      $$SearchFeaturesTableTableManager(_db, _db.searchFeatures);
}
