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
  static const VerificationMeta _listenedDurationMillisecondsMeta =
      const VerificationMeta('listenedDurationMilliseconds');
  @override
  late final GeneratedColumn<int> listenedDurationMilliseconds =
      GeneratedColumn<int>(
        'listened_duration_milliseconds',
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
    listenedDurationMilliseconds,
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
    if (data.containsKey('listened_duration_milliseconds')) {
      context.handle(
        _listenedDurationMillisecondsMeta,
        listenedDurationMilliseconds.isAcceptableOrUnknown(
          data['listened_duration_milliseconds']!,
          _listenedDurationMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_listenedDurationMillisecondsMeta);
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
      listenedDurationMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listened_duration_milliseconds'],
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
  final int listenedDurationMilliseconds;
  final DateTime playedAt;
  const PlayRecordTableData({
    required this.id,
    required this.trackId,
    required this.trackTitle,
    required this.artistName,
    required this.sourceType,
    required this.listenedDurationMilliseconds,
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
    map['listened_duration_milliseconds'] = Variable<int>(
      listenedDurationMilliseconds,
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
      listenedDurationMilliseconds: Value(listenedDurationMilliseconds),
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
      listenedDurationMilliseconds: serializer.fromJson<int>(
        json['listenedDurationMilliseconds'],
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
      'listenedDurationMilliseconds': serializer.toJson<int>(
        listenedDurationMilliseconds,
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
    int? listenedDurationMilliseconds,
    DateTime? playedAt,
  }) => PlayRecordTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    trackTitle: trackTitle ?? this.trackTitle,
    artistName: artistName ?? this.artistName,
    sourceType: sourceType ?? this.sourceType,
    listenedDurationMilliseconds:
        listenedDurationMilliseconds ?? this.listenedDurationMilliseconds,
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
      listenedDurationMilliseconds: data.listenedDurationMilliseconds.present
          ? data.listenedDurationMilliseconds.value
          : this.listenedDurationMilliseconds,
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
          ..write(
            'listenedDurationMilliseconds: $listenedDurationMilliseconds, ',
          )
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
    listenedDurationMilliseconds,
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
          other.listenedDurationMilliseconds ==
              this.listenedDurationMilliseconds &&
          other.playedAt == this.playedAt);
}

class PlayRecordTableCompanion extends UpdateCompanion<PlayRecordTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> trackTitle;
  final Value<String> artistName;
  final Value<String> sourceType;
  final Value<int> listenedDurationMilliseconds;
  final Value<DateTime> playedAt;
  final Value<int> rowid;
  const PlayRecordTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.trackTitle = const Value.absent(),
    this.artistName = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.listenedDurationMilliseconds = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayRecordTableCompanion.insert({
    required String id,
    required String trackId,
    required String trackTitle,
    required String artistName,
    required String sourceType,
    required int listenedDurationMilliseconds,
    required DateTime playedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       trackTitle = Value(trackTitle),
       artistName = Value(artistName),
       sourceType = Value(sourceType),
       listenedDurationMilliseconds = Value(listenedDurationMilliseconds),
       playedAt = Value(playedAt);
  static Insertable<PlayRecordTableData> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? trackTitle,
    Expression<String>? artistName,
    Expression<String>? sourceType,
    Expression<int>? listenedDurationMilliseconds,
    Expression<DateTime>? playedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (trackTitle != null) 'track_title': trackTitle,
      if (artistName != null) 'artist_name': artistName,
      if (sourceType != null) 'source_type': sourceType,
      if (listenedDurationMilliseconds != null)
        'listened_duration_milliseconds': listenedDurationMilliseconds,
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
    Value<int>? listenedDurationMilliseconds,
    Value<DateTime>? playedAt,
    Value<int>? rowid,
  }) {
    return PlayRecordTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      artistName: artistName ?? this.artistName,
      sourceType: sourceType ?? this.sourceType,
      listenedDurationMilliseconds:
          listenedDurationMilliseconds ?? this.listenedDurationMilliseconds,
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
    if (listenedDurationMilliseconds.present) {
      map['listened_duration_milliseconds'] = Variable<int>(
        listenedDurationMilliseconds.value,
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
          ..write(
            'listenedDurationMilliseconds: $listenedDurationMilliseconds, ',
          )
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
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    description,
    imageUrl,
    revision,
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
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
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
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
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;
  final int revision;
  const PlaylistTableData({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
    this.imageUrl,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  PlaylistTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      revision: Value(revision),
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
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'revision': serializer.toJson<int>(revision),
    };
  }

  PlaylistTableData copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Value<String?> description = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    int? revision,
  }) => PlaylistTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    description: description.present ? description.value : this.description,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    revision: revision ?? this.revision,
  );
  PlaylistTableData copyWithCompanion(PlaylistTableCompanion data) {
    return PlaylistTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, createdAt, description, imageUrl, revision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.revision == this.revision);
}

class PlaylistTableCompanion extends UpdateCompanion<PlaylistTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<int> revision;
  final Value<int> rowid;
  const PlaylistTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTableCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlaylistTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<String?>? description,
    Value<String?>? imageUrl,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return PlaylistTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      revision: revision ?? this.revision,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('revision: $revision, ')
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
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _audioRevisionMeta = const VerificationMeta(
    'audioRevision',
  );
  @override
  late final GeneratedColumn<int> audioRevision = GeneratedColumn<int>(
    'audio_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _metadataRevisionMeta = const VerificationMeta(
    'metadataRevision',
  );
  @override
  late final GeneratedColumn<int> metadataRevision = GeneratedColumn<int>(
    'metadata_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    pathToFile,
    durationMs,
    sourceType,
    sourceUri,
    addedAt,
    album,
    imageUrl,
    trackDescriptorJson,
    embedding,
    audioRevision,
    metadataRevision,
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
    if (data.containsKey('audio_revision')) {
      context.handle(
        _audioRevisionMeta,
        audioRevision.isAcceptableOrUnknown(
          data['audio_revision']!,
          _audioRevisionMeta,
        ),
      );
    }
    if (data.containsKey('metadata_revision')) {
      context.handle(
        _metadataRevisionMeta,
        metadataRevision.isAcceptableOrUnknown(
          data['metadata_revision']!,
          _metadataRevisionMeta,
        ),
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
        DriftSqlType.dateTime,
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
      audioRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_revision'],
      )!,
      metadataRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metadata_revision'],
      )!,
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
  final int? durationMs;
  final String sourceType;
  final String sourceUri;
  final DateTime? addedAt;
  final String? album;
  final String? imageUrl;
  final String? trackDescriptorJson;
  final String? embedding;
  final int audioRevision;
  final int metadataRevision;
  const TrackTableData({
    required this.id,
    required this.title,
    this.pathToFile,
    this.durationMs,
    required this.sourceType,
    required this.sourceUri,
    this.addedAt,
    this.album,
    this.imageUrl,
    this.trackDescriptorJson,
    this.embedding,
    required this.audioRevision,
    required this.metadataRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || pathToFile != null) {
      map['path_to_file'] = Variable<String>(pathToFile);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['source_type'] = Variable<String>(sourceType);
    map['source_uri'] = Variable<String>(sourceUri);
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
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
    map['audio_revision'] = Variable<int>(audioRevision);
    map['metadata_revision'] = Variable<int>(metadataRevision);
    return map;
  }

  TrackTableCompanion toCompanion(bool nullToAbsent) {
    return TrackTableCompanion(
      id: Value(id),
      title: Value(title),
      pathToFile: pathToFile == null && nullToAbsent
          ? const Value.absent()
          : Value(pathToFile),
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
      audioRevision: Value(audioRevision),
      metadataRevision: Value(metadataRevision),
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
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceUri: serializer.fromJson<String>(json['sourceUri']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
      album: serializer.fromJson<String?>(json['album']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      trackDescriptorJson: serializer.fromJson<String?>(
        json['trackDescriptorJson'],
      ),
      embedding: serializer.fromJson<String?>(json['embedding']),
      audioRevision: serializer.fromJson<int>(json['audioRevision']),
      metadataRevision: serializer.fromJson<int>(json['metadataRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'pathToFile': serializer.toJson<String?>(pathToFile),
      'durationMs': serializer.toJson<int?>(durationMs),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceUri': serializer.toJson<String>(sourceUri),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
      'album': serializer.toJson<String?>(album),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'trackDescriptorJson': serializer.toJson<String?>(trackDescriptorJson),
      'embedding': serializer.toJson<String?>(embedding),
      'audioRevision': serializer.toJson<int>(audioRevision),
      'metadataRevision': serializer.toJson<int>(metadataRevision),
    };
  }

  TrackTableData copyWith({
    String? id,
    String? title,
    Value<String?> pathToFile = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    String? sourceType,
    String? sourceUri,
    Value<DateTime?> addedAt = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> trackDescriptorJson = const Value.absent(),
    Value<String?> embedding = const Value.absent(),
    int? audioRevision,
    int? metadataRevision,
  }) => TrackTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    pathToFile: pathToFile.present ? pathToFile.value : this.pathToFile,
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
    audioRevision: audioRevision ?? this.audioRevision,
    metadataRevision: metadataRevision ?? this.metadataRevision,
  );
  TrackTableData copyWithCompanion(TrackTableCompanion data) {
    return TrackTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      pathToFile: data.pathToFile.present
          ? data.pathToFile.value
          : this.pathToFile,
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
      audioRevision: data.audioRevision.present
          ? data.audioRevision.value
          : this.audioRevision,
      metadataRevision: data.metadataRevision.present
          ? data.metadataRevision.value
          : this.metadataRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('pathToFile: $pathToFile, ')
          ..write('durationMs: $durationMs, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('addedAt: $addedAt, ')
          ..write('album: $album, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('trackDescriptorJson: $trackDescriptorJson, ')
          ..write('embedding: $embedding, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('metadataRevision: $metadataRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    pathToFile,
    durationMs,
    sourceType,
    sourceUri,
    addedAt,
    album,
    imageUrl,
    trackDescriptorJson,
    embedding,
    audioRevision,
    metadataRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.pathToFile == this.pathToFile &&
          other.durationMs == this.durationMs &&
          other.sourceType == this.sourceType &&
          other.sourceUri == this.sourceUri &&
          other.addedAt == this.addedAt &&
          other.album == this.album &&
          other.imageUrl == this.imageUrl &&
          other.trackDescriptorJson == this.trackDescriptorJson &&
          other.embedding == this.embedding &&
          other.audioRevision == this.audioRevision &&
          other.metadataRevision == this.metadataRevision);
}

class TrackTableCompanion extends UpdateCompanion<TrackTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> pathToFile;
  final Value<int?> durationMs;
  final Value<String> sourceType;
  final Value<String> sourceUri;
  final Value<DateTime?> addedAt;
  final Value<String?> album;
  final Value<String?> imageUrl;
  final Value<String?> trackDescriptorJson;
  final Value<String?> embedding;
  final Value<int> audioRevision;
  final Value<int> metadataRevision;
  final Value<int> rowid;
  const TrackTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.pathToFile = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.album = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.trackDescriptorJson = const Value.absent(),
    this.embedding = const Value.absent(),
    this.audioRevision = const Value.absent(),
    this.metadataRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackTableCompanion.insert({
    required String id,
    required String title,
    this.pathToFile = const Value.absent(),
    this.durationMs = const Value.absent(),
    required String sourceType,
    required String sourceUri,
    this.addedAt = const Value.absent(),
    this.album = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.trackDescriptorJson = const Value.absent(),
    this.embedding = const Value.absent(),
    this.audioRevision = const Value.absent(),
    this.metadataRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       sourceType = Value(sourceType),
       sourceUri = Value(sourceUri);
  static Insertable<TrackTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? pathToFile,
    Expression<int>? durationMs,
    Expression<String>? sourceType,
    Expression<String>? sourceUri,
    Expression<DateTime>? addedAt,
    Expression<String>? album,
    Expression<String>? imageUrl,
    Expression<String>? trackDescriptorJson,
    Expression<String>? embedding,
    Expression<int>? audioRevision,
    Expression<int>? metadataRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (pathToFile != null) 'path_to_file': pathToFile,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceUri != null) 'source_uri': sourceUri,
      if (addedAt != null) 'added_at': addedAt,
      if (album != null) 'album': album,
      if (imageUrl != null) 'image_url': imageUrl,
      if (trackDescriptorJson != null)
        'track_descriptor_json': trackDescriptorJson,
      if (embedding != null) 'embedding': embedding,
      if (audioRevision != null) 'audio_revision': audioRevision,
      if (metadataRevision != null) 'metadata_revision': metadataRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? pathToFile,
    Value<int?>? durationMs,
    Value<String>? sourceType,
    Value<String>? sourceUri,
    Value<DateTime?>? addedAt,
    Value<String?>? album,
    Value<String?>? imageUrl,
    Value<String?>? trackDescriptorJson,
    Value<String?>? embedding,
    Value<int>? audioRevision,
    Value<int>? metadataRevision,
    Value<int>? rowid,
  }) {
    return TrackTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      pathToFile: pathToFile ?? this.pathToFile,
      durationMs: durationMs ?? this.durationMs,
      sourceType: sourceType ?? this.sourceType,
      sourceUri: sourceUri ?? this.sourceUri,
      addedAt: addedAt ?? this.addedAt,
      album: album ?? this.album,
      imageUrl: imageUrl ?? this.imageUrl,
      trackDescriptorJson: trackDescriptorJson ?? this.trackDescriptorJson,
      embedding: embedding ?? this.embedding,
      audioRevision: audioRevision ?? this.audioRevision,
      metadataRevision: metadataRevision ?? this.metadataRevision,
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
      map['added_at'] = Variable<DateTime>(addedAt.value);
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
    if (audioRevision.present) {
      map['audio_revision'] = Variable<int>(audioRevision.value);
    }
    if (metadataRevision.present) {
      map['metadata_revision'] = Variable<int>(metadataRevision.value);
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
          ..write('durationMs: $durationMs, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('addedAt: $addedAt, ')
          ..write('album: $album, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('trackDescriptorJson: $trackDescriptorJson, ')
          ..write('embedding: $embedding, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('metadataRevision: $metadataRevision, ')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _audioRevisionMeta = const VerificationMeta(
    'audioRevision',
  );
  @override
  late final GeneratedColumn<int> audioRevision = GeneratedColumn<int>(
    'audio_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _leaseOwnerMeta = const VerificationMeta(
    'leaseOwner',
  );
  @override
  late final GeneratedColumn<String> leaseOwner = GeneratedColumn<String>(
    'lease_owner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leaseUntilMeta = const VerificationMeta(
    'leaseUntil',
  );
  @override
  late final GeneratedColumn<DateTime> leaseUntil = GeneratedColumn<DateTime>(
    'lease_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    status,
    filePath,
    createdAt,
    audioRevision,
    leaseOwner,
    leaseUntil,
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
    if (data.containsKey('audio_revision')) {
      context.handle(
        _audioRevisionMeta,
        audioRevision.isAcceptableOrUnknown(
          data['audio_revision']!,
          _audioRevisionMeta,
        ),
      );
    }
    if (data.containsKey('lease_owner')) {
      context.handle(
        _leaseOwnerMeta,
        leaseOwner.isAcceptableOrUnknown(data['lease_owner']!, _leaseOwnerMeta),
      );
    }
    if (data.containsKey('lease_until')) {
      context.handle(
        _leaseUntilMeta,
        leaseUntil.isAcceptableOrUnknown(data['lease_until']!, _leaseUntilMeta),
      );
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
      audioRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_revision'],
      )!,
      leaseOwner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lease_owner'],
      ),
      leaseUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lease_until'],
      ),
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
  final int audioRevision;
  final String? leaseOwner;
  final DateTime? leaseUntil;
  const EmbeddingTaskTableData({
    required this.id,
    required this.trackId,
    required this.status,
    required this.filePath,
    required this.createdAt,
    required this.audioRevision,
    this.leaseOwner,
    this.leaseUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['status'] = Variable<String>(status);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['audio_revision'] = Variable<int>(audioRevision);
    if (!nullToAbsent || leaseOwner != null) {
      map['lease_owner'] = Variable<String>(leaseOwner);
    }
    if (!nullToAbsent || leaseUntil != null) {
      map['lease_until'] = Variable<DateTime>(leaseUntil);
    }
    return map;
  }

  EmbeddingTaskTableCompanion toCompanion(bool nullToAbsent) {
    return EmbeddingTaskTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      status: Value(status),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
      audioRevision: Value(audioRevision),
      leaseOwner: leaseOwner == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseOwner),
      leaseUntil: leaseUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseUntil),
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
      audioRevision: serializer.fromJson<int>(json['audioRevision']),
      leaseOwner: serializer.fromJson<String?>(json['leaseOwner']),
      leaseUntil: serializer.fromJson<DateTime?>(json['leaseUntil']),
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
      'audioRevision': serializer.toJson<int>(audioRevision),
      'leaseOwner': serializer.toJson<String?>(leaseOwner),
      'leaseUntil': serializer.toJson<DateTime?>(leaseUntil),
    };
  }

  EmbeddingTaskTableData copyWith({
    String? id,
    String? trackId,
    String? status,
    String? filePath,
    DateTime? createdAt,
    int? audioRevision,
    Value<String?> leaseOwner = const Value.absent(),
    Value<DateTime?> leaseUntil = const Value.absent(),
  }) => EmbeddingTaskTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    status: status ?? this.status,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
    audioRevision: audioRevision ?? this.audioRevision,
    leaseOwner: leaseOwner.present ? leaseOwner.value : this.leaseOwner,
    leaseUntil: leaseUntil.present ? leaseUntil.value : this.leaseUntil,
  );
  EmbeddingTaskTableData copyWithCompanion(EmbeddingTaskTableCompanion data) {
    return EmbeddingTaskTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      status: data.status.present ? data.status.value : this.status,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      audioRevision: data.audioRevision.present
          ? data.audioRevision.value
          : this.audioRevision,
      leaseOwner: data.leaseOwner.present
          ? data.leaseOwner.value
          : this.leaseOwner,
      leaseUntil: data.leaseUntil.present
          ? data.leaseUntil.value
          : this.leaseUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmbeddingTaskTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('leaseOwner: $leaseOwner, ')
          ..write('leaseUntil: $leaseUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    status,
    filePath,
    createdAt,
    audioRevision,
    leaseOwner,
    leaseUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmbeddingTaskTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.status == this.status &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt &&
          other.audioRevision == this.audioRevision &&
          other.leaseOwner == this.leaseOwner &&
          other.leaseUntil == this.leaseUntil);
}

class EmbeddingTaskTableCompanion
    extends UpdateCompanion<EmbeddingTaskTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> status;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  final Value<int> audioRevision;
  final Value<String?> leaseOwner;
  final Value<DateTime?> leaseUntil;
  final Value<int> rowid;
  const EmbeddingTaskTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.status = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.audioRevision = const Value.absent(),
    this.leaseOwner = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmbeddingTaskTableCompanion.insert({
    required String id,
    required String trackId,
    required String status,
    required String filePath,
    required DateTime createdAt,
    this.audioRevision = const Value.absent(),
    this.leaseOwner = const Value.absent(),
    this.leaseUntil = const Value.absent(),
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
    Expression<int>? audioRevision,
    Expression<String>? leaseOwner,
    Expression<DateTime>? leaseUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (status != null) 'status': status,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (audioRevision != null) 'audio_revision': audioRevision,
      if (leaseOwner != null) 'lease_owner': leaseOwner,
      if (leaseUntil != null) 'lease_until': leaseUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmbeddingTaskTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? status,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
    Value<int>? audioRevision,
    Value<String?>? leaseOwner,
    Value<DateTime?>? leaseUntil,
    Value<int>? rowid,
  }) {
    return EmbeddingTaskTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      audioRevision: audioRevision ?? this.audioRevision,
      leaseOwner: leaseOwner ?? this.leaseOwner,
      leaseUntil: leaseUntil ?? this.leaseUntil,
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
    if (audioRevision.present) {
      map['audio_revision'] = Variable<int>(audioRevision.value);
    }
    if (leaseOwner.present) {
      map['lease_owner'] = Variable<String>(leaseOwner.value);
    }
    if (leaseUntil.present) {
      map['lease_until'] = Variable<DateTime>(leaseUntil.value);
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
          ..write('audioRevision: $audioRevision, ')
          ..write('leaseOwner: $leaseOwner, ')
          ..write('leaseUntil: $leaseUntil, ')
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
  static const VerificationMeta _leaseOwnerMeta = const VerificationMeta(
    'leaseOwner',
  );
  @override
  late final GeneratedColumn<String> leaseOwner = GeneratedColumn<String>(
    'lease_owner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leaseUntilMeta = const VerificationMeta(
    'leaseUntil',
  );
  @override
  late final GeneratedColumn<DateTime> leaseUntil = GeneratedColumn<DateTime>(
    'lease_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    originalUrl,
    status,
    createdAt,
    leaseOwner,
    leaseUntil,
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
    if (data.containsKey('lease_owner')) {
      context.handle(
        _leaseOwnerMeta,
        leaseOwner.isAcceptableOrUnknown(data['lease_owner']!, _leaseOwnerMeta),
      );
    }
    if (data.containsKey('lease_until')) {
      context.handle(
        _leaseUntilMeta,
        leaseUntil.isAcceptableOrUnknown(data['lease_until']!, _leaseUntilMeta),
      );
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
      leaseOwner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lease_owner'],
      ),
      leaseUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lease_until'],
      ),
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
  final String? leaseOwner;
  final DateTime? leaseUntil;
  const DownloadTaskTableData({
    required this.trackId,
    required this.originalUrl,
    required this.status,
    required this.createdAt,
    this.leaseOwner,
    this.leaseUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['original_url'] = Variable<String>(originalUrl);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || leaseOwner != null) {
      map['lease_owner'] = Variable<String>(leaseOwner);
    }
    if (!nullToAbsent || leaseUntil != null) {
      map['lease_until'] = Variable<DateTime>(leaseUntil);
    }
    return map;
  }

  DownloadTaskTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadTaskTableCompanion(
      trackId: Value(trackId),
      originalUrl: Value(originalUrl),
      status: Value(status),
      createdAt: Value(createdAt),
      leaseOwner: leaseOwner == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseOwner),
      leaseUntil: leaseUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseUntil),
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
      leaseOwner: serializer.fromJson<String?>(json['leaseOwner']),
      leaseUntil: serializer.fromJson<DateTime?>(json['leaseUntil']),
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
      'leaseOwner': serializer.toJson<String?>(leaseOwner),
      'leaseUntil': serializer.toJson<DateTime?>(leaseUntil),
    };
  }

  DownloadTaskTableData copyWith({
    String? trackId,
    String? originalUrl,
    String? status,
    DateTime? createdAt,
    Value<String?> leaseOwner = const Value.absent(),
    Value<DateTime?> leaseUntil = const Value.absent(),
  }) => DownloadTaskTableData(
    trackId: trackId ?? this.trackId,
    originalUrl: originalUrl ?? this.originalUrl,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    leaseOwner: leaseOwner.present ? leaseOwner.value : this.leaseOwner,
    leaseUntil: leaseUntil.present ? leaseUntil.value : this.leaseUntil,
  );
  DownloadTaskTableData copyWithCompanion(DownloadTaskTableCompanion data) {
    return DownloadTaskTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      originalUrl: data.originalUrl.present
          ? data.originalUrl.value
          : this.originalUrl,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      leaseOwner: data.leaseOwner.present
          ? data.leaseOwner.value
          : this.leaseOwner,
      leaseUntil: data.leaseUntil.present
          ? data.leaseUntil.value
          : this.leaseUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTaskTableData(')
          ..write('trackId: $trackId, ')
          ..write('originalUrl: $originalUrl, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('leaseOwner: $leaseOwner, ')
          ..write('leaseUntil: $leaseUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    originalUrl,
    status,
    createdAt,
    leaseOwner,
    leaseUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTaskTableData &&
          other.trackId == this.trackId &&
          other.originalUrl == this.originalUrl &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.leaseOwner == this.leaseOwner &&
          other.leaseUntil == this.leaseUntil);
}

class DownloadTaskTableCompanion
    extends UpdateCompanion<DownloadTaskTableData> {
  final Value<String> trackId;
  final Value<String> originalUrl;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String?> leaseOwner;
  final Value<DateTime?> leaseUntil;
  final Value<int> rowid;
  const DownloadTaskTableCompanion({
    this.trackId = const Value.absent(),
    this.originalUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.leaseOwner = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTaskTableCompanion.insert({
    required String trackId,
    required String originalUrl,
    required String status,
    required DateTime createdAt,
    this.leaseOwner = const Value.absent(),
    this.leaseUntil = const Value.absent(),
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
    Expression<String>? leaseOwner,
    Expression<DateTime>? leaseUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (originalUrl != null) 'original_url': originalUrl,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (leaseOwner != null) 'lease_owner': leaseOwner,
      if (leaseUntil != null) 'lease_until': leaseUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTaskTableCompanion copyWith({
    Value<String>? trackId,
    Value<String>? originalUrl,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<String?>? leaseOwner,
    Value<DateTime?>? leaseUntil,
    Value<int>? rowid,
  }) {
    return DownloadTaskTableCompanion(
      trackId: trackId ?? this.trackId,
      originalUrl: originalUrl ?? this.originalUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      leaseOwner: leaseOwner ?? this.leaseOwner,
      leaseUntil: leaseUntil ?? this.leaseUntil,
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
    if (leaseOwner.present) {
      map['lease_owner'] = Variable<String>(leaseOwner.value);
    }
    if (leaseUntil.present) {
      map['lease_until'] = Variable<DateTime>(leaseUntil.value);
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
          ..write('leaseOwner: $leaseOwner, ')
          ..write('leaseUntil: $leaseUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArtistTableTable extends ArtistTable
    with TableInfo<$ArtistTableTable, ArtistTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistTableTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artist_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtistTableData> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtistTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ArtistTableTable createAlias(String alias) {
    return $ArtistTableTable(attachedDatabase, alias);
  }
}

class ArtistTableData extends DataClass implements Insertable<ArtistTableData> {
  final String id;
  final String name;
  const ArtistTableData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ArtistTableCompanion toCompanion(bool nullToAbsent) {
    return ArtistTableCompanion(id: Value(id), name: Value(name));
  }

  factory ArtistTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  ArtistTableData copyWith({String? id, String? name}) =>
      ArtistTableData(id: id ?? this.id, name: name ?? this.name);
  ArtistTableData copyWithCompanion(ArtistTableCompanion data) {
    return ArtistTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtistTableData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistTableData &&
          other.id == this.id &&
          other.name == this.name);
}

class ArtistTableCompanion extends UpdateCompanion<ArtistTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const ArtistTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtistTableCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ArtistTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtistTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return ArtistTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackArtistTableTable extends TrackArtistTable
    with TableInfo<$TrackArtistTableTable, TrackArtistTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackArtistTableTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artist_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [trackId, artistId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_artist_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackArtistTableData> instance, {
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
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId, artistId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {trackId, position},
  ];
  @override
  TrackArtistTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackArtistTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TrackArtistTableTable createAlias(String alias) {
    return $TrackArtistTableTable(attachedDatabase, alias);
  }
}

class TrackArtistTableData extends DataClass
    implements Insertable<TrackArtistTableData> {
  final String trackId;
  final String artistId;
  final int position;
  const TrackArtistTableData({
    required this.trackId,
    required this.artistId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['artist_id'] = Variable<String>(artistId);
    map['position'] = Variable<int>(position);
    return map;
  }

  TrackArtistTableCompanion toCompanion(bool nullToAbsent) {
    return TrackArtistTableCompanion(
      trackId: Value(trackId),
      artistId: Value(artistId),
      position: Value(position),
    );
  }

  factory TrackArtistTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackArtistTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      artistId: serializer.fromJson<String>(json['artistId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'artistId': serializer.toJson<String>(artistId),
      'position': serializer.toJson<int>(position),
    };
  }

  TrackArtistTableData copyWith({
    String? trackId,
    String? artistId,
    int? position,
  }) => TrackArtistTableData(
    trackId: trackId ?? this.trackId,
    artistId: artistId ?? this.artistId,
    position: position ?? this.position,
  );
  TrackArtistTableData copyWithCompanion(TrackArtistTableCompanion data) {
    return TrackArtistTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackArtistTableData(')
          ..write('trackId: $trackId, ')
          ..write('artistId: $artistId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, artistId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackArtistTableData &&
          other.trackId == this.trackId &&
          other.artistId == this.artistId &&
          other.position == this.position);
}

class TrackArtistTableCompanion extends UpdateCompanion<TrackArtistTableData> {
  final Value<String> trackId;
  final Value<String> artistId;
  final Value<int> position;
  final Value<int> rowid;
  const TrackArtistTableCompanion({
    this.trackId = const Value.absent(),
    this.artistId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackArtistTableCompanion.insert({
    required String trackId,
    required String artistId,
    required int position,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       artistId = Value(artistId),
       position = Value(position);
  static Insertable<TrackArtistTableData> custom({
    Expression<String>? trackId,
    Expression<String>? artistId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (artistId != null) 'artist_id': artistId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackArtistTableCompanion copyWith({
    Value<String>? trackId,
    Value<String>? artistId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TrackArtistTableCompanion(
      trackId: trackId ?? this.trackId,
      artistId: artistId ?? this.artistId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackArtistTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('artistId: $artistId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTrackTableTable extends PlaylistTrackTable
    with TableInfo<$PlaylistTrackTableTable, PlaylistTrackTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTrackTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlist_table (id) ON DELETE CASCADE',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, trackId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_track_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTrackTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, trackId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {playlistId, position},
  ];
  @override
  PlaylistTrackTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTrackTableData(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaylistTrackTableTable createAlias(String alias) {
    return $PlaylistTrackTableTable(attachedDatabase, alias);
  }
}

class PlaylistTrackTableData extends DataClass
    implements Insertable<PlaylistTrackTableData> {
  final String playlistId;
  final String trackId;
  final int position;
  const PlaylistTrackTableData({
    required this.playlistId,
    required this.trackId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistTrackTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTrackTableCompanion(
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      position: Value(position),
    );
  }

  factory PlaylistTrackTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTrackTableData(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistTrackTableData copyWith({
    String? playlistId,
    String? trackId,
    int? position,
  }) => PlaylistTrackTableData(
    playlistId: playlistId ?? this.playlistId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
  );
  PlaylistTrackTableData copyWithCompanion(PlaylistTrackTableCompanion data) {
    return PlaylistTrackTableData(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrackTableData(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, trackId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTrackTableData &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.position == this.position);
}

class PlaylistTrackTableCompanion
    extends UpdateCompanion<PlaylistTrackTableData> {
  final Value<String> playlistId;
  final Value<String> trackId;
  final Value<int> position;
  final Value<int> rowid;
  const PlaylistTrackTableCompanion({
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTrackTableCompanion.insert({
    required String playlistId,
    required String trackId,
    required int position,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       trackId = Value(trackId),
       position = Value(position);
  static Insertable<PlaylistTrackTableData> custom({
    Expression<String>? playlistId,
    Expression<String>? trackId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTrackTableCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? trackId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return PlaylistTrackTableCompanion(
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrackTableCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FileCleanupTaskTableTable extends FileCleanupTaskTable
    with TableInfo<$FileCleanupTaskTableTable, FileCleanupTaskTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileCleanupTaskTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
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
  List<GeneratedColumn> get $columns => [path, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_cleanup_task_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileCleanupTaskTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
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
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  FileCleanupTaskTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileCleanupTaskTableData(
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FileCleanupTaskTableTable createAlias(String alias) {
    return $FileCleanupTaskTableTable(attachedDatabase, alias);
  }
}

class FileCleanupTaskTableData extends DataClass
    implements Insertable<FileCleanupTaskTableData> {
  final String path;
  final DateTime createdAt;
  const FileCleanupTaskTableData({required this.path, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FileCleanupTaskTableCompanion toCompanion(bool nullToAbsent) {
    return FileCleanupTaskTableCompanion(
      path: Value(path),
      createdAt: Value(createdAt),
    );
  }

  factory FileCleanupTaskTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileCleanupTaskTableData(
      path: serializer.fromJson<String>(json['path']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FileCleanupTaskTableData copyWith({String? path, DateTime? createdAt}) =>
      FileCleanupTaskTableData(
        path: path ?? this.path,
        createdAt: createdAt ?? this.createdAt,
      );
  FileCleanupTaskTableData copyWithCompanion(
    FileCleanupTaskTableCompanion data,
  ) {
    return FileCleanupTaskTableData(
      path: data.path.present ? data.path.value : this.path,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileCleanupTaskTableData(')
          ..write('path: $path, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(path, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileCleanupTaskTableData &&
          other.path == this.path &&
          other.createdAt == this.createdAt);
}

class FileCleanupTaskTableCompanion
    extends UpdateCompanion<FileCleanupTaskTableData> {
  final Value<String> path;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FileCleanupTaskTableCompanion({
    this.path = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileCleanupTaskTableCompanion.insert({
    required String path,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : path = Value(path),
       createdAt = Value(createdAt);
  static Insertable<FileCleanupTaskTableData> custom({
    Expression<String>? path,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileCleanupTaskTableCompanion copyWith({
    Value<String>? path,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FileCleanupTaskTableCompanion(
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
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
    return (StringBuffer('FileCleanupTaskTableCompanion(')
          ..write('path: $path, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListeningCheckpointTableTable extends ListeningCheckpointTable
    with
        TableInfo<
          $ListeningCheckpointTableTable,
          ListeningCheckpointTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningCheckpointTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _listenedMillisecondsMeta =
      const VerificationMeta('listenedMilliseconds');
  @override
  late final GeneratedColumn<int> listenedMilliseconds = GeneratedColumn<int>(
    'listened_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
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
    listenedMilliseconds,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listening_checkpoint_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListeningCheckpointTableData> instance, {
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
    if (data.containsKey('listened_milliseconds')) {
      context.handle(
        _listenedMillisecondsMeta,
        listenedMilliseconds.isAcceptableOrUnknown(
          data['listened_milliseconds']!,
          _listenedMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_listenedMillisecondsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListeningCheckpointTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningCheckpointTableData(
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
      listenedMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listened_milliseconds'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ListeningCheckpointTableTable createAlias(String alias) {
    return $ListeningCheckpointTableTable(attachedDatabase, alias);
  }
}

class ListeningCheckpointTableData extends DataClass
    implements Insertable<ListeningCheckpointTableData> {
  final String id;
  final String trackId;
  final String trackTitle;
  final String artistName;
  final String sourceType;
  final int listenedMilliseconds;
  final DateTime updatedAt;
  const ListeningCheckpointTableData({
    required this.id,
    required this.trackId,
    required this.trackTitle,
    required this.artistName,
    required this.sourceType,
    required this.listenedMilliseconds,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['track_title'] = Variable<String>(trackTitle);
    map['artist_name'] = Variable<String>(artistName);
    map['source_type'] = Variable<String>(sourceType);
    map['listened_milliseconds'] = Variable<int>(listenedMilliseconds);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ListeningCheckpointTableCompanion toCompanion(bool nullToAbsent) {
    return ListeningCheckpointTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      trackTitle: Value(trackTitle),
      artistName: Value(artistName),
      sourceType: Value(sourceType),
      listenedMilliseconds: Value(listenedMilliseconds),
      updatedAt: Value(updatedAt),
    );
  }

  factory ListeningCheckpointTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningCheckpointTableData(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      trackTitle: serializer.fromJson<String>(json['trackTitle']),
      artistName: serializer.fromJson<String>(json['artistName']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      listenedMilliseconds: serializer.fromJson<int>(
        json['listenedMilliseconds'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
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
      'listenedMilliseconds': serializer.toJson<int>(listenedMilliseconds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ListeningCheckpointTableData copyWith({
    String? id,
    String? trackId,
    String? trackTitle,
    String? artistName,
    String? sourceType,
    int? listenedMilliseconds,
    DateTime? updatedAt,
  }) => ListeningCheckpointTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    trackTitle: trackTitle ?? this.trackTitle,
    artistName: artistName ?? this.artistName,
    sourceType: sourceType ?? this.sourceType,
    listenedMilliseconds: listenedMilliseconds ?? this.listenedMilliseconds,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ListeningCheckpointTableData copyWithCompanion(
    ListeningCheckpointTableCompanion data,
  ) {
    return ListeningCheckpointTableData(
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
      listenedMilliseconds: data.listenedMilliseconds.present
          ? data.listenedMilliseconds.value
          : this.listenedMilliseconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListeningCheckpointTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('trackTitle: $trackTitle, ')
          ..write('artistName: $artistName, ')
          ..write('sourceType: $sourceType, ')
          ..write('listenedMilliseconds: $listenedMilliseconds, ')
          ..write('updatedAt: $updatedAt')
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
    listenedMilliseconds,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningCheckpointTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.trackTitle == this.trackTitle &&
          other.artistName == this.artistName &&
          other.sourceType == this.sourceType &&
          other.listenedMilliseconds == this.listenedMilliseconds &&
          other.updatedAt == this.updatedAt);
}

class ListeningCheckpointTableCompanion
    extends UpdateCompanion<ListeningCheckpointTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> trackTitle;
  final Value<String> artistName;
  final Value<String> sourceType;
  final Value<int> listenedMilliseconds;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ListeningCheckpointTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.trackTitle = const Value.absent(),
    this.artistName = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.listenedMilliseconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListeningCheckpointTableCompanion.insert({
    required String id,
    required String trackId,
    required String trackTitle,
    required String artistName,
    required String sourceType,
    required int listenedMilliseconds,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       trackTitle = Value(trackTitle),
       artistName = Value(artistName),
       sourceType = Value(sourceType),
       listenedMilliseconds = Value(listenedMilliseconds),
       updatedAt = Value(updatedAt);
  static Insertable<ListeningCheckpointTableData> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? trackTitle,
    Expression<String>? artistName,
    Expression<String>? sourceType,
    Expression<int>? listenedMilliseconds,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (trackTitle != null) 'track_title': trackTitle,
      if (artistName != null) 'artist_name': artistName,
      if (sourceType != null) 'source_type': sourceType,
      if (listenedMilliseconds != null)
        'listened_milliseconds': listenedMilliseconds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListeningCheckpointTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? trackTitle,
    Value<String>? artistName,
    Value<String>? sourceType,
    Value<int>? listenedMilliseconds,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ListeningCheckpointTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      artistName: artistName ?? this.artistName,
      sourceType: sourceType ?? this.sourceType,
      listenedMilliseconds: listenedMilliseconds ?? this.listenedMilliseconds,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (listenedMilliseconds.present) {
      map['listened_milliseconds'] = Variable<int>(listenedMilliseconds.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningCheckpointTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('trackTitle: $trackTitle, ')
          ..write('artistName: $artistName, ')
          ..write('sourceType: $sourceType, ')
          ..write('listenedMilliseconds: $listenedMilliseconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackSessionTableTable extends PlaybackSessionTable
    with TableInfo<$PlaybackSessionTableTable, PlaybackSessionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackSessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentTrackIdMeta = const VerificationMeta(
    'currentTrackId',
  );
  @override
  late final GeneratedColumn<String> currentTrackId = GeneratedColumn<String>(
    'current_track_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _currentQueuePositionMeta =
      const VerificationMeta('currentQueuePosition');
  @override
  late final GeneratedColumn<int> currentQueuePosition = GeneratedColumn<int>(
    'current_queue_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMillisecondsMeta =
      const VerificationMeta('positionMilliseconds');
  @override
  late final GeneratedColumn<int> positionMilliseconds = GeneratedColumn<int>(
    'position_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shuffleEnabledMeta = const VerificationMeta(
    'shuffleEnabled',
  );
  @override
  late final GeneratedColumn<bool> shuffleEnabled = GeneratedColumn<bool>(
    'shuffle_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _loopModeMeta = const VerificationMeta(
    'loopMode',
  );
  @override
  late final GeneratedColumn<String> loopMode = GeneratedColumn<String>(
    'loop_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentTrackId,
    currentQueuePosition,
    positionMilliseconds,
    shuffleEnabled,
    loopMode,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_session_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackSessionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('current_track_id')) {
      context.handle(
        _currentTrackIdMeta,
        currentTrackId.isAcceptableOrUnknown(
          data['current_track_id']!,
          _currentTrackIdMeta,
        ),
      );
    }
    if (data.containsKey('current_queue_position')) {
      context.handle(
        _currentQueuePositionMeta,
        currentQueuePosition.isAcceptableOrUnknown(
          data['current_queue_position']!,
          _currentQueuePositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentQueuePositionMeta);
    }
    if (data.containsKey('position_milliseconds')) {
      context.handle(
        _positionMillisecondsMeta,
        positionMilliseconds.isAcceptableOrUnknown(
          data['position_milliseconds']!,
          _positionMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionMillisecondsMeta);
    }
    if (data.containsKey('shuffle_enabled')) {
      context.handle(
        _shuffleEnabledMeta,
        shuffleEnabled.isAcceptableOrUnknown(
          data['shuffle_enabled']!,
          _shuffleEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shuffleEnabledMeta);
    }
    if (data.containsKey('loop_mode')) {
      context.handle(
        _loopModeMeta,
        loopMode.isAcceptableOrUnknown(data['loop_mode']!, _loopModeMeta),
      );
    } else if (isInserting) {
      context.missing(_loopModeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackSessionTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackSessionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      currentTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_track_id'],
      ),
      currentQueuePosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_queue_position'],
      )!,
      positionMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_milliseconds'],
      )!,
      shuffleEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_enabled'],
      )!,
      loopMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loop_mode'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaybackSessionTableTable createAlias(String alias) {
    return $PlaybackSessionTableTable(attachedDatabase, alias);
  }
}

class PlaybackSessionTableData extends DataClass
    implements Insertable<PlaybackSessionTableData> {
  final String id;
  final String? currentTrackId;
  final int currentQueuePosition;
  final int positionMilliseconds;
  final bool shuffleEnabled;
  final String loopMode;
  final DateTime updatedAt;
  const PlaybackSessionTableData({
    required this.id,
    this.currentTrackId,
    required this.currentQueuePosition,
    required this.positionMilliseconds,
    required this.shuffleEnabled,
    required this.loopMode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || currentTrackId != null) {
      map['current_track_id'] = Variable<String>(currentTrackId);
    }
    map['current_queue_position'] = Variable<int>(currentQueuePosition);
    map['position_milliseconds'] = Variable<int>(positionMilliseconds);
    map['shuffle_enabled'] = Variable<bool>(shuffleEnabled);
    map['loop_mode'] = Variable<String>(loopMode);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaybackSessionTableCompanion toCompanion(bool nullToAbsent) {
    return PlaybackSessionTableCompanion(
      id: Value(id),
      currentTrackId: currentTrackId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTrackId),
      currentQueuePosition: Value(currentQueuePosition),
      positionMilliseconds: Value(positionMilliseconds),
      shuffleEnabled: Value(shuffleEnabled),
      loopMode: Value(loopMode),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaybackSessionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackSessionTableData(
      id: serializer.fromJson<String>(json['id']),
      currentTrackId: serializer.fromJson<String?>(json['currentTrackId']),
      currentQueuePosition: serializer.fromJson<int>(
        json['currentQueuePosition'],
      ),
      positionMilliseconds: serializer.fromJson<int>(
        json['positionMilliseconds'],
      ),
      shuffleEnabled: serializer.fromJson<bool>(json['shuffleEnabled']),
      loopMode: serializer.fromJson<String>(json['loopMode']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'currentTrackId': serializer.toJson<String?>(currentTrackId),
      'currentQueuePosition': serializer.toJson<int>(currentQueuePosition),
      'positionMilliseconds': serializer.toJson<int>(positionMilliseconds),
      'shuffleEnabled': serializer.toJson<bool>(shuffleEnabled),
      'loopMode': serializer.toJson<String>(loopMode),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlaybackSessionTableData copyWith({
    String? id,
    Value<String?> currentTrackId = const Value.absent(),
    int? currentQueuePosition,
    int? positionMilliseconds,
    bool? shuffleEnabled,
    String? loopMode,
    DateTime? updatedAt,
  }) => PlaybackSessionTableData(
    id: id ?? this.id,
    currentTrackId: currentTrackId.present
        ? currentTrackId.value
        : this.currentTrackId,
    currentQueuePosition: currentQueuePosition ?? this.currentQueuePosition,
    positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
    shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    loopMode: loopMode ?? this.loopMode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaybackSessionTableData copyWithCompanion(
    PlaybackSessionTableCompanion data,
  ) {
    return PlaybackSessionTableData(
      id: data.id.present ? data.id.value : this.id,
      currentTrackId: data.currentTrackId.present
          ? data.currentTrackId.value
          : this.currentTrackId,
      currentQueuePosition: data.currentQueuePosition.present
          ? data.currentQueuePosition.value
          : this.currentQueuePosition,
      positionMilliseconds: data.positionMilliseconds.present
          ? data.positionMilliseconds.value
          : this.positionMilliseconds,
      shuffleEnabled: data.shuffleEnabled.present
          ? data.shuffleEnabled.value
          : this.shuffleEnabled,
      loopMode: data.loopMode.present ? data.loopMode.value : this.loopMode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSessionTableData(')
          ..write('id: $id, ')
          ..write('currentTrackId: $currentTrackId, ')
          ..write('currentQueuePosition: $currentQueuePosition, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('loopMode: $loopMode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentTrackId,
    currentQueuePosition,
    positionMilliseconds,
    shuffleEnabled,
    loopMode,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackSessionTableData &&
          other.id == this.id &&
          other.currentTrackId == this.currentTrackId &&
          other.currentQueuePosition == this.currentQueuePosition &&
          other.positionMilliseconds == this.positionMilliseconds &&
          other.shuffleEnabled == this.shuffleEnabled &&
          other.loopMode == this.loopMode &&
          other.updatedAt == this.updatedAt);
}

class PlaybackSessionTableCompanion
    extends UpdateCompanion<PlaybackSessionTableData> {
  final Value<String> id;
  final Value<String?> currentTrackId;
  final Value<int> currentQueuePosition;
  final Value<int> positionMilliseconds;
  final Value<bool> shuffleEnabled;
  final Value<String> loopMode;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlaybackSessionTableCompanion({
    this.id = const Value.absent(),
    this.currentTrackId = const Value.absent(),
    this.currentQueuePosition = const Value.absent(),
    this.positionMilliseconds = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.loopMode = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaybackSessionTableCompanion.insert({
    required String id,
    this.currentTrackId = const Value.absent(),
    required int currentQueuePosition,
    required int positionMilliseconds,
    required bool shuffleEnabled,
    required String loopMode,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       currentQueuePosition = Value(currentQueuePosition),
       positionMilliseconds = Value(positionMilliseconds),
       shuffleEnabled = Value(shuffleEnabled),
       loopMode = Value(loopMode),
       updatedAt = Value(updatedAt);
  static Insertable<PlaybackSessionTableData> custom({
    Expression<String>? id,
    Expression<String>? currentTrackId,
    Expression<int>? currentQueuePosition,
    Expression<int>? positionMilliseconds,
    Expression<bool>? shuffleEnabled,
    Expression<String>? loopMode,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentTrackId != null) 'current_track_id': currentTrackId,
      if (currentQueuePosition != null)
        'current_queue_position': currentQueuePosition,
      if (positionMilliseconds != null)
        'position_milliseconds': positionMilliseconds,
      if (shuffleEnabled != null) 'shuffle_enabled': shuffleEnabled,
      if (loopMode != null) 'loop_mode': loopMode,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaybackSessionTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? currentTrackId,
    Value<int>? currentQueuePosition,
    Value<int>? positionMilliseconds,
    Value<bool>? shuffleEnabled,
    Value<String>? loopMode,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlaybackSessionTableCompanion(
      id: id ?? this.id,
      currentTrackId: currentTrackId ?? this.currentTrackId,
      currentQueuePosition: currentQueuePosition ?? this.currentQueuePosition,
      positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      loopMode: loopMode ?? this.loopMode,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (currentTrackId.present) {
      map['current_track_id'] = Variable<String>(currentTrackId.value);
    }
    if (currentQueuePosition.present) {
      map['current_queue_position'] = Variable<int>(currentQueuePosition.value);
    }
    if (positionMilliseconds.present) {
      map['position_milliseconds'] = Variable<int>(positionMilliseconds.value);
    }
    if (shuffleEnabled.present) {
      map['shuffle_enabled'] = Variable<bool>(shuffleEnabled.value);
    }
    if (loopMode.present) {
      map['loop_mode'] = Variable<String>(loopMode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSessionTableCompanion(')
          ..write('id: $id, ')
          ..write('currentTrackId: $currentTrackId, ')
          ..write('currentQueuePosition: $currentQueuePosition, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('loopMode: $loopMode, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackQueueItemTableTable extends PlaybackQueueItemTable
    with TableInfo<$PlaybackQueueItemTableTable, PlaybackQueueItemTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackQueueItemTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playback_session_table (id) ON DELETE CASCADE',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, trackId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_queue_item_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackQueueItemTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, trackId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, position},
  ];
  @override
  PlaybackQueueItemTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackQueueItemTableData(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaybackQueueItemTableTable createAlias(String alias) {
    return $PlaybackQueueItemTableTable(attachedDatabase, alias);
  }
}

class PlaybackQueueItemTableData extends DataClass
    implements Insertable<PlaybackQueueItemTableData> {
  final String sessionId;
  final String trackId;
  final int position;
  const PlaybackQueueItemTableData({
    required this.sessionId,
    required this.trackId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaybackQueueItemTableCompanion toCompanion(bool nullToAbsent) {
    return PlaybackQueueItemTableCompanion(
      sessionId: Value(sessionId),
      trackId: Value(trackId),
      position: Value(position),
    );
  }

  factory PlaybackQueueItemTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackQueueItemTableData(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaybackQueueItemTableData copyWith({
    String? sessionId,
    String? trackId,
    int? position,
  }) => PlaybackQueueItemTableData(
    sessionId: sessionId ?? this.sessionId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
  );
  PlaybackQueueItemTableData copyWithCompanion(
    PlaybackQueueItemTableCompanion data,
  ) {
    return PlaybackQueueItemTableData(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackQueueItemTableData(')
          ..write('sessionId: $sessionId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, trackId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackQueueItemTableData &&
          other.sessionId == this.sessionId &&
          other.trackId == this.trackId &&
          other.position == this.position);
}

class PlaybackQueueItemTableCompanion
    extends UpdateCompanion<PlaybackQueueItemTableData> {
  final Value<String> sessionId;
  final Value<String> trackId;
  final Value<int> position;
  final Value<int> rowid;
  const PlaybackQueueItemTableCompanion({
    this.sessionId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaybackQueueItemTableCompanion.insert({
    required String sessionId,
    required String trackId,
    required int position,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       trackId = Value(trackId),
       position = Value(position);
  static Insertable<PlaybackQueueItemTableData> custom({
    Expression<String>? sessionId,
    Expression<String>? trackId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaybackQueueItemTableCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? trackId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return PlaybackQueueItemTableCompanion(
      sessionId: sessionId ?? this.sessionId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackQueueItemTableCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppNavigationStateTableTable extends AppNavigationStateTable
    with TableInfo<$AppNavigationStateTableTable, AppNavigationStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppNavigationStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionMeta = const VerificationMeta(
    'section',
  );
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, section, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_navigation_state_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppNavigationStateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('section')) {
      context.handle(
        _sectionMeta,
        section.isAcceptableOrUnknown(data['section']!, _sectionMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppNavigationStateTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppNavigationStateTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      section: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppNavigationStateTableTable createAlias(String alias) {
    return $AppNavigationStateTableTable(attachedDatabase, alias);
  }
}

class AppNavigationStateTableData extends DataClass
    implements Insertable<AppNavigationStateTableData> {
  final String id;
  final String section;
  final DateTime updatedAt;
  const AppNavigationStateTableData({
    required this.id,
    required this.section,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['section'] = Variable<String>(section);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppNavigationStateTableCompanion toCompanion(bool nullToAbsent) {
    return AppNavigationStateTableCompanion(
      id: Value(id),
      section: Value(section),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppNavigationStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppNavigationStateTableData(
      id: serializer.fromJson<String>(json['id']),
      section: serializer.fromJson<String>(json['section']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'section': serializer.toJson<String>(section),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppNavigationStateTableData copyWith({
    String? id,
    String? section,
    DateTime? updatedAt,
  }) => AppNavigationStateTableData(
    id: id ?? this.id,
    section: section ?? this.section,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppNavigationStateTableData copyWithCompanion(
    AppNavigationStateTableCompanion data,
  ) {
    return AppNavigationStateTableData(
      id: data.id.present ? data.id.value : this.id,
      section: data.section.present ? data.section.value : this.section,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppNavigationStateTableData(')
          ..write('id: $id, ')
          ..write('section: $section, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, section, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppNavigationStateTableData &&
          other.id == this.id &&
          other.section == this.section &&
          other.updatedAt == this.updatedAt);
}

class AppNavigationStateTableCompanion
    extends UpdateCompanion<AppNavigationStateTableData> {
  final Value<String> id;
  final Value<String> section;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppNavigationStateTableCompanion({
    this.id = const Value.absent(),
    this.section = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppNavigationStateTableCompanion.insert({
    required String id,
    required String section,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       section = Value(section),
       updatedAt = Value(updatedAt);
  static Insertable<AppNavigationStateTableData> custom({
    Expression<String>? id,
    Expression<String>? section,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (section != null) 'section': section,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppNavigationStateTableCompanion copyWith({
    Value<String>? id,
    Value<String>? section,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppNavigationStateTableCompanion(
      id: id ?? this.id,
      section: section ?? this.section,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppNavigationStateTableCompanion(')
          ..write('id: $id, ')
          ..write('section: $section, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $ArtistTableTable artistTable = $ArtistTableTable(this);
  late final $TrackArtistTableTable trackArtistTable = $TrackArtistTableTable(
    this,
  );
  late final $PlaylistTrackTableTable playlistTrackTable =
      $PlaylistTrackTableTable(this);
  late final $FileCleanupTaskTableTable fileCleanupTaskTable =
      $FileCleanupTaskTableTable(this);
  late final $ListeningCheckpointTableTable listeningCheckpointTable =
      $ListeningCheckpointTableTable(this);
  late final $PlaybackSessionTableTable playbackSessionTable =
      $PlaybackSessionTableTable(this);
  late final $PlaybackQueueItemTableTable playbackQueueItemTable =
      $PlaybackQueueItemTableTable(this);
  late final $AppNavigationStateTableTable appNavigationStateTable =
      $AppNavigationStateTableTable(this);
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
    artistTable,
    trackArtistTable,
    playlistTrackTable,
    fileCleanupTaskTable,
    listeningCheckpointTable,
    playbackSessionTable,
    playbackQueueItemTable,
    appNavigationStateTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_artist_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'artist_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_artist_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlist_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_track_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_track_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playback_session_table', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playback_session_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('playback_queue_item_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('playback_queue_item_table', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$PlayRecordTableTableCreateCompanionBuilder =
    PlayRecordTableCompanion Function({
      required String id,
      required String trackId,
      required String trackTitle,
      required String artistName,
      required String sourceType,
      required int listenedDurationMilliseconds,
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
      Value<int> listenedDurationMilliseconds,
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

  ColumnFilters<int> get listenedDurationMilliseconds => $composableBuilder(
    column: $table.listenedDurationMilliseconds,
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

  ColumnOrderings<int> get listenedDurationMilliseconds => $composableBuilder(
    column: $table.listenedDurationMilliseconds,
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

  GeneratedColumn<int> get listenedDurationMilliseconds => $composableBuilder(
    column: $table.listenedDurationMilliseconds,
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
                Value<int> listenedDurationMilliseconds = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayRecordTableCompanion(
                id: id,
                trackId: trackId,
                trackTitle: trackTitle,
                artistName: artistName,
                sourceType: sourceType,
                listenedDurationMilliseconds: listenedDurationMilliseconds,
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
                required int listenedDurationMilliseconds,
                required DateTime playedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlayRecordTableCompanion.insert(
                id: id,
                trackId: trackId,
                trackTitle: trackTitle,
                artistName: artistName,
                sourceType: sourceType,
                listenedDurationMilliseconds: listenedDurationMilliseconds,
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
      required DateTime createdAt,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$PlaylistTableTableUpdateCompanionBuilder =
    PlaylistTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<int> revision,
      Value<int> rowid,
    });

final class $$PlaylistTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlaylistTableTable, PlaylistTableData> {
  $$PlaylistTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PlaylistTrackTableTable,
    List<PlaylistTrackTableData>
  >
  _playlistTrackTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistTrackTable,
        aliasName: $_aliasNameGenerator(
          db.playlistTable.id,
          db.playlistTrackTable.playlistId,
        ),
      );

  $$PlaylistTrackTableTableProcessedTableManager get playlistTrackTableRefs {
    final manager = $$PlaylistTrackTableTableTableManager(
      $_db,
      $_db.playlistTrackTable,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistTrackTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistTrackTableRefs(
    Expression<bool> Function($$PlaylistTrackTableTableFilterComposer f) f,
  ) {
    final $$PlaylistTrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTrackTable,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTrackTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTrackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  Expression<T> playlistTrackTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistTrackTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTrackTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTrackTable,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTrackTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistTrackTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (PlaylistTableData, $$PlaylistTableTableReferences),
          PlaylistTableData,
          PrefetchHooks Function({bool playlistTrackTableRefs})
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
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                description: description,
                imageUrl: imageUrl,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                description: description,
                imageUrl: imageUrl,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistTrackTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistTrackTableRefs) db.playlistTrackTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistTrackTableRefs)
                    await $_getPrefetchedData<
                      PlaylistTableData,
                      $PlaylistTableTable,
                      PlaylistTrackTableData
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistTableTableReferences
                          ._playlistTrackTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistTableTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistTrackTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (PlaylistTableData, $$PlaylistTableTableReferences),
      PlaylistTableData,
      PrefetchHooks Function({bool playlistTrackTableRefs})
    >;
typedef $$TrackTableTableCreateCompanionBuilder =
    TrackTableCompanion Function({
      required String id,
      required String title,
      Value<String?> pathToFile,
      Value<int?> durationMs,
      required String sourceType,
      required String sourceUri,
      Value<DateTime?> addedAt,
      Value<String?> album,
      Value<String?> imageUrl,
      Value<String?> trackDescriptorJson,
      Value<String?> embedding,
      Value<int> audioRevision,
      Value<int> metadataRevision,
      Value<int> rowid,
    });
typedef $$TrackTableTableUpdateCompanionBuilder =
    TrackTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> pathToFile,
      Value<int?> durationMs,
      Value<String> sourceType,
      Value<String> sourceUri,
      Value<DateTime?> addedAt,
      Value<String?> album,
      Value<String?> imageUrl,
      Value<String?> trackDescriptorJson,
      Value<String?> embedding,
      Value<int> audioRevision,
      Value<int> metadataRevision,
      Value<int> rowid,
    });

final class $$TrackTableTableReferences
    extends BaseReferences<_$AppDatabase, $TrackTableTable, TrackTableData> {
  $$TrackTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrackArtistTableTable, List<TrackArtistTableData>>
  _trackArtistTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackArtistTable,
    aliasName: $_aliasNameGenerator(
      db.trackTable.id,
      db.trackArtistTable.trackId,
    ),
  );

  $$TrackArtistTableTableProcessedTableManager get trackArtistTableRefs {
    final manager = $$TrackArtistTableTableTableManager(
      $_db,
      $_db.trackArtistTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackArtistTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PlaylistTrackTableTable,
    List<PlaylistTrackTableData>
  >
  _playlistTrackTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistTrackTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.playlistTrackTable.trackId,
        ),
      );

  $$PlaylistTrackTableTableProcessedTableManager get playlistTrackTableRefs {
    final manager = $$PlaylistTrackTableTableTableManager(
      $_db,
      $_db.playlistTrackTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistTrackTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PlaybackSessionTableTable,
    List<PlaybackSessionTableData>
  >
  _playbackSessionTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playbackSessionTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.playbackSessionTable.currentTrackId,
        ),
      );

  $$PlaybackSessionTableTableProcessedTableManager
  get playbackSessionTableRefs {
    final manager = $$PlaybackSessionTableTableTableManager(
      $_db,
      $_db.playbackSessionTable,
    ).filter((f) => f.currentTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playbackSessionTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PlaybackQueueItemTableTable,
    List<PlaybackQueueItemTableData>
  >
  _playbackQueueItemTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playbackQueueItemTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.playbackQueueItemTable.trackId,
        ),
      );

  $$PlaybackQueueItemTableTableProcessedTableManager
  get playbackQueueItemTableRefs {
    final manager = $$PlaybackQueueItemTableTableTableManager(
      $_db,
      $_db.playbackQueueItemTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playbackQueueItemTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
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

  ColumnFilters<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metadataRevision => $composableBuilder(
    column: $table.metadataRevision,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackArtistTableRefs(
    Expression<bool> Function($$TrackArtistTableTableFilterComposer f) f,
  ) {
    final $$TrackArtistTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtistTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistTableTableFilterComposer(
            $db: $db,
            $table: $db.trackArtistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playlistTrackTableRefs(
    Expression<bool> Function($$PlaylistTrackTableTableFilterComposer f) f,
  ) {
    final $$PlaylistTrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTrackTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTrackTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTrackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playbackSessionTableRefs(
    Expression<bool> Function($$PlaybackSessionTableTableFilterComposer f) f,
  ) {
    final $$PlaybackSessionTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playbackSessionTable,
      getReferencedColumn: (t) => t.currentTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaybackSessionTableTableFilterComposer(
            $db: $db,
            $table: $db.playbackSessionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playbackQueueItemTableRefs(
    Expression<bool> Function($$PlaybackQueueItemTableTableFilterComposer f) f,
  ) {
    final $$PlaybackQueueItemTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playbackQueueItemTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaybackQueueItemTableTableFilterComposer(
                $db: $db,
                $table: $db.playbackQueueItemTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
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

  ColumnOrderings<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metadataRevision => $composableBuilder(
    column: $table.metadataRevision,
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

  GeneratedColumn<DateTime> get addedAt =>
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

  GeneratedColumn<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get metadataRevision => $composableBuilder(
    column: $table.metadataRevision,
    builder: (column) => column,
  );

  Expression<T> trackArtistTableRefs<T extends Object>(
    Expression<T> Function($$TrackArtistTableTableAnnotationComposer a) f,
  ) {
    final $$TrackArtistTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtistTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackArtistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playlistTrackTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistTrackTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTrackTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTrackTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTrackTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistTrackTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> playbackSessionTableRefs<T extends Object>(
    Expression<T> Function($$PlaybackSessionTableTableAnnotationComposer a) f,
  ) {
    final $$PlaybackSessionTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playbackSessionTable,
          getReferencedColumn: (t) => t.currentTrackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaybackSessionTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playbackSessionTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> playbackQueueItemTableRefs<T extends Object>(
    Expression<T> Function($$PlaybackQueueItemTableTableAnnotationComposer a) f,
  ) {
    final $$PlaybackQueueItemTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playbackQueueItemTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaybackQueueItemTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playbackQueueItemTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (TrackTableData, $$TrackTableTableReferences),
          TrackTableData,
          PrefetchHooks Function({
            bool trackArtistTableRefs,
            bool playlistTrackTableRefs,
            bool playbackSessionTableRefs,
            bool playbackQueueItemTableRefs,
          })
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
                Value<int?> durationMs = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceUri = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> trackDescriptorJson = const Value.absent(),
                Value<String?> embedding = const Value.absent(),
                Value<int> audioRevision = const Value.absent(),
                Value<int> metadataRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackTableCompanion(
                id: id,
                title: title,
                pathToFile: pathToFile,
                durationMs: durationMs,
                sourceType: sourceType,
                sourceUri: sourceUri,
                addedAt: addedAt,
                album: album,
                imageUrl: imageUrl,
                trackDescriptorJson: trackDescriptorJson,
                embedding: embedding,
                audioRevision: audioRevision,
                metadataRevision: metadataRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> pathToFile = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required String sourceType,
                required String sourceUri,
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> trackDescriptorJson = const Value.absent(),
                Value<String?> embedding = const Value.absent(),
                Value<int> audioRevision = const Value.absent(),
                Value<int> metadataRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackTableCompanion.insert(
                id: id,
                title: title,
                pathToFile: pathToFile,
                durationMs: durationMs,
                sourceType: sourceType,
                sourceUri: sourceUri,
                addedAt: addedAt,
                album: album,
                imageUrl: imageUrl,
                trackDescriptorJson: trackDescriptorJson,
                embedding: embedding,
                audioRevision: audioRevision,
                metadataRevision: metadataRevision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                trackArtistTableRefs = false,
                playlistTrackTableRefs = false,
                playbackSessionTableRefs = false,
                playbackQueueItemTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackArtistTableRefs) db.trackArtistTable,
                    if (playlistTrackTableRefs) db.playlistTrackTable,
                    if (playbackSessionTableRefs) db.playbackSessionTable,
                    if (playbackQueueItemTableRefs) db.playbackQueueItemTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackArtistTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          TrackArtistTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._trackArtistTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackArtistTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playlistTrackTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          PlaylistTrackTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._playlistTrackTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistTrackTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playbackSessionTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          PlaybackSessionTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._playbackSessionTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playbackSessionTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.currentTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playbackQueueItemTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          PlaybackQueueItemTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._playbackQueueItemTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playbackQueueItemTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (TrackTableData, $$TrackTableTableReferences),
      TrackTableData,
      PrefetchHooks Function({
        bool trackArtistTableRefs,
        bool playlistTrackTableRefs,
        bool playbackSessionTableRefs,
        bool playbackQueueItemTableRefs,
      })
    >;
typedef $$EmbeddingTaskTableTableCreateCompanionBuilder =
    EmbeddingTaskTableCompanion Function({
      required String id,
      required String trackId,
      required String status,
      required String filePath,
      required DateTime createdAt,
      Value<int> audioRevision,
      Value<String?> leaseOwner,
      Value<DateTime?> leaseUntil,
      Value<int> rowid,
    });
typedef $$EmbeddingTaskTableTableUpdateCompanionBuilder =
    EmbeddingTaskTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> status,
      Value<String> filePath,
      Value<DateTime> createdAt,
      Value<int> audioRevision,
      Value<String?> leaseOwner,
      Value<DateTime?> leaseUntil,
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

  ColumnFilters<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leaseOwner => $composableBuilder(
    column: $table.leaseOwner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
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

  ColumnOrderings<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leaseOwner => $composableBuilder(
    column: $table.leaseOwner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
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

  GeneratedColumn<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leaseOwner => $composableBuilder(
    column: $table.leaseOwner,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => column,
  );
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
                Value<int> audioRevision = const Value.absent(),
                Value<String?> leaseOwner = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmbeddingTaskTableCompanion(
                id: id,
                trackId: trackId,
                status: status,
                filePath: filePath,
                createdAt: createdAt,
                audioRevision: audioRevision,
                leaseOwner: leaseOwner,
                leaseUntil: leaseUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String status,
                required String filePath,
                required DateTime createdAt,
                Value<int> audioRevision = const Value.absent(),
                Value<String?> leaseOwner = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmbeddingTaskTableCompanion.insert(
                id: id,
                trackId: trackId,
                status: status,
                filePath: filePath,
                createdAt: createdAt,
                audioRevision: audioRevision,
                leaseOwner: leaseOwner,
                leaseUntil: leaseUntil,
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
      Value<String?> leaseOwner,
      Value<DateTime?> leaseUntil,
      Value<int> rowid,
    });
typedef $$DownloadTaskTableTableUpdateCompanionBuilder =
    DownloadTaskTableCompanion Function({
      Value<String> trackId,
      Value<String> originalUrl,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<String?> leaseOwner,
      Value<DateTime?> leaseUntil,
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

  ColumnFilters<String> get leaseOwner => $composableBuilder(
    column: $table.leaseOwner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
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

  ColumnOrderings<String> get leaseOwner => $composableBuilder(
    column: $table.leaseOwner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
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

  GeneratedColumn<String> get leaseOwner => $composableBuilder(
    column: $table.leaseOwner,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => column,
  );
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
                Value<String?> leaseOwner = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTaskTableCompanion(
                trackId: trackId,
                originalUrl: originalUrl,
                status: status,
                createdAt: createdAt,
                leaseOwner: leaseOwner,
                leaseUntil: leaseUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String originalUrl,
                required String status,
                required DateTime createdAt,
                Value<String?> leaseOwner = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTaskTableCompanion.insert(
                trackId: trackId,
                originalUrl: originalUrl,
                status: status,
                createdAt: createdAt,
                leaseOwner: leaseOwner,
                leaseUntil: leaseUntil,
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
typedef $$ArtistTableTableCreateCompanionBuilder =
    ArtistTableCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$ArtistTableTableUpdateCompanionBuilder =
    ArtistTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

final class $$ArtistTableTableReferences
    extends BaseReferences<_$AppDatabase, $ArtistTableTable, ArtistTableData> {
  $$ArtistTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrackArtistTableTable, List<TrackArtistTableData>>
  _trackArtistTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackArtistTable,
    aliasName: $_aliasNameGenerator(
      db.artistTable.id,
      db.trackArtistTable.artistId,
    ),
  );

  $$TrackArtistTableTableProcessedTableManager get trackArtistTableRefs {
    final manager = $$TrackArtistTableTableTableManager(
      $_db,
      $_db.trackArtistTable,
    ).filter((f) => f.artistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackArtistTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArtistTableTableFilterComposer
    extends Composer<_$AppDatabase, $ArtistTableTable> {
  $$ArtistTableTableFilterComposer({
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

  Expression<bool> trackArtistTableRefs(
    Expression<bool> Function($$TrackArtistTableTableFilterComposer f) f,
  ) {
    final $$TrackArtistTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtistTable,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistTableTableFilterComposer(
            $db: $db,
            $table: $db.trackArtistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ArtistTableTable> {
  $$ArtistTableTableOrderingComposer({
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
}

class $$ArtistTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArtistTableTable> {
  $$ArtistTableTableAnnotationComposer({
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

  Expression<T> trackArtistTableRefs<T extends Object>(
    Expression<T> Function($$TrackArtistTableTableAnnotationComposer a) f,
  ) {
    final $$TrackArtistTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtistTable,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackArtistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArtistTableTable,
          ArtistTableData,
          $$ArtistTableTableFilterComposer,
          $$ArtistTableTableOrderingComposer,
          $$ArtistTableTableAnnotationComposer,
          $$ArtistTableTableCreateCompanionBuilder,
          $$ArtistTableTableUpdateCompanionBuilder,
          (ArtistTableData, $$ArtistTableTableReferences),
          ArtistTableData,
          PrefetchHooks Function({bool trackArtistTableRefs})
        > {
  $$ArtistTableTableTableManager(_$AppDatabase db, $ArtistTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtistTableCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) =>
                  ArtistTableCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArtistTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackArtistTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (trackArtistTableRefs) db.trackArtistTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trackArtistTableRefs)
                    await $_getPrefetchedData<
                      ArtistTableData,
                      $ArtistTableTable,
                      TrackArtistTableData
                    >(
                      currentTable: table,
                      referencedTable: $$ArtistTableTableReferences
                          ._trackArtistTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ArtistTableTableReferences(
                            db,
                            table,
                            p0,
                          ).trackArtistTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.artistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ArtistTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArtistTableTable,
      ArtistTableData,
      $$ArtistTableTableFilterComposer,
      $$ArtistTableTableOrderingComposer,
      $$ArtistTableTableAnnotationComposer,
      $$ArtistTableTableCreateCompanionBuilder,
      $$ArtistTableTableUpdateCompanionBuilder,
      (ArtistTableData, $$ArtistTableTableReferences),
      ArtistTableData,
      PrefetchHooks Function({bool trackArtistTableRefs})
    >;
typedef $$TrackArtistTableTableCreateCompanionBuilder =
    TrackArtistTableCompanion Function({
      required String trackId,
      required String artistId,
      required int position,
      Value<int> rowid,
    });
typedef $$TrackArtistTableTableUpdateCompanionBuilder =
    TrackArtistTableCompanion Function({
      Value<String> trackId,
      Value<String> artistId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$TrackArtistTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackArtistTableTable,
          TrackArtistTableData
        > {
  $$TrackArtistTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(db.trackArtistTable.trackId, db.trackTable.id),
      );

  $$TrackTableTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ArtistTableTable _artistIdTable(_$AppDatabase db) =>
      db.artistTable.createAlias(
        $_aliasNameGenerator(db.trackArtistTable.artistId, db.artistTable.id),
      );

  $$ArtistTableTableProcessedTableManager get artistId {
    final $_column = $_itemColumn<String>('artist_id')!;

    final manager = $$ArtistTableTableTableManager(
      $_db,
      $_db.artistTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackArtistTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackArtistTableTable> {
  $$TrackArtistTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackTableTableFilterComposer get trackId {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableFilterComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistTableTableFilterComposer get artistId {
    final $$ArtistTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableTableFilterComposer(
            $db: $db,
            $table: $db.artistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackArtistTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackArtistTableTable> {
  $$TrackArtistTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackTableTableOrderingComposer get trackId {
    final $$TrackTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableOrderingComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistTableTableOrderingComposer get artistId {
    final $$ArtistTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableTableOrderingComposer(
            $db: $db,
            $table: $db.artistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackArtistTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackArtistTableTable> {
  $$TrackArtistTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$TrackTableTableAnnotationComposer get trackId {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistTableTableAnnotationComposer get artistId {
    final $$ArtistTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableTableAnnotationComposer(
            $db: $db,
            $table: $db.artistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackArtistTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackArtistTableTable,
          TrackArtistTableData,
          $$TrackArtistTableTableFilterComposer,
          $$TrackArtistTableTableOrderingComposer,
          $$TrackArtistTableTableAnnotationComposer,
          $$TrackArtistTableTableCreateCompanionBuilder,
          $$TrackArtistTableTableUpdateCompanionBuilder,
          (TrackArtistTableData, $$TrackArtistTableTableReferences),
          TrackArtistTableData,
          PrefetchHooks Function({bool trackId, bool artistId})
        > {
  $$TrackArtistTableTableTableManager(
    _$AppDatabase db,
    $TrackArtistTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackArtistTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackArtistTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackArtistTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> artistId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackArtistTableCompanion(
                trackId: trackId,
                artistId: artistId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String artistId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => TrackArtistTableCompanion.insert(
                trackId: trackId,
                artistId: artistId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackArtistTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false, artistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable:
                                    $$TrackArtistTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$TrackArtistTableTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (artistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.artistId,
                                referencedTable:
                                    $$TrackArtistTableTableReferences
                                        ._artistIdTable(db),
                                referencedColumn:
                                    $$TrackArtistTableTableReferences
                                        ._artistIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackArtistTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackArtistTableTable,
      TrackArtistTableData,
      $$TrackArtistTableTableFilterComposer,
      $$TrackArtistTableTableOrderingComposer,
      $$TrackArtistTableTableAnnotationComposer,
      $$TrackArtistTableTableCreateCompanionBuilder,
      $$TrackArtistTableTableUpdateCompanionBuilder,
      (TrackArtistTableData, $$TrackArtistTableTableReferences),
      TrackArtistTableData,
      PrefetchHooks Function({bool trackId, bool artistId})
    >;
typedef $$PlaylistTrackTableTableCreateCompanionBuilder =
    PlaylistTrackTableCompanion Function({
      required String playlistId,
      required String trackId,
      required int position,
      Value<int> rowid,
    });
typedef $$PlaylistTrackTableTableUpdateCompanionBuilder =
    PlaylistTrackTableCompanion Function({
      Value<String> playlistId,
      Value<String> trackId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$PlaylistTrackTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistTrackTableTable,
          PlaylistTrackTableData
        > {
  $$PlaylistTrackTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistTableTable _playlistIdTable(_$AppDatabase db) =>
      db.playlistTable.createAlias(
        $_aliasNameGenerator(
          db.playlistTrackTable.playlistId,
          db.playlistTable.id,
        ),
      );

  $$PlaylistTableTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistTableTableTableManager(
      $_db,
      $_db.playlistTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(db.playlistTrackTable.trackId, db.trackTable.id),
      );

  $$TrackTableTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistTrackTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistTrackTableTable> {
  $$PlaylistTrackTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistTableTableFilterComposer get playlistId {
    final $$PlaylistTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableTableFilterComposer get trackId {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableFilterComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTrackTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistTrackTableTable> {
  $$PlaylistTrackTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistTableTableOrderingComposer get playlistId {
    final $$PlaylistTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableTableOrderingComposer(
            $db: $db,
            $table: $db.playlistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableTableOrderingComposer get trackId {
    final $$TrackTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableOrderingComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTrackTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistTrackTableTable> {
  $$PlaylistTrackTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$PlaylistTableTableAnnotationComposer get playlistId {
    final $$PlaylistTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableTableAnnotationComposer get trackId {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTrackTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistTrackTableTable,
          PlaylistTrackTableData,
          $$PlaylistTrackTableTableFilterComposer,
          $$PlaylistTrackTableTableOrderingComposer,
          $$PlaylistTrackTableTableAnnotationComposer,
          $$PlaylistTrackTableTableCreateCompanionBuilder,
          $$PlaylistTrackTableTableUpdateCompanionBuilder,
          (PlaylistTrackTableData, $$PlaylistTrackTableTableReferences),
          PlaylistTrackTableData,
          PrefetchHooks Function({bool playlistId, bool trackId})
        > {
  $$PlaylistTrackTableTableTableManager(
    _$AppDatabase db,
    $PlaylistTrackTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTrackTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTrackTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTrackTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTrackTableCompanion(
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String trackId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTrackTableCompanion.insert(
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTrackTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$PlaylistTrackTableTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$PlaylistTrackTableTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable:
                                    $$PlaylistTrackTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$PlaylistTrackTableTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistTrackTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistTrackTableTable,
      PlaylistTrackTableData,
      $$PlaylistTrackTableTableFilterComposer,
      $$PlaylistTrackTableTableOrderingComposer,
      $$PlaylistTrackTableTableAnnotationComposer,
      $$PlaylistTrackTableTableCreateCompanionBuilder,
      $$PlaylistTrackTableTableUpdateCompanionBuilder,
      (PlaylistTrackTableData, $$PlaylistTrackTableTableReferences),
      PlaylistTrackTableData,
      PrefetchHooks Function({bool playlistId, bool trackId})
    >;
typedef $$FileCleanupTaskTableTableCreateCompanionBuilder =
    FileCleanupTaskTableCompanion Function({
      required String path,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FileCleanupTaskTableTableUpdateCompanionBuilder =
    FileCleanupTaskTableCompanion Function({
      Value<String> path,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FileCleanupTaskTableTableFilterComposer
    extends Composer<_$AppDatabase, $FileCleanupTaskTableTable> {
  $$FileCleanupTaskTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FileCleanupTaskTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FileCleanupTaskTableTable> {
  $$FileCleanupTaskTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FileCleanupTaskTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FileCleanupTaskTableTable> {
  $$FileCleanupTaskTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FileCleanupTaskTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FileCleanupTaskTableTable,
          FileCleanupTaskTableData,
          $$FileCleanupTaskTableTableFilterComposer,
          $$FileCleanupTaskTableTableOrderingComposer,
          $$FileCleanupTaskTableTableAnnotationComposer,
          $$FileCleanupTaskTableTableCreateCompanionBuilder,
          $$FileCleanupTaskTableTableUpdateCompanionBuilder,
          (
            FileCleanupTaskTableData,
            BaseReferences<
              _$AppDatabase,
              $FileCleanupTaskTableTable,
              FileCleanupTaskTableData
            >,
          ),
          FileCleanupTaskTableData,
          PrefetchHooks Function()
        > {
  $$FileCleanupTaskTableTableTableManager(
    _$AppDatabase db,
    $FileCleanupTaskTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FileCleanupTaskTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FileCleanupTaskTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FileCleanupTaskTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> path = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileCleanupTaskTableCompanion(
                path: path,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String path,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FileCleanupTaskTableCompanion.insert(
                path: path,
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

typedef $$FileCleanupTaskTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FileCleanupTaskTableTable,
      FileCleanupTaskTableData,
      $$FileCleanupTaskTableTableFilterComposer,
      $$FileCleanupTaskTableTableOrderingComposer,
      $$FileCleanupTaskTableTableAnnotationComposer,
      $$FileCleanupTaskTableTableCreateCompanionBuilder,
      $$FileCleanupTaskTableTableUpdateCompanionBuilder,
      (
        FileCleanupTaskTableData,
        BaseReferences<
          _$AppDatabase,
          $FileCleanupTaskTableTable,
          FileCleanupTaskTableData
        >,
      ),
      FileCleanupTaskTableData,
      PrefetchHooks Function()
    >;
typedef $$ListeningCheckpointTableTableCreateCompanionBuilder =
    ListeningCheckpointTableCompanion Function({
      required String id,
      required String trackId,
      required String trackTitle,
      required String artistName,
      required String sourceType,
      required int listenedMilliseconds,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ListeningCheckpointTableTableUpdateCompanionBuilder =
    ListeningCheckpointTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> trackTitle,
      Value<String> artistName,
      Value<String> sourceType,
      Value<int> listenedMilliseconds,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ListeningCheckpointTableTableFilterComposer
    extends Composer<_$AppDatabase, $ListeningCheckpointTableTable> {
  $$ListeningCheckpointTableTableFilterComposer({
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

  ColumnFilters<int> get listenedMilliseconds => $composableBuilder(
    column: $table.listenedMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ListeningCheckpointTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ListeningCheckpointTableTable> {
  $$ListeningCheckpointTableTableOrderingComposer({
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

  ColumnOrderings<int> get listenedMilliseconds => $composableBuilder(
    column: $table.listenedMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ListeningCheckpointTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListeningCheckpointTableTable> {
  $$ListeningCheckpointTableTableAnnotationComposer({
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

  GeneratedColumn<int> get listenedMilliseconds => $composableBuilder(
    column: $table.listenedMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ListeningCheckpointTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListeningCheckpointTableTable,
          ListeningCheckpointTableData,
          $$ListeningCheckpointTableTableFilterComposer,
          $$ListeningCheckpointTableTableOrderingComposer,
          $$ListeningCheckpointTableTableAnnotationComposer,
          $$ListeningCheckpointTableTableCreateCompanionBuilder,
          $$ListeningCheckpointTableTableUpdateCompanionBuilder,
          (
            ListeningCheckpointTableData,
            BaseReferences<
              _$AppDatabase,
              $ListeningCheckpointTableTable,
              ListeningCheckpointTableData
            >,
          ),
          ListeningCheckpointTableData,
          PrefetchHooks Function()
        > {
  $$ListeningCheckpointTableTableTableManager(
    _$AppDatabase db,
    $ListeningCheckpointTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningCheckpointTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ListeningCheckpointTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ListeningCheckpointTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> trackTitle = const Value.absent(),
                Value<String> artistName = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<int> listenedMilliseconds = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListeningCheckpointTableCompanion(
                id: id,
                trackId: trackId,
                trackTitle: trackTitle,
                artistName: artistName,
                sourceType: sourceType,
                listenedMilliseconds: listenedMilliseconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String trackTitle,
                required String artistName,
                required String sourceType,
                required int listenedMilliseconds,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ListeningCheckpointTableCompanion.insert(
                id: id,
                trackId: trackId,
                trackTitle: trackTitle,
                artistName: artistName,
                sourceType: sourceType,
                listenedMilliseconds: listenedMilliseconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ListeningCheckpointTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListeningCheckpointTableTable,
      ListeningCheckpointTableData,
      $$ListeningCheckpointTableTableFilterComposer,
      $$ListeningCheckpointTableTableOrderingComposer,
      $$ListeningCheckpointTableTableAnnotationComposer,
      $$ListeningCheckpointTableTableCreateCompanionBuilder,
      $$ListeningCheckpointTableTableUpdateCompanionBuilder,
      (
        ListeningCheckpointTableData,
        BaseReferences<
          _$AppDatabase,
          $ListeningCheckpointTableTable,
          ListeningCheckpointTableData
        >,
      ),
      ListeningCheckpointTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaybackSessionTableTableCreateCompanionBuilder =
    PlaybackSessionTableCompanion Function({
      required String id,
      Value<String?> currentTrackId,
      required int currentQueuePosition,
      required int positionMilliseconds,
      required bool shuffleEnabled,
      required String loopMode,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PlaybackSessionTableTableUpdateCompanionBuilder =
    PlaybackSessionTableCompanion Function({
      Value<String> id,
      Value<String?> currentTrackId,
      Value<int> currentQueuePosition,
      Value<int> positionMilliseconds,
      Value<bool> shuffleEnabled,
      Value<String> loopMode,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PlaybackSessionTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaybackSessionTableTable,
          PlaybackSessionTableData
        > {
  $$PlaybackSessionTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _currentTrackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.playbackSessionTable.currentTrackId,
          db.trackTable.id,
        ),
      );

  $$TrackTableTableProcessedTableManager? get currentTrackId {
    final $_column = $_itemColumn<String>('current_track_id');
    if ($_column == null) return null;
    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currentTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PlaybackQueueItemTableTable,
    List<PlaybackQueueItemTableData>
  >
  _playbackQueueItemTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playbackQueueItemTable,
        aliasName: $_aliasNameGenerator(
          db.playbackSessionTable.id,
          db.playbackQueueItemTable.sessionId,
        ),
      );

  $$PlaybackQueueItemTableTableProcessedTableManager
  get playbackQueueItemTableRefs {
    final manager = $$PlaybackQueueItemTableTableTableManager(
      $_db,
      $_db.playbackQueueItemTable,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playbackQueueItemTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaybackSessionTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackSessionTableTable> {
  $$PlaybackSessionTableTableFilterComposer({
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

  ColumnFilters<int> get currentQueuePosition => $composableBuilder(
    column: $table.currentQueuePosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loopMode => $composableBuilder(
    column: $table.loopMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackTableTableFilterComposer get currentTrackId {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentTrackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableFilterComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playbackQueueItemTableRefs(
    Expression<bool> Function($$PlaybackQueueItemTableTableFilterComposer f) f,
  ) {
    final $$PlaybackQueueItemTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playbackQueueItemTable,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaybackQueueItemTableTableFilterComposer(
                $db: $db,
                $table: $db.playbackQueueItemTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaybackSessionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackSessionTableTable> {
  $$PlaybackSessionTableTableOrderingComposer({
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

  ColumnOrderings<int> get currentQueuePosition => $composableBuilder(
    column: $table.currentQueuePosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loopMode => $composableBuilder(
    column: $table.loopMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackTableTableOrderingComposer get currentTrackId {
    final $$TrackTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentTrackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableOrderingComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackSessionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackSessionTableTable> {
  $$PlaybackSessionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentQueuePosition => $composableBuilder(
    column: $table.currentQueuePosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loopMode =>
      $composableBuilder(column: $table.loopMode, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TrackTableTableAnnotationComposer get currentTrackId {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentTrackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> playbackQueueItemTableRefs<T extends Object>(
    Expression<T> Function($$PlaybackQueueItemTableTableAnnotationComposer a) f,
  ) {
    final $$PlaybackQueueItemTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playbackQueueItemTable,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaybackQueueItemTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playbackQueueItemTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaybackSessionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackSessionTableTable,
          PlaybackSessionTableData,
          $$PlaybackSessionTableTableFilterComposer,
          $$PlaybackSessionTableTableOrderingComposer,
          $$PlaybackSessionTableTableAnnotationComposer,
          $$PlaybackSessionTableTableCreateCompanionBuilder,
          $$PlaybackSessionTableTableUpdateCompanionBuilder,
          (PlaybackSessionTableData, $$PlaybackSessionTableTableReferences),
          PlaybackSessionTableData,
          PrefetchHooks Function({
            bool currentTrackId,
            bool playbackQueueItemTableRefs,
          })
        > {
  $$PlaybackSessionTableTableTableManager(
    _$AppDatabase db,
    $PlaybackSessionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackSessionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackSessionTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaybackSessionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> currentTrackId = const Value.absent(),
                Value<int> currentQueuePosition = const Value.absent(),
                Value<int> positionMilliseconds = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String> loopMode = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackSessionTableCompanion(
                id: id,
                currentTrackId: currentTrackId,
                currentQueuePosition: currentQueuePosition,
                positionMilliseconds: positionMilliseconds,
                shuffleEnabled: shuffleEnabled,
                loopMode: loopMode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> currentTrackId = const Value.absent(),
                required int currentQueuePosition,
                required int positionMilliseconds,
                required bool shuffleEnabled,
                required String loopMode,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaybackSessionTableCompanion.insert(
                id: id,
                currentTrackId: currentTrackId,
                currentQueuePosition: currentQueuePosition,
                positionMilliseconds: positionMilliseconds,
                shuffleEnabled: shuffleEnabled,
                loopMode: loopMode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaybackSessionTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({currentTrackId = false, playbackQueueItemTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playbackQueueItemTableRefs) db.playbackQueueItemTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (currentTrackId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.currentTrackId,
                                    referencedTable:
                                        $$PlaybackSessionTableTableReferences
                                            ._currentTrackIdTable(db),
                                    referencedColumn:
                                        $$PlaybackSessionTableTableReferences
                                            ._currentTrackIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playbackQueueItemTableRefs)
                        await $_getPrefetchedData<
                          PlaybackSessionTableData,
                          $PlaybackSessionTableTable,
                          PlaybackQueueItemTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PlaybackSessionTableTableReferences
                              ._playbackQueueItemTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaybackSessionTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playbackQueueItemTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlaybackSessionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackSessionTableTable,
      PlaybackSessionTableData,
      $$PlaybackSessionTableTableFilterComposer,
      $$PlaybackSessionTableTableOrderingComposer,
      $$PlaybackSessionTableTableAnnotationComposer,
      $$PlaybackSessionTableTableCreateCompanionBuilder,
      $$PlaybackSessionTableTableUpdateCompanionBuilder,
      (PlaybackSessionTableData, $$PlaybackSessionTableTableReferences),
      PlaybackSessionTableData,
      PrefetchHooks Function({
        bool currentTrackId,
        bool playbackQueueItemTableRefs,
      })
    >;
typedef $$PlaybackQueueItemTableTableCreateCompanionBuilder =
    PlaybackQueueItemTableCompanion Function({
      required String sessionId,
      required String trackId,
      required int position,
      Value<int> rowid,
    });
typedef $$PlaybackQueueItemTableTableUpdateCompanionBuilder =
    PlaybackQueueItemTableCompanion Function({
      Value<String> sessionId,
      Value<String> trackId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$PlaybackQueueItemTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaybackQueueItemTableTable,
          PlaybackQueueItemTableData
        > {
  $$PlaybackQueueItemTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaybackSessionTableTable _sessionIdTable(_$AppDatabase db) =>
      db.playbackSessionTable.createAlias(
        $_aliasNameGenerator(
          db.playbackQueueItemTable.sessionId,
          db.playbackSessionTable.id,
        ),
      );

  $$PlaybackSessionTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PlaybackSessionTableTableTableManager(
      $_db,
      $_db.playbackSessionTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.playbackQueueItemTable.trackId,
          db.trackTable.id,
        ),
      );

  $$TrackTableTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaybackQueueItemTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackQueueItemTableTable> {
  $$PlaybackQueueItemTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaybackSessionTableTableFilterComposer get sessionId {
    final $$PlaybackSessionTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.playbackSessionTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaybackSessionTableTableFilterComposer(
            $db: $db,
            $table: $db.playbackSessionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableTableFilterComposer get trackId {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableFilterComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackQueueItemTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackQueueItemTableTable> {
  $$PlaybackQueueItemTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaybackSessionTableTableOrderingComposer get sessionId {
    final $$PlaybackSessionTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.playbackSessionTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaybackSessionTableTableOrderingComposer(
                $db: $db,
                $table: $db.playbackSessionTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TrackTableTableOrderingComposer get trackId {
    final $$TrackTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableOrderingComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackQueueItemTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackQueueItemTableTable> {
  $$PlaybackQueueItemTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$PlaybackSessionTableTableAnnotationComposer get sessionId {
    final $$PlaybackSessionTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.playbackSessionTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaybackSessionTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playbackSessionTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TrackTableTableAnnotationComposer get trackId {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackQueueItemTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackQueueItemTableTable,
          PlaybackQueueItemTableData,
          $$PlaybackQueueItemTableTableFilterComposer,
          $$PlaybackQueueItemTableTableOrderingComposer,
          $$PlaybackQueueItemTableTableAnnotationComposer,
          $$PlaybackQueueItemTableTableCreateCompanionBuilder,
          $$PlaybackQueueItemTableTableUpdateCompanionBuilder,
          (PlaybackQueueItemTableData, $$PlaybackQueueItemTableTableReferences),
          PlaybackQueueItemTableData,
          PrefetchHooks Function({bool sessionId, bool trackId})
        > {
  $$PlaybackQueueItemTableTableTableManager(
    _$AppDatabase db,
    $PlaybackQueueItemTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackQueueItemTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PlaybackQueueItemTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaybackQueueItemTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackQueueItemTableCompanion(
                sessionId: sessionId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String trackId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => PlaybackQueueItemTableCompanion.insert(
                sessionId: sessionId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaybackQueueItemTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$PlaybackQueueItemTableTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$PlaybackQueueItemTableTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable:
                                    $$PlaybackQueueItemTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$PlaybackQueueItemTableTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaybackQueueItemTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackQueueItemTableTable,
      PlaybackQueueItemTableData,
      $$PlaybackQueueItemTableTableFilterComposer,
      $$PlaybackQueueItemTableTableOrderingComposer,
      $$PlaybackQueueItemTableTableAnnotationComposer,
      $$PlaybackQueueItemTableTableCreateCompanionBuilder,
      $$PlaybackQueueItemTableTableUpdateCompanionBuilder,
      (PlaybackQueueItemTableData, $$PlaybackQueueItemTableTableReferences),
      PlaybackQueueItemTableData,
      PrefetchHooks Function({bool sessionId, bool trackId})
    >;
typedef $$AppNavigationStateTableTableCreateCompanionBuilder =
    AppNavigationStateTableCompanion Function({
      required String id,
      required String section,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppNavigationStateTableTableUpdateCompanionBuilder =
    AppNavigationStateTableCompanion Function({
      Value<String> id,
      Value<String> section,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppNavigationStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppNavigationStateTableTable> {
  $$AppNavigationStateTableTableFilterComposer({
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

  ColumnFilters<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppNavigationStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppNavigationStateTableTable> {
  $$AppNavigationStateTableTableOrderingComposer({
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

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppNavigationStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppNavigationStateTableTable> {
  $$AppNavigationStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppNavigationStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppNavigationStateTableTable,
          AppNavigationStateTableData,
          $$AppNavigationStateTableTableFilterComposer,
          $$AppNavigationStateTableTableOrderingComposer,
          $$AppNavigationStateTableTableAnnotationComposer,
          $$AppNavigationStateTableTableCreateCompanionBuilder,
          $$AppNavigationStateTableTableUpdateCompanionBuilder,
          (
            AppNavigationStateTableData,
            BaseReferences<
              _$AppDatabase,
              $AppNavigationStateTableTable,
              AppNavigationStateTableData
            >,
          ),
          AppNavigationStateTableData,
          PrefetchHooks Function()
        > {
  $$AppNavigationStateTableTableTableManager(
    _$AppDatabase db,
    $AppNavigationStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppNavigationStateTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AppNavigationStateTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AppNavigationStateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> section = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppNavigationStateTableCompanion(
                id: id,
                section: section,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String section,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppNavigationStateTableCompanion.insert(
                id: id,
                section: section,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppNavigationStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppNavigationStateTableTable,
      AppNavigationStateTableData,
      $$AppNavigationStateTableTableFilterComposer,
      $$AppNavigationStateTableTableOrderingComposer,
      $$AppNavigationStateTableTableAnnotationComposer,
      $$AppNavigationStateTableTableCreateCompanionBuilder,
      $$AppNavigationStateTableTableUpdateCompanionBuilder,
      (
        AppNavigationStateTableData,
        BaseReferences<
          _$AppDatabase,
          $AppNavigationStateTableTable,
          AppNavigationStateTableData
        >,
      ),
      AppNavigationStateTableData,
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
  $$ArtistTableTableTableManager get artistTable =>
      $$ArtistTableTableTableManager(_db, _db.artistTable);
  $$TrackArtistTableTableTableManager get trackArtistTable =>
      $$TrackArtistTableTableTableManager(_db, _db.trackArtistTable);
  $$PlaylistTrackTableTableTableManager get playlistTrackTable =>
      $$PlaylistTrackTableTableTableManager(_db, _db.playlistTrackTable);
  $$FileCleanupTaskTableTableTableManager get fileCleanupTaskTable =>
      $$FileCleanupTaskTableTableTableManager(_db, _db.fileCleanupTaskTable);
  $$ListeningCheckpointTableTableTableManager get listeningCheckpointTable =>
      $$ListeningCheckpointTableTableTableManager(
        _db,
        _db.listeningCheckpointTable,
      );
  $$PlaybackSessionTableTableTableManager get playbackSessionTable =>
      $$PlaybackSessionTableTableTableManager(_db, _db.playbackSessionTable);
  $$PlaybackQueueItemTableTableTableManager get playbackQueueItemTable =>
      $$PlaybackQueueItemTableTableTableManager(
        _db,
        _db.playbackQueueItemTable,
      );
  $$AppNavigationStateTableTableTableManager get appNavigationStateTable =>
      $$AppNavigationStateTableTableTableManager(
        _db,
        _db.appNavigationStateTable,
      );
}
