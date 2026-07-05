// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayRecordTableTable extends PlayRecordTable
    with TableInfo<$PlayRecordTableTable, PlayRecordTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayRecordTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackTitleMeta = const VerificationMeta(
    'trackTitle',
  );
  @override
  late final GeneratedColumn<String> trackTitle = GeneratedColumn<String>(
    'track_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistNameMeta = const VerificationMeta(
    'artistName',
  );
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
    'artist_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listenedDurationMilisecondMeta =
      const VerificationMeta('listenedDurationMilisecond');
  @override
  late final GeneratedColumn<int> listenedDurationMilisecond =
      GeneratedColumn<int>(
        'listened_duration_milisecond',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    trackTitle,
    artistName,
    sourceType,
    listenedDurationMilisecond,
    playedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_record_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayRecordTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('track_title')) {
      context.handle(
        _trackTitleMeta,
        trackTitle.isAcceptableOrUnknown(data['track_title']!, _trackTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_trackTitleMeta);
    }
    if (data.containsKey('artist_name')) {
      context.handle(
        _artistNameMeta,
        artistName.isAcceptableOrUnknown(data['artist_name']!, _artistNameMeta),
      );
    } else if (isInserting) {
      context.missing(_artistNameMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('listened_duration_milisecond')) {
      context.handle(
        _listenedDurationMilisecondMeta,
        listenedDurationMilisecond.isAcceptableOrUnknown(
          data['listened_duration_milisecond']!,
          _listenedDurationMilisecondMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_listenedDurationMilisecondMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayRecordTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayRecordTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      trackTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_title'],
      )!,
      artistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_name'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      listenedDurationMilisecond: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listened_duration_milisecond'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $PlayRecordTableTable createAlias(String alias) {
    return $PlayRecordTableTable(attachedDatabase, alias);
  }
}

class PlayRecordTableData extends DataClass
    implements Insertable<PlayRecordTableData> {
  final String id;
  final String trackId;
  final String trackTitle;
  final String artistName;
  final String sourceType;
  final int listenedDurationMilisecond;
  final DateTime playedAt;
  const PlayRecordTableData({
    required this.id,
    required this.trackId,
    required this.trackTitle,
    required this.artistName,
    required this.sourceType,
    required this.listenedDurationMilisecond,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['track_title'] = Variable<String>(trackTitle);
    map['artist_name'] = Variable<String>(artistName);
    map['source_type'] = Variable<String>(sourceType);
    map['listened_duration_milisecond'] = Variable<int>(
      listenedDurationMilisecond,
    );
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  PlayRecordTableCompanion toCompanion(bool nullToAbsent) {
    return PlayRecordTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      trackTitle: Value(trackTitle),
      artistName: Value(artistName),
      sourceType: Value(sourceType),
      listenedDurationMilisecond: Value(listenedDurationMilisecond),
      playedAt: Value(playedAt),
    );
  }

  factory PlayRecordTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayRecordTableData(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      trackTitle: serializer.fromJson<String>(json['trackTitle']),
      artistName: serializer.fromJson<String>(json['artistName']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      listenedDurationMilisecond: serializer.fromJson<int>(
        json['listenedDurationMilisecond'],
      ),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String>(trackId),
      'trackTitle': serializer.toJson<String>(trackTitle),
      'artistName': serializer.toJson<String>(artistName),
      'sourceType': serializer.toJson<String>(sourceType),
      'listenedDurationMilisecond': serializer.toJson<int>(
        listenedDurationMilisecond,
      ),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  PlayRecordTableData copyWith({
    String? id,
    String? trackId,
    String? trackTitle,
    String? artistName,
    String? sourceType,
    int? listenedDurationMilisecond,
    DateTime? playedAt,
  }) => PlayRecordTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    trackTitle: trackTitle ?? this.trackTitle,
    artistName: artistName ?? this.artistName,
    sourceType: sourceType ?? this.sourceType,
    listenedDurationMilisecond:
        listenedDurationMilisecond ?? this.listenedDurationMilisecond,
    playedAt: playedAt ?? this.playedAt,
  );
  PlayRecordTableData copyWithCompanion(PlayRecordTableCompanion data) {
    return PlayRecordTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      trackTitle: data.trackTitle.present
          ? data.trackTitle.value
          : this.trackTitle,
      artistName: data.artistName.present
          ? data.artistName.value
          : this.artistName,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      listenedDurationMilisecond: data.listenedDurationMilisecond.present
          ? data.listenedDurationMilisecond.value
          : this.listenedDurationMilisecond,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayRecordTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('trackTitle: $trackTitle, ')
          ..write('artistName: $artistName, ')
          ..write('sourceType: $sourceType, ')
          ..write('listenedDurationMilisecond: $listenedDurationMilisecond, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    trackTitle,
    artistName,
    sourceType,
    listenedDurationMilisecond,
    playedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayRecordTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.trackTitle == this.trackTitle &&
          other.artistName == this.artistName &&
          other.sourceType == this.sourceType &&
          other.listenedDurationMilisecond == this.listenedDurationMilisecond &&
          other.playedAt == this.playedAt);
}

class PlayRecordTableCompanion extends UpdateCompanion<PlayRecordTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> trackTitle;
  final Value<String> artistName;
  final Value<String> sourceType;
  final Value<int> listenedDurationMilisecond;
  final Value<DateTime> playedAt;
  final Value<int> rowid;
  const PlayRecordTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.trackTitle = const Value.absent(),
    this.artistName = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.listenedDurationMilisecond = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayRecordTableCompanion.insert({
    required String id,
    required String trackId,
    required String trackTitle,
    required String artistName,
    required String sourceType,
    required int listenedDurationMilisecond,
    required DateTime playedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       trackTitle = Value(trackTitle),
       artistName = Value(artistName),
       sourceType = Value(sourceType),
       listenedDurationMilisecond = Value(listenedDurationMilisecond),
       playedAt = Value(playedAt);
  static Insertable<PlayRecordTableData> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? trackTitle,
    Expression<String>? artistName,
    Expression<String>? sourceType,
    Expression<int>? listenedDurationMilisecond,
    Expression<DateTime>? playedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (trackTitle != null) 'track_title': trackTitle,
      if (artistName != null) 'artist_name': artistName,
      if (sourceType != null) 'source_type': sourceType,
      if (listenedDurationMilisecond != null)
        'listened_duration_milisecond': listenedDurationMilisecond,
      if (playedAt != null) 'played_at': playedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayRecordTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? trackTitle,
    Value<String>? artistName,
    Value<String>? sourceType,
    Value<int>? listenedDurationMilisecond,
    Value<DateTime>? playedAt,
    Value<int>? rowid,
  }) {
    return PlayRecordTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      artistName: artistName ?? this.artistName,
      sourceType: sourceType ?? this.sourceType,
      listenedDurationMilisecond:
          listenedDurationMilisecond ?? this.listenedDurationMilisecond,
      playedAt: playedAt ?? this.playedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (trackTitle.present) {
      map['track_title'] = Variable<String>(trackTitle.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (listenedDurationMilisecond.present) {
      map['listened_duration_milisecond'] = Variable<int>(
        listenedDurationMilisecond.value,
      );
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayRecordTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('trackTitle: $trackTitle, ')
          ..write('artistName: $artistName, ')
          ..write('sourceType: $sourceType, ')
          ..write('listenedDurationMilisecond: $listenedDurationMilisecond, ')
          ..write('playedAt: $playedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTableTable extends PlaylistTable
    with TableInfo<$PlaylistTableTable, PlaylistTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdsMeta = const VerificationMeta(
    'trackIds',
  );
  @override
  late final GeneratedColumn<String> trackIds = GeneratedColumn<String>(
    'track_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    trackIds,
    createdAt,
    description,
    imageUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('track_ids')) {
      context.handle(
        _trackIdsMeta,
        trackIds.isAcceptableOrUnknown(data['track_ids']!, _trackIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      trackIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_ids'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
    );
  }

  @override
  $PlaylistTableTable createAlias(String alias) {
    return $PlaylistTableTable(attachedDatabase, alias);
  }
}

class PlaylistTableData extends DataClass
    implements Insertable<PlaylistTableData> {
  final String id;
  final String name;
  final String trackIds;
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;
  const PlaylistTableData({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    this.description,
    this.imageUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['track_ids'] = Variable<String>(trackIds);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    return map;
  }

  PlaylistTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTableCompanion(
      id: Value(id),
      name: Value(name),
      trackIds: Value(trackIds),
      createdAt: Value(createdAt),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
    );
  }

  factory PlaylistTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      trackIds: serializer.fromJson<String>(json['trackIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'trackIds': serializer.toJson<String>(trackIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
    };
  }

  PlaylistTableData copyWith({
    String? id,
    String? name,
    String? trackIds,
    DateTime? createdAt,
    Value<String?> description = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
  }) => PlaylistTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    trackIds: trackIds ?? this.trackIds,
    createdAt: createdAt ?? this.createdAt,
    description: description.present ? description.value : this.description,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
  );
  PlaylistTableData copyWithCompanion(PlaylistTableCompanion data) {
    return PlaylistTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      trackIds: data.trackIds.present ? data.trackIds.value : this.trackIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trackIds: $trackIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, trackIds, createdAt, description, imageUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.trackIds == this.trackIds &&
          other.createdAt == this.createdAt &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl);
}

class PlaylistTableCompanion extends UpdateCompanion<PlaylistTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> trackIds;
  final Value<DateTime> createdAt;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<int> rowid;
  const PlaylistTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.trackIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTableCompanion.insert({
    required String id,
    required String name,
    required String trackIds,
    required DateTime createdAt,
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       trackIds = Value(trackIds),
       createdAt = Value(createdAt);
  static Insertable<PlaylistTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? trackIds,
    Expression<DateTime>? createdAt,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (trackIds != null) 'track_ids': trackIds,
      if (createdAt != null) 'created_at': createdAt,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? trackIds,
    Value<DateTime>? createdAt,
    Value<String?>? description,
    Value<String?>? imageUrl,
    Value<int>? rowid,
  }) {
    return PlaylistTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (trackIds.present) {
      map['track_ids'] = Variable<String>(trackIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trackIds: $trackIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackTableTable extends TrackTable
    with TableInfo<$TrackTableTable, TrackTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathToFileMeta = const VerificationMeta(
    'pathToFile',
  );
  @override
  late final GeneratedColumn<String> pathToFile = GeneratedColumn<String>(
    'path_to_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistIdsMeta = const VerificationMeta(
    'artistIds',
  );
  @override
  late final GeneratedColumn<String> artistIds = GeneratedColumn<String>(
    'artist_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistNamesMeta = const VerificationMeta(
    'artistNames',
  );
  @override
  late final GeneratedColumn<String> artistNames = GeneratedColumn<String>(
    'artist_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUriMeta = const VerificationMeta(
    'sourceUri',
  );
  @override
  late final GeneratedColumn<String> sourceUri = GeneratedColumn<String>(
    'source_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<String> addedAt = GeneratedColumn<String>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackDescriptorJsonMeta =
      const VerificationMeta('trackDescriptorJson');
  @override
  late final GeneratedColumn<String> trackDescriptorJson =
      GeneratedColumn<String>(
        'track_descriptor_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _embeddingMeta = const VerificationMeta(
    'embedding',
  );
  @override
  late final GeneratedColumn<String> embedding = GeneratedColumn<String>(
    'embedding',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    pathToFile,
    artistIds,
    artistNames,
    durationMs,
    sourceType,
    sourceUri,
    addedAt,
    album,
    imageUrl,
    trackDescriptorJson,
    embedding,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('path_to_file')) {
      context.handle(
        _pathToFileMeta,
        pathToFile.isAcceptableOrUnknown(
          data['path_to_file']!,
          _pathToFileMeta,
        ),
      );
    }
    if (data.containsKey('artist_ids')) {
      context.handle(
        _artistIdsMeta,
        artistIds.isAcceptableOrUnknown(data['artist_ids']!, _artistIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdsMeta);
    }
    if (data.containsKey('artist_names')) {
      context.handle(
        _artistNamesMeta,
        artistNames.isAcceptableOrUnknown(
          data['artist_names']!,
          _artistNamesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_artistNamesMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_uri')) {
      context.handle(
        _sourceUriMeta,
        sourceUri.isAcceptableOrUnknown(data['source_uri']!, _sourceUriMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUriMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('track_descriptor_json')) {
      context.handle(
        _trackDescriptorJsonMeta,
        trackDescriptorJson.isAcceptableOrUnknown(
          data['track_descriptor_json']!,
          _trackDescriptorJsonMeta,
        ),
      );
    }
    if (data.containsKey('embedding')) {
      context.handle(
        _embeddingMeta,
        embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      pathToFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path_to_file'],
      ),
      artistIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_ids'],
      )!,
      artistNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_names'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_uri'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_at'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      trackDescriptorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_descriptor_json'],
      ),
      embedding: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedding'],
      ),
    );
  }

  @override
  $TrackTableTable createAlias(String alias) {
    return $TrackTableTable(attachedDatabase, alias);
  }
}

class TrackTableData extends DataClass implements Insertable<TrackTableData> {
  final String id;
  final String title;
  final String? pathToFile;
  final String artistIds;
  final String artistNames;
  final int? durationMs;
  final String sourceType;
  final String sourceUri;
  final String? addedAt;
  final String? album;
  final String? imageUrl;
  final String? trackDescriptorJson;
  final String? embedding;
  const TrackTableData({
    required this.id,
    required this.title,
    this.pathToFile,
    required this.artistIds,
    required this.artistNames,
    this.durationMs,
    required this.sourceType,
    required this.sourceUri,
    this.addedAt,
    this.album,
    this.imageUrl,
    this.trackDescriptorJson,
    this.embedding,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || pathToFile != null) {
      map['path_to_file'] = Variable<String>(pathToFile);
    }
    map['artist_ids'] = Variable<String>(artistIds);
    map['artist_names'] = Variable<String>(artistNames);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['source_type'] = Variable<String>(sourceType);
    map['source_uri'] = Variable<String>(sourceUri);
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<String>(addedAt);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || trackDescriptorJson != null) {
      map['track_descriptor_json'] = Variable<String>(trackDescriptorJson);
    }
    if (!nullToAbsent || embedding != null) {
      map['embedding'] = Variable<String>(embedding);
    }
    return map;
  }

  TrackTableCompanion toCompanion(bool nullToAbsent) {
    return TrackTableCompanion(
      id: Value(id),
      title: Value(title),
      pathToFile: pathToFile == null && nullToAbsent
          ? const Value.absent()
          : Value(pathToFile),
      artistIds: Value(artistIds),
      artistNames: Value(artistNames),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      sourceType: Value(sourceType),
      sourceUri: Value(sourceUri),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      trackDescriptorJson: trackDescriptorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(trackDescriptorJson),
      embedding: embedding == null && nullToAbsent
          ? const Value.absent()
          : Value(embedding),
    );
  }

  factory TrackTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      pathToFile: serializer.fromJson<String?>(json['pathToFile']),
      artistIds: serializer.fromJson<String>(json['artistIds']),
      artistNames: serializer.fromJson<String>(json['artistNames']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceUri: serializer.fromJson<String>(json['sourceUri']),
      addedAt: serializer.fromJson<String?>(json['addedAt']),
      album: serializer.fromJson<String?>(json['album']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      trackDescriptorJson: serializer.fromJson<String?>(
        json['trackDescriptorJson'],
      ),
      embedding: serializer.fromJson<String?>(json['embedding']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'pathToFile': serializer.toJson<String?>(pathToFile),
      'artistIds': serializer.toJson<String>(artistIds),
      'artistNames': serializer.toJson<String>(artistNames),
      'durationMs': serializer.toJson<int?>(durationMs),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceUri': serializer.toJson<String>(sourceUri),
      'addedAt': serializer.toJson<String?>(addedAt),
      'album': serializer.toJson<String?>(album),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'trackDescriptorJson': serializer.toJson<String?>(trackDescriptorJson),
      'embedding': serializer.toJson<String?>(embedding),
    };
  }

  TrackTableData copyWith({
    String? id,
    String? title,
    Value<String?> pathToFile = const Value.absent(),
    String? artistIds,
    String? artistNames,
    Value<int?> durationMs = const Value.absent(),
    String? sourceType,
    String? sourceUri,
    Value<String?> addedAt = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> trackDescriptorJson = const Value.absent(),
    Value<String?> embedding = const Value.absent(),
  }) => TrackTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    pathToFile: pathToFile.present ? pathToFile.value : this.pathToFile,
    artistIds: artistIds ?? this.artistIds,
    artistNames: artistNames ?? this.artistNames,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    sourceType: sourceType ?? this.sourceType,
    sourceUri: sourceUri ?? this.sourceUri,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
    album: album.present ? album.value : this.album,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    trackDescriptorJson: trackDescriptorJson.present
        ? trackDescriptorJson.value
        : this.trackDescriptorJson,
    embedding: embedding.present ? embedding.value : this.embedding,
  );
  TrackTableData copyWithCompanion(TrackTableCompanion data) {
    return TrackTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      pathToFile: data.pathToFile.present
          ? data.pathToFile.value
          : this.pathToFile,
      artistIds: data.artistIds.present ? data.artistIds.value : this.artistIds,
      artistNames: data.artistNames.present
          ? data.artistNames.value
          : this.artistNames,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceUri: data.sourceUri.present ? data.sourceUri.value : this.sourceUri,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      album: data.album.present ? data.album.value : this.album,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      trackDescriptorJson: data.trackDescriptorJson.present
          ? data.trackDescriptorJson.value
          : this.trackDescriptorJson,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('pathToFile: $pathToFile, ')
          ..write('artistIds: $artistIds, ')
          ..write('artistNames: $artistNames, ')
          ..write('durationMs: $durationMs, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('addedAt: $addedAt, ')
          ..write('album: $album, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('trackDescriptorJson: $trackDescriptorJson, ')
          ..write('embedding: $embedding')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    pathToFile,
    artistIds,
    artistNames,
    durationMs,
    sourceType,
    sourceUri,
    addedAt,
    album,
    imageUrl,
    trackDescriptorJson,
    embedding,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.pathToFile == this.pathToFile &&
          other.artistIds == this.artistIds &&
          other.artistNames == this.artistNames &&
          other.durationMs == this.durationMs &&
          other.sourceType == this.sourceType &&
          other.sourceUri == this.sourceUri &&
          other.addedAt == this.addedAt &&
          other.album == this.album &&
          other.imageUrl == this.imageUrl &&
          other.trackDescriptorJson == this.trackDescriptorJson &&
          other.embedding == this.embedding);
}

class TrackTableCompanion extends UpdateCompanion<TrackTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> pathToFile;
  final Value<String> artistIds;
  final Value<String> artistNames;
  final Value<int?> durationMs;
  final Value<String> sourceType;
  final Value<String> sourceUri;
  final Value<String?> addedAt;
  final Value<String?> album;
  final Value<String?> imageUrl;
  final Value<String?> trackDescriptorJson;
  final Value<String?> embedding;
  final Value<int> rowid;
  const TrackTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.pathToFile = const Value.absent(),
    this.artistIds = const Value.absent(),
    this.artistNames = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.album = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.trackDescriptorJson = const Value.absent(),
    this.embedding = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackTableCompanion.insert({
    required String id,
    required String title,
    this.pathToFile = const Value.absent(),
    required String artistIds,
    required String artistNames,
    this.durationMs = const Value.absent(),
    required String sourceType,
    required String sourceUri,
    this.addedAt = const Value.absent(),
    this.album = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.trackDescriptorJson = const Value.absent(),
    this.embedding = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       artistIds = Value(artistIds),
       artistNames = Value(artistNames),
       sourceType = Value(sourceType),
       sourceUri = Value(sourceUri);
  static Insertable<TrackTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? pathToFile,
    Expression<String>? artistIds,
    Expression<String>? artistNames,
    Expression<int>? durationMs,
    Expression<String>? sourceType,
    Expression<String>? sourceUri,
    Expression<String>? addedAt,
    Expression<String>? album,
    Expression<String>? imageUrl,
    Expression<String>? trackDescriptorJson,
    Expression<String>? embedding,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (pathToFile != null) 'path_to_file': pathToFile,
      if (artistIds != null) 'artist_ids': artistIds,
      if (artistNames != null) 'artist_names': artistNames,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceUri != null) 'source_uri': sourceUri,
      if (addedAt != null) 'added_at': addedAt,
      if (album != null) 'album': album,
      if (imageUrl != null) 'image_url': imageUrl,
      if (trackDescriptorJson != null)
        'track_descriptor_json': trackDescriptorJson,
      if (embedding != null) 'embedding': embedding,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? pathToFile,
    Value<String>? artistIds,
    Value<String>? artistNames,
    Value<int?>? durationMs,
    Value<String>? sourceType,
    Value<String>? sourceUri,
    Value<String?>? addedAt,
    Value<String?>? album,
    Value<String?>? imageUrl,
    Value<String?>? trackDescriptorJson,
    Value<String?>? embedding,
    Value<int>? rowid,
  }) {
    return TrackTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      pathToFile: pathToFile ?? this.pathToFile,
      artistIds: artistIds ?? this.artistIds,
      artistNames: artistNames ?? this.artistNames,
      durationMs: durationMs ?? this.durationMs,
      sourceType: sourceType ?? this.sourceType,
      sourceUri: sourceUri ?? this.sourceUri,
      addedAt: addedAt ?? this.addedAt,
      album: album ?? this.album,
      imageUrl: imageUrl ?? this.imageUrl,
      trackDescriptorJson: trackDescriptorJson ?? this.trackDescriptorJson,
      embedding: embedding ?? this.embedding,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (pathToFile.present) {
      map['path_to_file'] = Variable<String>(pathToFile.value);
    }
    if (artistIds.present) {
      map['artist_ids'] = Variable<String>(artistIds.value);
    }
    if (artistNames.present) {
      map['artist_names'] = Variable<String>(artistNames.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceUri.present) {
      map['source_uri'] = Variable<String>(sourceUri.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<String>(addedAt.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (trackDescriptorJson.present) {
      map['track_descriptor_json'] = Variable<String>(
        trackDescriptorJson.value,
      );
    }
    if (embedding.present) {
      map['embedding'] = Variable<String>(embedding.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('pathToFile: $pathToFile, ')
          ..write('artistIds: $artistIds, ')
          ..write('artistNames: $artistNames, ')
          ..write('durationMs: $durationMs, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('addedAt: $addedAt, ')
          ..write('album: $album, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('trackDescriptorJson: $trackDescriptorJson, ')
          ..write('embedding: $embedding, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmbeddingTaskTableTable extends EmbeddingTaskTable
    with TableInfo<$EmbeddingTaskTableTable, EmbeddingTaskTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmbeddingTaskTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    status,
    filePath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'embedding_task_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmbeddingTaskTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  EmbeddingTaskTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmbeddingTaskTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EmbeddingTaskTableTable createAlias(String alias) {
    return $EmbeddingTaskTableTable(attachedDatabase, alias);
  }
}

class EmbeddingTaskTableData extends DataClass
    implements Insertable<EmbeddingTaskTableData> {
  final String id;
  final String trackId;
  final String status;
  final String filePath;
  final DateTime createdAt;
  const EmbeddingTaskTableData({
    required this.id,
    required this.trackId,
    required this.status,
    required this.filePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['status'] = Variable<String>(status);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EmbeddingTaskTableCompanion toCompanion(bool nullToAbsent) {
    return EmbeddingTaskTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      status: Value(status),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
    );
  }

  factory EmbeddingTaskTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmbeddingTaskTableData(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      status: serializer.fromJson<String>(json['status']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String>(trackId),
      'status': serializer.toJson<String>(status),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EmbeddingTaskTableData copyWith({
    String? id,
    String? trackId,
    String? status,
    String? filePath,
    DateTime? createdAt,
  }) => EmbeddingTaskTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    status: status ?? this.status,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
  );
  EmbeddingTaskTableData copyWithCompanion(EmbeddingTaskTableCompanion data) {
    return EmbeddingTaskTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      status: data.status.present ? data.status.value : this.status,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmbeddingTaskTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trackId, status, filePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmbeddingTaskTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.status == this.status &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt);
}

class EmbeddingTaskTableCompanion
    extends UpdateCompanion<EmbeddingTaskTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> status;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EmbeddingTaskTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.status = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmbeddingTaskTableCompanion.insert({
    required String id,
    required String trackId,
    required String status,
    required String filePath,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       status = Value(status),
       filePath = Value(filePath),
       createdAt = Value(createdAt);
  static Insertable<EmbeddingTaskTableData> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? status,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (status != null) 'status': status,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmbeddingTaskTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? status,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EmbeddingTaskTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmbeddingTaskTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadTaskTableTable extends DownloadTaskTable
    with TableInfo<$DownloadTaskTableTable, DownloadTaskTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTaskTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalUrlMeta = const VerificationMeta(
    'originalUrl',
  );
  @override
  late final GeneratedColumn<String> originalUrl = GeneratedColumn<String>(
    'original_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    originalUrl,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_task_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadTaskTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('original_url')) {
      context.handle(
        _originalUrlMeta,
        originalUrl.isAcceptableOrUnknown(
          data['original_url']!,
          _originalUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalUrlMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  DownloadTaskTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTaskTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      originalUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_url'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DownloadTaskTableTable createAlias(String alias) {
    return $DownloadTaskTableTable(attachedDatabase, alias);
  }
}

class DownloadTaskTableData extends DataClass
    implements Insertable<DownloadTaskTableData> {
  final String trackId;
  final String originalUrl;
  final String status;
  final DateTime createdAt;
  const DownloadTaskTableData({
    required this.trackId,
    required this.originalUrl,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['original_url'] = Variable<String>(originalUrl);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DownloadTaskTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadTaskTableCompanion(
      trackId: Value(trackId),
      originalUrl: Value(originalUrl),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory DownloadTaskTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTaskTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      originalUrl: serializer.fromJson<String>(json['originalUrl']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'originalUrl': serializer.toJson<String>(originalUrl),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DownloadTaskTableData copyWith({
    String? trackId,
    String? originalUrl,
    String? status,
    DateTime? createdAt,
  }) => DownloadTaskTableData(
    trackId: trackId ?? this.trackId,
    originalUrl: originalUrl ?? this.originalUrl,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  DownloadTaskTableData copyWithCompanion(DownloadTaskTableCompanion data) {
    return DownloadTaskTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      originalUrl: data.originalUrl.present
          ? data.originalUrl.value
          : this.originalUrl,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTaskTableData(')
          ..write('trackId: $trackId, ')
          ..write('originalUrl: $originalUrl, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, originalUrl, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTaskTableData &&
          other.trackId == this.trackId &&
          other.originalUrl == this.originalUrl &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class DownloadTaskTableCompanion
    extends UpdateCompanion<DownloadTaskTableData> {
  final Value<String> trackId;
  final Value<String> originalUrl;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DownloadTaskTableCompanion({
    this.trackId = const Value.absent(),
    this.originalUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTaskTableCompanion.insert({
    required String trackId,
    required String originalUrl,
    required String status,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       originalUrl = Value(originalUrl),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<DownloadTaskTableData> custom({
    Expression<String>? trackId,
    Expression<String>? originalUrl,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (originalUrl != null) 'original_url': originalUrl,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTaskTableCompanion copyWith({
    Value<String>? trackId,
    Value<String>? originalUrl,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DownloadTaskTableCompanion(
      trackId: trackId ?? this.trackId,
      originalUrl: originalUrl ?? this.originalUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (originalUrl.present) {
      map['original_url'] = Variable<String>(originalUrl.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTaskTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('originalUrl: $originalUrl, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayRecordTableTable playRecordTable = $PlayRecordTableTable(
    this,
  );
  late final $PlaylistTableTable playlistTable = $PlaylistTableTable(this);
  late final $TrackTableTable trackTable = $TrackTableTable(this);
  late final $EmbeddingTaskTableTable embeddingTaskTable =
      $EmbeddingTaskTableTable(this);
  late final $DownloadTaskTableTable downloadTaskTable =
      $DownloadTaskTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playRecordTable,
    playlistTable,
    trackTable,
    embeddingTaskTable,
    downloadTaskTable,
  ];
}

typedef $$PlayRecordTableTableCreateCompanionBuilder =
    PlayRecordTableCompanion Function({
      required String id,
      required String trackId,
      required String trackTitle,
      required String artistName,
      required String sourceType,
      required int listenedDurationMilisecond,
      required DateTime playedAt,
      Value<int> rowid,
    });
typedef $$PlayRecordTableTableUpdateCompanionBuilder =
    PlayRecordTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> trackTitle,
      Value<String> artistName,
      Value<String> sourceType,
      Value<int> listenedDurationMilisecond,
      Value<DateTime> playedAt,
      Value<int> rowid,
    });

class $$PlayRecordTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayRecordTableTable> {
  $$PlayRecordTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackTitle => $composableBuilder(
    column: $table.trackTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listenedDurationMilisecond => $composableBuilder(
    column: $table.listenedDurationMilisecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayRecordTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayRecordTableTable> {
  $$PlayRecordTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackTitle => $composableBuilder(
    column: $table.trackTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listenedDurationMilisecond => $composableBuilder(
    column: $table.listenedDurationMilisecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayRecordTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayRecordTableTable> {
  $$PlayRecordTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get trackTitle => $composableBuilder(
    column: $table.trackTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get listenedDurationMilisecond => $composableBuilder(
    column: $table.listenedDurationMilisecond,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);
}

class $$PlayRecordTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayRecordTableTable,
          PlayRecordTableData,
          $$PlayRecordTableTableFilterComposer,
          $$PlayRecordTableTableOrderingComposer,
          $$PlayRecordTableTableAnnotationComposer,
          $$PlayRecordTableTableCreateCompanionBuilder,
          $$PlayRecordTableTableUpdateCompanionBuilder,
          (
            PlayRecordTableData,
            BaseReferences<
              _$AppDatabase,
              $PlayRecordTableTable,
              PlayRecordTableData
            >,
          ),
          PlayRecordTableData,
          PrefetchHooks Function()
        > {
  $$PlayRecordTableTableTableManager(
    _$AppDatabase db,
    $PlayRecordTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayRecordTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayRecordTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayRecordTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> trackTitle = const Value.absent(),
                Value<String> artistName = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<int> listenedDurationMilisecond = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayRecordTableCompanion(
                id: id,
                trackId: trackId,
                trackTitle: trackTitle,
                artistName: artistName,
                sourceType: sourceType,
                listenedDurationMilisecond: listenedDurationMilisecond,
                playedAt: playedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String trackTitle,
                required String artistName,
                required String sourceType,
                required int listenedDurationMilisecond,
                required DateTime playedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlayRecordTableCompanion.insert(
                id: id,
                trackId: trackId,
                trackTitle: trackTitle,
                artistName: artistName,
                sourceType: sourceType,
                listenedDurationMilisecond: listenedDurationMilisecond,
                playedAt: playedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayRecordTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayRecordTableTable,
      PlayRecordTableData,
      $$PlayRecordTableTableFilterComposer,
      $$PlayRecordTableTableOrderingComposer,
      $$PlayRecordTableTableAnnotationComposer,
      $$PlayRecordTableTableCreateCompanionBuilder,
      $$PlayRecordTableTableUpdateCompanionBuilder,
      (
        PlayRecordTableData,
        BaseReferences<
          _$AppDatabase,
          $PlayRecordTableTable,
          PlayRecordTableData
        >,
      ),
      PlayRecordTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistTableTableCreateCompanionBuilder =
    PlaylistTableCompanion Function({
      required String id,
      required String name,
      required String trackIds,
      required DateTime createdAt,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<int> rowid,
    });
typedef $$PlaylistTableTableUpdateCompanionBuilder =
    PlaylistTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> trackIds,
      Value<DateTime> createdAt,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<int> rowid,
    });

class $$PlaylistTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackIds => $composableBuilder(
    column: $table.trackIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackIds => $composableBuilder(
    column: $table.trackIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get trackIds =>
      $composableBuilder(column: $table.trackIds, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);
}

class $$PlaylistTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistTableTable,
          PlaylistTableData,
          $$PlaylistTableTableFilterComposer,
          $$PlaylistTableTableOrderingComposer,
          $$PlaylistTableTableAnnotationComposer,
          $$PlaylistTableTableCreateCompanionBuilder,
          $$PlaylistTableTableUpdateCompanionBuilder,
          (
            PlaylistTableData,
            BaseReferences<
              _$AppDatabase,
              $PlaylistTableTable,
              PlaylistTableData
            >,
          ),
          PlaylistTableData,
          PrefetchHooks Function()
        > {
  $$PlaylistTableTableTableManager(_$AppDatabase db, $PlaylistTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> trackIds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTableCompanion(
                id: id,
                name: name,
                trackIds: trackIds,
                createdAt: createdAt,
                description: description,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String trackIds,
                required DateTime createdAt,
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTableCompanion.insert(
                id: id,
                name: name,
                trackIds: trackIds,
                createdAt: createdAt,
                description: description,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistTableTable,
      PlaylistTableData,
      $$PlaylistTableTableFilterComposer,
      $$PlaylistTableTableOrderingComposer,
      $$PlaylistTableTableAnnotationComposer,
      $$PlaylistTableTableCreateCompanionBuilder,
      $$PlaylistTableTableUpdateCompanionBuilder,
      (
        PlaylistTableData,
        BaseReferences<_$AppDatabase, $PlaylistTableTable, PlaylistTableData>,
      ),
      PlaylistTableData,
      PrefetchHooks Function()
    >;
typedef $$TrackTableTableCreateCompanionBuilder =
    TrackTableCompanion Function({
      required String id,
      required String title,
      Value<String?> pathToFile,
      required String artistIds,
      required String artistNames,
      Value<int?> durationMs,
      required String sourceType,
      required String sourceUri,
      Value<String?> addedAt,
      Value<String?> album,
      Value<String?> imageUrl,
      Value<String?> trackDescriptorJson,
      Value<String?> embedding,
      Value<int> rowid,
    });
typedef $$TrackTableTableUpdateCompanionBuilder =
    TrackTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> pathToFile,
      Value<String> artistIds,
      Value<String> artistNames,
      Value<int?> durationMs,
      Value<String> sourceType,
      Value<String> sourceUri,
      Value<String?> addedAt,
      Value<String?> album,
      Value<String?> imageUrl,
      Value<String?> trackDescriptorJson,
      Value<String?> embedding,
      Value<int> rowid,
    });

class $$TrackTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackTableTable> {
  $$TrackTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pathToFile => $composableBuilder(
    column: $table.pathToFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistIds => $composableBuilder(
    column: $table.artistIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistNames => $composableBuilder(
    column: $table.artistNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackDescriptorJson => $composableBuilder(
    column: $table.trackDescriptorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackTableTable> {
  $$TrackTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pathToFile => $composableBuilder(
    column: $table.pathToFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistIds => $composableBuilder(
    column: $table.artistIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistNames => $composableBuilder(
    column: $table.artistNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackDescriptorJson => $composableBuilder(
    column: $table.trackDescriptorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackTableTable> {
  $$TrackTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get pathToFile => $composableBuilder(
    column: $table.pathToFile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artistIds =>
      $composableBuilder(column: $table.artistIds, builder: (column) => column);

  GeneratedColumn<String> get artistNames => $composableBuilder(
    column: $table.artistNames,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUri =>
      $composableBuilder(column: $table.sourceUri, builder: (column) => column);

  GeneratedColumn<String> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get trackDescriptorJson => $composableBuilder(
    column: $table.trackDescriptorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);
}

class $$TrackTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackTableTable,
          TrackTableData,
          $$TrackTableTableFilterComposer,
          $$TrackTableTableOrderingComposer,
          $$TrackTableTableAnnotationComposer,
          $$TrackTableTableCreateCompanionBuilder,
          $$TrackTableTableUpdateCompanionBuilder,
          (
            TrackTableData,
            BaseReferences<_$AppDatabase, $TrackTableTable, TrackTableData>,
          ),
          TrackTableData,
          PrefetchHooks Function()
        > {
  $$TrackTableTableTableManager(_$AppDatabase db, $TrackTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> pathToFile = const Value.absent(),
                Value<String> artistIds = const Value.absent(),
                Value<String> artistNames = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceUri = const Value.absent(),
                Value<String?> addedAt = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> trackDescriptorJson = const Value.absent(),
                Value<String?> embedding = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackTableCompanion(
                id: id,
                title: title,
                pathToFile: pathToFile,
                artistIds: artistIds,
                artistNames: artistNames,
                durationMs: durationMs,
                sourceType: sourceType,
                sourceUri: sourceUri,
                addedAt: addedAt,
                album: album,
                imageUrl: imageUrl,
                trackDescriptorJson: trackDescriptorJson,
                embedding: embedding,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> pathToFile = const Value.absent(),
                required String artistIds,
                required String artistNames,
                Value<int?> durationMs = const Value.absent(),
                required String sourceType,
                required String sourceUri,
                Value<String?> addedAt = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> trackDescriptorJson = const Value.absent(),
                Value<String?> embedding = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackTableCompanion.insert(
                id: id,
                title: title,
                pathToFile: pathToFile,
                artistIds: artistIds,
                artistNames: artistNames,
                durationMs: durationMs,
                sourceType: sourceType,
                sourceUri: sourceUri,
                addedAt: addedAt,
                album: album,
                imageUrl: imageUrl,
                trackDescriptorJson: trackDescriptorJson,
                embedding: embedding,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackTableTable,
      TrackTableData,
      $$TrackTableTableFilterComposer,
      $$TrackTableTableOrderingComposer,
      $$TrackTableTableAnnotationComposer,
      $$TrackTableTableCreateCompanionBuilder,
      $$TrackTableTableUpdateCompanionBuilder,
      (
        TrackTableData,
        BaseReferences<_$AppDatabase, $TrackTableTable, TrackTableData>,
      ),
      TrackTableData,
      PrefetchHooks Function()
    >;
typedef $$EmbeddingTaskTableTableCreateCompanionBuilder =
    EmbeddingTaskTableCompanion Function({
      required String id,
      required String trackId,
      required String status,
      required String filePath,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$EmbeddingTaskTableTableUpdateCompanionBuilder =
    EmbeddingTaskTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> status,
      Value<String> filePath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$EmbeddingTaskTableTableFilterComposer
    extends Composer<_$AppDatabase, $EmbeddingTaskTableTable> {
  $$EmbeddingTaskTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmbeddingTaskTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EmbeddingTaskTableTable> {
  $$EmbeddingTaskTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmbeddingTaskTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmbeddingTaskTableTable> {
  $$EmbeddingTaskTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EmbeddingTaskTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmbeddingTaskTableTable,
          EmbeddingTaskTableData,
          $$EmbeddingTaskTableTableFilterComposer,
          $$EmbeddingTaskTableTableOrderingComposer,
          $$EmbeddingTaskTableTableAnnotationComposer,
          $$EmbeddingTaskTableTableCreateCompanionBuilder,
          $$EmbeddingTaskTableTableUpdateCompanionBuilder,
          (
            EmbeddingTaskTableData,
            BaseReferences<
              _$AppDatabase,
              $EmbeddingTaskTableTable,
              EmbeddingTaskTableData
            >,
          ),
          EmbeddingTaskTableData,
          PrefetchHooks Function()
        > {
  $$EmbeddingTaskTableTableTableManager(
    _$AppDatabase db,
    $EmbeddingTaskTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmbeddingTaskTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmbeddingTaskTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmbeddingTaskTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmbeddingTaskTableCompanion(
                id: id,
                trackId: trackId,
                status: status,
                filePath: filePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String status,
                required String filePath,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EmbeddingTaskTableCompanion.insert(
                id: id,
                trackId: trackId,
                status: status,
                filePath: filePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmbeddingTaskTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmbeddingTaskTableTable,
      EmbeddingTaskTableData,
      $$EmbeddingTaskTableTableFilterComposer,
      $$EmbeddingTaskTableTableOrderingComposer,
      $$EmbeddingTaskTableTableAnnotationComposer,
      $$EmbeddingTaskTableTableCreateCompanionBuilder,
      $$EmbeddingTaskTableTableUpdateCompanionBuilder,
      (
        EmbeddingTaskTableData,
        BaseReferences<
          _$AppDatabase,
          $EmbeddingTaskTableTable,
          EmbeddingTaskTableData
        >,
      ),
      EmbeddingTaskTableData,
      PrefetchHooks Function()
    >;
typedef $$DownloadTaskTableTableCreateCompanionBuilder =
    DownloadTaskTableCompanion Function({
      required String trackId,
      required String originalUrl,
      required String status,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DownloadTaskTableTableUpdateCompanionBuilder =
    DownloadTaskTableCompanion Function({
      Value<String> trackId,
      Value<String> originalUrl,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DownloadTaskTableTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadTaskTableTable> {
  $$DownloadTaskTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalUrl => $composableBuilder(
    column: $table.originalUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadTaskTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadTaskTableTable> {
  $$DownloadTaskTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalUrl => $composableBuilder(
    column: $table.originalUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadTaskTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadTaskTableTable> {
  $$DownloadTaskTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get originalUrl => $composableBuilder(
    column: $table.originalUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DownloadTaskTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadTaskTableTable,
          DownloadTaskTableData,
          $$DownloadTaskTableTableFilterComposer,
          $$DownloadTaskTableTableOrderingComposer,
          $$DownloadTaskTableTableAnnotationComposer,
          $$DownloadTaskTableTableCreateCompanionBuilder,
          $$DownloadTaskTableTableUpdateCompanionBuilder,
          (
            DownloadTaskTableData,
            BaseReferences<
              _$AppDatabase,
              $DownloadTaskTableTable,
              DownloadTaskTableData
            >,
          ),
          DownloadTaskTableData,
          PrefetchHooks Function()
        > {
  $$DownloadTaskTableTableTableManager(
    _$AppDatabase db,
    $DownloadTaskTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTaskTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTaskTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTaskTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> originalUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTaskTableCompanion(
                trackId: trackId,
                originalUrl: originalUrl,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String originalUrl,
                required String status,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadTaskTableCompanion.insert(
                trackId: trackId,
                originalUrl: originalUrl,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadTaskTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadTaskTableTable,
      DownloadTaskTableData,
      $$DownloadTaskTableTableFilterComposer,
      $$DownloadTaskTableTableOrderingComposer,
      $$DownloadTaskTableTableAnnotationComposer,
      $$DownloadTaskTableTableCreateCompanionBuilder,
      $$DownloadTaskTableTableUpdateCompanionBuilder,
      (
        DownloadTaskTableData,
        BaseReferences<
          _$AppDatabase,
          $DownloadTaskTableTable,
          DownloadTaskTableData
        >,
      ),
      DownloadTaskTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayRecordTableTableTableManager get playRecordTable =>
      $$PlayRecordTableTableTableManager(_db, _db.playRecordTable);
  $$PlaylistTableTableTableManager get playlistTable =>
      $$PlaylistTableTableTableManager(_db, _db.playlistTable);
  $$TrackTableTableTableManager get trackTable =>
      $$TrackTableTableTableManager(_db, _db.trackTable);
  $$EmbeddingTaskTableTableTableManager get embeddingTaskTable =>
      $$EmbeddingTaskTableTableTableManager(_db, _db.embeddingTaskTable);
  $$DownloadTaskTableTableTableManager get downloadTaskTable =>
      $$DownloadTaskTableTableTableManager(_db, _db.downloadTaskTable);
}
