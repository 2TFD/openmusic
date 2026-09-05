// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ListeningSummaryTableTable extends ListeningSummaryTable
    with TableInfo<$ListeningSummaryTableTable, ListeningSummaryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningSummaryTableTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'listening_summary_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListeningSummaryTableData> instance, {
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
  ListeningSummaryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningSummaryTableData(
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
  $ListeningSummaryTableTable createAlias(String alias) {
    return $ListeningSummaryTableTable(attachedDatabase, alias);
  }
}

class ListeningSummaryTableData extends DataClass
    implements Insertable<ListeningSummaryTableData> {
  final String id;
  final String trackId;
  final String trackTitle;
  final String artistName;
  final String sourceType;
  final int listenedDurationMilliseconds;
  final DateTime playedAt;
  const ListeningSummaryTableData({
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

  ListeningSummaryTableCompanion toCompanion(bool nullToAbsent) {
    return ListeningSummaryTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      trackTitle: Value(trackTitle),
      artistName: Value(artistName),
      sourceType: Value(sourceType),
      listenedDurationMilliseconds: Value(listenedDurationMilliseconds),
      playedAt: Value(playedAt),
    );
  }

  factory ListeningSummaryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningSummaryTableData(
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

  ListeningSummaryTableData copyWith({
    String? id,
    String? trackId,
    String? trackTitle,
    String? artistName,
    String? sourceType,
    int? listenedDurationMilliseconds,
    DateTime? playedAt,
  }) => ListeningSummaryTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    trackTitle: trackTitle ?? this.trackTitle,
    artistName: artistName ?? this.artistName,
    sourceType: sourceType ?? this.sourceType,
    listenedDurationMilliseconds:
        listenedDurationMilliseconds ?? this.listenedDurationMilliseconds,
    playedAt: playedAt ?? this.playedAt,
  );
  ListeningSummaryTableData copyWithCompanion(
    ListeningSummaryTableCompanion data,
  ) {
    return ListeningSummaryTableData(
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
    return (StringBuffer('ListeningSummaryTableData(')
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
      (other is ListeningSummaryTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.trackTitle == this.trackTitle &&
          other.artistName == this.artistName &&
          other.sourceType == this.sourceType &&
          other.listenedDurationMilliseconds ==
              this.listenedDurationMilliseconds &&
          other.playedAt == this.playedAt);
}

class ListeningSummaryTableCompanion
    extends UpdateCompanion<ListeningSummaryTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> trackTitle;
  final Value<String> artistName;
  final Value<String> sourceType;
  final Value<int> listenedDurationMilliseconds;
  final Value<DateTime> playedAt;
  final Value<int> rowid;
  const ListeningSummaryTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.trackTitle = const Value.absent(),
    this.artistName = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.listenedDurationMilliseconds = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListeningSummaryTableCompanion.insert({
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
  static Insertable<ListeningSummaryTableData> custom({
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

  ListeningSummaryTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? trackTitle,
    Value<String>? artistName,
    Value<String>? sourceType,
    Value<int>? listenedDurationMilliseconds,
    Value<DateTime>? playedAt,
    Value<int>? rowid,
  }) {
    return ListeningSummaryTableCompanion(
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
    return (StringBuffer('ListeningSummaryTableCompanion(')
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
  static const VerificationMeta _contentIdentityMeta = const VerificationMeta(
    'contentIdentity',
  );
  @override
  late final GeneratedColumn<String> contentIdentity = GeneratedColumn<String>(
    'content_identity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    contentIdentity,
    title,
    pathToFile,
    durationMs,
    sourceType,
    sourceUri,
    addedAt,
    album,
    imageUrl,
    trackDescriptorJson,
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
    if (data.containsKey('content_identity')) {
      context.handle(
        _contentIdentityMeta,
        contentIdentity.isAcceptableOrUnknown(
          data['content_identity']!,
          _contentIdentityMeta,
        ),
      );
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
      contentIdentity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_identity'],
      ),
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
  final String? contentIdentity;
  final String title;
  final String? pathToFile;
  final int? durationMs;
  final String sourceType;
  final String sourceUri;
  final DateTime? addedAt;
  final String? album;
  final String? imageUrl;
  final String? trackDescriptorJson;
  final int audioRevision;
  final int metadataRevision;
  const TrackTableData({
    required this.id,
    this.contentIdentity,
    required this.title,
    this.pathToFile,
    this.durationMs,
    required this.sourceType,
    required this.sourceUri,
    this.addedAt,
    this.album,
    this.imageUrl,
    this.trackDescriptorJson,
    required this.audioRevision,
    required this.metadataRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || contentIdentity != null) {
      map['content_identity'] = Variable<String>(contentIdentity);
    }
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
    map['audio_revision'] = Variable<int>(audioRevision);
    map['metadata_revision'] = Variable<int>(metadataRevision);
    return map;
  }

  TrackTableCompanion toCompanion(bool nullToAbsent) {
    return TrackTableCompanion(
      id: Value(id),
      contentIdentity: contentIdentity == null && nullToAbsent
          ? const Value.absent()
          : Value(contentIdentity),
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
      contentIdentity: serializer.fromJson<String?>(json['contentIdentity']),
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
      audioRevision: serializer.fromJson<int>(json['audioRevision']),
      metadataRevision: serializer.fromJson<int>(json['metadataRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contentIdentity': serializer.toJson<String?>(contentIdentity),
      'title': serializer.toJson<String>(title),
      'pathToFile': serializer.toJson<String?>(pathToFile),
      'durationMs': serializer.toJson<int?>(durationMs),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceUri': serializer.toJson<String>(sourceUri),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
      'album': serializer.toJson<String?>(album),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'trackDescriptorJson': serializer.toJson<String?>(trackDescriptorJson),
      'audioRevision': serializer.toJson<int>(audioRevision),
      'metadataRevision': serializer.toJson<int>(metadataRevision),
    };
  }

  TrackTableData copyWith({
    String? id,
    Value<String?> contentIdentity = const Value.absent(),
    String? title,
    Value<String?> pathToFile = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    String? sourceType,
    String? sourceUri,
    Value<DateTime?> addedAt = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> trackDescriptorJson = const Value.absent(),
    int? audioRevision,
    int? metadataRevision,
  }) => TrackTableData(
    id: id ?? this.id,
    contentIdentity: contentIdentity.present
        ? contentIdentity.value
        : this.contentIdentity,
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
    audioRevision: audioRevision ?? this.audioRevision,
    metadataRevision: metadataRevision ?? this.metadataRevision,
  );
  TrackTableData copyWithCompanion(TrackTableCompanion data) {
    return TrackTableData(
      id: data.id.present ? data.id.value : this.id,
      contentIdentity: data.contentIdentity.present
          ? data.contentIdentity.value
          : this.contentIdentity,
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
          ..write('contentIdentity: $contentIdentity, ')
          ..write('title: $title, ')
          ..write('pathToFile: $pathToFile, ')
          ..write('durationMs: $durationMs, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('addedAt: $addedAt, ')
          ..write('album: $album, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('trackDescriptorJson: $trackDescriptorJson, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('metadataRevision: $metadataRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contentIdentity,
    title,
    pathToFile,
    durationMs,
    sourceType,
    sourceUri,
    addedAt,
    album,
    imageUrl,
    trackDescriptorJson,
    audioRevision,
    metadataRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackTableData &&
          other.id == this.id &&
          other.contentIdentity == this.contentIdentity &&
          other.title == this.title &&
          other.pathToFile == this.pathToFile &&
          other.durationMs == this.durationMs &&
          other.sourceType == this.sourceType &&
          other.sourceUri == this.sourceUri &&
          other.addedAt == this.addedAt &&
          other.album == this.album &&
          other.imageUrl == this.imageUrl &&
          other.trackDescriptorJson == this.trackDescriptorJson &&
          other.audioRevision == this.audioRevision &&
          other.metadataRevision == this.metadataRevision);
}

class TrackTableCompanion extends UpdateCompanion<TrackTableData> {
  final Value<String> id;
  final Value<String?> contentIdentity;
  final Value<String> title;
  final Value<String?> pathToFile;
  final Value<int?> durationMs;
  final Value<String> sourceType;
  final Value<String> sourceUri;
  final Value<DateTime?> addedAt;
  final Value<String?> album;
  final Value<String?> imageUrl;
  final Value<String?> trackDescriptorJson;
  final Value<int> audioRevision;
  final Value<int> metadataRevision;
  final Value<int> rowid;
  const TrackTableCompanion({
    this.id = const Value.absent(),
    this.contentIdentity = const Value.absent(),
    this.title = const Value.absent(),
    this.pathToFile = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.album = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.trackDescriptorJson = const Value.absent(),
    this.audioRevision = const Value.absent(),
    this.metadataRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackTableCompanion.insert({
    required String id,
    this.contentIdentity = const Value.absent(),
    required String title,
    this.pathToFile = const Value.absent(),
    this.durationMs = const Value.absent(),
    required String sourceType,
    required String sourceUri,
    this.addedAt = const Value.absent(),
    this.album = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.trackDescriptorJson = const Value.absent(),
    this.audioRevision = const Value.absent(),
    this.metadataRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       sourceType = Value(sourceType),
       sourceUri = Value(sourceUri);
  static Insertable<TrackTableData> custom({
    Expression<String>? id,
    Expression<String>? contentIdentity,
    Expression<String>? title,
    Expression<String>? pathToFile,
    Expression<int>? durationMs,
    Expression<String>? sourceType,
    Expression<String>? sourceUri,
    Expression<DateTime>? addedAt,
    Expression<String>? album,
    Expression<String>? imageUrl,
    Expression<String>? trackDescriptorJson,
    Expression<int>? audioRevision,
    Expression<int>? metadataRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentIdentity != null) 'content_identity': contentIdentity,
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
      if (audioRevision != null) 'audio_revision': audioRevision,
      if (metadataRevision != null) 'metadata_revision': metadataRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? contentIdentity,
    Value<String>? title,
    Value<String?>? pathToFile,
    Value<int?>? durationMs,
    Value<String>? sourceType,
    Value<String>? sourceUri,
    Value<DateTime?>? addedAt,
    Value<String?>? album,
    Value<String?>? imageUrl,
    Value<String?>? trackDescriptorJson,
    Value<int>? audioRevision,
    Value<int>? metadataRevision,
    Value<int>? rowid,
  }) {
    return TrackTableCompanion(
      id: id ?? this.id,
      contentIdentity: contentIdentity ?? this.contentIdentity,
      title: title ?? this.title,
      pathToFile: pathToFile ?? this.pathToFile,
      durationMs: durationMs ?? this.durationMs,
      sourceType: sourceType ?? this.sourceType,
      sourceUri: sourceUri ?? this.sourceUri,
      addedAt: addedAt ?? this.addedAt,
      album: album ?? this.album,
      imageUrl: imageUrl ?? this.imageUrl,
      trackDescriptorJson: trackDescriptorJson ?? this.trackDescriptorJson,
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
    if (contentIdentity.present) {
      map['content_identity'] = Variable<String>(contentIdentity.value);
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
          ..write('contentIdentity: $contentIdentity, ')
          ..write('title: $title, ')
          ..write('pathToFile: $pathToFile, ')
          ..write('durationMs: $durationMs, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('addedAt: $addedAt, ')
          ..write('album: $album, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('trackDescriptorJson: $trackDescriptorJson, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('metadataRevision: $metadataRevision, ')
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
  static const VerificationMeta _failureCodeMeta = const VerificationMeta(
    'failureCode',
  );
  @override
  late final GeneratedColumn<String> failureCode = GeneratedColumn<String>(
    'failure_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failureMessageMeta = const VerificationMeta(
    'failureMessage',
  );
  @override
  late final GeneratedColumn<String> failureMessage = GeneratedColumn<String>(
    'failure_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failureDetailsMeta = const VerificationMeta(
    'failureDetails',
  );
  @override
  late final GeneratedColumn<String> failureDetails = GeneratedColumn<String>(
    'failure_details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failedAtMeta = const VerificationMeta(
    'failedAt',
  );
  @override
  late final GeneratedColumn<DateTime> failedAt = GeneratedColumn<DateTime>(
    'failed_at',
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
    failureCode,
    failureMessage,
    failureDetails,
    failedAt,
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
    if (data.containsKey('failure_code')) {
      context.handle(
        _failureCodeMeta,
        failureCode.isAcceptableOrUnknown(
          data['failure_code']!,
          _failureCodeMeta,
        ),
      );
    }
    if (data.containsKey('failure_message')) {
      context.handle(
        _failureMessageMeta,
        failureMessage.isAcceptableOrUnknown(
          data['failure_message']!,
          _failureMessageMeta,
        ),
      );
    }
    if (data.containsKey('failure_details')) {
      context.handle(
        _failureDetailsMeta,
        failureDetails.isAcceptableOrUnknown(
          data['failure_details']!,
          _failureDetailsMeta,
        ),
      );
    }
    if (data.containsKey('failed_at')) {
      context.handle(
        _failedAtMeta,
        failedAt.isAcceptableOrUnknown(data['failed_at']!, _failedAtMeta),
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
      failureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_code'],
      ),
      failureMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_message'],
      ),
      failureDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_details'],
      ),
      failedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}failed_at'],
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
  final String? failureCode;
  final String? failureMessage;
  final String? failureDetails;
  final DateTime? failedAt;
  const DownloadTaskTableData({
    required this.trackId,
    required this.originalUrl,
    required this.status,
    required this.createdAt,
    this.leaseOwner,
    this.leaseUntil,
    this.failureCode,
    this.failureMessage,
    this.failureDetails,
    this.failedAt,
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
    if (!nullToAbsent || failureCode != null) {
      map['failure_code'] = Variable<String>(failureCode);
    }
    if (!nullToAbsent || failureMessage != null) {
      map['failure_message'] = Variable<String>(failureMessage);
    }
    if (!nullToAbsent || failureDetails != null) {
      map['failure_details'] = Variable<String>(failureDetails);
    }
    if (!nullToAbsent || failedAt != null) {
      map['failed_at'] = Variable<DateTime>(failedAt);
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
      failureCode: failureCode == null && nullToAbsent
          ? const Value.absent()
          : Value(failureCode),
      failureMessage: failureMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(failureMessage),
      failureDetails: failureDetails == null && nullToAbsent
          ? const Value.absent()
          : Value(failureDetails),
      failedAt: failedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(failedAt),
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
      failureCode: serializer.fromJson<String?>(json['failureCode']),
      failureMessage: serializer.fromJson<String?>(json['failureMessage']),
      failureDetails: serializer.fromJson<String?>(json['failureDetails']),
      failedAt: serializer.fromJson<DateTime?>(json['failedAt']),
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
      'failureCode': serializer.toJson<String?>(failureCode),
      'failureMessage': serializer.toJson<String?>(failureMessage),
      'failureDetails': serializer.toJson<String?>(failureDetails),
      'failedAt': serializer.toJson<DateTime?>(failedAt),
    };
  }

  DownloadTaskTableData copyWith({
    String? trackId,
    String? originalUrl,
    String? status,
    DateTime? createdAt,
    Value<String?> leaseOwner = const Value.absent(),
    Value<DateTime?> leaseUntil = const Value.absent(),
    Value<String?> failureCode = const Value.absent(),
    Value<String?> failureMessage = const Value.absent(),
    Value<String?> failureDetails = const Value.absent(),
    Value<DateTime?> failedAt = const Value.absent(),
  }) => DownloadTaskTableData(
    trackId: trackId ?? this.trackId,
    originalUrl: originalUrl ?? this.originalUrl,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    leaseOwner: leaseOwner.present ? leaseOwner.value : this.leaseOwner,
    leaseUntil: leaseUntil.present ? leaseUntil.value : this.leaseUntil,
    failureCode: failureCode.present ? failureCode.value : this.failureCode,
    failureMessage: failureMessage.present
        ? failureMessage.value
        : this.failureMessage,
    failureDetails: failureDetails.present
        ? failureDetails.value
        : this.failureDetails,
    failedAt: failedAt.present ? failedAt.value : this.failedAt,
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
      failureCode: data.failureCode.present
          ? data.failureCode.value
          : this.failureCode,
      failureMessage: data.failureMessage.present
          ? data.failureMessage.value
          : this.failureMessage,
      failureDetails: data.failureDetails.present
          ? data.failureDetails.value
          : this.failureDetails,
      failedAt: data.failedAt.present ? data.failedAt.value : this.failedAt,
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
          ..write('leaseUntil: $leaseUntil, ')
          ..write('failureCode: $failureCode, ')
          ..write('failureMessage: $failureMessage, ')
          ..write('failureDetails: $failureDetails, ')
          ..write('failedAt: $failedAt')
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
    failureCode,
    failureMessage,
    failureDetails,
    failedAt,
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
          other.leaseUntil == this.leaseUntil &&
          other.failureCode == this.failureCode &&
          other.failureMessage == this.failureMessage &&
          other.failureDetails == this.failureDetails &&
          other.failedAt == this.failedAt);
}

class DownloadTaskTableCompanion
    extends UpdateCompanion<DownloadTaskTableData> {
  final Value<String> trackId;
  final Value<String> originalUrl;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String?> leaseOwner;
  final Value<DateTime?> leaseUntil;
  final Value<String?> failureCode;
  final Value<String?> failureMessage;
  final Value<String?> failureDetails;
  final Value<DateTime?> failedAt;
  final Value<int> rowid;
  const DownloadTaskTableCompanion({
    this.trackId = const Value.absent(),
    this.originalUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.leaseOwner = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    this.failureCode = const Value.absent(),
    this.failureMessage = const Value.absent(),
    this.failureDetails = const Value.absent(),
    this.failedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTaskTableCompanion.insert({
    required String trackId,
    required String originalUrl,
    required String status,
    required DateTime createdAt,
    this.leaseOwner = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    this.failureCode = const Value.absent(),
    this.failureMessage = const Value.absent(),
    this.failureDetails = const Value.absent(),
    this.failedAt = const Value.absent(),
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
    Expression<String>? failureCode,
    Expression<String>? failureMessage,
    Expression<String>? failureDetails,
    Expression<DateTime>? failedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (originalUrl != null) 'original_url': originalUrl,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (leaseOwner != null) 'lease_owner': leaseOwner,
      if (leaseUntil != null) 'lease_until': leaseUntil,
      if (failureCode != null) 'failure_code': failureCode,
      if (failureMessage != null) 'failure_message': failureMessage,
      if (failureDetails != null) 'failure_details': failureDetails,
      if (failedAt != null) 'failed_at': failedAt,
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
    Value<String?>? failureCode,
    Value<String?>? failureMessage,
    Value<String?>? failureDetails,
    Value<DateTime?>? failedAt,
    Value<int>? rowid,
  }) {
    return DownloadTaskTableCompanion(
      trackId: trackId ?? this.trackId,
      originalUrl: originalUrl ?? this.originalUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      leaseOwner: leaseOwner ?? this.leaseOwner,
      leaseUntil: leaseUntil ?? this.leaseUntil,
      failureCode: failureCode ?? this.failureCode,
      failureMessage: failureMessage ?? this.failureMessage,
      failureDetails: failureDetails ?? this.failureDetails,
      failedAt: failedAt ?? this.failedAt,
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
    if (failureCode.present) {
      map['failure_code'] = Variable<String>(failureCode.value);
    }
    if (failureMessage.present) {
      map['failure_message'] = Variable<String>(failureMessage.value);
    }
    if (failureDetails.present) {
      map['failure_details'] = Variable<String>(failureDetails.value);
    }
    if (failedAt.present) {
      map['failed_at'] = Variable<DateTime>(failedAt.value);
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
          ..write('failureCode: $failureCode, ')
          ..write('failureMessage: $failureMessage, ')
          ..write('failureDetails: $failureDetails, ')
          ..write('failedAt: $failedAt, ')
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

class $TrackEmbeddingTableTable extends TrackEmbeddingTable
    with TableInfo<$TrackEmbeddingTableTable, TrackEmbeddingTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackEmbeddingTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _modalityMeta = const VerificationMeta(
    'modality',
  );
  @override
  late final GeneratedColumn<String> modality = GeneratedColumn<String>(
    'modality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preprocessingVersionMeta =
      const VerificationMeta('preprocessingVersion');
  @override
  late final GeneratedColumn<String> preprocessingVersion =
      GeneratedColumn<String>(
        'preprocessing_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('legacy-unknown'),
      );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioRevisionMeta = const VerificationMeta(
    'audioRevision',
  );
  @override
  late final GeneratedColumn<int> audioRevision = GeneratedColumn<int>(
    'audio_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentRevisionMeta = const VerificationMeta(
    'contentRevision',
  );
  @override
  late final GeneratedColumn<String> contentRevision = GeneratedColumn<String>(
    'content_revision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dtypeMeta = const VerificationMeta('dtype');
  @override
  late final GeneratedColumn<String> dtype = GeneratedColumn<String>(
    'dtype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('float32'),
  );
  static const VerificationMeta _normalizedMeta = const VerificationMeta(
    'normalized',
  );
  @override
  late final GeneratedColumn<bool> normalized = GeneratedColumn<bool>(
    'normalized',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("normalized" IN (0, 1))',
    ),
  );
  static const VerificationMeta _dimensionsMeta = const VerificationMeta(
    'dimensions',
  );
  @override
  late final GeneratedColumn<int> dimensions = GeneratedColumn<int>(
    'dimensions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
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
    modality,
    modelId,
    modelVersion,
    preprocessingVersion,
    provider,
    audioRevision,
    contentRevision,
    dtype,
    normalized,
    dimensions,
    vector,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_embedding_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackEmbeddingTableData> instance, {
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
    if (data.containsKey('modality')) {
      context.handle(
        _modalityMeta,
        modality.isAcceptableOrUnknown(data['modality']!, _modalityMeta),
      );
    } else if (isInserting) {
      context.missing(_modalityMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('preprocessing_version')) {
      context.handle(
        _preprocessingVersionMeta,
        preprocessingVersion.isAcceptableOrUnknown(
          data['preprocessing_version']!,
          _preprocessingVersionMeta,
        ),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
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
    if (data.containsKey('content_revision')) {
      context.handle(
        _contentRevisionMeta,
        contentRevision.isAcceptableOrUnknown(
          data['content_revision']!,
          _contentRevisionMeta,
        ),
      );
    }
    if (data.containsKey('dtype')) {
      context.handle(
        _dtypeMeta,
        dtype.isAcceptableOrUnknown(data['dtype']!, _dtypeMeta),
      );
    }
    if (data.containsKey('normalized')) {
      context.handle(
        _normalizedMeta,
        normalized.isAcceptableOrUnknown(data['normalized']!, _normalizedMeta),
      );
    }
    if (data.containsKey('dimensions')) {
      context.handle(
        _dimensionsMeta,
        dimensions.isAcceptableOrUnknown(data['dimensions']!, _dimensionsMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionsMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
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
  Set<GeneratedColumn> get $primaryKey => {
    trackId,
    modality,
    modelId,
    modelVersion,
    preprocessingVersion,
    provider,
  };
  @override
  TrackEmbeddingTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackEmbeddingTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      modality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modality'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      preprocessingVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preprocessing_version'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      audioRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_revision'],
      ),
      contentRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_revision'],
      ),
      dtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dtype'],
      )!,
      normalized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}normalized'],
      ),
      dimensions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dimensions'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TrackEmbeddingTableTable createAlias(String alias) {
    return $TrackEmbeddingTableTable(attachedDatabase, alias);
  }
}

class TrackEmbeddingTableData extends DataClass
    implements Insertable<TrackEmbeddingTableData> {
  final String trackId;
  final String modality;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
  final String provider;
  final int? audioRevision;
  final String? contentRevision;
  final String dtype;
  final bool? normalized;
  final int dimensions;
  final Uint8List vector;
  final DateTime createdAt;
  const TrackEmbeddingTableData({
    required this.trackId,
    required this.modality,
    required this.modelId,
    required this.modelVersion,
    required this.preprocessingVersion,
    required this.provider,
    this.audioRevision,
    this.contentRevision,
    required this.dtype,
    this.normalized,
    required this.dimensions,
    required this.vector,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['modality'] = Variable<String>(modality);
    map['model_id'] = Variable<String>(modelId);
    map['model_version'] = Variable<String>(modelVersion);
    map['preprocessing_version'] = Variable<String>(preprocessingVersion);
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || audioRevision != null) {
      map['audio_revision'] = Variable<int>(audioRevision);
    }
    if (!nullToAbsent || contentRevision != null) {
      map['content_revision'] = Variable<String>(contentRevision);
    }
    map['dtype'] = Variable<String>(dtype);
    if (!nullToAbsent || normalized != null) {
      map['normalized'] = Variable<bool>(normalized);
    }
    map['dimensions'] = Variable<int>(dimensions);
    map['vector'] = Variable<Uint8List>(vector);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TrackEmbeddingTableCompanion toCompanion(bool nullToAbsent) {
    return TrackEmbeddingTableCompanion(
      trackId: Value(trackId),
      modality: Value(modality),
      modelId: Value(modelId),
      modelVersion: Value(modelVersion),
      preprocessingVersion: Value(preprocessingVersion),
      provider: Value(provider),
      audioRevision: audioRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(audioRevision),
      contentRevision: contentRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(contentRevision),
      dtype: Value(dtype),
      normalized: normalized == null && nullToAbsent
          ? const Value.absent()
          : Value(normalized),
      dimensions: Value(dimensions),
      vector: Value(vector),
      createdAt: Value(createdAt),
    );
  }

  factory TrackEmbeddingTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackEmbeddingTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      modality: serializer.fromJson<String>(json['modality']),
      modelId: serializer.fromJson<String>(json['modelId']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      preprocessingVersion: serializer.fromJson<String>(
        json['preprocessingVersion'],
      ),
      provider: serializer.fromJson<String>(json['provider']),
      audioRevision: serializer.fromJson<int?>(json['audioRevision']),
      contentRevision: serializer.fromJson<String?>(json['contentRevision']),
      dtype: serializer.fromJson<String>(json['dtype']),
      normalized: serializer.fromJson<bool?>(json['normalized']),
      dimensions: serializer.fromJson<int>(json['dimensions']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'modality': serializer.toJson<String>(modality),
      'modelId': serializer.toJson<String>(modelId),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'preprocessingVersion': serializer.toJson<String>(preprocessingVersion),
      'provider': serializer.toJson<String>(provider),
      'audioRevision': serializer.toJson<int?>(audioRevision),
      'contentRevision': serializer.toJson<String?>(contentRevision),
      'dtype': serializer.toJson<String>(dtype),
      'normalized': serializer.toJson<bool?>(normalized),
      'dimensions': serializer.toJson<int>(dimensions),
      'vector': serializer.toJson<Uint8List>(vector),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TrackEmbeddingTableData copyWith({
    String? trackId,
    String? modality,
    String? modelId,
    String? modelVersion,
    String? preprocessingVersion,
    String? provider,
    Value<int?> audioRevision = const Value.absent(),
    Value<String?> contentRevision = const Value.absent(),
    String? dtype,
    Value<bool?> normalized = const Value.absent(),
    int? dimensions,
    Uint8List? vector,
    DateTime? createdAt,
  }) => TrackEmbeddingTableData(
    trackId: trackId ?? this.trackId,
    modality: modality ?? this.modality,
    modelId: modelId ?? this.modelId,
    modelVersion: modelVersion ?? this.modelVersion,
    preprocessingVersion: preprocessingVersion ?? this.preprocessingVersion,
    provider: provider ?? this.provider,
    audioRevision: audioRevision.present
        ? audioRevision.value
        : this.audioRevision,
    contentRevision: contentRevision.present
        ? contentRevision.value
        : this.contentRevision,
    dtype: dtype ?? this.dtype,
    normalized: normalized.present ? normalized.value : this.normalized,
    dimensions: dimensions ?? this.dimensions,
    vector: vector ?? this.vector,
    createdAt: createdAt ?? this.createdAt,
  );
  TrackEmbeddingTableData copyWithCompanion(TrackEmbeddingTableCompanion data) {
    return TrackEmbeddingTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      modality: data.modality.present ? data.modality.value : this.modality,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      preprocessingVersion: data.preprocessingVersion.present
          ? data.preprocessingVersion.value
          : this.preprocessingVersion,
      provider: data.provider.present ? data.provider.value : this.provider,
      audioRevision: data.audioRevision.present
          ? data.audioRevision.value
          : this.audioRevision,
      contentRevision: data.contentRevision.present
          ? data.contentRevision.value
          : this.contentRevision,
      dtype: data.dtype.present ? data.dtype.value : this.dtype,
      normalized: data.normalized.present
          ? data.normalized.value
          : this.normalized,
      dimensions: data.dimensions.present
          ? data.dimensions.value
          : this.dimensions,
      vector: data.vector.present ? data.vector.value : this.vector,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackEmbeddingTableData(')
          ..write('trackId: $trackId, ')
          ..write('modality: $modality, ')
          ..write('modelId: $modelId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('preprocessingVersion: $preprocessingVersion, ')
          ..write('provider: $provider, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('contentRevision: $contentRevision, ')
          ..write('dtype: $dtype, ')
          ..write('normalized: $normalized, ')
          ..write('dimensions: $dimensions, ')
          ..write('vector: $vector, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    modality,
    modelId,
    modelVersion,
    preprocessingVersion,
    provider,
    audioRevision,
    contentRevision,
    dtype,
    normalized,
    dimensions,
    $driftBlobEquality.hash(vector),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackEmbeddingTableData &&
          other.trackId == this.trackId &&
          other.modality == this.modality &&
          other.modelId == this.modelId &&
          other.modelVersion == this.modelVersion &&
          other.preprocessingVersion == this.preprocessingVersion &&
          other.provider == this.provider &&
          other.audioRevision == this.audioRevision &&
          other.contentRevision == this.contentRevision &&
          other.dtype == this.dtype &&
          other.normalized == this.normalized &&
          other.dimensions == this.dimensions &&
          $driftBlobEquality.equals(other.vector, this.vector) &&
          other.createdAt == this.createdAt);
}

class TrackEmbeddingTableCompanion
    extends UpdateCompanion<TrackEmbeddingTableData> {
  final Value<String> trackId;
  final Value<String> modality;
  final Value<String> modelId;
  final Value<String> modelVersion;
  final Value<String> preprocessingVersion;
  final Value<String> provider;
  final Value<int?> audioRevision;
  final Value<String?> contentRevision;
  final Value<String> dtype;
  final Value<bool?> normalized;
  final Value<int> dimensions;
  final Value<Uint8List> vector;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TrackEmbeddingTableCompanion({
    this.trackId = const Value.absent(),
    this.modality = const Value.absent(),
    this.modelId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.preprocessingVersion = const Value.absent(),
    this.provider = const Value.absent(),
    this.audioRevision = const Value.absent(),
    this.contentRevision = const Value.absent(),
    this.dtype = const Value.absent(),
    this.normalized = const Value.absent(),
    this.dimensions = const Value.absent(),
    this.vector = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackEmbeddingTableCompanion.insert({
    required String trackId,
    required String modality,
    required String modelId,
    required String modelVersion,
    this.preprocessingVersion = const Value.absent(),
    required String provider,
    this.audioRevision = const Value.absent(),
    this.contentRevision = const Value.absent(),
    this.dtype = const Value.absent(),
    this.normalized = const Value.absent(),
    required int dimensions,
    required Uint8List vector,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       modality = Value(modality),
       modelId = Value(modelId),
       modelVersion = Value(modelVersion),
       provider = Value(provider),
       dimensions = Value(dimensions),
       vector = Value(vector),
       createdAt = Value(createdAt);
  static Insertable<TrackEmbeddingTableData> custom({
    Expression<String>? trackId,
    Expression<String>? modality,
    Expression<String>? modelId,
    Expression<String>? modelVersion,
    Expression<String>? preprocessingVersion,
    Expression<String>? provider,
    Expression<int>? audioRevision,
    Expression<String>? contentRevision,
    Expression<String>? dtype,
    Expression<bool>? normalized,
    Expression<int>? dimensions,
    Expression<Uint8List>? vector,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (modality != null) 'modality': modality,
      if (modelId != null) 'model_id': modelId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (preprocessingVersion != null)
        'preprocessing_version': preprocessingVersion,
      if (provider != null) 'provider': provider,
      if (audioRevision != null) 'audio_revision': audioRevision,
      if (contentRevision != null) 'content_revision': contentRevision,
      if (dtype != null) 'dtype': dtype,
      if (normalized != null) 'normalized': normalized,
      if (dimensions != null) 'dimensions': dimensions,
      if (vector != null) 'vector': vector,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackEmbeddingTableCompanion copyWith({
    Value<String>? trackId,
    Value<String>? modality,
    Value<String>? modelId,
    Value<String>? modelVersion,
    Value<String>? preprocessingVersion,
    Value<String>? provider,
    Value<int?>? audioRevision,
    Value<String?>? contentRevision,
    Value<String>? dtype,
    Value<bool?>? normalized,
    Value<int>? dimensions,
    Value<Uint8List>? vector,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TrackEmbeddingTableCompanion(
      trackId: trackId ?? this.trackId,
      modality: modality ?? this.modality,
      modelId: modelId ?? this.modelId,
      modelVersion: modelVersion ?? this.modelVersion,
      preprocessingVersion: preprocessingVersion ?? this.preprocessingVersion,
      provider: provider ?? this.provider,
      audioRevision: audioRevision ?? this.audioRevision,
      contentRevision: contentRevision ?? this.contentRevision,
      dtype: dtype ?? this.dtype,
      normalized: normalized ?? this.normalized,
      dimensions: dimensions ?? this.dimensions,
      vector: vector ?? this.vector,
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
    if (modality.present) {
      map['modality'] = Variable<String>(modality.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (preprocessingVersion.present) {
      map['preprocessing_version'] = Variable<String>(
        preprocessingVersion.value,
      );
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (audioRevision.present) {
      map['audio_revision'] = Variable<int>(audioRevision.value);
    }
    if (contentRevision.present) {
      map['content_revision'] = Variable<String>(contentRevision.value);
    }
    if (dtype.present) {
      map['dtype'] = Variable<String>(dtype.value);
    }
    if (normalized.present) {
      map['normalized'] = Variable<bool>(normalized.value);
    }
    if (dimensions.present) {
      map['dimensions'] = Variable<int>(dimensions.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
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
    return (StringBuffer('TrackEmbeddingTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('modality: $modality, ')
          ..write('modelId: $modelId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('preprocessingVersion: $preprocessingVersion, ')
          ..write('provider: $provider, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('contentRevision: $contentRevision, ')
          ..write('dtype: $dtype, ')
          ..write('normalized: $normalized, ')
          ..write('dimensions: $dimensions, ')
          ..write('vector: $vector, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListeningEventTableTable extends ListeningEventTable
    with TableInfo<$ListeningEventTableTable, ListeningEventTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningEventTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listenedMsMeta = const VerificationMeta(
    'listenedMs',
  );
  @override
  late final GeneratedColumn<int> listenedMs = GeneratedColumn<int>(
    'listened_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _previousTrackIdMeta = const VerificationMeta(
    'previousTrackId',
  );
  @override
  late final GeneratedColumn<String> previousTrackId = GeneratedColumn<String>(
    'previous_track_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transitionReasonMeta = const VerificationMeta(
    'transitionReason',
  );
  @override
  late final GeneratedColumn<String> transitionReason = GeneratedColumn<String>(
    'transition_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    trackId,
    type,
    occurredAt,
    positionMs,
    listenedMs,
    durationMs,
    previousTrackId,
    transitionReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listening_event_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListeningEventTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('listened_ms')) {
      context.handle(
        _listenedMsMeta,
        listenedMs.isAcceptableOrUnknown(data['listened_ms']!, _listenedMsMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('previous_track_id')) {
      context.handle(
        _previousTrackIdMeta,
        previousTrackId.isAcceptableOrUnknown(
          data['previous_track_id']!,
          _previousTrackIdMeta,
        ),
      );
    }
    if (data.containsKey('transition_reason')) {
      context.handle(
        _transitionReasonMeta,
        transitionReason.isAcceptableOrUnknown(
          data['transition_reason']!,
          _transitionReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListeningEventTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningEventTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      ),
      listenedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listened_ms'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      previousTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_track_id'],
      ),
      transitionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transition_reason'],
      ),
    );
  }

  @override
  $ListeningEventTableTable createAlias(String alias) {
    return $ListeningEventTableTable(attachedDatabase, alias);
  }
}

class ListeningEventTableData extends DataClass
    implements Insertable<ListeningEventTableData> {
  final String id;
  final String? sessionId;
  final String trackId;
  final String type;
  final DateTime occurredAt;
  final int? positionMs;
  final int? listenedMs;
  final int? durationMs;
  final String? previousTrackId;
  final String? transitionReason;
  const ListeningEventTableData({
    required this.id,
    this.sessionId,
    required this.trackId,
    required this.type,
    required this.occurredAt,
    this.positionMs,
    this.listenedMs,
    this.durationMs,
    this.previousTrackId,
    this.transitionReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['track_id'] = Variable<String>(trackId);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || positionMs != null) {
      map['position_ms'] = Variable<int>(positionMs);
    }
    if (!nullToAbsent || listenedMs != null) {
      map['listened_ms'] = Variable<int>(listenedMs);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || previousTrackId != null) {
      map['previous_track_id'] = Variable<String>(previousTrackId);
    }
    if (!nullToAbsent || transitionReason != null) {
      map['transition_reason'] = Variable<String>(transitionReason);
    }
    return map;
  }

  ListeningEventTableCompanion toCompanion(bool nullToAbsent) {
    return ListeningEventTableCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      trackId: Value(trackId),
      type: Value(type),
      occurredAt: Value(occurredAt),
      positionMs: positionMs == null && nullToAbsent
          ? const Value.absent()
          : Value(positionMs),
      listenedMs: listenedMs == null && nullToAbsent
          ? const Value.absent()
          : Value(listenedMs),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      previousTrackId: previousTrackId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousTrackId),
      transitionReason: transitionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(transitionReason),
    );
  }

  factory ListeningEventTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningEventTableData(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      positionMs: serializer.fromJson<int?>(json['positionMs']),
      listenedMs: serializer.fromJson<int?>(json['listenedMs']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      previousTrackId: serializer.fromJson<String?>(json['previousTrackId']),
      transitionReason: serializer.fromJson<String?>(json['transitionReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String?>(sessionId),
      'trackId': serializer.toJson<String>(trackId),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'positionMs': serializer.toJson<int?>(positionMs),
      'listenedMs': serializer.toJson<int?>(listenedMs),
      'durationMs': serializer.toJson<int?>(durationMs),
      'previousTrackId': serializer.toJson<String?>(previousTrackId),
      'transitionReason': serializer.toJson<String?>(transitionReason),
    };
  }

  ListeningEventTableData copyWith({
    String? id,
    Value<String?> sessionId = const Value.absent(),
    String? trackId,
    String? type,
    DateTime? occurredAt,
    Value<int?> positionMs = const Value.absent(),
    Value<int?> listenedMs = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> previousTrackId = const Value.absent(),
    Value<String?> transitionReason = const Value.absent(),
  }) => ListeningEventTableData(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    trackId: trackId ?? this.trackId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    positionMs: positionMs.present ? positionMs.value : this.positionMs,
    listenedMs: listenedMs.present ? listenedMs.value : this.listenedMs,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    previousTrackId: previousTrackId.present
        ? previousTrackId.value
        : this.previousTrackId,
    transitionReason: transitionReason.present
        ? transitionReason.value
        : this.transitionReason,
  );
  ListeningEventTableData copyWithCompanion(ListeningEventTableCompanion data) {
    return ListeningEventTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      listenedMs: data.listenedMs.present
          ? data.listenedMs.value
          : this.listenedMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      previousTrackId: data.previousTrackId.present
          ? data.previousTrackId.value
          : this.previousTrackId,
      transitionReason: data.transitionReason.present
          ? data.transitionReason.value
          : this.transitionReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListeningEventTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('trackId: $trackId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('positionMs: $positionMs, ')
          ..write('listenedMs: $listenedMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('previousTrackId: $previousTrackId, ')
          ..write('transitionReason: $transitionReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    trackId,
    type,
    occurredAt,
    positionMs,
    listenedMs,
    durationMs,
    previousTrackId,
    transitionReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningEventTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.trackId == this.trackId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.positionMs == this.positionMs &&
          other.listenedMs == this.listenedMs &&
          other.durationMs == this.durationMs &&
          other.previousTrackId == this.previousTrackId &&
          other.transitionReason == this.transitionReason);
}

class ListeningEventTableCompanion
    extends UpdateCompanion<ListeningEventTableData> {
  final Value<String> id;
  final Value<String?> sessionId;
  final Value<String> trackId;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<int?> positionMs;
  final Value<int?> listenedMs;
  final Value<int?> durationMs;
  final Value<String?> previousTrackId;
  final Value<String?> transitionReason;
  final Value<int> rowid;
  const ListeningEventTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.previousTrackId = const Value.absent(),
    this.transitionReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListeningEventTableCompanion.insert({
    required String id,
    this.sessionId = const Value.absent(),
    required String trackId,
    required String type,
    required DateTime occurredAt,
    this.positionMs = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.previousTrackId = const Value.absent(),
    this.transitionReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       type = Value(type),
       occurredAt = Value(occurredAt);
  static Insertable<ListeningEventTableData> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? trackId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<int>? positionMs,
    Expression<int>? listenedMs,
    Expression<int>? durationMs,
    Expression<String>? previousTrackId,
    Expression<String>? transitionReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (trackId != null) 'track_id': trackId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (positionMs != null) 'position_ms': positionMs,
      if (listenedMs != null) 'listened_ms': listenedMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (previousTrackId != null) 'previous_track_id': previousTrackId,
      if (transitionReason != null) 'transition_reason': transitionReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListeningEventTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? sessionId,
    Value<String>? trackId,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<int?>? positionMs,
    Value<int?>? listenedMs,
    Value<int?>? durationMs,
    Value<String?>? previousTrackId,
    Value<String?>? transitionReason,
    Value<int>? rowid,
  }) {
    return ListeningEventTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      trackId: trackId ?? this.trackId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      positionMs: positionMs ?? this.positionMs,
      listenedMs: listenedMs ?? this.listenedMs,
      durationMs: durationMs ?? this.durationMs,
      previousTrackId: previousTrackId ?? this.previousTrackId,
      transitionReason: transitionReason ?? this.transitionReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (listenedMs.present) {
      map['listened_ms'] = Variable<int>(listenedMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (previousTrackId.present) {
      map['previous_track_id'] = Variable<String>(previousTrackId.value);
    }
    if (transitionReason.present) {
      map['transition_reason'] = Variable<String>(transitionReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningEventTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('trackId: $trackId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('positionMs: $positionMs, ')
          ..write('listenedMs: $listenedMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('previousTrackId: $previousTrackId, ')
          ..write('transitionReason: $transitionReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackTemporalEmbeddingTableTable extends TrackTemporalEmbeddingTable
    with
        TableInfo<
          $TrackTemporalEmbeddingTableTable,
          TrackTemporalEmbeddingTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackTemporalEmbeddingTableTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _representationMeta = const VerificationMeta(
    'representation',
  );
  @override
  late final GeneratedColumn<String> representation = GeneratedColumn<String>(
    'representation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preprocessingVersionMeta =
      const VerificationMeta('preprocessingVersion');
  @override
  late final GeneratedColumn<String> preprocessingVersion =
      GeneratedColumn<String>(
        'preprocessing_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionMeta = const VerificationMeta(
    'dimension',
  );
  @override
  late final GeneratedColumn<int> dimension = GeneratedColumn<int>(
    'dimension',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dtypeMeta = const VerificationMeta('dtype');
  @override
  late final GeneratedColumn<String> dtype = GeneratedColumn<String>(
    'dtype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedMeta = const VerificationMeta(
    'normalized',
  );
  @override
  late final GeneratedColumn<bool> normalized = GeneratedColumn<bool>(
    'normalized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("normalized" IN (0, 1))',
    ),
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
  static const VerificationMeta _numberOfSegmentsMeta = const VerificationMeta(
    'numberOfSegments',
  );
  @override
  late final GeneratedColumn<int> numberOfSegments = GeneratedColumn<int>(
    'number_of_segments',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meanAdjacentDistanceMeta =
      const VerificationMeta('meanAdjacentDistance');
  @override
  late final GeneratedColumn<double> meanAdjacentDistance =
      GeneratedColumn<double>(
        'mean_adjacent_distance',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _maxAdjacentDistanceMeta =
      const VerificationMeta('maxAdjacentDistance');
  @override
  late final GeneratedColumn<double> maxAdjacentDistance =
      GeneratedColumn<double>(
        'max_adjacent_distance',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _trajectoryVarianceMeta =
      const VerificationMeta('trajectoryVariance');
  @override
  late final GeneratedColumn<double> trajectoryVariance =
      GeneratedColumn<double>(
        'trajectory_variance',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _largestTransitionIndexMeta =
      const VerificationMeta('largestTransitionIndex');
  @override
  late final GeneratedColumn<int> largestTransitionIndex = GeneratedColumn<int>(
    'largest_transition_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    representation,
    modelId,
    modelVersion,
    preprocessingVersion,
    provider,
    audioRevision,
    dimension,
    dtype,
    normalized,
    createdAt,
    numberOfSegments,
    meanAdjacentDistance,
    maxAdjacentDistance,
    trajectoryVariance,
    largestTransitionIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_temporal_embedding_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackTemporalEmbeddingTableData> instance, {
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
    if (data.containsKey('representation')) {
      context.handle(
        _representationMeta,
        representation.isAcceptableOrUnknown(
          data['representation']!,
          _representationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_representationMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('preprocessing_version')) {
      context.handle(
        _preprocessingVersionMeta,
        preprocessingVersion.isAcceptableOrUnknown(
          data['preprocessing_version']!,
          _preprocessingVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preprocessingVersionMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('audio_revision')) {
      context.handle(
        _audioRevisionMeta,
        audioRevision.isAcceptableOrUnknown(
          data['audio_revision']!,
          _audioRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioRevisionMeta);
    }
    if (data.containsKey('dimension')) {
      context.handle(
        _dimensionMeta,
        dimension.isAcceptableOrUnknown(data['dimension']!, _dimensionMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionMeta);
    }
    if (data.containsKey('dtype')) {
      context.handle(
        _dtypeMeta,
        dtype.isAcceptableOrUnknown(data['dtype']!, _dtypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dtypeMeta);
    }
    if (data.containsKey('normalized')) {
      context.handle(
        _normalizedMeta,
        normalized.isAcceptableOrUnknown(data['normalized']!, _normalizedMeta),
      );
    } else if (isInserting) {
      context.missing(_normalizedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('number_of_segments')) {
      context.handle(
        _numberOfSegmentsMeta,
        numberOfSegments.isAcceptableOrUnknown(
          data['number_of_segments']!,
          _numberOfSegmentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numberOfSegmentsMeta);
    }
    if (data.containsKey('mean_adjacent_distance')) {
      context.handle(
        _meanAdjacentDistanceMeta,
        meanAdjacentDistance.isAcceptableOrUnknown(
          data['mean_adjacent_distance']!,
          _meanAdjacentDistanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meanAdjacentDistanceMeta);
    }
    if (data.containsKey('max_adjacent_distance')) {
      context.handle(
        _maxAdjacentDistanceMeta,
        maxAdjacentDistance.isAcceptableOrUnknown(
          data['max_adjacent_distance']!,
          _maxAdjacentDistanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maxAdjacentDistanceMeta);
    }
    if (data.containsKey('trajectory_variance')) {
      context.handle(
        _trajectoryVarianceMeta,
        trajectoryVariance.isAcceptableOrUnknown(
          data['trajectory_variance']!,
          _trajectoryVarianceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trajectoryVarianceMeta);
    }
    if (data.containsKey('largest_transition_index')) {
      context.handle(
        _largestTransitionIndexMeta,
        largestTransitionIndex.isAcceptableOrUnknown(
          data['largest_transition_index']!,
          _largestTransitionIndexMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {
      trackId,
      representation,
      modelId,
      modelVersion,
      preprocessingVersion,
      provider,
      audioRevision,
    },
  ];
  @override
  TrackTemporalEmbeddingTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackTemporalEmbeddingTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      representation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}representation'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      preprocessingVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preprocessing_version'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      audioRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_revision'],
      )!,
      dimension: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dimension'],
      )!,
      dtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dtype'],
      )!,
      normalized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}normalized'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      numberOfSegments: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_of_segments'],
      )!,
      meanAdjacentDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mean_adjacent_distance'],
      )!,
      maxAdjacentDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_adjacent_distance'],
      )!,
      trajectoryVariance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trajectory_variance'],
      )!,
      largestTransitionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}largest_transition_index'],
      ),
    );
  }

  @override
  $TrackTemporalEmbeddingTableTable createAlias(String alias) {
    return $TrackTemporalEmbeddingTableTable(attachedDatabase, alias);
  }
}

class TrackTemporalEmbeddingTableData extends DataClass
    implements Insertable<TrackTemporalEmbeddingTableData> {
  final String id;
  final String trackId;
  final String representation;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
  final String provider;
  final int audioRevision;
  final int dimension;
  final String dtype;
  final bool normalized;
  final DateTime createdAt;
  final int numberOfSegments;
  final double meanAdjacentDistance;
  final double maxAdjacentDistance;
  final double trajectoryVariance;
  final int? largestTransitionIndex;
  const TrackTemporalEmbeddingTableData({
    required this.id,
    required this.trackId,
    required this.representation,
    required this.modelId,
    required this.modelVersion,
    required this.preprocessingVersion,
    required this.provider,
    required this.audioRevision,
    required this.dimension,
    required this.dtype,
    required this.normalized,
    required this.createdAt,
    required this.numberOfSegments,
    required this.meanAdjacentDistance,
    required this.maxAdjacentDistance,
    required this.trajectoryVariance,
    this.largestTransitionIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['representation'] = Variable<String>(representation);
    map['model_id'] = Variable<String>(modelId);
    map['model_version'] = Variable<String>(modelVersion);
    map['preprocessing_version'] = Variable<String>(preprocessingVersion);
    map['provider'] = Variable<String>(provider);
    map['audio_revision'] = Variable<int>(audioRevision);
    map['dimension'] = Variable<int>(dimension);
    map['dtype'] = Variable<String>(dtype);
    map['normalized'] = Variable<bool>(normalized);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['number_of_segments'] = Variable<int>(numberOfSegments);
    map['mean_adjacent_distance'] = Variable<double>(meanAdjacentDistance);
    map['max_adjacent_distance'] = Variable<double>(maxAdjacentDistance);
    map['trajectory_variance'] = Variable<double>(trajectoryVariance);
    if (!nullToAbsent || largestTransitionIndex != null) {
      map['largest_transition_index'] = Variable<int>(largestTransitionIndex);
    }
    return map;
  }

  TrackTemporalEmbeddingTableCompanion toCompanion(bool nullToAbsent) {
    return TrackTemporalEmbeddingTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      representation: Value(representation),
      modelId: Value(modelId),
      modelVersion: Value(modelVersion),
      preprocessingVersion: Value(preprocessingVersion),
      provider: Value(provider),
      audioRevision: Value(audioRevision),
      dimension: Value(dimension),
      dtype: Value(dtype),
      normalized: Value(normalized),
      createdAt: Value(createdAt),
      numberOfSegments: Value(numberOfSegments),
      meanAdjacentDistance: Value(meanAdjacentDistance),
      maxAdjacentDistance: Value(maxAdjacentDistance),
      trajectoryVariance: Value(trajectoryVariance),
      largestTransitionIndex: largestTransitionIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(largestTransitionIndex),
    );
  }

  factory TrackTemporalEmbeddingTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackTemporalEmbeddingTableData(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      representation: serializer.fromJson<String>(json['representation']),
      modelId: serializer.fromJson<String>(json['modelId']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      preprocessingVersion: serializer.fromJson<String>(
        json['preprocessingVersion'],
      ),
      provider: serializer.fromJson<String>(json['provider']),
      audioRevision: serializer.fromJson<int>(json['audioRevision']),
      dimension: serializer.fromJson<int>(json['dimension']),
      dtype: serializer.fromJson<String>(json['dtype']),
      normalized: serializer.fromJson<bool>(json['normalized']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      numberOfSegments: serializer.fromJson<int>(json['numberOfSegments']),
      meanAdjacentDistance: serializer.fromJson<double>(
        json['meanAdjacentDistance'],
      ),
      maxAdjacentDistance: serializer.fromJson<double>(
        json['maxAdjacentDistance'],
      ),
      trajectoryVariance: serializer.fromJson<double>(
        json['trajectoryVariance'],
      ),
      largestTransitionIndex: serializer.fromJson<int?>(
        json['largestTransitionIndex'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String>(trackId),
      'representation': serializer.toJson<String>(representation),
      'modelId': serializer.toJson<String>(modelId),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'preprocessingVersion': serializer.toJson<String>(preprocessingVersion),
      'provider': serializer.toJson<String>(provider),
      'audioRevision': serializer.toJson<int>(audioRevision),
      'dimension': serializer.toJson<int>(dimension),
      'dtype': serializer.toJson<String>(dtype),
      'normalized': serializer.toJson<bool>(normalized),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'numberOfSegments': serializer.toJson<int>(numberOfSegments),
      'meanAdjacentDistance': serializer.toJson<double>(meanAdjacentDistance),
      'maxAdjacentDistance': serializer.toJson<double>(maxAdjacentDistance),
      'trajectoryVariance': serializer.toJson<double>(trajectoryVariance),
      'largestTransitionIndex': serializer.toJson<int?>(largestTransitionIndex),
    };
  }

  TrackTemporalEmbeddingTableData copyWith({
    String? id,
    String? trackId,
    String? representation,
    String? modelId,
    String? modelVersion,
    String? preprocessingVersion,
    String? provider,
    int? audioRevision,
    int? dimension,
    String? dtype,
    bool? normalized,
    DateTime? createdAt,
    int? numberOfSegments,
    double? meanAdjacentDistance,
    double? maxAdjacentDistance,
    double? trajectoryVariance,
    Value<int?> largestTransitionIndex = const Value.absent(),
  }) => TrackTemporalEmbeddingTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    representation: representation ?? this.representation,
    modelId: modelId ?? this.modelId,
    modelVersion: modelVersion ?? this.modelVersion,
    preprocessingVersion: preprocessingVersion ?? this.preprocessingVersion,
    provider: provider ?? this.provider,
    audioRevision: audioRevision ?? this.audioRevision,
    dimension: dimension ?? this.dimension,
    dtype: dtype ?? this.dtype,
    normalized: normalized ?? this.normalized,
    createdAt: createdAt ?? this.createdAt,
    numberOfSegments: numberOfSegments ?? this.numberOfSegments,
    meanAdjacentDistance: meanAdjacentDistance ?? this.meanAdjacentDistance,
    maxAdjacentDistance: maxAdjacentDistance ?? this.maxAdjacentDistance,
    trajectoryVariance: trajectoryVariance ?? this.trajectoryVariance,
    largestTransitionIndex: largestTransitionIndex.present
        ? largestTransitionIndex.value
        : this.largestTransitionIndex,
  );
  TrackTemporalEmbeddingTableData copyWithCompanion(
    TrackTemporalEmbeddingTableCompanion data,
  ) {
    return TrackTemporalEmbeddingTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      representation: data.representation.present
          ? data.representation.value
          : this.representation,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      preprocessingVersion: data.preprocessingVersion.present
          ? data.preprocessingVersion.value
          : this.preprocessingVersion,
      provider: data.provider.present ? data.provider.value : this.provider,
      audioRevision: data.audioRevision.present
          ? data.audioRevision.value
          : this.audioRevision,
      dimension: data.dimension.present ? data.dimension.value : this.dimension,
      dtype: data.dtype.present ? data.dtype.value : this.dtype,
      normalized: data.normalized.present
          ? data.normalized.value
          : this.normalized,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      numberOfSegments: data.numberOfSegments.present
          ? data.numberOfSegments.value
          : this.numberOfSegments,
      meanAdjacentDistance: data.meanAdjacentDistance.present
          ? data.meanAdjacentDistance.value
          : this.meanAdjacentDistance,
      maxAdjacentDistance: data.maxAdjacentDistance.present
          ? data.maxAdjacentDistance.value
          : this.maxAdjacentDistance,
      trajectoryVariance: data.trajectoryVariance.present
          ? data.trajectoryVariance.value
          : this.trajectoryVariance,
      largestTransitionIndex: data.largestTransitionIndex.present
          ? data.largestTransitionIndex.value
          : this.largestTransitionIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackTemporalEmbeddingTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('representation: $representation, ')
          ..write('modelId: $modelId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('preprocessingVersion: $preprocessingVersion, ')
          ..write('provider: $provider, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('dimension: $dimension, ')
          ..write('dtype: $dtype, ')
          ..write('normalized: $normalized, ')
          ..write('createdAt: $createdAt, ')
          ..write('numberOfSegments: $numberOfSegments, ')
          ..write('meanAdjacentDistance: $meanAdjacentDistance, ')
          ..write('maxAdjacentDistance: $maxAdjacentDistance, ')
          ..write('trajectoryVariance: $trajectoryVariance, ')
          ..write('largestTransitionIndex: $largestTransitionIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    representation,
    modelId,
    modelVersion,
    preprocessingVersion,
    provider,
    audioRevision,
    dimension,
    dtype,
    normalized,
    createdAt,
    numberOfSegments,
    meanAdjacentDistance,
    maxAdjacentDistance,
    trajectoryVariance,
    largestTransitionIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackTemporalEmbeddingTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.representation == this.representation &&
          other.modelId == this.modelId &&
          other.modelVersion == this.modelVersion &&
          other.preprocessingVersion == this.preprocessingVersion &&
          other.provider == this.provider &&
          other.audioRevision == this.audioRevision &&
          other.dimension == this.dimension &&
          other.dtype == this.dtype &&
          other.normalized == this.normalized &&
          other.createdAt == this.createdAt &&
          other.numberOfSegments == this.numberOfSegments &&
          other.meanAdjacentDistance == this.meanAdjacentDistance &&
          other.maxAdjacentDistance == this.maxAdjacentDistance &&
          other.trajectoryVariance == this.trajectoryVariance &&
          other.largestTransitionIndex == this.largestTransitionIndex);
}

class TrackTemporalEmbeddingTableCompanion
    extends UpdateCompanion<TrackTemporalEmbeddingTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> representation;
  final Value<String> modelId;
  final Value<String> modelVersion;
  final Value<String> preprocessingVersion;
  final Value<String> provider;
  final Value<int> audioRevision;
  final Value<int> dimension;
  final Value<String> dtype;
  final Value<bool> normalized;
  final Value<DateTime> createdAt;
  final Value<int> numberOfSegments;
  final Value<double> meanAdjacentDistance;
  final Value<double> maxAdjacentDistance;
  final Value<double> trajectoryVariance;
  final Value<int?> largestTransitionIndex;
  final Value<int> rowid;
  const TrackTemporalEmbeddingTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.representation = const Value.absent(),
    this.modelId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.preprocessingVersion = const Value.absent(),
    this.provider = const Value.absent(),
    this.audioRevision = const Value.absent(),
    this.dimension = const Value.absent(),
    this.dtype = const Value.absent(),
    this.normalized = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.numberOfSegments = const Value.absent(),
    this.meanAdjacentDistance = const Value.absent(),
    this.maxAdjacentDistance = const Value.absent(),
    this.trajectoryVariance = const Value.absent(),
    this.largestTransitionIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackTemporalEmbeddingTableCompanion.insert({
    required String id,
    required String trackId,
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required String provider,
    required int audioRevision,
    required int dimension,
    required String dtype,
    required bool normalized,
    required DateTime createdAt,
    required int numberOfSegments,
    required double meanAdjacentDistance,
    required double maxAdjacentDistance,
    required double trajectoryVariance,
    this.largestTransitionIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       representation = Value(representation),
       modelId = Value(modelId),
       modelVersion = Value(modelVersion),
       preprocessingVersion = Value(preprocessingVersion),
       provider = Value(provider),
       audioRevision = Value(audioRevision),
       dimension = Value(dimension),
       dtype = Value(dtype),
       normalized = Value(normalized),
       createdAt = Value(createdAt),
       numberOfSegments = Value(numberOfSegments),
       meanAdjacentDistance = Value(meanAdjacentDistance),
       maxAdjacentDistance = Value(maxAdjacentDistance),
       trajectoryVariance = Value(trajectoryVariance);
  static Insertable<TrackTemporalEmbeddingTableData> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? representation,
    Expression<String>? modelId,
    Expression<String>? modelVersion,
    Expression<String>? preprocessingVersion,
    Expression<String>? provider,
    Expression<int>? audioRevision,
    Expression<int>? dimension,
    Expression<String>? dtype,
    Expression<bool>? normalized,
    Expression<DateTime>? createdAt,
    Expression<int>? numberOfSegments,
    Expression<double>? meanAdjacentDistance,
    Expression<double>? maxAdjacentDistance,
    Expression<double>? trajectoryVariance,
    Expression<int>? largestTransitionIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (representation != null) 'representation': representation,
      if (modelId != null) 'model_id': modelId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (preprocessingVersion != null)
        'preprocessing_version': preprocessingVersion,
      if (provider != null) 'provider': provider,
      if (audioRevision != null) 'audio_revision': audioRevision,
      if (dimension != null) 'dimension': dimension,
      if (dtype != null) 'dtype': dtype,
      if (normalized != null) 'normalized': normalized,
      if (createdAt != null) 'created_at': createdAt,
      if (numberOfSegments != null) 'number_of_segments': numberOfSegments,
      if (meanAdjacentDistance != null)
        'mean_adjacent_distance': meanAdjacentDistance,
      if (maxAdjacentDistance != null)
        'max_adjacent_distance': maxAdjacentDistance,
      if (trajectoryVariance != null) 'trajectory_variance': trajectoryVariance,
      if (largestTransitionIndex != null)
        'largest_transition_index': largestTransitionIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackTemporalEmbeddingTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? representation,
    Value<String>? modelId,
    Value<String>? modelVersion,
    Value<String>? preprocessingVersion,
    Value<String>? provider,
    Value<int>? audioRevision,
    Value<int>? dimension,
    Value<String>? dtype,
    Value<bool>? normalized,
    Value<DateTime>? createdAt,
    Value<int>? numberOfSegments,
    Value<double>? meanAdjacentDistance,
    Value<double>? maxAdjacentDistance,
    Value<double>? trajectoryVariance,
    Value<int?>? largestTransitionIndex,
    Value<int>? rowid,
  }) {
    return TrackTemporalEmbeddingTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      representation: representation ?? this.representation,
      modelId: modelId ?? this.modelId,
      modelVersion: modelVersion ?? this.modelVersion,
      preprocessingVersion: preprocessingVersion ?? this.preprocessingVersion,
      provider: provider ?? this.provider,
      audioRevision: audioRevision ?? this.audioRevision,
      dimension: dimension ?? this.dimension,
      dtype: dtype ?? this.dtype,
      normalized: normalized ?? this.normalized,
      createdAt: createdAt ?? this.createdAt,
      numberOfSegments: numberOfSegments ?? this.numberOfSegments,
      meanAdjacentDistance: meanAdjacentDistance ?? this.meanAdjacentDistance,
      maxAdjacentDistance: maxAdjacentDistance ?? this.maxAdjacentDistance,
      trajectoryVariance: trajectoryVariance ?? this.trajectoryVariance,
      largestTransitionIndex:
          largestTransitionIndex ?? this.largestTransitionIndex,
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
    if (representation.present) {
      map['representation'] = Variable<String>(representation.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (preprocessingVersion.present) {
      map['preprocessing_version'] = Variable<String>(
        preprocessingVersion.value,
      );
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (audioRevision.present) {
      map['audio_revision'] = Variable<int>(audioRevision.value);
    }
    if (dimension.present) {
      map['dimension'] = Variable<int>(dimension.value);
    }
    if (dtype.present) {
      map['dtype'] = Variable<String>(dtype.value);
    }
    if (normalized.present) {
      map['normalized'] = Variable<bool>(normalized.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (numberOfSegments.present) {
      map['number_of_segments'] = Variable<int>(numberOfSegments.value);
    }
    if (meanAdjacentDistance.present) {
      map['mean_adjacent_distance'] = Variable<double>(
        meanAdjacentDistance.value,
      );
    }
    if (maxAdjacentDistance.present) {
      map['max_adjacent_distance'] = Variable<double>(
        maxAdjacentDistance.value,
      );
    }
    if (trajectoryVariance.present) {
      map['trajectory_variance'] = Variable<double>(trajectoryVariance.value);
    }
    if (largestTransitionIndex.present) {
      map['largest_transition_index'] = Variable<int>(
        largestTransitionIndex.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackTemporalEmbeddingTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('representation: $representation, ')
          ..write('modelId: $modelId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('preprocessingVersion: $preprocessingVersion, ')
          ..write('provider: $provider, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('dimension: $dimension, ')
          ..write('dtype: $dtype, ')
          ..write('normalized: $normalized, ')
          ..write('createdAt: $createdAt, ')
          ..write('numberOfSegments: $numberOfSegments, ')
          ..write('meanAdjacentDistance: $meanAdjacentDistance, ')
          ..write('maxAdjacentDistance: $maxAdjacentDistance, ')
          ..write('trajectoryVariance: $trajectoryVariance, ')
          ..write('largestTransitionIndex: $largestTransitionIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackTemporalEmbeddingSegmentTableTable
    extends TrackTemporalEmbeddingSegmentTable
    with
        TableInfo<
          $TrackTemporalEmbeddingSegmentTableTable,
          TrackTemporalEmbeddingSegmentTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackTemporalEmbeddingSegmentTableTable(
    this.attachedDatabase, [
    this._alias,
  ]);
  static const VerificationMeta _temporalEmbeddingIdMeta =
      const VerificationMeta('temporalEmbeddingId');
  @override
  late final GeneratedColumn<String> temporalEmbeddingId =
      GeneratedColumn<String>(
        'temporal_embedding_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES track_temporal_embedding_table (id) ON DELETE CASCADE',
        ),
      );
  static const VerificationMeta _segmentIndexMeta = const VerificationMeta(
    'segmentIndex',
  );
  @override
  late final GeneratedColumn<int> segmentIndex = GeneratedColumn<int>(
    'segment_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionsMeta = const VerificationMeta(
    'dimensions',
  );
  @override
  late final GeneratedColumn<int> dimensions = GeneratedColumn<int>(
    'dimensions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    temporalEmbeddingId,
    segmentIndex,
    startMs,
    endMs,
    dimensions,
    vector,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_temporal_embedding_segment_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackTemporalEmbeddingSegmentTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('temporal_embedding_id')) {
      context.handle(
        _temporalEmbeddingIdMeta,
        temporalEmbeddingId.isAcceptableOrUnknown(
          data['temporal_embedding_id']!,
          _temporalEmbeddingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temporalEmbeddingIdMeta);
    }
    if (data.containsKey('segment_index')) {
      context.handle(
        _segmentIndexMeta,
        segmentIndex.isAcceptableOrUnknown(
          data['segment_index']!,
          _segmentIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentIndexMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('dimensions')) {
      context.handle(
        _dimensionsMeta,
        dimensions.isAcceptableOrUnknown(data['dimensions']!, _dimensionsMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionsMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {temporalEmbeddingId, segmentIndex};
  @override
  TrackTemporalEmbeddingSegmentTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackTemporalEmbeddingSegmentTableData(
      temporalEmbeddingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temporal_embedding_id'],
      )!,
      segmentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_index'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      dimensions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dimensions'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
    );
  }

  @override
  $TrackTemporalEmbeddingSegmentTableTable createAlias(String alias) {
    return $TrackTemporalEmbeddingSegmentTableTable(attachedDatabase, alias);
  }
}

class TrackTemporalEmbeddingSegmentTableData extends DataClass
    implements Insertable<TrackTemporalEmbeddingSegmentTableData> {
  final String temporalEmbeddingId;
  final int segmentIndex;
  final int startMs;
  final int endMs;
  final int dimensions;
  final Uint8List vector;
  const TrackTemporalEmbeddingSegmentTableData({
    required this.temporalEmbeddingId,
    required this.segmentIndex,
    required this.startMs,
    required this.endMs,
    required this.dimensions,
    required this.vector,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['temporal_embedding_id'] = Variable<String>(temporalEmbeddingId);
    map['segment_index'] = Variable<int>(segmentIndex);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['dimensions'] = Variable<int>(dimensions);
    map['vector'] = Variable<Uint8List>(vector);
    return map;
  }

  TrackTemporalEmbeddingSegmentTableCompanion toCompanion(bool nullToAbsent) {
    return TrackTemporalEmbeddingSegmentTableCompanion(
      temporalEmbeddingId: Value(temporalEmbeddingId),
      segmentIndex: Value(segmentIndex),
      startMs: Value(startMs),
      endMs: Value(endMs),
      dimensions: Value(dimensions),
      vector: Value(vector),
    );
  }

  factory TrackTemporalEmbeddingSegmentTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackTemporalEmbeddingSegmentTableData(
      temporalEmbeddingId: serializer.fromJson<String>(
        json['temporalEmbeddingId'],
      ),
      segmentIndex: serializer.fromJson<int>(json['segmentIndex']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      dimensions: serializer.fromJson<int>(json['dimensions']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'temporalEmbeddingId': serializer.toJson<String>(temporalEmbeddingId),
      'segmentIndex': serializer.toJson<int>(segmentIndex),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'dimensions': serializer.toJson<int>(dimensions),
      'vector': serializer.toJson<Uint8List>(vector),
    };
  }

  TrackTemporalEmbeddingSegmentTableData copyWith({
    String? temporalEmbeddingId,
    int? segmentIndex,
    int? startMs,
    int? endMs,
    int? dimensions,
    Uint8List? vector,
  }) => TrackTemporalEmbeddingSegmentTableData(
    temporalEmbeddingId: temporalEmbeddingId ?? this.temporalEmbeddingId,
    segmentIndex: segmentIndex ?? this.segmentIndex,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    dimensions: dimensions ?? this.dimensions,
    vector: vector ?? this.vector,
  );
  TrackTemporalEmbeddingSegmentTableData copyWithCompanion(
    TrackTemporalEmbeddingSegmentTableCompanion data,
  ) {
    return TrackTemporalEmbeddingSegmentTableData(
      temporalEmbeddingId: data.temporalEmbeddingId.present
          ? data.temporalEmbeddingId.value
          : this.temporalEmbeddingId,
      segmentIndex: data.segmentIndex.present
          ? data.segmentIndex.value
          : this.segmentIndex,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      dimensions: data.dimensions.present
          ? data.dimensions.value
          : this.dimensions,
      vector: data.vector.present ? data.vector.value : this.vector,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackTemporalEmbeddingSegmentTableData(')
          ..write('temporalEmbeddingId: $temporalEmbeddingId, ')
          ..write('segmentIndex: $segmentIndex, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('dimensions: $dimensions, ')
          ..write('vector: $vector')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    temporalEmbeddingId,
    segmentIndex,
    startMs,
    endMs,
    dimensions,
    $driftBlobEquality.hash(vector),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackTemporalEmbeddingSegmentTableData &&
          other.temporalEmbeddingId == this.temporalEmbeddingId &&
          other.segmentIndex == this.segmentIndex &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.dimensions == this.dimensions &&
          $driftBlobEquality.equals(other.vector, this.vector));
}

class TrackTemporalEmbeddingSegmentTableCompanion
    extends UpdateCompanion<TrackTemporalEmbeddingSegmentTableData> {
  final Value<String> temporalEmbeddingId;
  final Value<int> segmentIndex;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<int> dimensions;
  final Value<Uint8List> vector;
  final Value<int> rowid;
  const TrackTemporalEmbeddingSegmentTableCompanion({
    this.temporalEmbeddingId = const Value.absent(),
    this.segmentIndex = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.dimensions = const Value.absent(),
    this.vector = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackTemporalEmbeddingSegmentTableCompanion.insert({
    required String temporalEmbeddingId,
    required int segmentIndex,
    required int startMs,
    required int endMs,
    required int dimensions,
    required Uint8List vector,
    this.rowid = const Value.absent(),
  }) : temporalEmbeddingId = Value(temporalEmbeddingId),
       segmentIndex = Value(segmentIndex),
       startMs = Value(startMs),
       endMs = Value(endMs),
       dimensions = Value(dimensions),
       vector = Value(vector);
  static Insertable<TrackTemporalEmbeddingSegmentTableData> custom({
    Expression<String>? temporalEmbeddingId,
    Expression<int>? segmentIndex,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<int>? dimensions,
    Expression<Uint8List>? vector,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (temporalEmbeddingId != null)
        'temporal_embedding_id': temporalEmbeddingId,
      if (segmentIndex != null) 'segment_index': segmentIndex,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (dimensions != null) 'dimensions': dimensions,
      if (vector != null) 'vector': vector,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackTemporalEmbeddingSegmentTableCompanion copyWith({
    Value<String>? temporalEmbeddingId,
    Value<int>? segmentIndex,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<int>? dimensions,
    Value<Uint8List>? vector,
    Value<int>? rowid,
  }) {
    return TrackTemporalEmbeddingSegmentTableCompanion(
      temporalEmbeddingId: temporalEmbeddingId ?? this.temporalEmbeddingId,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      dimensions: dimensions ?? this.dimensions,
      vector: vector ?? this.vector,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (temporalEmbeddingId.present) {
      map['temporal_embedding_id'] = Variable<String>(
        temporalEmbeddingId.value,
      );
    }
    if (segmentIndex.present) {
      map['segment_index'] = Variable<int>(segmentIndex.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (dimensions.present) {
      map['dimensions'] = Variable<int>(dimensions.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackTemporalEmbeddingSegmentTableCompanion(')
          ..write('temporalEmbeddingId: $temporalEmbeddingId, ')
          ..write('segmentIndex: $segmentIndex, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('dimensions: $dimensions, ')
          ..write('vector: $vector, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MusicAnalysisTaskTableTable extends MusicAnalysisTaskTable
    with TableInfo<$MusicAnalysisTaskTableTable, MusicAnalysisTaskTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MusicAnalysisTaskTableTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _requestedRepresentationsMeta =
      const VerificationMeta('requestedRepresentations');
  @override
  late final GeneratedColumn<String> requestedRepresentations =
      GeneratedColumn<String>(
        'requested_representations',
        aliasedName,
        false,
        type: DriftSqlType.string,
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
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requestedRepresentations,
    audioRevision,
    status,
    attemptCount,
    lastErrorCode,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'music_analysis_task_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MusicAnalysisTaskTableData> instance, {
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
    if (data.containsKey('requested_representations')) {
      context.handle(
        _requestedRepresentationsMeta,
        requestedRepresentations.isAcceptableOrUnknown(
          data['requested_representations']!,
          _requestedRepresentationsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedRepresentationsMeta);
    }
    if (data.containsKey('audio_revision')) {
      context.handle(
        _audioRevisionMeta,
        audioRevision.isAcceptableOrUnknown(
          data['audio_revision']!,
          _audioRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioRevisionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  MusicAnalysisTaskTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MusicAnalysisTaskTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      requestedRepresentations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_representations'],
      )!,
      audioRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_revision'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MusicAnalysisTaskTableTable createAlias(String alias) {
    return $MusicAnalysisTaskTableTable(attachedDatabase, alias);
  }
}

class MusicAnalysisTaskTableData extends DataClass
    implements Insertable<MusicAnalysisTaskTableData> {
  final String id;
  final String trackId;
  final String requestedRepresentations;
  final int audioRevision;
  final String status;
  final int attemptCount;
  final String? lastErrorCode;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MusicAnalysisTaskTableData({
    required this.id,
    required this.trackId,
    required this.requestedRepresentations,
    required this.audioRevision,
    required this.status,
    required this.attemptCount,
    this.lastErrorCode,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['requested_representations'] = Variable<String>(
      requestedRepresentations,
    );
    map['audio_revision'] = Variable<int>(audioRevision);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MusicAnalysisTaskTableCompanion toCompanion(bool nullToAbsent) {
    return MusicAnalysisTaskTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      requestedRepresentations: Value(requestedRepresentations),
      audioRevision: Value(audioRevision),
      status: Value(status),
      attemptCount: Value(attemptCount),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MusicAnalysisTaskTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MusicAnalysisTaskTableData(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      requestedRepresentations: serializer.fromJson<String>(
        json['requestedRepresentations'],
      ),
      audioRevision: serializer.fromJson<int>(json['audioRevision']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String>(trackId),
      'requestedRepresentations': serializer.toJson<String>(
        requestedRepresentations,
      ),
      'audioRevision': serializer.toJson<int>(audioRevision),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MusicAnalysisTaskTableData copyWith({
    String? id,
    String? trackId,
    String? requestedRepresentations,
    int? audioRevision,
    String? status,
    int? attemptCount,
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MusicAnalysisTaskTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    requestedRepresentations:
        requestedRepresentations ?? this.requestedRepresentations,
    audioRevision: audioRevision ?? this.audioRevision,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MusicAnalysisTaskTableData copyWithCompanion(
    MusicAnalysisTaskTableCompanion data,
  ) {
    return MusicAnalysisTaskTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      requestedRepresentations: data.requestedRepresentations.present
          ? data.requestedRepresentations.value
          : this.requestedRepresentations,
      audioRevision: data.audioRevision.present
          ? data.audioRevision.value
          : this.audioRevision,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MusicAnalysisTaskTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('requestedRepresentations: $requestedRepresentations, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    requestedRepresentations,
    audioRevision,
    status,
    attemptCount,
    lastErrorCode,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MusicAnalysisTaskTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.requestedRepresentations == this.requestedRepresentations &&
          other.audioRevision == this.audioRevision &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MusicAnalysisTaskTableCompanion
    extends UpdateCompanion<MusicAnalysisTaskTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> requestedRepresentations;
  final Value<int> audioRevision;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<String?> lastErrorCode;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MusicAnalysisTaskTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.requestedRepresentations = const Value.absent(),
    this.audioRevision = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MusicAnalysisTaskTableCompanion.insert({
    required String id,
    required String trackId,
    required String requestedRepresentations,
    required int audioRevision,
    required String status,
    this.attemptCount = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       requestedRepresentations = Value(requestedRepresentations),
       audioRevision = Value(audioRevision),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MusicAnalysisTaskTableData> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? requestedRepresentations,
    Expression<int>? audioRevision,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<String>? lastErrorCode,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (requestedRepresentations != null)
        'requested_representations': requestedRepresentations,
      if (audioRevision != null) 'audio_revision': audioRevision,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MusicAnalysisTaskTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? requestedRepresentations,
    Value<int>? audioRevision,
    Value<String>? status,
    Value<int>? attemptCount,
    Value<String?>? lastErrorCode,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MusicAnalysisTaskTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      requestedRepresentations:
          requestedRepresentations ?? this.requestedRepresentations,
      audioRevision: audioRevision ?? this.audioRevision,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
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
    if (requestedRepresentations.present) {
      map['requested_representations'] = Variable<String>(
        requestedRepresentations.value,
      );
    }
    if (audioRevision.present) {
      map['audio_revision'] = Variable<int>(audioRevision.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('MusicAnalysisTaskTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('requestedRepresentations: $requestedRepresentations, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MusicAnalysisSettingsTableTable extends MusicAnalysisSettingsTable
    with
        TableInfo<
          $MusicAnalysisSettingsTableTable,
          MusicAnalysisSettingsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MusicAnalysisSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverEnabledMeta = const VerificationMeta(
    'serverEnabled',
  );
  @override
  late final GeneratedColumn<bool> serverEnabled = GeneratedColumn<bool>(
    'server_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("server_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [id, serverEnabled, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'music_analysis_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MusicAnalysisSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_enabled')) {
      context.handle(
        _serverEnabledMeta,
        serverEnabled.isAcceptableOrUnknown(
          data['server_enabled']!,
          _serverEnabledMeta,
        ),
      );
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
  MusicAnalysisSettingsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MusicAnalysisSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}server_enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MusicAnalysisSettingsTableTable createAlias(String alias) {
    return $MusicAnalysisSettingsTableTable(attachedDatabase, alias);
  }
}

class MusicAnalysisSettingsTableData extends DataClass
    implements Insertable<MusicAnalysisSettingsTableData> {
  final int id;
  final bool serverEnabled;
  final DateTime updatedAt;
  const MusicAnalysisSettingsTableData({
    required this.id,
    required this.serverEnabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_enabled'] = Variable<bool>(serverEnabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MusicAnalysisSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return MusicAnalysisSettingsTableCompanion(
      id: Value(id),
      serverEnabled: Value(serverEnabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory MusicAnalysisSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MusicAnalysisSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      serverEnabled: serializer.fromJson<bool>(json['serverEnabled']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverEnabled': serializer.toJson<bool>(serverEnabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MusicAnalysisSettingsTableData copyWith({
    int? id,
    bool? serverEnabled,
    DateTime? updatedAt,
  }) => MusicAnalysisSettingsTableData(
    id: id ?? this.id,
    serverEnabled: serverEnabled ?? this.serverEnabled,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MusicAnalysisSettingsTableData copyWithCompanion(
    MusicAnalysisSettingsTableCompanion data,
  ) {
    return MusicAnalysisSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      serverEnabled: data.serverEnabled.present
          ? data.serverEnabled.value
          : this.serverEnabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MusicAnalysisSettingsTableData(')
          ..write('id: $id, ')
          ..write('serverEnabled: $serverEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverEnabled, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MusicAnalysisSettingsTableData &&
          other.id == this.id &&
          other.serverEnabled == this.serverEnabled &&
          other.updatedAt == this.updatedAt);
}

class MusicAnalysisSettingsTableCompanion
    extends UpdateCompanion<MusicAnalysisSettingsTableData> {
  final Value<int> id;
  final Value<bool> serverEnabled;
  final Value<DateTime> updatedAt;
  const MusicAnalysisSettingsTableCompanion({
    this.id = const Value.absent(),
    this.serverEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MusicAnalysisSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.serverEnabled = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<MusicAnalysisSettingsTableData> custom({
    Expression<int>? id,
    Expression<bool>? serverEnabled,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverEnabled != null) 'server_enabled': serverEnabled,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MusicAnalysisSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<bool>? serverEnabled,
    Value<DateTime>? updatedAt,
  }) {
    return MusicAnalysisSettingsTableCompanion(
      id: id ?? this.id,
      serverEnabled: serverEnabled ?? this.serverEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverEnabled.present) {
      map['server_enabled'] = Variable<bool>(serverEnabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MusicAnalysisSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('serverEnabled: $serverEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SimilarityEvaluationTableTable extends SimilarityEvaluationTable
    with
        TableInfo<
          $SimilarityEvaluationTableTable,
          SimilarityEvaluationTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimilarityEvaluationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedTrackIdMeta = const VerificationMeta(
    'seedTrackId',
  );
  @override
  late final GeneratedColumn<String> seedTrackId = GeneratedColumn<String>(
    'seed_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _candidateTrackIdMeta = const VerificationMeta(
    'candidateTrackId',
  );
  @override
  late final GeneratedColumn<String> candidateTrackId = GeneratedColumn<String>(
    'candidate_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _methodVersionMeta = const VerificationMeta(
    'methodVersion',
  );
  @override
  late final GeneratedColumn<String> methodVersion = GeneratedColumn<String>(
    'method_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRepresentationModelIdMeta =
      const VerificationMeta('sourceRepresentationModelId');
  @override
  late final GeneratedColumn<String> sourceRepresentationModelId =
      GeneratedColumn<String>(
        'source_representation_model_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceRepresentationModelVersionMeta =
      const VerificationMeta('sourceRepresentationModelVersion');
  @override
  late final GeneratedColumn<String> sourceRepresentationModelVersion =
      GeneratedColumn<String>(
        'source_representation_model_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourcePreprocessingVersionMeta =
      const VerificationMeta('sourcePreprocessingVersion');
  @override
  late final GeneratedColumn<String> sourcePreprocessingVersion =
      GeneratedColumn<String>(
        'source_preprocessing_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _scoreShownMeta = const VerificationMeta(
    'scoreShown',
  );
  @override
  late final GeneratedColumn<double> scoreShown = GeneratedColumn<double>(
    'score_shown',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawDistanceMeta = const VerificationMeta(
    'rawDistance',
  );
  @override
  late final GeneratedColumn<double> rawDistance = GeneratedColumn<double>(
    'raw_distance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soundRatingMeta = const VerificationMeta(
    'soundRating',
  );
  @override
  late final GeneratedColumn<int> soundRating = GeneratedColumn<int>(
    'sound_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atmosphereRatingMeta = const VerificationMeta(
    'atmosphereRating',
  );
  @override
  late final GeneratedColumn<int> atmosphereRating = GeneratedColumn<int>(
    'atmosphere_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trajectoryRatingMeta = const VerificationMeta(
    'trajectoryRating',
  );
  @override
  late final GeneratedColumn<int> trajectoryRating = GeneratedColumn<int>(
    'trajectory_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wouldListenNextMeta = const VerificationMeta(
    'wouldListenNext',
  );
  @override
  late final GeneratedColumn<bool> wouldListenNext = GeneratedColumn<bool>(
    'would_listen_next',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("would_listen_next" IN (0, 1))',
    ),
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
    seedTrackId,
    candidateTrackId,
    methodVersion,
    sourceRepresentationModelId,
    sourceRepresentationModelVersion,
    sourcePreprocessingVersion,
    scoreShown,
    rawDistance,
    soundRating,
    atmosphereRating,
    trajectoryRating,
    wouldListenNext,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'similarity_evaluation_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SimilarityEvaluationTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seed_track_id')) {
      context.handle(
        _seedTrackIdMeta,
        seedTrackId.isAcceptableOrUnknown(
          data['seed_track_id']!,
          _seedTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seedTrackIdMeta);
    }
    if (data.containsKey('candidate_track_id')) {
      context.handle(
        _candidateTrackIdMeta,
        candidateTrackId.isAcceptableOrUnknown(
          data['candidate_track_id']!,
          _candidateTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_candidateTrackIdMeta);
    }
    if (data.containsKey('method_version')) {
      context.handle(
        _methodVersionMeta,
        methodVersion.isAcceptableOrUnknown(
          data['method_version']!,
          _methodVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_methodVersionMeta);
    }
    if (data.containsKey('source_representation_model_id')) {
      context.handle(
        _sourceRepresentationModelIdMeta,
        sourceRepresentationModelId.isAcceptableOrUnknown(
          data['source_representation_model_id']!,
          _sourceRepresentationModelIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceRepresentationModelIdMeta);
    }
    if (data.containsKey('source_representation_model_version')) {
      context.handle(
        _sourceRepresentationModelVersionMeta,
        sourceRepresentationModelVersion.isAcceptableOrUnknown(
          data['source_representation_model_version']!,
          _sourceRepresentationModelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceRepresentationModelVersionMeta);
    }
    if (data.containsKey('source_preprocessing_version')) {
      context.handle(
        _sourcePreprocessingVersionMeta,
        sourcePreprocessingVersion.isAcceptableOrUnknown(
          data['source_preprocessing_version']!,
          _sourcePreprocessingVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourcePreprocessingVersionMeta);
    }
    if (data.containsKey('score_shown')) {
      context.handle(
        _scoreShownMeta,
        scoreShown.isAcceptableOrUnknown(data['score_shown']!, _scoreShownMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreShownMeta);
    }
    if (data.containsKey('raw_distance')) {
      context.handle(
        _rawDistanceMeta,
        rawDistance.isAcceptableOrUnknown(
          data['raw_distance']!,
          _rawDistanceMeta,
        ),
      );
    }
    if (data.containsKey('sound_rating')) {
      context.handle(
        _soundRatingMeta,
        soundRating.isAcceptableOrUnknown(
          data['sound_rating']!,
          _soundRatingMeta,
        ),
      );
    }
    if (data.containsKey('atmosphere_rating')) {
      context.handle(
        _atmosphereRatingMeta,
        atmosphereRating.isAcceptableOrUnknown(
          data['atmosphere_rating']!,
          _atmosphereRatingMeta,
        ),
      );
    }
    if (data.containsKey('trajectory_rating')) {
      context.handle(
        _trajectoryRatingMeta,
        trajectoryRating.isAcceptableOrUnknown(
          data['trajectory_rating']!,
          _trajectoryRatingMeta,
        ),
      );
    }
    if (data.containsKey('would_listen_next')) {
      context.handle(
        _wouldListenNextMeta,
        wouldListenNext.isAcceptableOrUnknown(
          data['would_listen_next']!,
          _wouldListenNextMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {
      seedTrackId,
      candidateTrackId,
      methodVersion,
      sourceRepresentationModelId,
      sourceRepresentationModelVersion,
      sourcePreprocessingVersion,
    },
  ];
  @override
  SimilarityEvaluationTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SimilarityEvaluationTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seedTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed_track_id'],
      )!,
      candidateTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_track_id'],
      )!,
      methodVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_version'],
      )!,
      sourceRepresentationModelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_representation_model_id'],
      )!,
      sourceRepresentationModelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_representation_model_version'],
      )!,
      sourcePreprocessingVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_preprocessing_version'],
      )!,
      scoreShown: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score_shown'],
      )!,
      rawDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}raw_distance'],
      ),
      soundRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sound_rating'],
      ),
      atmosphereRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}atmosphere_rating'],
      ),
      trajectoryRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trajectory_rating'],
      ),
      wouldListenNext: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}would_listen_next'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SimilarityEvaluationTableTable createAlias(String alias) {
    return $SimilarityEvaluationTableTable(attachedDatabase, alias);
  }
}

class SimilarityEvaluationTableData extends DataClass
    implements Insertable<SimilarityEvaluationTableData> {
  final String id;
  final String seedTrackId;
  final String candidateTrackId;
  final String methodVersion;
  final String sourceRepresentationModelId;
  final String sourceRepresentationModelVersion;
  final String sourcePreprocessingVersion;
  final double scoreShown;
  final double? rawDistance;
  final int? soundRating;
  final int? atmosphereRating;
  final int? trajectoryRating;
  final bool? wouldListenNext;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SimilarityEvaluationTableData({
    required this.id,
    required this.seedTrackId,
    required this.candidateTrackId,
    required this.methodVersion,
    required this.sourceRepresentationModelId,
    required this.sourceRepresentationModelVersion,
    required this.sourcePreprocessingVersion,
    required this.scoreShown,
    this.rawDistance,
    this.soundRating,
    this.atmosphereRating,
    this.trajectoryRating,
    this.wouldListenNext,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seed_track_id'] = Variable<String>(seedTrackId);
    map['candidate_track_id'] = Variable<String>(candidateTrackId);
    map['method_version'] = Variable<String>(methodVersion);
    map['source_representation_model_id'] = Variable<String>(
      sourceRepresentationModelId,
    );
    map['source_representation_model_version'] = Variable<String>(
      sourceRepresentationModelVersion,
    );
    map['source_preprocessing_version'] = Variable<String>(
      sourcePreprocessingVersion,
    );
    map['score_shown'] = Variable<double>(scoreShown);
    if (!nullToAbsent || rawDistance != null) {
      map['raw_distance'] = Variable<double>(rawDistance);
    }
    if (!nullToAbsent || soundRating != null) {
      map['sound_rating'] = Variable<int>(soundRating);
    }
    if (!nullToAbsent || atmosphereRating != null) {
      map['atmosphere_rating'] = Variable<int>(atmosphereRating);
    }
    if (!nullToAbsent || trajectoryRating != null) {
      map['trajectory_rating'] = Variable<int>(trajectoryRating);
    }
    if (!nullToAbsent || wouldListenNext != null) {
      map['would_listen_next'] = Variable<bool>(wouldListenNext);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SimilarityEvaluationTableCompanion toCompanion(bool nullToAbsent) {
    return SimilarityEvaluationTableCompanion(
      id: Value(id),
      seedTrackId: Value(seedTrackId),
      candidateTrackId: Value(candidateTrackId),
      methodVersion: Value(methodVersion),
      sourceRepresentationModelId: Value(sourceRepresentationModelId),
      sourceRepresentationModelVersion: Value(sourceRepresentationModelVersion),
      sourcePreprocessingVersion: Value(sourcePreprocessingVersion),
      scoreShown: Value(scoreShown),
      rawDistance: rawDistance == null && nullToAbsent
          ? const Value.absent()
          : Value(rawDistance),
      soundRating: soundRating == null && nullToAbsent
          ? const Value.absent()
          : Value(soundRating),
      atmosphereRating: atmosphereRating == null && nullToAbsent
          ? const Value.absent()
          : Value(atmosphereRating),
      trajectoryRating: trajectoryRating == null && nullToAbsent
          ? const Value.absent()
          : Value(trajectoryRating),
      wouldListenNext: wouldListenNext == null && nullToAbsent
          ? const Value.absent()
          : Value(wouldListenNext),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SimilarityEvaluationTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SimilarityEvaluationTableData(
      id: serializer.fromJson<String>(json['id']),
      seedTrackId: serializer.fromJson<String>(json['seedTrackId']),
      candidateTrackId: serializer.fromJson<String>(json['candidateTrackId']),
      methodVersion: serializer.fromJson<String>(json['methodVersion']),
      sourceRepresentationModelId: serializer.fromJson<String>(
        json['sourceRepresentationModelId'],
      ),
      sourceRepresentationModelVersion: serializer.fromJson<String>(
        json['sourceRepresentationModelVersion'],
      ),
      sourcePreprocessingVersion: serializer.fromJson<String>(
        json['sourcePreprocessingVersion'],
      ),
      scoreShown: serializer.fromJson<double>(json['scoreShown']),
      rawDistance: serializer.fromJson<double?>(json['rawDistance']),
      soundRating: serializer.fromJson<int?>(json['soundRating']),
      atmosphereRating: serializer.fromJson<int?>(json['atmosphereRating']),
      trajectoryRating: serializer.fromJson<int?>(json['trajectoryRating']),
      wouldListenNext: serializer.fromJson<bool?>(json['wouldListenNext']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seedTrackId': serializer.toJson<String>(seedTrackId),
      'candidateTrackId': serializer.toJson<String>(candidateTrackId),
      'methodVersion': serializer.toJson<String>(methodVersion),
      'sourceRepresentationModelId': serializer.toJson<String>(
        sourceRepresentationModelId,
      ),
      'sourceRepresentationModelVersion': serializer.toJson<String>(
        sourceRepresentationModelVersion,
      ),
      'sourcePreprocessingVersion': serializer.toJson<String>(
        sourcePreprocessingVersion,
      ),
      'scoreShown': serializer.toJson<double>(scoreShown),
      'rawDistance': serializer.toJson<double?>(rawDistance),
      'soundRating': serializer.toJson<int?>(soundRating),
      'atmosphereRating': serializer.toJson<int?>(atmosphereRating),
      'trajectoryRating': serializer.toJson<int?>(trajectoryRating),
      'wouldListenNext': serializer.toJson<bool?>(wouldListenNext),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SimilarityEvaluationTableData copyWith({
    String? id,
    String? seedTrackId,
    String? candidateTrackId,
    String? methodVersion,
    String? sourceRepresentationModelId,
    String? sourceRepresentationModelVersion,
    String? sourcePreprocessingVersion,
    double? scoreShown,
    Value<double?> rawDistance = const Value.absent(),
    Value<int?> soundRating = const Value.absent(),
    Value<int?> atmosphereRating = const Value.absent(),
    Value<int?> trajectoryRating = const Value.absent(),
    Value<bool?> wouldListenNext = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SimilarityEvaluationTableData(
    id: id ?? this.id,
    seedTrackId: seedTrackId ?? this.seedTrackId,
    candidateTrackId: candidateTrackId ?? this.candidateTrackId,
    methodVersion: methodVersion ?? this.methodVersion,
    sourceRepresentationModelId:
        sourceRepresentationModelId ?? this.sourceRepresentationModelId,
    sourceRepresentationModelVersion:
        sourceRepresentationModelVersion ??
        this.sourceRepresentationModelVersion,
    sourcePreprocessingVersion:
        sourcePreprocessingVersion ?? this.sourcePreprocessingVersion,
    scoreShown: scoreShown ?? this.scoreShown,
    rawDistance: rawDistance.present ? rawDistance.value : this.rawDistance,
    soundRating: soundRating.present ? soundRating.value : this.soundRating,
    atmosphereRating: atmosphereRating.present
        ? atmosphereRating.value
        : this.atmosphereRating,
    trajectoryRating: trajectoryRating.present
        ? trajectoryRating.value
        : this.trajectoryRating,
    wouldListenNext: wouldListenNext.present
        ? wouldListenNext.value
        : this.wouldListenNext,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SimilarityEvaluationTableData copyWithCompanion(
    SimilarityEvaluationTableCompanion data,
  ) {
    return SimilarityEvaluationTableData(
      id: data.id.present ? data.id.value : this.id,
      seedTrackId: data.seedTrackId.present
          ? data.seedTrackId.value
          : this.seedTrackId,
      candidateTrackId: data.candidateTrackId.present
          ? data.candidateTrackId.value
          : this.candidateTrackId,
      methodVersion: data.methodVersion.present
          ? data.methodVersion.value
          : this.methodVersion,
      sourceRepresentationModelId: data.sourceRepresentationModelId.present
          ? data.sourceRepresentationModelId.value
          : this.sourceRepresentationModelId,
      sourceRepresentationModelVersion:
          data.sourceRepresentationModelVersion.present
          ? data.sourceRepresentationModelVersion.value
          : this.sourceRepresentationModelVersion,
      sourcePreprocessingVersion: data.sourcePreprocessingVersion.present
          ? data.sourcePreprocessingVersion.value
          : this.sourcePreprocessingVersion,
      scoreShown: data.scoreShown.present
          ? data.scoreShown.value
          : this.scoreShown,
      rawDistance: data.rawDistance.present
          ? data.rawDistance.value
          : this.rawDistance,
      soundRating: data.soundRating.present
          ? data.soundRating.value
          : this.soundRating,
      atmosphereRating: data.atmosphereRating.present
          ? data.atmosphereRating.value
          : this.atmosphereRating,
      trajectoryRating: data.trajectoryRating.present
          ? data.trajectoryRating.value
          : this.trajectoryRating,
      wouldListenNext: data.wouldListenNext.present
          ? data.wouldListenNext.value
          : this.wouldListenNext,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SimilarityEvaluationTableData(')
          ..write('id: $id, ')
          ..write('seedTrackId: $seedTrackId, ')
          ..write('candidateTrackId: $candidateTrackId, ')
          ..write('methodVersion: $methodVersion, ')
          ..write('sourceRepresentationModelId: $sourceRepresentationModelId, ')
          ..write(
            'sourceRepresentationModelVersion: $sourceRepresentationModelVersion, ',
          )
          ..write('sourcePreprocessingVersion: $sourcePreprocessingVersion, ')
          ..write('scoreShown: $scoreShown, ')
          ..write('rawDistance: $rawDistance, ')
          ..write('soundRating: $soundRating, ')
          ..write('atmosphereRating: $atmosphereRating, ')
          ..write('trajectoryRating: $trajectoryRating, ')
          ..write('wouldListenNext: $wouldListenNext, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seedTrackId,
    candidateTrackId,
    methodVersion,
    sourceRepresentationModelId,
    sourceRepresentationModelVersion,
    sourcePreprocessingVersion,
    scoreShown,
    rawDistance,
    soundRating,
    atmosphereRating,
    trajectoryRating,
    wouldListenNext,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimilarityEvaluationTableData &&
          other.id == this.id &&
          other.seedTrackId == this.seedTrackId &&
          other.candidateTrackId == this.candidateTrackId &&
          other.methodVersion == this.methodVersion &&
          other.sourceRepresentationModelId ==
              this.sourceRepresentationModelId &&
          other.sourceRepresentationModelVersion ==
              this.sourceRepresentationModelVersion &&
          other.sourcePreprocessingVersion == this.sourcePreprocessingVersion &&
          other.scoreShown == this.scoreShown &&
          other.rawDistance == this.rawDistance &&
          other.soundRating == this.soundRating &&
          other.atmosphereRating == this.atmosphereRating &&
          other.trajectoryRating == this.trajectoryRating &&
          other.wouldListenNext == this.wouldListenNext &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SimilarityEvaluationTableCompanion
    extends UpdateCompanion<SimilarityEvaluationTableData> {
  final Value<String> id;
  final Value<String> seedTrackId;
  final Value<String> candidateTrackId;
  final Value<String> methodVersion;
  final Value<String> sourceRepresentationModelId;
  final Value<String> sourceRepresentationModelVersion;
  final Value<String> sourcePreprocessingVersion;
  final Value<double> scoreShown;
  final Value<double?> rawDistance;
  final Value<int?> soundRating;
  final Value<int?> atmosphereRating;
  final Value<int?> trajectoryRating;
  final Value<bool?> wouldListenNext;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SimilarityEvaluationTableCompanion({
    this.id = const Value.absent(),
    this.seedTrackId = const Value.absent(),
    this.candidateTrackId = const Value.absent(),
    this.methodVersion = const Value.absent(),
    this.sourceRepresentationModelId = const Value.absent(),
    this.sourceRepresentationModelVersion = const Value.absent(),
    this.sourcePreprocessingVersion = const Value.absent(),
    this.scoreShown = const Value.absent(),
    this.rawDistance = const Value.absent(),
    this.soundRating = const Value.absent(),
    this.atmosphereRating = const Value.absent(),
    this.trajectoryRating = const Value.absent(),
    this.wouldListenNext = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SimilarityEvaluationTableCompanion.insert({
    required String id,
    required String seedTrackId,
    required String candidateTrackId,
    required String methodVersion,
    required String sourceRepresentationModelId,
    required String sourceRepresentationModelVersion,
    required String sourcePreprocessingVersion,
    required double scoreShown,
    this.rawDistance = const Value.absent(),
    this.soundRating = const Value.absent(),
    this.atmosphereRating = const Value.absent(),
    this.trajectoryRating = const Value.absent(),
    this.wouldListenNext = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seedTrackId = Value(seedTrackId),
       candidateTrackId = Value(candidateTrackId),
       methodVersion = Value(methodVersion),
       sourceRepresentationModelId = Value(sourceRepresentationModelId),
       sourceRepresentationModelVersion = Value(
         sourceRepresentationModelVersion,
       ),
       sourcePreprocessingVersion = Value(sourcePreprocessingVersion),
       scoreShown = Value(scoreShown),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SimilarityEvaluationTableData> custom({
    Expression<String>? id,
    Expression<String>? seedTrackId,
    Expression<String>? candidateTrackId,
    Expression<String>? methodVersion,
    Expression<String>? sourceRepresentationModelId,
    Expression<String>? sourceRepresentationModelVersion,
    Expression<String>? sourcePreprocessingVersion,
    Expression<double>? scoreShown,
    Expression<double>? rawDistance,
    Expression<int>? soundRating,
    Expression<int>? atmosphereRating,
    Expression<int>? trajectoryRating,
    Expression<bool>? wouldListenNext,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seedTrackId != null) 'seed_track_id': seedTrackId,
      if (candidateTrackId != null) 'candidate_track_id': candidateTrackId,
      if (methodVersion != null) 'method_version': methodVersion,
      if (sourceRepresentationModelId != null)
        'source_representation_model_id': sourceRepresentationModelId,
      if (sourceRepresentationModelVersion != null)
        'source_representation_model_version': sourceRepresentationModelVersion,
      if (sourcePreprocessingVersion != null)
        'source_preprocessing_version': sourcePreprocessingVersion,
      if (scoreShown != null) 'score_shown': scoreShown,
      if (rawDistance != null) 'raw_distance': rawDistance,
      if (soundRating != null) 'sound_rating': soundRating,
      if (atmosphereRating != null) 'atmosphere_rating': atmosphereRating,
      if (trajectoryRating != null) 'trajectory_rating': trajectoryRating,
      if (wouldListenNext != null) 'would_listen_next': wouldListenNext,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SimilarityEvaluationTableCompanion copyWith({
    Value<String>? id,
    Value<String>? seedTrackId,
    Value<String>? candidateTrackId,
    Value<String>? methodVersion,
    Value<String>? sourceRepresentationModelId,
    Value<String>? sourceRepresentationModelVersion,
    Value<String>? sourcePreprocessingVersion,
    Value<double>? scoreShown,
    Value<double?>? rawDistance,
    Value<int?>? soundRating,
    Value<int?>? atmosphereRating,
    Value<int?>? trajectoryRating,
    Value<bool?>? wouldListenNext,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SimilarityEvaluationTableCompanion(
      id: id ?? this.id,
      seedTrackId: seedTrackId ?? this.seedTrackId,
      candidateTrackId: candidateTrackId ?? this.candidateTrackId,
      methodVersion: methodVersion ?? this.methodVersion,
      sourceRepresentationModelId:
          sourceRepresentationModelId ?? this.sourceRepresentationModelId,
      sourceRepresentationModelVersion:
          sourceRepresentationModelVersion ??
          this.sourceRepresentationModelVersion,
      sourcePreprocessingVersion:
          sourcePreprocessingVersion ?? this.sourcePreprocessingVersion,
      scoreShown: scoreShown ?? this.scoreShown,
      rawDistance: rawDistance ?? this.rawDistance,
      soundRating: soundRating ?? this.soundRating,
      atmosphereRating: atmosphereRating ?? this.atmosphereRating,
      trajectoryRating: trajectoryRating ?? this.trajectoryRating,
      wouldListenNext: wouldListenNext ?? this.wouldListenNext,
      createdAt: createdAt ?? this.createdAt,
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
    if (seedTrackId.present) {
      map['seed_track_id'] = Variable<String>(seedTrackId.value);
    }
    if (candidateTrackId.present) {
      map['candidate_track_id'] = Variable<String>(candidateTrackId.value);
    }
    if (methodVersion.present) {
      map['method_version'] = Variable<String>(methodVersion.value);
    }
    if (sourceRepresentationModelId.present) {
      map['source_representation_model_id'] = Variable<String>(
        sourceRepresentationModelId.value,
      );
    }
    if (sourceRepresentationModelVersion.present) {
      map['source_representation_model_version'] = Variable<String>(
        sourceRepresentationModelVersion.value,
      );
    }
    if (sourcePreprocessingVersion.present) {
      map['source_preprocessing_version'] = Variable<String>(
        sourcePreprocessingVersion.value,
      );
    }
    if (scoreShown.present) {
      map['score_shown'] = Variable<double>(scoreShown.value);
    }
    if (rawDistance.present) {
      map['raw_distance'] = Variable<double>(rawDistance.value);
    }
    if (soundRating.present) {
      map['sound_rating'] = Variable<int>(soundRating.value);
    }
    if (atmosphereRating.present) {
      map['atmosphere_rating'] = Variable<int>(atmosphereRating.value);
    }
    if (trajectoryRating.present) {
      map['trajectory_rating'] = Variable<int>(trajectoryRating.value);
    }
    if (wouldListenNext.present) {
      map['would_listen_next'] = Variable<bool>(wouldListenNext.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('SimilarityEvaluationTableCompanion(')
          ..write('id: $id, ')
          ..write('seedTrackId: $seedTrackId, ')
          ..write('candidateTrackId: $candidateTrackId, ')
          ..write('methodVersion: $methodVersion, ')
          ..write('sourceRepresentationModelId: $sourceRepresentationModelId, ')
          ..write(
            'sourceRepresentationModelVersion: $sourceRepresentationModelVersion, ',
          )
          ..write('sourcePreprocessingVersion: $sourcePreprocessingVersion, ')
          ..write('scoreShown: $scoreShown, ')
          ..write('rawDistance: $rawDistance, ')
          ..write('soundRating: $soundRating, ')
          ..write('atmosphereRating: $atmosphereRating, ')
          ..write('trajectoryRating: $trajectoryRating, ')
          ..write('wouldListenNext: $wouldListenNext, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackLyricsTableTable extends TrackLyricsTable
    with TableInfo<$TrackLyricsTableTable, TrackLyricsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackLyricsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plainTextMeta = const VerificationMeta(
    'plainText',
  );
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
    'plain_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedTextMeta = const VerificationMeta(
    'syncedText',
  );
  @override
  late final GeneratedColumn<String> syncedText = GeneratedColumn<String>(
    'synced_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isInstrumentalMeta = const VerificationMeta(
    'isInstrumental',
  );
  @override
  late final GeneratedColumn<bool> isInstrumental = GeneratedColumn<bool>(
    'is_instrumental',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_instrumental" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _matchConfidenceMeta = const VerificationMeta(
    'matchConfidence',
  );
  @override
  late final GeneratedColumn<double> matchConfidence = GeneratedColumn<double>(
    'match_confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchedTitleMeta = const VerificationMeta(
    'matchedTitle',
  );
  @override
  late final GeneratedColumn<String> matchedTitle = GeneratedColumn<String>(
    'matched_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchedArtistMeta = const VerificationMeta(
    'matchedArtist',
  );
  @override
  late final GeneratedColumn<String> matchedArtist = GeneratedColumn<String>(
    'matched_artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchedDurationMsMeta = const VerificationMeta(
    'matchedDurationMs',
  );
  @override
  late final GeneratedColumn<int> matchedDurationMs = GeneratedColumn<int>(
    'matched_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    trackId,
    source,
    sourceId,
    plainText,
    syncedText,
    language,
    contentHash,
    isInstrumental,
    matchConfidence,
    matchedTitle,
    matchedArtist,
    matchedDurationMs,
    fetchedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_lyrics_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackLyricsTableData> instance, {
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
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('plain_text')) {
      context.handle(
        _plainTextMeta,
        plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta),
      );
    } else if (isInserting) {
      context.missing(_plainTextMeta);
    }
    if (data.containsKey('synced_text')) {
      context.handle(
        _syncedTextMeta,
        syncedText.isAcceptableOrUnknown(data['synced_text']!, _syncedTextMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('is_instrumental')) {
      context.handle(
        _isInstrumentalMeta,
        isInstrumental.isAcceptableOrUnknown(
          data['is_instrumental']!,
          _isInstrumentalMeta,
        ),
      );
    }
    if (data.containsKey('match_confidence')) {
      context.handle(
        _matchConfidenceMeta,
        matchConfidence.isAcceptableOrUnknown(
          data['match_confidence']!,
          _matchConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('matched_title')) {
      context.handle(
        _matchedTitleMeta,
        matchedTitle.isAcceptableOrUnknown(
          data['matched_title']!,
          _matchedTitleMeta,
        ),
      );
    }
    if (data.containsKey('matched_artist')) {
      context.handle(
        _matchedArtistMeta,
        matchedArtist.isAcceptableOrUnknown(
          data['matched_artist']!,
          _matchedArtistMeta,
        ),
      );
    }
    if (data.containsKey('matched_duration_ms')) {
      context.handle(
        _matchedDurationMsMeta,
        matchedDurationMs.isAcceptableOrUnknown(
          data['matched_duration_ms']!,
          _matchedDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  TrackLyricsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackLyricsTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      plainText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plain_text'],
      )!,
      syncedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_text'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      isInstrumental: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_instrumental'],
      )!,
      matchConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}match_confidence'],
      ),
      matchedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_title'],
      ),
      matchedArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_artist'],
      ),
      matchedDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}matched_duration_ms'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TrackLyricsTableTable createAlias(String alias) {
    return $TrackLyricsTableTable(attachedDatabase, alias);
  }
}

class TrackLyricsTableData extends DataClass
    implements Insertable<TrackLyricsTableData> {
  final String trackId;
  final String source;
  final String? sourceId;
  final String plainText;
  final String? syncedText;
  final String? language;
  final String contentHash;
  final bool isInstrumental;
  final double? matchConfidence;
  final String? matchedTitle;
  final String? matchedArtist;
  final int? matchedDurationMs;
  final DateTime fetchedAt;
  final DateTime updatedAt;
  const TrackLyricsTableData({
    required this.trackId,
    required this.source,
    this.sourceId,
    required this.plainText,
    this.syncedText,
    this.language,
    required this.contentHash,
    required this.isInstrumental,
    this.matchConfidence,
    this.matchedTitle,
    this.matchedArtist,
    this.matchedDurationMs,
    required this.fetchedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['plain_text'] = Variable<String>(plainText);
    if (!nullToAbsent || syncedText != null) {
      map['synced_text'] = Variable<String>(syncedText);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    map['content_hash'] = Variable<String>(contentHash);
    map['is_instrumental'] = Variable<bool>(isInstrumental);
    if (!nullToAbsent || matchConfidence != null) {
      map['match_confidence'] = Variable<double>(matchConfidence);
    }
    if (!nullToAbsent || matchedTitle != null) {
      map['matched_title'] = Variable<String>(matchedTitle);
    }
    if (!nullToAbsent || matchedArtist != null) {
      map['matched_artist'] = Variable<String>(matchedArtist);
    }
    if (!nullToAbsent || matchedDurationMs != null) {
      map['matched_duration_ms'] = Variable<int>(matchedDurationMs);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrackLyricsTableCompanion toCompanion(bool nullToAbsent) {
    return TrackLyricsTableCompanion(
      trackId: Value(trackId),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      plainText: Value(plainText),
      syncedText: syncedText == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedText),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      contentHash: Value(contentHash),
      isInstrumental: Value(isInstrumental),
      matchConfidence: matchConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(matchConfidence),
      matchedTitle: matchedTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedTitle),
      matchedArtist: matchedArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedArtist),
      matchedDurationMs: matchedDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedDurationMs),
      fetchedAt: Value(fetchedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrackLyricsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackLyricsTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      source: serializer.fromJson<String>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      plainText: serializer.fromJson<String>(json['plainText']),
      syncedText: serializer.fromJson<String?>(json['syncedText']),
      language: serializer.fromJson<String?>(json['language']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      isInstrumental: serializer.fromJson<bool>(json['isInstrumental']),
      matchConfidence: serializer.fromJson<double?>(json['matchConfidence']),
      matchedTitle: serializer.fromJson<String?>(json['matchedTitle']),
      matchedArtist: serializer.fromJson<String?>(json['matchedArtist']),
      matchedDurationMs: serializer.fromJson<int?>(json['matchedDurationMs']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'source': serializer.toJson<String>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
      'plainText': serializer.toJson<String>(plainText),
      'syncedText': serializer.toJson<String?>(syncedText),
      'language': serializer.toJson<String?>(language),
      'contentHash': serializer.toJson<String>(contentHash),
      'isInstrumental': serializer.toJson<bool>(isInstrumental),
      'matchConfidence': serializer.toJson<double?>(matchConfidence),
      'matchedTitle': serializer.toJson<String?>(matchedTitle),
      'matchedArtist': serializer.toJson<String?>(matchedArtist),
      'matchedDurationMs': serializer.toJson<int?>(matchedDurationMs),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrackLyricsTableData copyWith({
    String? trackId,
    String? source,
    Value<String?> sourceId = const Value.absent(),
    String? plainText,
    Value<String?> syncedText = const Value.absent(),
    Value<String?> language = const Value.absent(),
    String? contentHash,
    bool? isInstrumental,
    Value<double?> matchConfidence = const Value.absent(),
    Value<String?> matchedTitle = const Value.absent(),
    Value<String?> matchedArtist = const Value.absent(),
    Value<int?> matchedDurationMs = const Value.absent(),
    DateTime? fetchedAt,
    DateTime? updatedAt,
  }) => TrackLyricsTableData(
    trackId: trackId ?? this.trackId,
    source: source ?? this.source,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    plainText: plainText ?? this.plainText,
    syncedText: syncedText.present ? syncedText.value : this.syncedText,
    language: language.present ? language.value : this.language,
    contentHash: contentHash ?? this.contentHash,
    isInstrumental: isInstrumental ?? this.isInstrumental,
    matchConfidence: matchConfidence.present
        ? matchConfidence.value
        : this.matchConfidence,
    matchedTitle: matchedTitle.present ? matchedTitle.value : this.matchedTitle,
    matchedArtist: matchedArtist.present
        ? matchedArtist.value
        : this.matchedArtist,
    matchedDurationMs: matchedDurationMs.present
        ? matchedDurationMs.value
        : this.matchedDurationMs,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrackLyricsTableData copyWithCompanion(TrackLyricsTableCompanion data) {
    return TrackLyricsTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      syncedText: data.syncedText.present
          ? data.syncedText.value
          : this.syncedText,
      language: data.language.present ? data.language.value : this.language,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      isInstrumental: data.isInstrumental.present
          ? data.isInstrumental.value
          : this.isInstrumental,
      matchConfidence: data.matchConfidence.present
          ? data.matchConfidence.value
          : this.matchConfidence,
      matchedTitle: data.matchedTitle.present
          ? data.matchedTitle.value
          : this.matchedTitle,
      matchedArtist: data.matchedArtist.present
          ? data.matchedArtist.value
          : this.matchedArtist,
      matchedDurationMs: data.matchedDurationMs.present
          ? data.matchedDurationMs.value
          : this.matchedDurationMs,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackLyricsTableData(')
          ..write('trackId: $trackId, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('plainText: $plainText, ')
          ..write('syncedText: $syncedText, ')
          ..write('language: $language, ')
          ..write('contentHash: $contentHash, ')
          ..write('isInstrumental: $isInstrumental, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('matchedTitle: $matchedTitle, ')
          ..write('matchedArtist: $matchedArtist, ')
          ..write('matchedDurationMs: $matchedDurationMs, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    source,
    sourceId,
    plainText,
    syncedText,
    language,
    contentHash,
    isInstrumental,
    matchConfidence,
    matchedTitle,
    matchedArtist,
    matchedDurationMs,
    fetchedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackLyricsTableData &&
          other.trackId == this.trackId &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.plainText == this.plainText &&
          other.syncedText == this.syncedText &&
          other.language == this.language &&
          other.contentHash == this.contentHash &&
          other.isInstrumental == this.isInstrumental &&
          other.matchConfidence == this.matchConfidence &&
          other.matchedTitle == this.matchedTitle &&
          other.matchedArtist == this.matchedArtist &&
          other.matchedDurationMs == this.matchedDurationMs &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt);
}

class TrackLyricsTableCompanion extends UpdateCompanion<TrackLyricsTableData> {
  final Value<String> trackId;
  final Value<String> source;
  final Value<String?> sourceId;
  final Value<String> plainText;
  final Value<String?> syncedText;
  final Value<String?> language;
  final Value<String> contentHash;
  final Value<bool> isInstrumental;
  final Value<double?> matchConfidence;
  final Value<String?> matchedTitle;
  final Value<String?> matchedArtist;
  final Value<int?> matchedDurationMs;
  final Value<DateTime> fetchedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrackLyricsTableCompanion({
    this.trackId = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.plainText = const Value.absent(),
    this.syncedText = const Value.absent(),
    this.language = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.isInstrumental = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.matchedTitle = const Value.absent(),
    this.matchedArtist = const Value.absent(),
    this.matchedDurationMs = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackLyricsTableCompanion.insert({
    required String trackId,
    required String source,
    this.sourceId = const Value.absent(),
    required String plainText,
    this.syncedText = const Value.absent(),
    this.language = const Value.absent(),
    required String contentHash,
    this.isInstrumental = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.matchedTitle = const Value.absent(),
    this.matchedArtist = const Value.absent(),
    this.matchedDurationMs = const Value.absent(),
    required DateTime fetchedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       source = Value(source),
       plainText = Value(plainText),
       contentHash = Value(contentHash),
       fetchedAt = Value(fetchedAt),
       updatedAt = Value(updatedAt);
  static Insertable<TrackLyricsTableData> custom({
    Expression<String>? trackId,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? plainText,
    Expression<String>? syncedText,
    Expression<String>? language,
    Expression<String>? contentHash,
    Expression<bool>? isInstrumental,
    Expression<double>? matchConfidence,
    Expression<String>? matchedTitle,
    Expression<String>? matchedArtist,
    Expression<int>? matchedDurationMs,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (plainText != null) 'plain_text': plainText,
      if (syncedText != null) 'synced_text': syncedText,
      if (language != null) 'language': language,
      if (contentHash != null) 'content_hash': contentHash,
      if (isInstrumental != null) 'is_instrumental': isInstrumental,
      if (matchConfidence != null) 'match_confidence': matchConfidence,
      if (matchedTitle != null) 'matched_title': matchedTitle,
      if (matchedArtist != null) 'matched_artist': matchedArtist,
      if (matchedDurationMs != null) 'matched_duration_ms': matchedDurationMs,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackLyricsTableCompanion copyWith({
    Value<String>? trackId,
    Value<String>? source,
    Value<String?>? sourceId,
    Value<String>? plainText,
    Value<String?>? syncedText,
    Value<String?>? language,
    Value<String>? contentHash,
    Value<bool>? isInstrumental,
    Value<double?>? matchConfidence,
    Value<String?>? matchedTitle,
    Value<String?>? matchedArtist,
    Value<int?>? matchedDurationMs,
    Value<DateTime>? fetchedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TrackLyricsTableCompanion(
      trackId: trackId ?? this.trackId,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      plainText: plainText ?? this.plainText,
      syncedText: syncedText ?? this.syncedText,
      language: language ?? this.language,
      contentHash: contentHash ?? this.contentHash,
      isInstrumental: isInstrumental ?? this.isInstrumental,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      matchedTitle: matchedTitle ?? this.matchedTitle,
      matchedArtist: matchedArtist ?? this.matchedArtist,
      matchedDurationMs: matchedDurationMs ?? this.matchedDurationMs,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (syncedText.present) {
      map['synced_text'] = Variable<String>(syncedText.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (isInstrumental.present) {
      map['is_instrumental'] = Variable<bool>(isInstrumental.value);
    }
    if (matchConfidence.present) {
      map['match_confidence'] = Variable<double>(matchConfidence.value);
    }
    if (matchedTitle.present) {
      map['matched_title'] = Variable<String>(matchedTitle.value);
    }
    if (matchedArtist.present) {
      map['matched_artist'] = Variable<String>(matchedArtist.value);
    }
    if (matchedDurationMs.present) {
      map['matched_duration_ms'] = Variable<int>(matchedDurationMs.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
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
    return (StringBuffer('TrackLyricsTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('plainText: $plainText, ')
          ..write('syncedText: $syncedText, ')
          ..write('language: $language, ')
          ..write('contentHash: $contentHash, ')
          ..write('isInstrumental: $isInstrumental, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('matchedTitle: $matchedTitle, ')
          ..write('matchedArtist: $matchedArtist, ')
          ..write('matchedDurationMs: $matchedDurationMs, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LyricsResolutionStateTableTable extends LyricsResolutionStateTable
    with
        TableInfo<
          $LyricsResolutionStateTableTable,
          LyricsResolutionStateTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricsResolutionStateTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    trackId,
    status,
    provider,
    metadataRevision,
    attemptCount,
    lastErrorCode,
    lastError,
    nextRetryAt,
    lastAttemptAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyrics_resolution_state_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricsResolutionStateTableData> instance, {
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
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
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
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
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  LyricsResolutionStateTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricsResolutionStateTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      metadataRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metadata_revision'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LyricsResolutionStateTableTable createAlias(String alias) {
    return $LyricsResolutionStateTableTable(attachedDatabase, alias);
  }
}

class LyricsResolutionStateTableData extends DataClass
    implements Insertable<LyricsResolutionStateTableData> {
  final String trackId;
  final String status;
  final String? provider;
  final int metadataRevision;
  final int attemptCount;
  final String? lastErrorCode;
  final String? lastError;
  final DateTime? nextRetryAt;
  final DateTime? lastAttemptAt;
  final DateTime updatedAt;
  const LyricsResolutionStateTableData({
    required this.trackId,
    required this.status,
    this.provider,
    required this.metadataRevision,
    required this.attemptCount,
    this.lastErrorCode,
    this.lastError,
    this.nextRetryAt,
    this.lastAttemptAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    map['metadata_revision'] = Variable<int>(metadataRevision);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LyricsResolutionStateTableCompanion toCompanion(bool nullToAbsent) {
    return LyricsResolutionStateTableCompanion(
      trackId: Value(trackId),
      status: Value(status),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      metadataRevision: Value(metadataRevision),
      attemptCount: Value(attemptCount),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LyricsResolutionStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricsResolutionStateTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      status: serializer.fromJson<String>(json['status']),
      provider: serializer.fromJson<String?>(json['provider']),
      metadataRevision: serializer.fromJson<int>(json['metadataRevision']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'status': serializer.toJson<String>(status),
      'provider': serializer.toJson<String?>(provider),
      'metadataRevision': serializer.toJson<int>(metadataRevision),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastError': serializer.toJson<String?>(lastError),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LyricsResolutionStateTableData copyWith({
    String? trackId,
    String? status,
    Value<String?> provider = const Value.absent(),
    int? metadataRevision,
    int? attemptCount,
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    DateTime? updatedAt,
  }) => LyricsResolutionStateTableData(
    trackId: trackId ?? this.trackId,
    status: status ?? this.status,
    provider: provider.present ? provider.value : this.provider,
    metadataRevision: metadataRevision ?? this.metadataRevision,
    attemptCount: attemptCount ?? this.attemptCount,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    lastError: lastError.present ? lastError.value : this.lastError,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LyricsResolutionStateTableData copyWithCompanion(
    LyricsResolutionStateTableCompanion data,
  ) {
    return LyricsResolutionStateTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      status: data.status.present ? data.status.value : this.status,
      provider: data.provider.present ? data.provider.value : this.provider,
      metadataRevision: data.metadataRevision.present
          ? data.metadataRevision.value
          : this.metadataRevision,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricsResolutionStateTableData(')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('provider: $provider, ')
          ..write('metadataRevision: $metadataRevision, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    status,
    provider,
    metadataRevision,
    attemptCount,
    lastErrorCode,
    lastError,
    nextRetryAt,
    lastAttemptAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricsResolutionStateTableData &&
          other.trackId == this.trackId &&
          other.status == this.status &&
          other.provider == this.provider &&
          other.metadataRevision == this.metadataRevision &&
          other.attemptCount == this.attemptCount &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastError == this.lastError &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.updatedAt == this.updatedAt);
}

class LyricsResolutionStateTableCompanion
    extends UpdateCompanion<LyricsResolutionStateTableData> {
  final Value<String> trackId;
  final Value<String> status;
  final Value<String?> provider;
  final Value<int> metadataRevision;
  final Value<int> attemptCount;
  final Value<String?> lastErrorCode;
  final Value<String?> lastError;
  final Value<DateTime?> nextRetryAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LyricsResolutionStateTableCompanion({
    this.trackId = const Value.absent(),
    this.status = const Value.absent(),
    this.provider = const Value.absent(),
    this.metadataRevision = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LyricsResolutionStateTableCompanion.insert({
    required String trackId,
    required String status,
    this.provider = const Value.absent(),
    this.metadataRevision = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<LyricsResolutionStateTableData> custom({
    Expression<String>? trackId,
    Expression<String>? status,
    Expression<String>? provider,
    Expression<int>? metadataRevision,
    Expression<int>? attemptCount,
    Expression<String>? lastErrorCode,
    Expression<String>? lastError,
    Expression<DateTime>? nextRetryAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (status != null) 'status': status,
      if (provider != null) 'provider': provider,
      if (metadataRevision != null) 'metadata_revision': metadataRevision,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastError != null) 'last_error': lastError,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LyricsResolutionStateTableCompanion copyWith({
    Value<String>? trackId,
    Value<String>? status,
    Value<String?>? provider,
    Value<int>? metadataRevision,
    Value<int>? attemptCount,
    Value<String?>? lastErrorCode,
    Value<String?>? lastError,
    Value<DateTime?>? nextRetryAt,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LyricsResolutionStateTableCompanion(
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      provider: provider ?? this.provider,
      metadataRevision: metadataRevision ?? this.metadataRevision,
      attemptCount: attemptCount ?? this.attemptCount,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastError: lastError ?? this.lastError,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (metadataRevision.present) {
      map['metadata_revision'] = Variable<int>(metadataRevision.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
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
    return (StringBuffer('LyricsResolutionStateTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('provider: $provider, ')
          ..write('metadataRevision: $metadataRevision, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LyricsResolutionTaskTableTable extends LyricsResolutionTaskTable
    with
        TableInfo<
          $LyricsResolutionTaskTableTable,
          LyricsResolutionTaskTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricsResolutionTaskTableTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    status,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyrics_resolution_task_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricsResolutionTaskTableData> instance, {
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
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {trackId},
  ];
  @override
  LyricsResolutionTaskTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricsResolutionTaskTableData(
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
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LyricsResolutionTaskTableTable createAlias(String alias) {
    return $LyricsResolutionTaskTableTable(attachedDatabase, alias);
  }
}

class LyricsResolutionTaskTableData extends DataClass
    implements Insertable<LyricsResolutionTaskTableData> {
  final String id;
  final String trackId;
  final String status;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final String? lastErrorCode;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LyricsResolutionTaskTableData({
    required this.id,
    required this.trackId,
    required this.status,
    required this.attemptCount,
    this.nextAttemptAt,
    this.lastErrorCode,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LyricsResolutionTaskTableCompanion toCompanion(bool nullToAbsent) {
    return LyricsResolutionTaskTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      status: Value(status),
      attemptCount: Value(attemptCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LyricsResolutionTaskTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricsResolutionTaskTableData(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String>(trackId),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LyricsResolutionTaskTableData copyWith({
    String? id,
    String? trackId,
    String? status,
    int? attemptCount,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LyricsResolutionTaskTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LyricsResolutionTaskTableData copyWithCompanion(
    LyricsResolutionTaskTableCompanion data,
  ) {
    return LyricsResolutionTaskTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricsResolutionTaskTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    status,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricsResolutionTaskTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LyricsResolutionTaskTableCompanion
    extends UpdateCompanion<LyricsResolutionTaskTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastErrorCode;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LyricsResolutionTaskTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LyricsResolutionTaskTableCompanion.insert({
    required String id,
    required String trackId,
    required String status,
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LyricsResolutionTaskTableData> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastErrorCode,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LyricsResolutionTaskTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? status,
    Value<int>? attemptCount,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastErrorCode,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LyricsResolutionTaskTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
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
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('LyricsResolutionTaskTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackEmotionAnalysisTableTable extends TrackEmotionAnalysisTable
    with
        TableInfo<
          $TrackEmotionAnalysisTableTable,
          TrackEmotionAnalysisTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackEmotionAnalysisTableTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _representationMeta = const VerificationMeta(
    'representation',
  );
  @override
  late final GeneratedColumn<String> representation = GeneratedColumn<String>(
    'representation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preprocessingVersionMeta =
      const VerificationMeta('preprocessingVersion');
  @override
  late final GeneratedColumn<String> preprocessingVersion =
      GeneratedColumn<String>(
        'preprocessing_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _contentRevisionMeta = const VerificationMeta(
    'contentRevision',
  );
  @override
  late final GeneratedColumn<String> contentRevision = GeneratedColumn<String>(
    'content_revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valenceMeta = const VerificationMeta(
    'valence',
  );
  @override
  late final GeneratedColumn<double> valence = GeneratedColumn<double>(
    'valence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arousalMeta = const VerificationMeta(
    'arousal',
  );
  @override
  late final GeneratedColumn<double> arousal = GeneratedColumn<double>(
    'arousal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawValenceMeta = const VerificationMeta(
    'rawValence',
  );
  @override
  late final GeneratedColumn<double> rawValence = GeneratedColumn<double>(
    'raw_valence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawArousalMeta = const VerificationMeta(
    'rawArousal',
  );
  @override
  late final GeneratedColumn<double> rawArousal = GeneratedColumn<double>(
    'raw_arousal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodDistributionVersionMeta =
      const VerificationMeta('moodDistributionVersion');
  @override
  late final GeneratedColumn<int> moodDistributionVersion =
      GeneratedColumn<int>(
        'mood_distribution_version',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      );
  static const VerificationMeta _moodDistributionJsonMeta =
      const VerificationMeta('moodDistributionJson');
  @override
  late final GeneratedColumn<String> moodDistributionJson =
      GeneratedColumn<String>(
        'mood_distribution_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _temporalSummaryJsonMeta =
      const VerificationMeta('temporalSummaryJson');
  @override
  late final GeneratedColumn<String> temporalSummaryJson =
      GeneratedColumn<String>(
        'temporal_summary_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _analyzedAtMeta = const VerificationMeta(
    'analyzedAt',
  );
  @override
  late final GeneratedColumn<DateTime> analyzedAt = GeneratedColumn<DateTime>(
    'analyzed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    representation,
    modelId,
    modelVersion,
    preprocessingVersion,
    contentRevision,
    audioRevision,
    valence,
    arousal,
    rawValence,
    rawArousal,
    moodDistributionVersion,
    moodDistributionJson,
    temporalSummaryJson,
    analyzedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_emotion_analysis_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackEmotionAnalysisTableData> instance, {
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
    if (data.containsKey('representation')) {
      context.handle(
        _representationMeta,
        representation.isAcceptableOrUnknown(
          data['representation']!,
          _representationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_representationMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('preprocessing_version')) {
      context.handle(
        _preprocessingVersionMeta,
        preprocessingVersion.isAcceptableOrUnknown(
          data['preprocessing_version']!,
          _preprocessingVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preprocessingVersionMeta);
    }
    if (data.containsKey('content_revision')) {
      context.handle(
        _contentRevisionMeta,
        contentRevision.isAcceptableOrUnknown(
          data['content_revision']!,
          _contentRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentRevisionMeta);
    }
    if (data.containsKey('audio_revision')) {
      context.handle(
        _audioRevisionMeta,
        audioRevision.isAcceptableOrUnknown(
          data['audio_revision']!,
          _audioRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioRevisionMeta);
    }
    if (data.containsKey('valence')) {
      context.handle(
        _valenceMeta,
        valence.isAcceptableOrUnknown(data['valence']!, _valenceMeta),
      );
    }
    if (data.containsKey('arousal')) {
      context.handle(
        _arousalMeta,
        arousal.isAcceptableOrUnknown(data['arousal']!, _arousalMeta),
      );
    }
    if (data.containsKey('raw_valence')) {
      context.handle(
        _rawValenceMeta,
        rawValence.isAcceptableOrUnknown(data['raw_valence']!, _rawValenceMeta),
      );
    }
    if (data.containsKey('raw_arousal')) {
      context.handle(
        _rawArousalMeta,
        rawArousal.isAcceptableOrUnknown(data['raw_arousal']!, _rawArousalMeta),
      );
    }
    if (data.containsKey('mood_distribution_version')) {
      context.handle(
        _moodDistributionVersionMeta,
        moodDistributionVersion.isAcceptableOrUnknown(
          data['mood_distribution_version']!,
          _moodDistributionVersionMeta,
        ),
      );
    }
    if (data.containsKey('mood_distribution_json')) {
      context.handle(
        _moodDistributionJsonMeta,
        moodDistributionJson.isAcceptableOrUnknown(
          data['mood_distribution_json']!,
          _moodDistributionJsonMeta,
        ),
      );
    }
    if (data.containsKey('temporal_summary_json')) {
      context.handle(
        _temporalSummaryJsonMeta,
        temporalSummaryJson.isAcceptableOrUnknown(
          data['temporal_summary_json']!,
          _temporalSummaryJsonMeta,
        ),
      );
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
        _analyzedAtMeta,
        analyzedAt.isAcceptableOrUnknown(data['analyzed_at']!, _analyzedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_analyzedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {
      trackId,
      representation,
      modelId,
      modelVersion,
      preprocessingVersion,
      contentRevision,
      audioRevision,
    },
  ];
  @override
  TrackEmotionAnalysisTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackEmotionAnalysisTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      representation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}representation'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      preprocessingVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preprocessing_version'],
      )!,
      contentRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_revision'],
      )!,
      audioRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_revision'],
      )!,
      valence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valence'],
      ),
      arousal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arousal'],
      ),
      rawValence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}raw_valence'],
      ),
      rawArousal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}raw_arousal'],
      ),
      moodDistributionVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood_distribution_version'],
      )!,
      moodDistributionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_distribution_json'],
      ),
      temporalSummaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temporal_summary_json'],
      ),
      analyzedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}analyzed_at'],
      )!,
    );
  }

  @override
  $TrackEmotionAnalysisTableTable createAlias(String alias) {
    return $TrackEmotionAnalysisTableTable(attachedDatabase, alias);
  }
}

class TrackEmotionAnalysisTableData extends DataClass
    implements Insertable<TrackEmotionAnalysisTableData> {
  final String id;
  final String trackId;
  final String representation;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
  final String contentRevision;
  final int audioRevision;
  final double? valence;
  final double? arousal;
  final double? rawValence;
  final double? rawArousal;
  final int moodDistributionVersion;
  final String? moodDistributionJson;
  final String? temporalSummaryJson;
  final DateTime analyzedAt;
  const TrackEmotionAnalysisTableData({
    required this.id,
    required this.trackId,
    required this.representation,
    required this.modelId,
    required this.modelVersion,
    required this.preprocessingVersion,
    required this.contentRevision,
    required this.audioRevision,
    this.valence,
    this.arousal,
    this.rawValence,
    this.rawArousal,
    required this.moodDistributionVersion,
    this.moodDistributionJson,
    this.temporalSummaryJson,
    required this.analyzedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['representation'] = Variable<String>(representation);
    map['model_id'] = Variable<String>(modelId);
    map['model_version'] = Variable<String>(modelVersion);
    map['preprocessing_version'] = Variable<String>(preprocessingVersion);
    map['content_revision'] = Variable<String>(contentRevision);
    map['audio_revision'] = Variable<int>(audioRevision);
    if (!nullToAbsent || valence != null) {
      map['valence'] = Variable<double>(valence);
    }
    if (!nullToAbsent || arousal != null) {
      map['arousal'] = Variable<double>(arousal);
    }
    if (!nullToAbsent || rawValence != null) {
      map['raw_valence'] = Variable<double>(rawValence);
    }
    if (!nullToAbsent || rawArousal != null) {
      map['raw_arousal'] = Variable<double>(rawArousal);
    }
    map['mood_distribution_version'] = Variable<int>(moodDistributionVersion);
    if (!nullToAbsent || moodDistributionJson != null) {
      map['mood_distribution_json'] = Variable<String>(moodDistributionJson);
    }
    if (!nullToAbsent || temporalSummaryJson != null) {
      map['temporal_summary_json'] = Variable<String>(temporalSummaryJson);
    }
    map['analyzed_at'] = Variable<DateTime>(analyzedAt);
    return map;
  }

  TrackEmotionAnalysisTableCompanion toCompanion(bool nullToAbsent) {
    return TrackEmotionAnalysisTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      representation: Value(representation),
      modelId: Value(modelId),
      modelVersion: Value(modelVersion),
      preprocessingVersion: Value(preprocessingVersion),
      contentRevision: Value(contentRevision),
      audioRevision: Value(audioRevision),
      valence: valence == null && nullToAbsent
          ? const Value.absent()
          : Value(valence),
      arousal: arousal == null && nullToAbsent
          ? const Value.absent()
          : Value(arousal),
      rawValence: rawValence == null && nullToAbsent
          ? const Value.absent()
          : Value(rawValence),
      rawArousal: rawArousal == null && nullToAbsent
          ? const Value.absent()
          : Value(rawArousal),
      moodDistributionVersion: Value(moodDistributionVersion),
      moodDistributionJson: moodDistributionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(moodDistributionJson),
      temporalSummaryJson: temporalSummaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(temporalSummaryJson),
      analyzedAt: Value(analyzedAt),
    );
  }

  factory TrackEmotionAnalysisTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackEmotionAnalysisTableData(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      representation: serializer.fromJson<String>(json['representation']),
      modelId: serializer.fromJson<String>(json['modelId']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      preprocessingVersion: serializer.fromJson<String>(
        json['preprocessingVersion'],
      ),
      contentRevision: serializer.fromJson<String>(json['contentRevision']),
      audioRevision: serializer.fromJson<int>(json['audioRevision']),
      valence: serializer.fromJson<double?>(json['valence']),
      arousal: serializer.fromJson<double?>(json['arousal']),
      rawValence: serializer.fromJson<double?>(json['rawValence']),
      rawArousal: serializer.fromJson<double?>(json['rawArousal']),
      moodDistributionVersion: serializer.fromJson<int>(
        json['moodDistributionVersion'],
      ),
      moodDistributionJson: serializer.fromJson<String?>(
        json['moodDistributionJson'],
      ),
      temporalSummaryJson: serializer.fromJson<String?>(
        json['temporalSummaryJson'],
      ),
      analyzedAt: serializer.fromJson<DateTime>(json['analyzedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String>(trackId),
      'representation': serializer.toJson<String>(representation),
      'modelId': serializer.toJson<String>(modelId),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'preprocessingVersion': serializer.toJson<String>(preprocessingVersion),
      'contentRevision': serializer.toJson<String>(contentRevision),
      'audioRevision': serializer.toJson<int>(audioRevision),
      'valence': serializer.toJson<double?>(valence),
      'arousal': serializer.toJson<double?>(arousal),
      'rawValence': serializer.toJson<double?>(rawValence),
      'rawArousal': serializer.toJson<double?>(rawArousal),
      'moodDistributionVersion': serializer.toJson<int>(
        moodDistributionVersion,
      ),
      'moodDistributionJson': serializer.toJson<String?>(moodDistributionJson),
      'temporalSummaryJson': serializer.toJson<String?>(temporalSummaryJson),
      'analyzedAt': serializer.toJson<DateTime>(analyzedAt),
    };
  }

  TrackEmotionAnalysisTableData copyWith({
    String? id,
    String? trackId,
    String? representation,
    String? modelId,
    String? modelVersion,
    String? preprocessingVersion,
    String? contentRevision,
    int? audioRevision,
    Value<double?> valence = const Value.absent(),
    Value<double?> arousal = const Value.absent(),
    Value<double?> rawValence = const Value.absent(),
    Value<double?> rawArousal = const Value.absent(),
    int? moodDistributionVersion,
    Value<String?> moodDistributionJson = const Value.absent(),
    Value<String?> temporalSummaryJson = const Value.absent(),
    DateTime? analyzedAt,
  }) => TrackEmotionAnalysisTableData(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    representation: representation ?? this.representation,
    modelId: modelId ?? this.modelId,
    modelVersion: modelVersion ?? this.modelVersion,
    preprocessingVersion: preprocessingVersion ?? this.preprocessingVersion,
    contentRevision: contentRevision ?? this.contentRevision,
    audioRevision: audioRevision ?? this.audioRevision,
    valence: valence.present ? valence.value : this.valence,
    arousal: arousal.present ? arousal.value : this.arousal,
    rawValence: rawValence.present ? rawValence.value : this.rawValence,
    rawArousal: rawArousal.present ? rawArousal.value : this.rawArousal,
    moodDistributionVersion:
        moodDistributionVersion ?? this.moodDistributionVersion,
    moodDistributionJson: moodDistributionJson.present
        ? moodDistributionJson.value
        : this.moodDistributionJson,
    temporalSummaryJson: temporalSummaryJson.present
        ? temporalSummaryJson.value
        : this.temporalSummaryJson,
    analyzedAt: analyzedAt ?? this.analyzedAt,
  );
  TrackEmotionAnalysisTableData copyWithCompanion(
    TrackEmotionAnalysisTableCompanion data,
  ) {
    return TrackEmotionAnalysisTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      representation: data.representation.present
          ? data.representation.value
          : this.representation,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      preprocessingVersion: data.preprocessingVersion.present
          ? data.preprocessingVersion.value
          : this.preprocessingVersion,
      contentRevision: data.contentRevision.present
          ? data.contentRevision.value
          : this.contentRevision,
      audioRevision: data.audioRevision.present
          ? data.audioRevision.value
          : this.audioRevision,
      valence: data.valence.present ? data.valence.value : this.valence,
      arousal: data.arousal.present ? data.arousal.value : this.arousal,
      rawValence: data.rawValence.present
          ? data.rawValence.value
          : this.rawValence,
      rawArousal: data.rawArousal.present
          ? data.rawArousal.value
          : this.rawArousal,
      moodDistributionVersion: data.moodDistributionVersion.present
          ? data.moodDistributionVersion.value
          : this.moodDistributionVersion,
      moodDistributionJson: data.moodDistributionJson.present
          ? data.moodDistributionJson.value
          : this.moodDistributionJson,
      temporalSummaryJson: data.temporalSummaryJson.present
          ? data.temporalSummaryJson.value
          : this.temporalSummaryJson,
      analyzedAt: data.analyzedAt.present
          ? data.analyzedAt.value
          : this.analyzedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackEmotionAnalysisTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('representation: $representation, ')
          ..write('modelId: $modelId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('preprocessingVersion: $preprocessingVersion, ')
          ..write('contentRevision: $contentRevision, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('valence: $valence, ')
          ..write('arousal: $arousal, ')
          ..write('rawValence: $rawValence, ')
          ..write('rawArousal: $rawArousal, ')
          ..write('moodDistributionVersion: $moodDistributionVersion, ')
          ..write('moodDistributionJson: $moodDistributionJson, ')
          ..write('temporalSummaryJson: $temporalSummaryJson, ')
          ..write('analyzedAt: $analyzedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    representation,
    modelId,
    modelVersion,
    preprocessingVersion,
    contentRevision,
    audioRevision,
    valence,
    arousal,
    rawValence,
    rawArousal,
    moodDistributionVersion,
    moodDistributionJson,
    temporalSummaryJson,
    analyzedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackEmotionAnalysisTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.representation == this.representation &&
          other.modelId == this.modelId &&
          other.modelVersion == this.modelVersion &&
          other.preprocessingVersion == this.preprocessingVersion &&
          other.contentRevision == this.contentRevision &&
          other.audioRevision == this.audioRevision &&
          other.valence == this.valence &&
          other.arousal == this.arousal &&
          other.rawValence == this.rawValence &&
          other.rawArousal == this.rawArousal &&
          other.moodDistributionVersion == this.moodDistributionVersion &&
          other.moodDistributionJson == this.moodDistributionJson &&
          other.temporalSummaryJson == this.temporalSummaryJson &&
          other.analyzedAt == this.analyzedAt);
}

class TrackEmotionAnalysisTableCompanion
    extends UpdateCompanion<TrackEmotionAnalysisTableData> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> representation;
  final Value<String> modelId;
  final Value<String> modelVersion;
  final Value<String> preprocessingVersion;
  final Value<String> contentRevision;
  final Value<int> audioRevision;
  final Value<double?> valence;
  final Value<double?> arousal;
  final Value<double?> rawValence;
  final Value<double?> rawArousal;
  final Value<int> moodDistributionVersion;
  final Value<String?> moodDistributionJson;
  final Value<String?> temporalSummaryJson;
  final Value<DateTime> analyzedAt;
  final Value<int> rowid;
  const TrackEmotionAnalysisTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.representation = const Value.absent(),
    this.modelId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.preprocessingVersion = const Value.absent(),
    this.contentRevision = const Value.absent(),
    this.audioRevision = const Value.absent(),
    this.valence = const Value.absent(),
    this.arousal = const Value.absent(),
    this.rawValence = const Value.absent(),
    this.rawArousal = const Value.absent(),
    this.moodDistributionVersion = const Value.absent(),
    this.moodDistributionJson = const Value.absent(),
    this.temporalSummaryJson = const Value.absent(),
    this.analyzedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackEmotionAnalysisTableCompanion.insert({
    required String id,
    required String trackId,
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required String contentRevision,
    required int audioRevision,
    this.valence = const Value.absent(),
    this.arousal = const Value.absent(),
    this.rawValence = const Value.absent(),
    this.rawArousal = const Value.absent(),
    this.moodDistributionVersion = const Value.absent(),
    this.moodDistributionJson = const Value.absent(),
    this.temporalSummaryJson = const Value.absent(),
    required DateTime analyzedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       representation = Value(representation),
       modelId = Value(modelId),
       modelVersion = Value(modelVersion),
       preprocessingVersion = Value(preprocessingVersion),
       contentRevision = Value(contentRevision),
       audioRevision = Value(audioRevision),
       analyzedAt = Value(analyzedAt);
  static Insertable<TrackEmotionAnalysisTableData> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? representation,
    Expression<String>? modelId,
    Expression<String>? modelVersion,
    Expression<String>? preprocessingVersion,
    Expression<String>? contentRevision,
    Expression<int>? audioRevision,
    Expression<double>? valence,
    Expression<double>? arousal,
    Expression<double>? rawValence,
    Expression<double>? rawArousal,
    Expression<int>? moodDistributionVersion,
    Expression<String>? moodDistributionJson,
    Expression<String>? temporalSummaryJson,
    Expression<DateTime>? analyzedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (representation != null) 'representation': representation,
      if (modelId != null) 'model_id': modelId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (preprocessingVersion != null)
        'preprocessing_version': preprocessingVersion,
      if (contentRevision != null) 'content_revision': contentRevision,
      if (audioRevision != null) 'audio_revision': audioRevision,
      if (valence != null) 'valence': valence,
      if (arousal != null) 'arousal': arousal,
      if (rawValence != null) 'raw_valence': rawValence,
      if (rawArousal != null) 'raw_arousal': rawArousal,
      if (moodDistributionVersion != null)
        'mood_distribution_version': moodDistributionVersion,
      if (moodDistributionJson != null)
        'mood_distribution_json': moodDistributionJson,
      if (temporalSummaryJson != null)
        'temporal_summary_json': temporalSummaryJson,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackEmotionAnalysisTableCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? representation,
    Value<String>? modelId,
    Value<String>? modelVersion,
    Value<String>? preprocessingVersion,
    Value<String>? contentRevision,
    Value<int>? audioRevision,
    Value<double?>? valence,
    Value<double?>? arousal,
    Value<double?>? rawValence,
    Value<double?>? rawArousal,
    Value<int>? moodDistributionVersion,
    Value<String?>? moodDistributionJson,
    Value<String?>? temporalSummaryJson,
    Value<DateTime>? analyzedAt,
    Value<int>? rowid,
  }) {
    return TrackEmotionAnalysisTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      representation: representation ?? this.representation,
      modelId: modelId ?? this.modelId,
      modelVersion: modelVersion ?? this.modelVersion,
      preprocessingVersion: preprocessingVersion ?? this.preprocessingVersion,
      contentRevision: contentRevision ?? this.contentRevision,
      audioRevision: audioRevision ?? this.audioRevision,
      valence: valence ?? this.valence,
      arousal: arousal ?? this.arousal,
      rawValence: rawValence ?? this.rawValence,
      rawArousal: rawArousal ?? this.rawArousal,
      moodDistributionVersion:
          moodDistributionVersion ?? this.moodDistributionVersion,
      moodDistributionJson: moodDistributionJson ?? this.moodDistributionJson,
      temporalSummaryJson: temporalSummaryJson ?? this.temporalSummaryJson,
      analyzedAt: analyzedAt ?? this.analyzedAt,
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
    if (representation.present) {
      map['representation'] = Variable<String>(representation.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (preprocessingVersion.present) {
      map['preprocessing_version'] = Variable<String>(
        preprocessingVersion.value,
      );
    }
    if (contentRevision.present) {
      map['content_revision'] = Variable<String>(contentRevision.value);
    }
    if (audioRevision.present) {
      map['audio_revision'] = Variable<int>(audioRevision.value);
    }
    if (valence.present) {
      map['valence'] = Variable<double>(valence.value);
    }
    if (arousal.present) {
      map['arousal'] = Variable<double>(arousal.value);
    }
    if (rawValence.present) {
      map['raw_valence'] = Variable<double>(rawValence.value);
    }
    if (rawArousal.present) {
      map['raw_arousal'] = Variable<double>(rawArousal.value);
    }
    if (moodDistributionVersion.present) {
      map['mood_distribution_version'] = Variable<int>(
        moodDistributionVersion.value,
      );
    }
    if (moodDistributionJson.present) {
      map['mood_distribution_json'] = Variable<String>(
        moodDistributionJson.value,
      );
    }
    if (temporalSummaryJson.present) {
      map['temporal_summary_json'] = Variable<String>(
        temporalSummaryJson.value,
      );
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackEmotionAnalysisTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('representation: $representation, ')
          ..write('modelId: $modelId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('preprocessingVersion: $preprocessingVersion, ')
          ..write('contentRevision: $contentRevision, ')
          ..write('audioRevision: $audioRevision, ')
          ..write('valence: $valence, ')
          ..write('arousal: $arousal, ')
          ..write('rawValence: $rawValence, ')
          ..write('rawArousal: $rawArousal, ')
          ..write('moodDistributionVersion: $moodDistributionVersion, ')
          ..write('moodDistributionJson: $moodDistributionJson, ')
          ..write('temporalSummaryJson: $temporalSummaryJson, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackEmotionSegmentTableTable extends TrackEmotionSegmentTable
    with
        TableInfo<
          $TrackEmotionSegmentTableTable,
          TrackEmotionSegmentTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackEmotionSegmentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _analysisIdMeta = const VerificationMeta(
    'analysisId',
  );
  @override
  late final GeneratedColumn<String> analysisId = GeneratedColumn<String>(
    'analysis_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track_emotion_analysis_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _segmentIndexMeta = const VerificationMeta(
    'segmentIndex',
  );
  @override
  late final GeneratedColumn<int> segmentIndex = GeneratedColumn<int>(
    'segment_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valenceMeta = const VerificationMeta(
    'valence',
  );
  @override
  late final GeneratedColumn<double> valence = GeneratedColumn<double>(
    'valence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arousalMeta = const VerificationMeta(
    'arousal',
  );
  @override
  late final GeneratedColumn<double> arousal = GeneratedColumn<double>(
    'arousal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodDistributionVersionMeta =
      const VerificationMeta('moodDistributionVersion');
  @override
  late final GeneratedColumn<int> moodDistributionVersion =
      GeneratedColumn<int>(
        'mood_distribution_version',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      );
  static const VerificationMeta _moodDistributionJsonMeta =
      const VerificationMeta('moodDistributionJson');
  @override
  late final GeneratedColumn<String> moodDistributionJson =
      GeneratedColumn<String>(
        'mood_distribution_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    analysisId,
    segmentIndex,
    startMs,
    endMs,
    valence,
    arousal,
    moodDistributionVersion,
    moodDistributionJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_emotion_segment_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackEmotionSegmentTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('analysis_id')) {
      context.handle(
        _analysisIdMeta,
        analysisId.isAcceptableOrUnknown(data['analysis_id']!, _analysisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_analysisIdMeta);
    }
    if (data.containsKey('segment_index')) {
      context.handle(
        _segmentIndexMeta,
        segmentIndex.isAcceptableOrUnknown(
          data['segment_index']!,
          _segmentIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentIndexMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('valence')) {
      context.handle(
        _valenceMeta,
        valence.isAcceptableOrUnknown(data['valence']!, _valenceMeta),
      );
    } else if (isInserting) {
      context.missing(_valenceMeta);
    }
    if (data.containsKey('arousal')) {
      context.handle(
        _arousalMeta,
        arousal.isAcceptableOrUnknown(data['arousal']!, _arousalMeta),
      );
    } else if (isInserting) {
      context.missing(_arousalMeta);
    }
    if (data.containsKey('mood_distribution_version')) {
      context.handle(
        _moodDistributionVersionMeta,
        moodDistributionVersion.isAcceptableOrUnknown(
          data['mood_distribution_version']!,
          _moodDistributionVersionMeta,
        ),
      );
    }
    if (data.containsKey('mood_distribution_json')) {
      context.handle(
        _moodDistributionJsonMeta,
        moodDistributionJson.isAcceptableOrUnknown(
          data['mood_distribution_json']!,
          _moodDistributionJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_moodDistributionJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {analysisId, segmentIndex};
  @override
  TrackEmotionSegmentTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackEmotionSegmentTableData(
      analysisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_id'],
      )!,
      segmentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_index'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      valence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valence'],
      )!,
      arousal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arousal'],
      )!,
      moodDistributionVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood_distribution_version'],
      )!,
      moodDistributionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_distribution_json'],
      )!,
    );
  }

  @override
  $TrackEmotionSegmentTableTable createAlias(String alias) {
    return $TrackEmotionSegmentTableTable(attachedDatabase, alias);
  }
}

class TrackEmotionSegmentTableData extends DataClass
    implements Insertable<TrackEmotionSegmentTableData> {
  final String analysisId;
  final int segmentIndex;
  final int startMs;
  final int endMs;
  final double valence;
  final double arousal;
  final int moodDistributionVersion;
  final String moodDistributionJson;
  const TrackEmotionSegmentTableData({
    required this.analysisId,
    required this.segmentIndex,
    required this.startMs,
    required this.endMs,
    required this.valence,
    required this.arousal,
    required this.moodDistributionVersion,
    required this.moodDistributionJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['analysis_id'] = Variable<String>(analysisId);
    map['segment_index'] = Variable<int>(segmentIndex);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['valence'] = Variable<double>(valence);
    map['arousal'] = Variable<double>(arousal);
    map['mood_distribution_version'] = Variable<int>(moodDistributionVersion);
    map['mood_distribution_json'] = Variable<String>(moodDistributionJson);
    return map;
  }

  TrackEmotionSegmentTableCompanion toCompanion(bool nullToAbsent) {
    return TrackEmotionSegmentTableCompanion(
      analysisId: Value(analysisId),
      segmentIndex: Value(segmentIndex),
      startMs: Value(startMs),
      endMs: Value(endMs),
      valence: Value(valence),
      arousal: Value(arousal),
      moodDistributionVersion: Value(moodDistributionVersion),
      moodDistributionJson: Value(moodDistributionJson),
    );
  }

  factory TrackEmotionSegmentTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackEmotionSegmentTableData(
      analysisId: serializer.fromJson<String>(json['analysisId']),
      segmentIndex: serializer.fromJson<int>(json['segmentIndex']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      valence: serializer.fromJson<double>(json['valence']),
      arousal: serializer.fromJson<double>(json['arousal']),
      moodDistributionVersion: serializer.fromJson<int>(
        json['moodDistributionVersion'],
      ),
      moodDistributionJson: serializer.fromJson<String>(
        json['moodDistributionJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'analysisId': serializer.toJson<String>(analysisId),
      'segmentIndex': serializer.toJson<int>(segmentIndex),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'valence': serializer.toJson<double>(valence),
      'arousal': serializer.toJson<double>(arousal),
      'moodDistributionVersion': serializer.toJson<int>(
        moodDistributionVersion,
      ),
      'moodDistributionJson': serializer.toJson<String>(moodDistributionJson),
    };
  }

  TrackEmotionSegmentTableData copyWith({
    String? analysisId,
    int? segmentIndex,
    int? startMs,
    int? endMs,
    double? valence,
    double? arousal,
    int? moodDistributionVersion,
    String? moodDistributionJson,
  }) => TrackEmotionSegmentTableData(
    analysisId: analysisId ?? this.analysisId,
    segmentIndex: segmentIndex ?? this.segmentIndex,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    valence: valence ?? this.valence,
    arousal: arousal ?? this.arousal,
    moodDistributionVersion:
        moodDistributionVersion ?? this.moodDistributionVersion,
    moodDistributionJson: moodDistributionJson ?? this.moodDistributionJson,
  );
  TrackEmotionSegmentTableData copyWithCompanion(
    TrackEmotionSegmentTableCompanion data,
  ) {
    return TrackEmotionSegmentTableData(
      analysisId: data.analysisId.present
          ? data.analysisId.value
          : this.analysisId,
      segmentIndex: data.segmentIndex.present
          ? data.segmentIndex.value
          : this.segmentIndex,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      valence: data.valence.present ? data.valence.value : this.valence,
      arousal: data.arousal.present ? data.arousal.value : this.arousal,
      moodDistributionVersion: data.moodDistributionVersion.present
          ? data.moodDistributionVersion.value
          : this.moodDistributionVersion,
      moodDistributionJson: data.moodDistributionJson.present
          ? data.moodDistributionJson.value
          : this.moodDistributionJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackEmotionSegmentTableData(')
          ..write('analysisId: $analysisId, ')
          ..write('segmentIndex: $segmentIndex, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('valence: $valence, ')
          ..write('arousal: $arousal, ')
          ..write('moodDistributionVersion: $moodDistributionVersion, ')
          ..write('moodDistributionJson: $moodDistributionJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    analysisId,
    segmentIndex,
    startMs,
    endMs,
    valence,
    arousal,
    moodDistributionVersion,
    moodDistributionJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackEmotionSegmentTableData &&
          other.analysisId == this.analysisId &&
          other.segmentIndex == this.segmentIndex &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.valence == this.valence &&
          other.arousal == this.arousal &&
          other.moodDistributionVersion == this.moodDistributionVersion &&
          other.moodDistributionJson == this.moodDistributionJson);
}

class TrackEmotionSegmentTableCompanion
    extends UpdateCompanion<TrackEmotionSegmentTableData> {
  final Value<String> analysisId;
  final Value<int> segmentIndex;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<double> valence;
  final Value<double> arousal;
  final Value<int> moodDistributionVersion;
  final Value<String> moodDistributionJson;
  final Value<int> rowid;
  const TrackEmotionSegmentTableCompanion({
    this.analysisId = const Value.absent(),
    this.segmentIndex = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.valence = const Value.absent(),
    this.arousal = const Value.absent(),
    this.moodDistributionVersion = const Value.absent(),
    this.moodDistributionJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackEmotionSegmentTableCompanion.insert({
    required String analysisId,
    required int segmentIndex,
    required int startMs,
    required int endMs,
    required double valence,
    required double arousal,
    this.moodDistributionVersion = const Value.absent(),
    required String moodDistributionJson,
    this.rowid = const Value.absent(),
  }) : analysisId = Value(analysisId),
       segmentIndex = Value(segmentIndex),
       startMs = Value(startMs),
       endMs = Value(endMs),
       valence = Value(valence),
       arousal = Value(arousal),
       moodDistributionJson = Value(moodDistributionJson);
  static Insertable<TrackEmotionSegmentTableData> custom({
    Expression<String>? analysisId,
    Expression<int>? segmentIndex,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<double>? valence,
    Expression<double>? arousal,
    Expression<int>? moodDistributionVersion,
    Expression<String>? moodDistributionJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (analysisId != null) 'analysis_id': analysisId,
      if (segmentIndex != null) 'segment_index': segmentIndex,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (valence != null) 'valence': valence,
      if (arousal != null) 'arousal': arousal,
      if (moodDistributionVersion != null)
        'mood_distribution_version': moodDistributionVersion,
      if (moodDistributionJson != null)
        'mood_distribution_json': moodDistributionJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackEmotionSegmentTableCompanion copyWith({
    Value<String>? analysisId,
    Value<int>? segmentIndex,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<double>? valence,
    Value<double>? arousal,
    Value<int>? moodDistributionVersion,
    Value<String>? moodDistributionJson,
    Value<int>? rowid,
  }) {
    return TrackEmotionSegmentTableCompanion(
      analysisId: analysisId ?? this.analysisId,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      valence: valence ?? this.valence,
      arousal: arousal ?? this.arousal,
      moodDistributionVersion:
          moodDistributionVersion ?? this.moodDistributionVersion,
      moodDistributionJson: moodDistributionJson ?? this.moodDistributionJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (analysisId.present) {
      map['analysis_id'] = Variable<String>(analysisId.value);
    }
    if (segmentIndex.present) {
      map['segment_index'] = Variable<int>(segmentIndex.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (valence.present) {
      map['valence'] = Variable<double>(valence.value);
    }
    if (arousal.present) {
      map['arousal'] = Variable<double>(arousal.value);
    }
    if (moodDistributionVersion.present) {
      map['mood_distribution_version'] = Variable<int>(
        moodDistributionVersion.value,
      );
    }
    if (moodDistributionJson.present) {
      map['mood_distribution_json'] = Variable<String>(
        moodDistributionJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackEmotionSegmentTableCompanion(')
          ..write('analysisId: $analysisId, ')
          ..write('segmentIndex: $segmentIndex, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('valence: $valence, ')
          ..write('arousal: $arousal, ')
          ..write('moodDistributionVersion: $moodDistributionVersion, ')
          ..write('moodDistributionJson: $moodDistributionJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalMoodAdjustmentTableTable extends PersonalMoodAdjustmentTable
    with
        TableInfo<
          $PersonalMoodAdjustmentTableTable,
          PersonalMoodAdjustmentTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalMoodAdjustmentTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _valenceMeta = const VerificationMeta(
    'valence',
  );
  @override
  late final GeneratedColumn<double> valence = GeneratedColumn<double>(
    'valence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arousalMeta = const VerificationMeta(
    'arousal',
  );
  @override
  late final GeneratedColumn<double> arousal = GeneratedColumn<double>(
    'arousal',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  List<GeneratedColumn> get $columns => [trackId, valence, arousal, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_mood_adjustment_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalMoodAdjustmentTableData> instance, {
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
    if (data.containsKey('valence')) {
      context.handle(
        _valenceMeta,
        valence.isAcceptableOrUnknown(data['valence']!, _valenceMeta),
      );
    } else if (isInserting) {
      context.missing(_valenceMeta);
    }
    if (data.containsKey('arousal')) {
      context.handle(
        _arousalMeta,
        arousal.isAcceptableOrUnknown(data['arousal']!, _arousalMeta),
      );
    } else if (isInserting) {
      context.missing(_arousalMeta);
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
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  PersonalMoodAdjustmentTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalMoodAdjustmentTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      valence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valence'],
      )!,
      arousal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arousal'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PersonalMoodAdjustmentTableTable createAlias(String alias) {
    return $PersonalMoodAdjustmentTableTable(attachedDatabase, alias);
  }
}

class PersonalMoodAdjustmentTableData extends DataClass
    implements Insertable<PersonalMoodAdjustmentTableData> {
  final String trackId;
  final double valence;
  final double arousal;
  final DateTime updatedAt;
  const PersonalMoodAdjustmentTableData({
    required this.trackId,
    required this.valence,
    required this.arousal,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['valence'] = Variable<double>(valence);
    map['arousal'] = Variable<double>(arousal);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PersonalMoodAdjustmentTableCompanion toCompanion(bool nullToAbsent) {
    return PersonalMoodAdjustmentTableCompanion(
      trackId: Value(trackId),
      valence: Value(valence),
      arousal: Value(arousal),
      updatedAt: Value(updatedAt),
    );
  }

  factory PersonalMoodAdjustmentTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalMoodAdjustmentTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      valence: serializer.fromJson<double>(json['valence']),
      arousal: serializer.fromJson<double>(json['arousal']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'valence': serializer.toJson<double>(valence),
      'arousal': serializer.toJson<double>(arousal),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PersonalMoodAdjustmentTableData copyWith({
    String? trackId,
    double? valence,
    double? arousal,
    DateTime? updatedAt,
  }) => PersonalMoodAdjustmentTableData(
    trackId: trackId ?? this.trackId,
    valence: valence ?? this.valence,
    arousal: arousal ?? this.arousal,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PersonalMoodAdjustmentTableData copyWithCompanion(
    PersonalMoodAdjustmentTableCompanion data,
  ) {
    return PersonalMoodAdjustmentTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      valence: data.valence.present ? data.valence.value : this.valence,
      arousal: data.arousal.present ? data.arousal.value : this.arousal,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalMoodAdjustmentTableData(')
          ..write('trackId: $trackId, ')
          ..write('valence: $valence, ')
          ..write('arousal: $arousal, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, valence, arousal, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalMoodAdjustmentTableData &&
          other.trackId == this.trackId &&
          other.valence == this.valence &&
          other.arousal == this.arousal &&
          other.updatedAt == this.updatedAt);
}

class PersonalMoodAdjustmentTableCompanion
    extends UpdateCompanion<PersonalMoodAdjustmentTableData> {
  final Value<String> trackId;
  final Value<double> valence;
  final Value<double> arousal;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PersonalMoodAdjustmentTableCompanion({
    this.trackId = const Value.absent(),
    this.valence = const Value.absent(),
    this.arousal = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalMoodAdjustmentTableCompanion.insert({
    required String trackId,
    required double valence,
    required double arousal,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       valence = Value(valence),
       arousal = Value(arousal),
       updatedAt = Value(updatedAt);
  static Insertable<PersonalMoodAdjustmentTableData> custom({
    Expression<String>? trackId,
    Expression<double>? valence,
    Expression<double>? arousal,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (valence != null) 'valence': valence,
      if (arousal != null) 'arousal': arousal,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalMoodAdjustmentTableCompanion copyWith({
    Value<String>? trackId,
    Value<double>? valence,
    Value<double>? arousal,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PersonalMoodAdjustmentTableCompanion(
      trackId: trackId ?? this.trackId,
      valence: valence ?? this.valence,
      arousal: arousal ?? this.arousal,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (valence.present) {
      map['valence'] = Variable<double>(valence.value);
    }
    if (arousal.present) {
      map['arousal'] = Variable<double>(arousal.value);
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
    return (StringBuffer('PersonalMoodAdjustmentTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('valence: $valence, ')
          ..write('arousal: $arousal, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ListeningSummaryTableTable listeningSummaryTable =
      $ListeningSummaryTableTable(this);
  late final $PlaylistTableTable playlistTable = $PlaylistTableTable(this);
  late final $TrackTableTable trackTable = $TrackTableTable(this);
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
  late final $TrackEmbeddingTableTable trackEmbeddingTable =
      $TrackEmbeddingTableTable(this);
  late final $ListeningEventTableTable listeningEventTable =
      $ListeningEventTableTable(this);
  late final $TrackTemporalEmbeddingTableTable trackTemporalEmbeddingTable =
      $TrackTemporalEmbeddingTableTable(this);
  late final $TrackTemporalEmbeddingSegmentTableTable
  trackTemporalEmbeddingSegmentTable = $TrackTemporalEmbeddingSegmentTableTable(
    this,
  );
  late final $MusicAnalysisTaskTableTable musicAnalysisTaskTable =
      $MusicAnalysisTaskTableTable(this);
  late final $MusicAnalysisSettingsTableTable musicAnalysisSettingsTable =
      $MusicAnalysisSettingsTableTable(this);
  late final $SimilarityEvaluationTableTable similarityEvaluationTable =
      $SimilarityEvaluationTableTable(this);
  late final $TrackLyricsTableTable trackLyricsTable = $TrackLyricsTableTable(
    this,
  );
  late final $LyricsResolutionStateTableTable lyricsResolutionStateTable =
      $LyricsResolutionStateTableTable(this);
  late final $LyricsResolutionTaskTableTable lyricsResolutionTaskTable =
      $LyricsResolutionTaskTableTable(this);
  late final $TrackEmotionAnalysisTableTable trackEmotionAnalysisTable =
      $TrackEmotionAnalysisTableTable(this);
  late final $TrackEmotionSegmentTableTable trackEmotionSegmentTable =
      $TrackEmotionSegmentTableTable(this);
  late final $PersonalMoodAdjustmentTableTable personalMoodAdjustmentTable =
      $PersonalMoodAdjustmentTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    listeningSummaryTable,
    playlistTable,
    trackTable,
    downloadTaskTable,
    artistTable,
    trackArtistTable,
    playlistTrackTable,
    fileCleanupTaskTable,
    listeningCheckpointTable,
    playbackSessionTable,
    playbackQueueItemTable,
    appNavigationStateTable,
    trackEmbeddingTable,
    listeningEventTable,
    trackTemporalEmbeddingTable,
    trackTemporalEmbeddingSegmentTable,
    musicAnalysisTaskTable,
    musicAnalysisSettingsTable,
    similarityEvaluationTable,
    trackLyricsTable,
    lyricsResolutionStateTable,
    lyricsResolutionTaskTable,
    trackEmotionAnalysisTable,
    trackEmotionSegmentTable,
    personalMoodAdjustmentTable,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_embedding_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('track_temporal_embedding_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_temporal_embedding_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate(
          'track_temporal_embedding_segment_table',
          kind: UpdateKind.delete,
        ),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('music_analysis_task_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('similarity_evaluation_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('similarity_evaluation_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_lyrics_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('lyrics_resolution_state_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('lyrics_resolution_task_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('track_emotion_analysis_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_emotion_analysis_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('track_emotion_segment_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('personal_mood_adjustment_table', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$ListeningSummaryTableTableCreateCompanionBuilder =
    ListeningSummaryTableCompanion Function({
      required String id,
      required String trackId,
      required String trackTitle,
      required String artistName,
      required String sourceType,
      required int listenedDurationMilliseconds,
      required DateTime playedAt,
      Value<int> rowid,
    });
typedef $$ListeningSummaryTableTableUpdateCompanionBuilder =
    ListeningSummaryTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> trackTitle,
      Value<String> artistName,
      Value<String> sourceType,
      Value<int> listenedDurationMilliseconds,
      Value<DateTime> playedAt,
      Value<int> rowid,
    });

class $$ListeningSummaryTableTableFilterComposer
    extends Composer<_$AppDatabase, $ListeningSummaryTableTable> {
  $$ListeningSummaryTableTableFilterComposer({
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

class $$ListeningSummaryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ListeningSummaryTableTable> {
  $$ListeningSummaryTableTableOrderingComposer({
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

class $$ListeningSummaryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListeningSummaryTableTable> {
  $$ListeningSummaryTableTableAnnotationComposer({
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

class $$ListeningSummaryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListeningSummaryTableTable,
          ListeningSummaryTableData,
          $$ListeningSummaryTableTableFilterComposer,
          $$ListeningSummaryTableTableOrderingComposer,
          $$ListeningSummaryTableTableAnnotationComposer,
          $$ListeningSummaryTableTableCreateCompanionBuilder,
          $$ListeningSummaryTableTableUpdateCompanionBuilder,
          (
            ListeningSummaryTableData,
            BaseReferences<
              _$AppDatabase,
              $ListeningSummaryTableTable,
              ListeningSummaryTableData
            >,
          ),
          ListeningSummaryTableData,
          PrefetchHooks Function()
        > {
  $$ListeningSummaryTableTableTableManager(
    _$AppDatabase db,
    $ListeningSummaryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningSummaryTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ListeningSummaryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ListeningSummaryTableTableAnnotationComposer(
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
                Value<int> listenedDurationMilliseconds = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListeningSummaryTableCompanion(
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
              }) => ListeningSummaryTableCompanion.insert(
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

typedef $$ListeningSummaryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListeningSummaryTableTable,
      ListeningSummaryTableData,
      $$ListeningSummaryTableTableFilterComposer,
      $$ListeningSummaryTableTableOrderingComposer,
      $$ListeningSummaryTableTableAnnotationComposer,
      $$ListeningSummaryTableTableCreateCompanionBuilder,
      $$ListeningSummaryTableTableUpdateCompanionBuilder,
      (
        ListeningSummaryTableData,
        BaseReferences<
          _$AppDatabase,
          $ListeningSummaryTableTable,
          ListeningSummaryTableData
        >,
      ),
      ListeningSummaryTableData,
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
      Value<String?> contentIdentity,
      required String title,
      Value<String?> pathToFile,
      Value<int?> durationMs,
      required String sourceType,
      required String sourceUri,
      Value<DateTime?> addedAt,
      Value<String?> album,
      Value<String?> imageUrl,
      Value<String?> trackDescriptorJson,
      Value<int> audioRevision,
      Value<int> metadataRevision,
      Value<int> rowid,
    });
typedef $$TrackTableTableUpdateCompanionBuilder =
    TrackTableCompanion Function({
      Value<String> id,
      Value<String?> contentIdentity,
      Value<String> title,
      Value<String?> pathToFile,
      Value<int?> durationMs,
      Value<String> sourceType,
      Value<String> sourceUri,
      Value<DateTime?> addedAt,
      Value<String?> album,
      Value<String?> imageUrl,
      Value<String?> trackDescriptorJson,
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

  static MultiTypedResultKey<
    $TrackEmbeddingTableTable,
    List<TrackEmbeddingTableData>
  >
  _trackEmbeddingTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackEmbeddingTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.trackEmbeddingTable.trackId,
        ),
      );

  $$TrackEmbeddingTableTableProcessedTableManager get trackEmbeddingTableRefs {
    final manager = $$TrackEmbeddingTableTableTableManager(
      $_db,
      $_db.trackEmbeddingTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackEmbeddingTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TrackTemporalEmbeddingTableTable,
    List<TrackTemporalEmbeddingTableData>
  >
  _trackTemporalEmbeddingTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackTemporalEmbeddingTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.trackTemporalEmbeddingTable.trackId,
        ),
      );

  $$TrackTemporalEmbeddingTableTableProcessedTableManager
  get trackTemporalEmbeddingTableRefs {
    final manager = $$TrackTemporalEmbeddingTableTableTableManager(
      $_db,
      $_db.trackTemporalEmbeddingTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackTemporalEmbeddingTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MusicAnalysisTaskTableTable,
    List<MusicAnalysisTaskTableData>
  >
  _musicAnalysisTaskTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.musicAnalysisTaskTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.musicAnalysisTaskTable.trackId,
        ),
      );

  $$MusicAnalysisTaskTableTableProcessedTableManager
  get musicAnalysisTaskTableRefs {
    final manager = $$MusicAnalysisTaskTableTableTableManager(
      $_db,
      $_db.musicAnalysisTaskTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _musicAnalysisTaskTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SimilarityEvaluationTableTable,
    List<SimilarityEvaluationTableData>
  >
  _seedSimilarityEvaluationsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.similarityEvaluationTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.similarityEvaluationTable.seedTrackId,
        ),
      );

  $$SimilarityEvaluationTableTableProcessedTableManager
  get seedSimilarityEvaluations {
    final manager = $$SimilarityEvaluationTableTableTableManager(
      $_db,
      $_db.similarityEvaluationTable,
    ).filter((f) => f.seedTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _seedSimilarityEvaluationsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SimilarityEvaluationTableTable,
    List<SimilarityEvaluationTableData>
  >
  _candidateSimilarityEvaluationsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.similarityEvaluationTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.similarityEvaluationTable.candidateTrackId,
        ),
      );

  $$SimilarityEvaluationTableTableProcessedTableManager
  get candidateSimilarityEvaluations {
    final manager =
        $$SimilarityEvaluationTableTableTableManager(
          $_db,
          $_db.similarityEvaluationTable,
        ).filter(
          (f) => f.candidateTrackId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _candidateSimilarityEvaluationsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrackLyricsTableTable, List<TrackLyricsTableData>>
  _trackLyricsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackLyricsTable,
    aliasName: $_aliasNameGenerator(
      db.trackTable.id,
      db.trackLyricsTable.trackId,
    ),
  );

  $$TrackLyricsTableTableProcessedTableManager get trackLyricsTableRefs {
    final manager = $$TrackLyricsTableTableTableManager(
      $_db,
      $_db.trackLyricsTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackLyricsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LyricsResolutionStateTableTable,
    List<LyricsResolutionStateTableData>
  >
  _lyricsResolutionStateTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lyricsResolutionStateTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.lyricsResolutionStateTable.trackId,
        ),
      );

  $$LyricsResolutionStateTableTableProcessedTableManager
  get lyricsResolutionStateTableRefs {
    final manager = $$LyricsResolutionStateTableTableTableManager(
      $_db,
      $_db.lyricsResolutionStateTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lyricsResolutionStateTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LyricsResolutionTaskTableTable,
    List<LyricsResolutionTaskTableData>
  >
  _lyricsResolutionTaskTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lyricsResolutionTaskTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.lyricsResolutionTaskTable.trackId,
        ),
      );

  $$LyricsResolutionTaskTableTableProcessedTableManager
  get lyricsResolutionTaskTableRefs {
    final manager = $$LyricsResolutionTaskTableTableTableManager(
      $_db,
      $_db.lyricsResolutionTaskTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lyricsResolutionTaskTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TrackEmotionAnalysisTableTable,
    List<TrackEmotionAnalysisTableData>
  >
  _trackEmotionAnalysisTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackEmotionAnalysisTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.trackEmotionAnalysisTable.trackId,
        ),
      );

  $$TrackEmotionAnalysisTableTableProcessedTableManager
  get trackEmotionAnalysisTableRefs {
    final manager = $$TrackEmotionAnalysisTableTableTableManager(
      $_db,
      $_db.trackEmotionAnalysisTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackEmotionAnalysisTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PersonalMoodAdjustmentTableTable,
    List<PersonalMoodAdjustmentTableData>
  >
  _personalMoodAdjustmentTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.personalMoodAdjustmentTable,
        aliasName: $_aliasNameGenerator(
          db.trackTable.id,
          db.personalMoodAdjustmentTable.trackId,
        ),
      );

  $$PersonalMoodAdjustmentTableTableProcessedTableManager
  get personalMoodAdjustmentTableRefs {
    final manager = $$PersonalMoodAdjustmentTableTableTableManager(
      $_db,
      $_db.personalMoodAdjustmentTable,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalMoodAdjustmentTableRefsTable($_db),
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

  ColumnFilters<String> get contentIdentity => $composableBuilder(
    column: $table.contentIdentity,
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

  Expression<bool> trackEmbeddingTableRefs(
    Expression<bool> Function($$TrackEmbeddingTableTableFilterComposer f) f,
  ) {
    final $$TrackEmbeddingTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackEmbeddingTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackEmbeddingTableTableFilterComposer(
            $db: $db,
            $table: $db.trackEmbeddingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackTemporalEmbeddingTableRefs(
    Expression<bool> Function(
      $$TrackTemporalEmbeddingTableTableFilterComposer f,
    )
    f,
  ) {
    final $$TrackTemporalEmbeddingTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackTemporalEmbeddingTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackTemporalEmbeddingTableTableFilterComposer(
                $db: $db,
                $table: $db.trackTemporalEmbeddingTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> musicAnalysisTaskTableRefs(
    Expression<bool> Function($$MusicAnalysisTaskTableTableFilterComposer f) f,
  ) {
    final $$MusicAnalysisTaskTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.musicAnalysisTaskTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MusicAnalysisTaskTableTableFilterComposer(
                $db: $db,
                $table: $db.musicAnalysisTaskTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> seedSimilarityEvaluations(
    Expression<bool> Function($$SimilarityEvaluationTableTableFilterComposer f)
    f,
  ) {
    final $$SimilarityEvaluationTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.similarityEvaluationTable,
          getReferencedColumn: (t) => t.seedTrackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimilarityEvaluationTableTableFilterComposer(
                $db: $db,
                $table: $db.similarityEvaluationTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> candidateSimilarityEvaluations(
    Expression<bool> Function($$SimilarityEvaluationTableTableFilterComposer f)
    f,
  ) {
    final $$SimilarityEvaluationTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.similarityEvaluationTable,
          getReferencedColumn: (t) => t.candidateTrackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimilarityEvaluationTableTableFilterComposer(
                $db: $db,
                $table: $db.similarityEvaluationTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> trackLyricsTableRefs(
    Expression<bool> Function($$TrackLyricsTableTableFilterComposer f) f,
  ) {
    final $$TrackLyricsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackLyricsTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackLyricsTableTableFilterComposer(
            $db: $db,
            $table: $db.trackLyricsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lyricsResolutionStateTableRefs(
    Expression<bool> Function($$LyricsResolutionStateTableTableFilterComposer f)
    f,
  ) {
    final $$LyricsResolutionStateTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.lyricsResolutionStateTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LyricsResolutionStateTableTableFilterComposer(
                $db: $db,
                $table: $db.lyricsResolutionStateTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> lyricsResolutionTaskTableRefs(
    Expression<bool> Function($$LyricsResolutionTaskTableTableFilterComposer f)
    f,
  ) {
    final $$LyricsResolutionTaskTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.lyricsResolutionTaskTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LyricsResolutionTaskTableTableFilterComposer(
                $db: $db,
                $table: $db.lyricsResolutionTaskTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> trackEmotionAnalysisTableRefs(
    Expression<bool> Function($$TrackEmotionAnalysisTableTableFilterComposer f)
    f,
  ) {
    final $$TrackEmotionAnalysisTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackEmotionAnalysisTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackEmotionAnalysisTableTableFilterComposer(
                $db: $db,
                $table: $db.trackEmotionAnalysisTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> personalMoodAdjustmentTableRefs(
    Expression<bool> Function(
      $$PersonalMoodAdjustmentTableTableFilterComposer f,
    )
    f,
  ) {
    final $$PersonalMoodAdjustmentTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personalMoodAdjustmentTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonalMoodAdjustmentTableTableFilterComposer(
                $db: $db,
                $table: $db.personalMoodAdjustmentTable,
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

  ColumnOrderings<String> get contentIdentity => $composableBuilder(
    column: $table.contentIdentity,
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

  GeneratedColumn<String> get contentIdentity => $composableBuilder(
    column: $table.contentIdentity,
    builder: (column) => column,
  );

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

  Expression<T> trackEmbeddingTableRefs<T extends Object>(
    Expression<T> Function($$TrackEmbeddingTableTableAnnotationComposer a) f,
  ) {
    final $$TrackEmbeddingTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackEmbeddingTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackEmbeddingTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackEmbeddingTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> trackTemporalEmbeddingTableRefs<T extends Object>(
    Expression<T> Function(
      $$TrackTemporalEmbeddingTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$TrackTemporalEmbeddingTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackTemporalEmbeddingTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackTemporalEmbeddingTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackTemporalEmbeddingTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> musicAnalysisTaskTableRefs<T extends Object>(
    Expression<T> Function($$MusicAnalysisTaskTableTableAnnotationComposer a) f,
  ) {
    final $$MusicAnalysisTaskTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.musicAnalysisTaskTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MusicAnalysisTaskTableTableAnnotationComposer(
                $db: $db,
                $table: $db.musicAnalysisTaskTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> seedSimilarityEvaluations<T extends Object>(
    Expression<T> Function($$SimilarityEvaluationTableTableAnnotationComposer a)
    f,
  ) {
    final $$SimilarityEvaluationTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.similarityEvaluationTable,
          getReferencedColumn: (t) => t.seedTrackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimilarityEvaluationTableTableAnnotationComposer(
                $db: $db,
                $table: $db.similarityEvaluationTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> candidateSimilarityEvaluations<T extends Object>(
    Expression<T> Function($$SimilarityEvaluationTableTableAnnotationComposer a)
    f,
  ) {
    final $$SimilarityEvaluationTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.similarityEvaluationTable,
          getReferencedColumn: (t) => t.candidateTrackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimilarityEvaluationTableTableAnnotationComposer(
                $db: $db,
                $table: $db.similarityEvaluationTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> trackLyricsTableRefs<T extends Object>(
    Expression<T> Function($$TrackLyricsTableTableAnnotationComposer a) f,
  ) {
    final $$TrackLyricsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackLyricsTable,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackLyricsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.trackLyricsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lyricsResolutionStateTableRefs<T extends Object>(
    Expression<T> Function(
      $$LyricsResolutionStateTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$LyricsResolutionStateTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.lyricsResolutionStateTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LyricsResolutionStateTableTableAnnotationComposer(
                $db: $db,
                $table: $db.lyricsResolutionStateTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> lyricsResolutionTaskTableRefs<T extends Object>(
    Expression<T> Function($$LyricsResolutionTaskTableTableAnnotationComposer a)
    f,
  ) {
    final $$LyricsResolutionTaskTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.lyricsResolutionTaskTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LyricsResolutionTaskTableTableAnnotationComposer(
                $db: $db,
                $table: $db.lyricsResolutionTaskTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> trackEmotionAnalysisTableRefs<T extends Object>(
    Expression<T> Function($$TrackEmotionAnalysisTableTableAnnotationComposer a)
    f,
  ) {
    final $$TrackEmotionAnalysisTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackEmotionAnalysisTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackEmotionAnalysisTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackEmotionAnalysisTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> personalMoodAdjustmentTableRefs<T extends Object>(
    Expression<T> Function(
      $$PersonalMoodAdjustmentTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$PersonalMoodAdjustmentTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personalMoodAdjustmentTable,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonalMoodAdjustmentTableTableAnnotationComposer(
                $db: $db,
                $table: $db.personalMoodAdjustmentTable,
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
            bool trackEmbeddingTableRefs,
            bool trackTemporalEmbeddingTableRefs,
            bool musicAnalysisTaskTableRefs,
            bool seedSimilarityEvaluations,
            bool candidateSimilarityEvaluations,
            bool trackLyricsTableRefs,
            bool lyricsResolutionStateTableRefs,
            bool lyricsResolutionTaskTableRefs,
            bool trackEmotionAnalysisTableRefs,
            bool personalMoodAdjustmentTableRefs,
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
                Value<String?> contentIdentity = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> pathToFile = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceUri = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> trackDescriptorJson = const Value.absent(),
                Value<int> audioRevision = const Value.absent(),
                Value<int> metadataRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackTableCompanion(
                id: id,
                contentIdentity: contentIdentity,
                title: title,
                pathToFile: pathToFile,
                durationMs: durationMs,
                sourceType: sourceType,
                sourceUri: sourceUri,
                addedAt: addedAt,
                album: album,
                imageUrl: imageUrl,
                trackDescriptorJson: trackDescriptorJson,
                audioRevision: audioRevision,
                metadataRevision: metadataRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> contentIdentity = const Value.absent(),
                required String title,
                Value<String?> pathToFile = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required String sourceType,
                required String sourceUri,
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> trackDescriptorJson = const Value.absent(),
                Value<int> audioRevision = const Value.absent(),
                Value<int> metadataRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackTableCompanion.insert(
                id: id,
                contentIdentity: contentIdentity,
                title: title,
                pathToFile: pathToFile,
                durationMs: durationMs,
                sourceType: sourceType,
                sourceUri: sourceUri,
                addedAt: addedAt,
                album: album,
                imageUrl: imageUrl,
                trackDescriptorJson: trackDescriptorJson,
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
                trackEmbeddingTableRefs = false,
                trackTemporalEmbeddingTableRefs = false,
                musicAnalysisTaskTableRefs = false,
                seedSimilarityEvaluations = false,
                candidateSimilarityEvaluations = false,
                trackLyricsTableRefs = false,
                lyricsResolutionStateTableRefs = false,
                lyricsResolutionTaskTableRefs = false,
                trackEmotionAnalysisTableRefs = false,
                personalMoodAdjustmentTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackArtistTableRefs) db.trackArtistTable,
                    if (playlistTrackTableRefs) db.playlistTrackTable,
                    if (playbackSessionTableRefs) db.playbackSessionTable,
                    if (playbackQueueItemTableRefs) db.playbackQueueItemTable,
                    if (trackEmbeddingTableRefs) db.trackEmbeddingTable,
                    if (trackTemporalEmbeddingTableRefs)
                      db.trackTemporalEmbeddingTable,
                    if (musicAnalysisTaskTableRefs) db.musicAnalysisTaskTable,
                    if (seedSimilarityEvaluations) db.similarityEvaluationTable,
                    if (candidateSimilarityEvaluations)
                      db.similarityEvaluationTable,
                    if (trackLyricsTableRefs) db.trackLyricsTable,
                    if (lyricsResolutionStateTableRefs)
                      db.lyricsResolutionStateTable,
                    if (lyricsResolutionTaskTableRefs)
                      db.lyricsResolutionTaskTable,
                    if (trackEmotionAnalysisTableRefs)
                      db.trackEmotionAnalysisTable,
                    if (personalMoodAdjustmentTableRefs)
                      db.personalMoodAdjustmentTable,
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
                      if (trackEmbeddingTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          TrackEmbeddingTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._trackEmbeddingTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackEmbeddingTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackTemporalEmbeddingTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          TrackTemporalEmbeddingTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._trackTemporalEmbeddingTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackTemporalEmbeddingTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (musicAnalysisTaskTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          MusicAnalysisTaskTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._musicAnalysisTaskTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).musicAnalysisTaskTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (seedSimilarityEvaluations)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          SimilarityEvaluationTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._seedSimilarityEvaluationsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).seedSimilarityEvaluations,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seedTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (candidateSimilarityEvaluations)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          SimilarityEvaluationTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._candidateSimilarityEvaluationsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).candidateSimilarityEvaluations,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.candidateTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackLyricsTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          TrackLyricsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._trackLyricsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackLyricsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lyricsResolutionStateTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          LyricsResolutionStateTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._lyricsResolutionStateTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).lyricsResolutionStateTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lyricsResolutionTaskTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          LyricsResolutionTaskTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._lyricsResolutionTaskTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).lyricsResolutionTaskTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackEmotionAnalysisTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          TrackEmotionAnalysisTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._trackEmotionAnalysisTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackEmotionAnalysisTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalMoodAdjustmentTableRefs)
                        await $_getPrefetchedData<
                          TrackTableData,
                          $TrackTableTable,
                          PersonalMoodAdjustmentTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackTableTableReferences
                              ._personalMoodAdjustmentTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackTableTableReferences(
                                db,
                                table,
                                p0,
                              ).personalMoodAdjustmentTableRefs,
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
        bool trackEmbeddingTableRefs,
        bool trackTemporalEmbeddingTableRefs,
        bool musicAnalysisTaskTableRefs,
        bool seedSimilarityEvaluations,
        bool candidateSimilarityEvaluations,
        bool trackLyricsTableRefs,
        bool lyricsResolutionStateTableRefs,
        bool lyricsResolutionTaskTableRefs,
        bool trackEmotionAnalysisTableRefs,
        bool personalMoodAdjustmentTableRefs,
      })
    >;
typedef $$DownloadTaskTableTableCreateCompanionBuilder =
    DownloadTaskTableCompanion Function({
      required String trackId,
      required String originalUrl,
      required String status,
      required DateTime createdAt,
      Value<String?> leaseOwner,
      Value<DateTime?> leaseUntil,
      Value<String?> failureCode,
      Value<String?> failureMessage,
      Value<String?> failureDetails,
      Value<DateTime?> failedAt,
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
      Value<String?> failureCode,
      Value<String?> failureMessage,
      Value<String?> failureDetails,
      Value<DateTime?> failedAt,
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

  ColumnFilters<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureMessage => $composableBuilder(
    column: $table.failureMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureDetails => $composableBuilder(
    column: $table.failureDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get failedAt => $composableBuilder(
    column: $table.failedAt,
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

  ColumnOrderings<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureMessage => $composableBuilder(
    column: $table.failureMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureDetails => $composableBuilder(
    column: $table.failureDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get failedAt => $composableBuilder(
    column: $table.failedAt,
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

  GeneratedColumn<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureMessage => $composableBuilder(
    column: $table.failureMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureDetails => $composableBuilder(
    column: $table.failureDetails,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get failedAt =>
      $composableBuilder(column: $table.failedAt, builder: (column) => column);
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
                Value<String?> failureCode = const Value.absent(),
                Value<String?> failureMessage = const Value.absent(),
                Value<String?> failureDetails = const Value.absent(),
                Value<DateTime?> failedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTaskTableCompanion(
                trackId: trackId,
                originalUrl: originalUrl,
                status: status,
                createdAt: createdAt,
                leaseOwner: leaseOwner,
                leaseUntil: leaseUntil,
                failureCode: failureCode,
                failureMessage: failureMessage,
                failureDetails: failureDetails,
                failedAt: failedAt,
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
                Value<String?> failureCode = const Value.absent(),
                Value<String?> failureMessage = const Value.absent(),
                Value<String?> failureDetails = const Value.absent(),
                Value<DateTime?> failedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTaskTableCompanion.insert(
                trackId: trackId,
                originalUrl: originalUrl,
                status: status,
                createdAt: createdAt,
                leaseOwner: leaseOwner,
                leaseUntil: leaseUntil,
                failureCode: failureCode,
                failureMessage: failureMessage,
                failureDetails: failureDetails,
                failedAt: failedAt,
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
typedef $$TrackEmbeddingTableTableCreateCompanionBuilder =
    TrackEmbeddingTableCompanion Function({
      required String trackId,
      required String modality,
      required String modelId,
      required String modelVersion,
      Value<String> preprocessingVersion,
      required String provider,
      Value<int?> audioRevision,
      Value<String?> contentRevision,
      Value<String> dtype,
      Value<bool?> normalized,
      required int dimensions,
      required Uint8List vector,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TrackEmbeddingTableTableUpdateCompanionBuilder =
    TrackEmbeddingTableCompanion Function({
      Value<String> trackId,
      Value<String> modality,
      Value<String> modelId,
      Value<String> modelVersion,
      Value<String> preprocessingVersion,
      Value<String> provider,
      Value<int?> audioRevision,
      Value<String?> contentRevision,
      Value<String> dtype,
      Value<bool?> normalized,
      Value<int> dimensions,
      Value<Uint8List> vector,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TrackEmbeddingTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackEmbeddingTableTable,
          TrackEmbeddingTableData
        > {
  $$TrackEmbeddingTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(db.trackEmbeddingTable.trackId, db.trackTable.id),
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

class $$TrackEmbeddingTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackEmbeddingTableTable> {
  $$TrackEmbeddingTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preprocessingVersion => $composableBuilder(
    column: $table.preprocessingVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentRevision => $composableBuilder(
    column: $table.contentRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dtype => $composableBuilder(
    column: $table.dtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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
}

class $$TrackEmbeddingTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackEmbeddingTableTable> {
  $$TrackEmbeddingTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preprocessingVersion => $composableBuilder(
    column: $table.preprocessingVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentRevision => $composableBuilder(
    column: $table.contentRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dtype => $composableBuilder(
    column: $table.dtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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
}

class $$TrackEmbeddingTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackEmbeddingTableTable> {
  $$TrackEmbeddingTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get modality =>
      $composableBuilder(column: $table.modality, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preprocessingVersion => $composableBuilder(
    column: $table.preprocessingVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentRevision => $composableBuilder(
    column: $table.contentRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dtype =>
      $composableBuilder(column: $table.dtype, builder: (column) => column);

  GeneratedColumn<bool> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

class $$TrackEmbeddingTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackEmbeddingTableTable,
          TrackEmbeddingTableData,
          $$TrackEmbeddingTableTableFilterComposer,
          $$TrackEmbeddingTableTableOrderingComposer,
          $$TrackEmbeddingTableTableAnnotationComposer,
          $$TrackEmbeddingTableTableCreateCompanionBuilder,
          $$TrackEmbeddingTableTableUpdateCompanionBuilder,
          (TrackEmbeddingTableData, $$TrackEmbeddingTableTableReferences),
          TrackEmbeddingTableData,
          PrefetchHooks Function({bool trackId})
        > {
  $$TrackEmbeddingTableTableTableManager(
    _$AppDatabase db,
    $TrackEmbeddingTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackEmbeddingTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackEmbeddingTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackEmbeddingTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> modality = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> preprocessingVersion = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<int?> audioRevision = const Value.absent(),
                Value<String?> contentRevision = const Value.absent(),
                Value<String> dtype = const Value.absent(),
                Value<bool?> normalized = const Value.absent(),
                Value<int> dimensions = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackEmbeddingTableCompanion(
                trackId: trackId,
                modality: modality,
                modelId: modelId,
                modelVersion: modelVersion,
                preprocessingVersion: preprocessingVersion,
                provider: provider,
                audioRevision: audioRevision,
                contentRevision: contentRevision,
                dtype: dtype,
                normalized: normalized,
                dimensions: dimensions,
                vector: vector,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String modality,
                required String modelId,
                required String modelVersion,
                Value<String> preprocessingVersion = const Value.absent(),
                required String provider,
                Value<int?> audioRevision = const Value.absent(),
                Value<String?> contentRevision = const Value.absent(),
                Value<String> dtype = const Value.absent(),
                Value<bool?> normalized = const Value.absent(),
                required int dimensions,
                required Uint8List vector,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TrackEmbeddingTableCompanion.insert(
                trackId: trackId,
                modality: modality,
                modelId: modelId,
                modelVersion: modelVersion,
                preprocessingVersion: preprocessingVersion,
                provider: provider,
                audioRevision: audioRevision,
                contentRevision: contentRevision,
                dtype: dtype,
                normalized: normalized,
                dimensions: dimensions,
                vector: vector,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackEmbeddingTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
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
                                    $$TrackEmbeddingTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$TrackEmbeddingTableTableReferences
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

typedef $$TrackEmbeddingTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackEmbeddingTableTable,
      TrackEmbeddingTableData,
      $$TrackEmbeddingTableTableFilterComposer,
      $$TrackEmbeddingTableTableOrderingComposer,
      $$TrackEmbeddingTableTableAnnotationComposer,
      $$TrackEmbeddingTableTableCreateCompanionBuilder,
      $$TrackEmbeddingTableTableUpdateCompanionBuilder,
      (TrackEmbeddingTableData, $$TrackEmbeddingTableTableReferences),
      TrackEmbeddingTableData,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$ListeningEventTableTableCreateCompanionBuilder =
    ListeningEventTableCompanion Function({
      required String id,
      Value<String?> sessionId,
      required String trackId,
      required String type,
      required DateTime occurredAt,
      Value<int?> positionMs,
      Value<int?> listenedMs,
      Value<int?> durationMs,
      Value<String?> previousTrackId,
      Value<String?> transitionReason,
      Value<int> rowid,
    });
typedef $$ListeningEventTableTableUpdateCompanionBuilder =
    ListeningEventTableCompanion Function({
      Value<String> id,
      Value<String?> sessionId,
      Value<String> trackId,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<int?> positionMs,
      Value<int?> listenedMs,
      Value<int?> durationMs,
      Value<String?> previousTrackId,
      Value<String?> transitionReason,
      Value<int> rowid,
    });

class $$ListeningEventTableTableFilterComposer
    extends Composer<_$AppDatabase, $ListeningEventTableTable> {
  $$ListeningEventTableTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousTrackId => $composableBuilder(
    column: $table.previousTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transitionReason => $composableBuilder(
    column: $table.transitionReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ListeningEventTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ListeningEventTableTable> {
  $$ListeningEventTableTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousTrackId => $composableBuilder(
    column: $table.previousTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transitionReason => $composableBuilder(
    column: $table.transitionReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ListeningEventTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListeningEventTableTable> {
  $$ListeningEventTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousTrackId => $composableBuilder(
    column: $table.previousTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transitionReason => $composableBuilder(
    column: $table.transitionReason,
    builder: (column) => column,
  );
}

class $$ListeningEventTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListeningEventTableTable,
          ListeningEventTableData,
          $$ListeningEventTableTableFilterComposer,
          $$ListeningEventTableTableOrderingComposer,
          $$ListeningEventTableTableAnnotationComposer,
          $$ListeningEventTableTableCreateCompanionBuilder,
          $$ListeningEventTableTableUpdateCompanionBuilder,
          (
            ListeningEventTableData,
            BaseReferences<
              _$AppDatabase,
              $ListeningEventTableTable,
              ListeningEventTableData
            >,
          ),
          ListeningEventTableData,
          PrefetchHooks Function()
        > {
  $$ListeningEventTableTableTableManager(
    _$AppDatabase db,
    $ListeningEventTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningEventTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListeningEventTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ListeningEventTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int?> positionMs = const Value.absent(),
                Value<int?> listenedMs = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> previousTrackId = const Value.absent(),
                Value<String?> transitionReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListeningEventTableCompanion(
                id: id,
                sessionId: sessionId,
                trackId: trackId,
                type: type,
                occurredAt: occurredAt,
                positionMs: positionMs,
                listenedMs: listenedMs,
                durationMs: durationMs,
                previousTrackId: previousTrackId,
                transitionReason: transitionReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> sessionId = const Value.absent(),
                required String trackId,
                required String type,
                required DateTime occurredAt,
                Value<int?> positionMs = const Value.absent(),
                Value<int?> listenedMs = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> previousTrackId = const Value.absent(),
                Value<String?> transitionReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListeningEventTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                trackId: trackId,
                type: type,
                occurredAt: occurredAt,
                positionMs: positionMs,
                listenedMs: listenedMs,
                durationMs: durationMs,
                previousTrackId: previousTrackId,
                transitionReason: transitionReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ListeningEventTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListeningEventTableTable,
      ListeningEventTableData,
      $$ListeningEventTableTableFilterComposer,
      $$ListeningEventTableTableOrderingComposer,
      $$ListeningEventTableTableAnnotationComposer,
      $$ListeningEventTableTableCreateCompanionBuilder,
      $$ListeningEventTableTableUpdateCompanionBuilder,
      (
        ListeningEventTableData,
        BaseReferences<
          _$AppDatabase,
          $ListeningEventTableTable,
          ListeningEventTableData
        >,
      ),
      ListeningEventTableData,
      PrefetchHooks Function()
    >;
typedef $$TrackTemporalEmbeddingTableTableCreateCompanionBuilder =
    TrackTemporalEmbeddingTableCompanion Function({
      required String id,
      required String trackId,
      required String representation,
      required String modelId,
      required String modelVersion,
      required String preprocessingVersion,
      required String provider,
      required int audioRevision,
      required int dimension,
      required String dtype,
      required bool normalized,
      required DateTime createdAt,
      required int numberOfSegments,
      required double meanAdjacentDistance,
      required double maxAdjacentDistance,
      required double trajectoryVariance,
      Value<int?> largestTransitionIndex,
      Value<int> rowid,
    });
typedef $$TrackTemporalEmbeddingTableTableUpdateCompanionBuilder =
    TrackTemporalEmbeddingTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> representation,
      Value<String> modelId,
      Value<String> modelVersion,
      Value<String> preprocessingVersion,
      Value<String> provider,
      Value<int> audioRevision,
      Value<int> dimension,
      Value<String> dtype,
      Value<bool> normalized,
      Value<DateTime> createdAt,
      Value<int> numberOfSegments,
      Value<double> meanAdjacentDistance,
      Value<double> maxAdjacentDistance,
      Value<double> trajectoryVariance,
      Value<int?> largestTransitionIndex,
      Value<int> rowid,
    });

final class $$TrackTemporalEmbeddingTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackTemporalEmbeddingTableTable,
          TrackTemporalEmbeddingTableData
        > {
  $$TrackTemporalEmbeddingTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.trackTemporalEmbeddingTable.trackId,
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

  static MultiTypedResultKey<
    $TrackTemporalEmbeddingSegmentTableTable,
    List<TrackTemporalEmbeddingSegmentTableData>
  >
  _trackTemporalEmbeddingSegmentTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackTemporalEmbeddingSegmentTable,
        aliasName: $_aliasNameGenerator(
          db.trackTemporalEmbeddingTable.id,
          db.trackTemporalEmbeddingSegmentTable.temporalEmbeddingId,
        ),
      );

  $$TrackTemporalEmbeddingSegmentTableTableProcessedTableManager
  get trackTemporalEmbeddingSegmentTableRefs {
    final manager =
        $$TrackTemporalEmbeddingSegmentTableTableTableManager(
          $_db,
          $_db.trackTemporalEmbeddingSegmentTable,
        ).filter(
          (f) =>
              f.temporalEmbeddingId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _trackTemporalEmbeddingSegmentTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackTemporalEmbeddingTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackTemporalEmbeddingTableTable> {
  $$TrackTemporalEmbeddingTableTableFilterComposer({
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

  ColumnFilters<String> get representation => $composableBuilder(
    column: $table.representation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preprocessingVersion => $composableBuilder(
    column: $table.preprocessingVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dtype => $composableBuilder(
    column: $table.dtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberOfSegments => $composableBuilder(
    column: $table.numberOfSegments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanAdjacentDistance => $composableBuilder(
    column: $table.meanAdjacentDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxAdjacentDistance => $composableBuilder(
    column: $table.maxAdjacentDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get trajectoryVariance => $composableBuilder(
    column: $table.trajectoryVariance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get largestTransitionIndex => $composableBuilder(
    column: $table.largestTransitionIndex,
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

  Expression<bool> trackTemporalEmbeddingSegmentTableRefs(
    Expression<bool> Function(
      $$TrackTemporalEmbeddingSegmentTableTableFilterComposer f,
    )
    f,
  ) {
    final $$TrackTemporalEmbeddingSegmentTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackTemporalEmbeddingSegmentTable,
          getReferencedColumn: (t) => t.temporalEmbeddingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackTemporalEmbeddingSegmentTableTableFilterComposer(
                $db: $db,
                $table: $db.trackTemporalEmbeddingSegmentTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TrackTemporalEmbeddingTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackTemporalEmbeddingTableTable> {
  $$TrackTemporalEmbeddingTableTableOrderingComposer({
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

  ColumnOrderings<String> get representation => $composableBuilder(
    column: $table.representation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preprocessingVersion => $composableBuilder(
    column: $table.preprocessingVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dtype => $composableBuilder(
    column: $table.dtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberOfSegments => $composableBuilder(
    column: $table.numberOfSegments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanAdjacentDistance => $composableBuilder(
    column: $table.meanAdjacentDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxAdjacentDistance => $composableBuilder(
    column: $table.maxAdjacentDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get trajectoryVariance => $composableBuilder(
    column: $table.trajectoryVariance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get largestTransitionIndex => $composableBuilder(
    column: $table.largestTransitionIndex,
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
}

class $$TrackTemporalEmbeddingTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackTemporalEmbeddingTableTable> {
  $$TrackTemporalEmbeddingTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get representation => $composableBuilder(
    column: $table.representation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preprocessingVersion => $composableBuilder(
    column: $table.preprocessingVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dimension =>
      $composableBuilder(column: $table.dimension, builder: (column) => column);

  GeneratedColumn<String> get dtype =>
      $composableBuilder(column: $table.dtype, builder: (column) => column);

  GeneratedColumn<bool> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get numberOfSegments => $composableBuilder(
    column: $table.numberOfSegments,
    builder: (column) => column,
  );

  GeneratedColumn<double> get meanAdjacentDistance => $composableBuilder(
    column: $table.meanAdjacentDistance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxAdjacentDistance => $composableBuilder(
    column: $table.maxAdjacentDistance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get trajectoryVariance => $composableBuilder(
    column: $table.trajectoryVariance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get largestTransitionIndex => $composableBuilder(
    column: $table.largestTransitionIndex,
    builder: (column) => column,
  );

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

  Expression<T> trackTemporalEmbeddingSegmentTableRefs<T extends Object>(
    Expression<T> Function(
      $$TrackTemporalEmbeddingSegmentTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$TrackTemporalEmbeddingSegmentTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackTemporalEmbeddingSegmentTable,
          getReferencedColumn: (t) => t.temporalEmbeddingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackTemporalEmbeddingSegmentTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackTemporalEmbeddingSegmentTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TrackTemporalEmbeddingTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackTemporalEmbeddingTableTable,
          TrackTemporalEmbeddingTableData,
          $$TrackTemporalEmbeddingTableTableFilterComposer,
          $$TrackTemporalEmbeddingTableTableOrderingComposer,
          $$TrackTemporalEmbeddingTableTableAnnotationComposer,
          $$TrackTemporalEmbeddingTableTableCreateCompanionBuilder,
          $$TrackTemporalEmbeddingTableTableUpdateCompanionBuilder,
          (
            TrackTemporalEmbeddingTableData,
            $$TrackTemporalEmbeddingTableTableReferences,
          ),
          TrackTemporalEmbeddingTableData,
          PrefetchHooks Function({
            bool trackId,
            bool trackTemporalEmbeddingSegmentTableRefs,
          })
        > {
  $$TrackTemporalEmbeddingTableTableTableManager(
    _$AppDatabase db,
    $TrackTemporalEmbeddingTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackTemporalEmbeddingTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TrackTemporalEmbeddingTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackTemporalEmbeddingTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> representation = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> preprocessingVersion = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<int> audioRevision = const Value.absent(),
                Value<int> dimension = const Value.absent(),
                Value<String> dtype = const Value.absent(),
                Value<bool> normalized = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> numberOfSegments = const Value.absent(),
                Value<double> meanAdjacentDistance = const Value.absent(),
                Value<double> maxAdjacentDistance = const Value.absent(),
                Value<double> trajectoryVariance = const Value.absent(),
                Value<int?> largestTransitionIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackTemporalEmbeddingTableCompanion(
                id: id,
                trackId: trackId,
                representation: representation,
                modelId: modelId,
                modelVersion: modelVersion,
                preprocessingVersion: preprocessingVersion,
                provider: provider,
                audioRevision: audioRevision,
                dimension: dimension,
                dtype: dtype,
                normalized: normalized,
                createdAt: createdAt,
                numberOfSegments: numberOfSegments,
                meanAdjacentDistance: meanAdjacentDistance,
                maxAdjacentDistance: maxAdjacentDistance,
                trajectoryVariance: trajectoryVariance,
                largestTransitionIndex: largestTransitionIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String representation,
                required String modelId,
                required String modelVersion,
                required String preprocessingVersion,
                required String provider,
                required int audioRevision,
                required int dimension,
                required String dtype,
                required bool normalized,
                required DateTime createdAt,
                required int numberOfSegments,
                required double meanAdjacentDistance,
                required double maxAdjacentDistance,
                required double trajectoryVariance,
                Value<int?> largestTransitionIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackTemporalEmbeddingTableCompanion.insert(
                id: id,
                trackId: trackId,
                representation: representation,
                modelId: modelId,
                modelVersion: modelVersion,
                preprocessingVersion: preprocessingVersion,
                provider: provider,
                audioRevision: audioRevision,
                dimension: dimension,
                dtype: dtype,
                normalized: normalized,
                createdAt: createdAt,
                numberOfSegments: numberOfSegments,
                meanAdjacentDistance: meanAdjacentDistance,
                maxAdjacentDistance: maxAdjacentDistance,
                trajectoryVariance: trajectoryVariance,
                largestTransitionIndex: largestTransitionIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackTemporalEmbeddingTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                trackId = false,
                trackTemporalEmbeddingSegmentTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackTemporalEmbeddingSegmentTableRefs)
                      db.trackTemporalEmbeddingSegmentTable,
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
                        if (trackId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.trackId,
                                    referencedTable:
                                        $$TrackTemporalEmbeddingTableTableReferences
                                            ._trackIdTable(db),
                                    referencedColumn:
                                        $$TrackTemporalEmbeddingTableTableReferences
                                            ._trackIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackTemporalEmbeddingSegmentTableRefs)
                        await $_getPrefetchedData<
                          TrackTemporalEmbeddingTableData,
                          $TrackTemporalEmbeddingTableTable,
                          TrackTemporalEmbeddingSegmentTableData
                        >(
                          currentTable: table,
                          referencedTable:
                              $$TrackTemporalEmbeddingTableTableReferences
                                  ._trackTemporalEmbeddingSegmentTableRefsTable(
                                    db,
                                  ),
                          managerFromTypedResult: (p0) =>
                              $$TrackTemporalEmbeddingTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackTemporalEmbeddingSegmentTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.temporalEmbeddingId == item.id,
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

typedef $$TrackTemporalEmbeddingTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackTemporalEmbeddingTableTable,
      TrackTemporalEmbeddingTableData,
      $$TrackTemporalEmbeddingTableTableFilterComposer,
      $$TrackTemporalEmbeddingTableTableOrderingComposer,
      $$TrackTemporalEmbeddingTableTableAnnotationComposer,
      $$TrackTemporalEmbeddingTableTableCreateCompanionBuilder,
      $$TrackTemporalEmbeddingTableTableUpdateCompanionBuilder,
      (
        TrackTemporalEmbeddingTableData,
        $$TrackTemporalEmbeddingTableTableReferences,
      ),
      TrackTemporalEmbeddingTableData,
      PrefetchHooks Function({
        bool trackId,
        bool trackTemporalEmbeddingSegmentTableRefs,
      })
    >;
typedef $$TrackTemporalEmbeddingSegmentTableTableCreateCompanionBuilder =
    TrackTemporalEmbeddingSegmentTableCompanion Function({
      required String temporalEmbeddingId,
      required int segmentIndex,
      required int startMs,
      required int endMs,
      required int dimensions,
      required Uint8List vector,
      Value<int> rowid,
    });
typedef $$TrackTemporalEmbeddingSegmentTableTableUpdateCompanionBuilder =
    TrackTemporalEmbeddingSegmentTableCompanion Function({
      Value<String> temporalEmbeddingId,
      Value<int> segmentIndex,
      Value<int> startMs,
      Value<int> endMs,
      Value<int> dimensions,
      Value<Uint8List> vector,
      Value<int> rowid,
    });

final class $$TrackTemporalEmbeddingSegmentTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackTemporalEmbeddingSegmentTableTable,
          TrackTemporalEmbeddingSegmentTableData
        > {
  $$TrackTemporalEmbeddingSegmentTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTemporalEmbeddingTableTable _temporalEmbeddingIdTable(
    _$AppDatabase db,
  ) => db.trackTemporalEmbeddingTable.createAlias(
    $_aliasNameGenerator(
      db.trackTemporalEmbeddingSegmentTable.temporalEmbeddingId,
      db.trackTemporalEmbeddingTable.id,
    ),
  );

  $$TrackTemporalEmbeddingTableTableProcessedTableManager
  get temporalEmbeddingId {
    final $_column = $_itemColumn<String>('temporal_embedding_id')!;

    final manager = $$TrackTemporalEmbeddingTableTableTableManager(
      $_db,
      $_db.trackTemporalEmbeddingTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_temporalEmbeddingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackTemporalEmbeddingSegmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackTemporalEmbeddingSegmentTableTable> {
  $$TrackTemporalEmbeddingSegmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackTemporalEmbeddingTableTableFilterComposer get temporalEmbeddingId {
    final $$TrackTemporalEmbeddingTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.temporalEmbeddingId,
          referencedTable: $db.trackTemporalEmbeddingTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackTemporalEmbeddingTableTableFilterComposer(
                $db: $db,
                $table: $db.trackTemporalEmbeddingTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrackTemporalEmbeddingSegmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackTemporalEmbeddingSegmentTableTable> {
  $$TrackTemporalEmbeddingSegmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackTemporalEmbeddingTableTableOrderingComposer get temporalEmbeddingId {
    final $$TrackTemporalEmbeddingTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.temporalEmbeddingId,
          referencedTable: $db.trackTemporalEmbeddingTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackTemporalEmbeddingTableTableOrderingComposer(
                $db: $db,
                $table: $db.trackTemporalEmbeddingTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrackTemporalEmbeddingSegmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackTemporalEmbeddingSegmentTableTable> {
  $$TrackTemporalEmbeddingSegmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  $$TrackTemporalEmbeddingTableTableAnnotationComposer get temporalEmbeddingId {
    final $$TrackTemporalEmbeddingTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.temporalEmbeddingId,
          referencedTable: $db.trackTemporalEmbeddingTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackTemporalEmbeddingTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackTemporalEmbeddingTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrackTemporalEmbeddingSegmentTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackTemporalEmbeddingSegmentTableTable,
          TrackTemporalEmbeddingSegmentTableData,
          $$TrackTemporalEmbeddingSegmentTableTableFilterComposer,
          $$TrackTemporalEmbeddingSegmentTableTableOrderingComposer,
          $$TrackTemporalEmbeddingSegmentTableTableAnnotationComposer,
          $$TrackTemporalEmbeddingSegmentTableTableCreateCompanionBuilder,
          $$TrackTemporalEmbeddingSegmentTableTableUpdateCompanionBuilder,
          (
            TrackTemporalEmbeddingSegmentTableData,
            $$TrackTemporalEmbeddingSegmentTableTableReferences,
          ),
          TrackTemporalEmbeddingSegmentTableData,
          PrefetchHooks Function({bool temporalEmbeddingId})
        > {
  $$TrackTemporalEmbeddingSegmentTableTableTableManager(
    _$AppDatabase db,
    $TrackTemporalEmbeddingSegmentTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackTemporalEmbeddingSegmentTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TrackTemporalEmbeddingSegmentTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackTemporalEmbeddingSegmentTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> temporalEmbeddingId = const Value.absent(),
                Value<int> segmentIndex = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<int> dimensions = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackTemporalEmbeddingSegmentTableCompanion(
                temporalEmbeddingId: temporalEmbeddingId,
                segmentIndex: segmentIndex,
                startMs: startMs,
                endMs: endMs,
                dimensions: dimensions,
                vector: vector,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String temporalEmbeddingId,
                required int segmentIndex,
                required int startMs,
                required int endMs,
                required int dimensions,
                required Uint8List vector,
                Value<int> rowid = const Value.absent(),
              }) => TrackTemporalEmbeddingSegmentTableCompanion.insert(
                temporalEmbeddingId: temporalEmbeddingId,
                segmentIndex: segmentIndex,
                startMs: startMs,
                endMs: endMs,
                dimensions: dimensions,
                vector: vector,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackTemporalEmbeddingSegmentTableTableReferences(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({temporalEmbeddingId = false}) {
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
                    if (temporalEmbeddingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.temporalEmbeddingId,
                                referencedTable:
                                    $$TrackTemporalEmbeddingSegmentTableTableReferences
                                        ._temporalEmbeddingIdTable(db),
                                referencedColumn:
                                    $$TrackTemporalEmbeddingSegmentTableTableReferences
                                        ._temporalEmbeddingIdTable(db)
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

typedef $$TrackTemporalEmbeddingSegmentTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackTemporalEmbeddingSegmentTableTable,
      TrackTemporalEmbeddingSegmentTableData,
      $$TrackTemporalEmbeddingSegmentTableTableFilterComposer,
      $$TrackTemporalEmbeddingSegmentTableTableOrderingComposer,
      $$TrackTemporalEmbeddingSegmentTableTableAnnotationComposer,
      $$TrackTemporalEmbeddingSegmentTableTableCreateCompanionBuilder,
      $$TrackTemporalEmbeddingSegmentTableTableUpdateCompanionBuilder,
      (
        TrackTemporalEmbeddingSegmentTableData,
        $$TrackTemporalEmbeddingSegmentTableTableReferences,
      ),
      TrackTemporalEmbeddingSegmentTableData,
      PrefetchHooks Function({bool temporalEmbeddingId})
    >;
typedef $$MusicAnalysisTaskTableTableCreateCompanionBuilder =
    MusicAnalysisTaskTableCompanion Function({
      required String id,
      required String trackId,
      required String requestedRepresentations,
      required int audioRevision,
      required String status,
      Value<int> attemptCount,
      Value<String?> lastErrorCode,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MusicAnalysisTaskTableTableUpdateCompanionBuilder =
    MusicAnalysisTaskTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> requestedRepresentations,
      Value<int> audioRevision,
      Value<String> status,
      Value<int> attemptCount,
      Value<String?> lastErrorCode,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MusicAnalysisTaskTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MusicAnalysisTaskTableTable,
          MusicAnalysisTaskTableData
        > {
  $$MusicAnalysisTaskTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.musicAnalysisTaskTable.trackId,
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

class $$MusicAnalysisTaskTableTableFilterComposer
    extends Composer<_$AppDatabase, $MusicAnalysisTaskTableTable> {
  $$MusicAnalysisTaskTableTableFilterComposer({
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

  ColumnFilters<String> get requestedRepresentations => $composableBuilder(
    column: $table.requestedRepresentations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$MusicAnalysisTaskTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MusicAnalysisTaskTableTable> {
  $$MusicAnalysisTaskTableTableOrderingComposer({
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

  ColumnOrderings<String> get requestedRepresentations => $composableBuilder(
    column: $table.requestedRepresentations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$MusicAnalysisTaskTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MusicAnalysisTaskTableTable> {
  $$MusicAnalysisTaskTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestedRepresentations => $composableBuilder(
    column: $table.requestedRepresentations,
    builder: (column) => column,
  );

  GeneratedColumn<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$MusicAnalysisTaskTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MusicAnalysisTaskTableTable,
          MusicAnalysisTaskTableData,
          $$MusicAnalysisTaskTableTableFilterComposer,
          $$MusicAnalysisTaskTableTableOrderingComposer,
          $$MusicAnalysisTaskTableTableAnnotationComposer,
          $$MusicAnalysisTaskTableTableCreateCompanionBuilder,
          $$MusicAnalysisTaskTableTableUpdateCompanionBuilder,
          (MusicAnalysisTaskTableData, $$MusicAnalysisTaskTableTableReferences),
          MusicAnalysisTaskTableData,
          PrefetchHooks Function({bool trackId})
        > {
  $$MusicAnalysisTaskTableTableTableManager(
    _$AppDatabase db,
    $MusicAnalysisTaskTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MusicAnalysisTaskTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MusicAnalysisTaskTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MusicAnalysisTaskTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> requestedRepresentations = const Value.absent(),
                Value<int> audioRevision = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MusicAnalysisTaskTableCompanion(
                id: id,
                trackId: trackId,
                requestedRepresentations: requestedRepresentations,
                audioRevision: audioRevision,
                status: status,
                attemptCount: attemptCount,
                lastErrorCode: lastErrorCode,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String requestedRepresentations,
                required int audioRevision,
                required String status,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MusicAnalysisTaskTableCompanion.insert(
                id: id,
                trackId: trackId,
                requestedRepresentations: requestedRepresentations,
                audioRevision: audioRevision,
                status: status,
                attemptCount: attemptCount,
                lastErrorCode: lastErrorCode,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MusicAnalysisTaskTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
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
                                    $$MusicAnalysisTaskTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$MusicAnalysisTaskTableTableReferences
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

typedef $$MusicAnalysisTaskTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MusicAnalysisTaskTableTable,
      MusicAnalysisTaskTableData,
      $$MusicAnalysisTaskTableTableFilterComposer,
      $$MusicAnalysisTaskTableTableOrderingComposer,
      $$MusicAnalysisTaskTableTableAnnotationComposer,
      $$MusicAnalysisTaskTableTableCreateCompanionBuilder,
      $$MusicAnalysisTaskTableTableUpdateCompanionBuilder,
      (MusicAnalysisTaskTableData, $$MusicAnalysisTaskTableTableReferences),
      MusicAnalysisTaskTableData,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$MusicAnalysisSettingsTableTableCreateCompanionBuilder =
    MusicAnalysisSettingsTableCompanion Function({
      Value<int> id,
      Value<bool> serverEnabled,
      required DateTime updatedAt,
    });
typedef $$MusicAnalysisSettingsTableTableUpdateCompanionBuilder =
    MusicAnalysisSettingsTableCompanion Function({
      Value<int> id,
      Value<bool> serverEnabled,
      Value<DateTime> updatedAt,
    });

class $$MusicAnalysisSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MusicAnalysisSettingsTableTable> {
  $$MusicAnalysisSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get serverEnabled => $composableBuilder(
    column: $table.serverEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MusicAnalysisSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MusicAnalysisSettingsTableTable> {
  $$MusicAnalysisSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get serverEnabled => $composableBuilder(
    column: $table.serverEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MusicAnalysisSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MusicAnalysisSettingsTableTable> {
  $$MusicAnalysisSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get serverEnabled => $composableBuilder(
    column: $table.serverEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MusicAnalysisSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MusicAnalysisSettingsTableTable,
          MusicAnalysisSettingsTableData,
          $$MusicAnalysisSettingsTableTableFilterComposer,
          $$MusicAnalysisSettingsTableTableOrderingComposer,
          $$MusicAnalysisSettingsTableTableAnnotationComposer,
          $$MusicAnalysisSettingsTableTableCreateCompanionBuilder,
          $$MusicAnalysisSettingsTableTableUpdateCompanionBuilder,
          (
            MusicAnalysisSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $MusicAnalysisSettingsTableTable,
              MusicAnalysisSettingsTableData
            >,
          ),
          MusicAnalysisSettingsTableData,
          PrefetchHooks Function()
        > {
  $$MusicAnalysisSettingsTableTableTableManager(
    _$AppDatabase db,
    $MusicAnalysisSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MusicAnalysisSettingsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MusicAnalysisSettingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MusicAnalysisSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> serverEnabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MusicAnalysisSettingsTableCompanion(
                id: id,
                serverEnabled: serverEnabled,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> serverEnabled = const Value.absent(),
                required DateTime updatedAt,
              }) => MusicAnalysisSettingsTableCompanion.insert(
                id: id,
                serverEnabled: serverEnabled,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MusicAnalysisSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MusicAnalysisSettingsTableTable,
      MusicAnalysisSettingsTableData,
      $$MusicAnalysisSettingsTableTableFilterComposer,
      $$MusicAnalysisSettingsTableTableOrderingComposer,
      $$MusicAnalysisSettingsTableTableAnnotationComposer,
      $$MusicAnalysisSettingsTableTableCreateCompanionBuilder,
      $$MusicAnalysisSettingsTableTableUpdateCompanionBuilder,
      (
        MusicAnalysisSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $MusicAnalysisSettingsTableTable,
          MusicAnalysisSettingsTableData
        >,
      ),
      MusicAnalysisSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$SimilarityEvaluationTableTableCreateCompanionBuilder =
    SimilarityEvaluationTableCompanion Function({
      required String id,
      required String seedTrackId,
      required String candidateTrackId,
      required String methodVersion,
      required String sourceRepresentationModelId,
      required String sourceRepresentationModelVersion,
      required String sourcePreprocessingVersion,
      required double scoreShown,
      Value<double?> rawDistance,
      Value<int?> soundRating,
      Value<int?> atmosphereRating,
      Value<int?> trajectoryRating,
      Value<bool?> wouldListenNext,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SimilarityEvaluationTableTableUpdateCompanionBuilder =
    SimilarityEvaluationTableCompanion Function({
      Value<String> id,
      Value<String> seedTrackId,
      Value<String> candidateTrackId,
      Value<String> methodVersion,
      Value<String> sourceRepresentationModelId,
      Value<String> sourceRepresentationModelVersion,
      Value<String> sourcePreprocessingVersion,
      Value<double> scoreShown,
      Value<double?> rawDistance,
      Value<int?> soundRating,
      Value<int?> atmosphereRating,
      Value<int?> trajectoryRating,
      Value<bool?> wouldListenNext,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SimilarityEvaluationTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SimilarityEvaluationTableTable,
          SimilarityEvaluationTableData
        > {
  $$SimilarityEvaluationTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _seedTrackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.similarityEvaluationTable.seedTrackId,
          db.trackTable.id,
        ),
      );

  $$TrackTableTableProcessedTableManager get seedTrackId {
    final $_column = $_itemColumn<String>('seed_track_id')!;

    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seedTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrackTableTable _candidateTrackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.similarityEvaluationTable.candidateTrackId,
          db.trackTable.id,
        ),
      );

  $$TrackTableTableProcessedTableManager get candidateTrackId {
    final $_column = $_itemColumn<String>('candidate_track_id')!;

    final manager = $$TrackTableTableTableManager(
      $_db,
      $_db.trackTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_candidateTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SimilarityEvaluationTableTableFilterComposer
    extends Composer<_$AppDatabase, $SimilarityEvaluationTableTable> {
  $$SimilarityEvaluationTableTableFilterComposer({
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

  ColumnFilters<String> get methodVersion => $composableBuilder(
    column: $table.methodVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRepresentationModelId => $composableBuilder(
    column: $table.sourceRepresentationModelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRepresentationModelVersion =>
      $composableBuilder(
        column: $table.sourceRepresentationModelVersion,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get sourcePreprocessingVersion => $composableBuilder(
    column: $table.sourcePreprocessingVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scoreShown => $composableBuilder(
    column: $table.scoreShown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rawDistance => $composableBuilder(
    column: $table.rawDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get soundRating => $composableBuilder(
    column: $table.soundRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atmosphereRating => $composableBuilder(
    column: $table.atmosphereRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trajectoryRating => $composableBuilder(
    column: $table.trajectoryRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wouldListenNext => $composableBuilder(
    column: $table.wouldListenNext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackTableTableFilterComposer get seedTrackId {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seedTrackId,
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

  $$TrackTableTableFilterComposer get candidateTrackId {
    final $$TrackTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.candidateTrackId,
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

class $$SimilarityEvaluationTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SimilarityEvaluationTableTable> {
  $$SimilarityEvaluationTableTableOrderingComposer({
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

  ColumnOrderings<String> get methodVersion => $composableBuilder(
    column: $table.methodVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRepresentationModelId => $composableBuilder(
    column: $table.sourceRepresentationModelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRepresentationModelVersion =>
      $composableBuilder(
        column: $table.sourceRepresentationModelVersion,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get sourcePreprocessingVersion => $composableBuilder(
    column: $table.sourcePreprocessingVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scoreShown => $composableBuilder(
    column: $table.scoreShown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rawDistance => $composableBuilder(
    column: $table.rawDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get soundRating => $composableBuilder(
    column: $table.soundRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atmosphereRating => $composableBuilder(
    column: $table.atmosphereRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trajectoryRating => $composableBuilder(
    column: $table.trajectoryRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wouldListenNext => $composableBuilder(
    column: $table.wouldListenNext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackTableTableOrderingComposer get seedTrackId {
    final $$TrackTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seedTrackId,
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

  $$TrackTableTableOrderingComposer get candidateTrackId {
    final $$TrackTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.candidateTrackId,
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

class $$SimilarityEvaluationTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SimilarityEvaluationTableTable> {
  $$SimilarityEvaluationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get methodVersion => $composableBuilder(
    column: $table.methodVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRepresentationModelId => $composableBuilder(
    column: $table.sourceRepresentationModelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRepresentationModelVersion =>
      $composableBuilder(
        column: $table.sourceRepresentationModelVersion,
        builder: (column) => column,
      );

  GeneratedColumn<String> get sourcePreprocessingVersion => $composableBuilder(
    column: $table.sourcePreprocessingVersion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get scoreShown => $composableBuilder(
    column: $table.scoreShown,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rawDistance => $composableBuilder(
    column: $table.rawDistance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get soundRating => $composableBuilder(
    column: $table.soundRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get atmosphereRating => $composableBuilder(
    column: $table.atmosphereRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trajectoryRating => $composableBuilder(
    column: $table.trajectoryRating,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wouldListenNext => $composableBuilder(
    column: $table.wouldListenNext,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TrackTableTableAnnotationComposer get seedTrackId {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seedTrackId,
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

  $$TrackTableTableAnnotationComposer get candidateTrackId {
    final $$TrackTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.candidateTrackId,
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

class $$SimilarityEvaluationTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SimilarityEvaluationTableTable,
          SimilarityEvaluationTableData,
          $$SimilarityEvaluationTableTableFilterComposer,
          $$SimilarityEvaluationTableTableOrderingComposer,
          $$SimilarityEvaluationTableTableAnnotationComposer,
          $$SimilarityEvaluationTableTableCreateCompanionBuilder,
          $$SimilarityEvaluationTableTableUpdateCompanionBuilder,
          (
            SimilarityEvaluationTableData,
            $$SimilarityEvaluationTableTableReferences,
          ),
          SimilarityEvaluationTableData,
          PrefetchHooks Function({bool seedTrackId, bool candidateTrackId})
        > {
  $$SimilarityEvaluationTableTableTableManager(
    _$AppDatabase db,
    $SimilarityEvaluationTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SimilarityEvaluationTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SimilarityEvaluationTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SimilarityEvaluationTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> seedTrackId = const Value.absent(),
                Value<String> candidateTrackId = const Value.absent(),
                Value<String> methodVersion = const Value.absent(),
                Value<String> sourceRepresentationModelId =
                    const Value.absent(),
                Value<String> sourceRepresentationModelVersion =
                    const Value.absent(),
                Value<String> sourcePreprocessingVersion = const Value.absent(),
                Value<double> scoreShown = const Value.absent(),
                Value<double?> rawDistance = const Value.absent(),
                Value<int?> soundRating = const Value.absent(),
                Value<int?> atmosphereRating = const Value.absent(),
                Value<int?> trajectoryRating = const Value.absent(),
                Value<bool?> wouldListenNext = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SimilarityEvaluationTableCompanion(
                id: id,
                seedTrackId: seedTrackId,
                candidateTrackId: candidateTrackId,
                methodVersion: methodVersion,
                sourceRepresentationModelId: sourceRepresentationModelId,
                sourceRepresentationModelVersion:
                    sourceRepresentationModelVersion,
                sourcePreprocessingVersion: sourcePreprocessingVersion,
                scoreShown: scoreShown,
                rawDistance: rawDistance,
                soundRating: soundRating,
                atmosphereRating: atmosphereRating,
                trajectoryRating: trajectoryRating,
                wouldListenNext: wouldListenNext,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String seedTrackId,
                required String candidateTrackId,
                required String methodVersion,
                required String sourceRepresentationModelId,
                required String sourceRepresentationModelVersion,
                required String sourcePreprocessingVersion,
                required double scoreShown,
                Value<double?> rawDistance = const Value.absent(),
                Value<int?> soundRating = const Value.absent(),
                Value<int?> atmosphereRating = const Value.absent(),
                Value<int?> trajectoryRating = const Value.absent(),
                Value<bool?> wouldListenNext = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SimilarityEvaluationTableCompanion.insert(
                id: id,
                seedTrackId: seedTrackId,
                candidateTrackId: candidateTrackId,
                methodVersion: methodVersion,
                sourceRepresentationModelId: sourceRepresentationModelId,
                sourceRepresentationModelVersion:
                    sourceRepresentationModelVersion,
                sourcePreprocessingVersion: sourcePreprocessingVersion,
                scoreShown: scoreShown,
                rawDistance: rawDistance,
                soundRating: soundRating,
                atmosphereRating: atmosphereRating,
                trajectoryRating: trajectoryRating,
                wouldListenNext: wouldListenNext,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SimilarityEvaluationTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seedTrackId = false, candidateTrackId = false}) {
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
                    if (seedTrackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.seedTrackId,
                                referencedTable:
                                    $$SimilarityEvaluationTableTableReferences
                                        ._seedTrackIdTable(db),
                                referencedColumn:
                                    $$SimilarityEvaluationTableTableReferences
                                        ._seedTrackIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (candidateTrackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.candidateTrackId,
                                referencedTable:
                                    $$SimilarityEvaluationTableTableReferences
                                        ._candidateTrackIdTable(db),
                                referencedColumn:
                                    $$SimilarityEvaluationTableTableReferences
                                        ._candidateTrackIdTable(db)
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

typedef $$SimilarityEvaluationTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SimilarityEvaluationTableTable,
      SimilarityEvaluationTableData,
      $$SimilarityEvaluationTableTableFilterComposer,
      $$SimilarityEvaluationTableTableOrderingComposer,
      $$SimilarityEvaluationTableTableAnnotationComposer,
      $$SimilarityEvaluationTableTableCreateCompanionBuilder,
      $$SimilarityEvaluationTableTableUpdateCompanionBuilder,
      (
        SimilarityEvaluationTableData,
        $$SimilarityEvaluationTableTableReferences,
      ),
      SimilarityEvaluationTableData,
      PrefetchHooks Function({bool seedTrackId, bool candidateTrackId})
    >;
typedef $$TrackLyricsTableTableCreateCompanionBuilder =
    TrackLyricsTableCompanion Function({
      required String trackId,
      required String source,
      Value<String?> sourceId,
      required String plainText,
      Value<String?> syncedText,
      Value<String?> language,
      required String contentHash,
      Value<bool> isInstrumental,
      Value<double?> matchConfidence,
      Value<String?> matchedTitle,
      Value<String?> matchedArtist,
      Value<int?> matchedDurationMs,
      required DateTime fetchedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TrackLyricsTableTableUpdateCompanionBuilder =
    TrackLyricsTableCompanion Function({
      Value<String> trackId,
      Value<String> source,
      Value<String?> sourceId,
      Value<String> plainText,
      Value<String?> syncedText,
      Value<String?> language,
      Value<String> contentHash,
      Value<bool> isInstrumental,
      Value<double?> matchConfidence,
      Value<String?> matchedTitle,
      Value<String?> matchedArtist,
      Value<int?> matchedDurationMs,
      Value<DateTime> fetchedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TrackLyricsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackLyricsTableTable,
          TrackLyricsTableData
        > {
  $$TrackLyricsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(db.trackLyricsTable.trackId, db.trackTable.id),
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

class $$TrackLyricsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackLyricsTableTable> {
  $$TrackLyricsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedText => $composableBuilder(
    column: $table.syncedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInstrumental => $composableBuilder(
    column: $table.isInstrumental,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchedTitle => $composableBuilder(
    column: $table.matchedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchedArtist => $composableBuilder(
    column: $table.matchedArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get matchedDurationMs => $composableBuilder(
    column: $table.matchedDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$TrackLyricsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackLyricsTableTable> {
  $$TrackLyricsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedText => $composableBuilder(
    column: $table.syncedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInstrumental => $composableBuilder(
    column: $table.isInstrumental,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchedTitle => $composableBuilder(
    column: $table.matchedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchedArtist => $composableBuilder(
    column: $table.matchedArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matchedDurationMs => $composableBuilder(
    column: $table.matchedDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$TrackLyricsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackLyricsTableTable> {
  $$TrackLyricsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<String> get syncedText => $composableBuilder(
    column: $table.syncedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isInstrumental => $composableBuilder(
    column: $table.isInstrumental,
    builder: (column) => column,
  );

  GeneratedColumn<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchedTitle => $composableBuilder(
    column: $table.matchedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchedArtist => $composableBuilder(
    column: $table.matchedArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get matchedDurationMs => $composableBuilder(
    column: $table.matchedDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$TrackLyricsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackLyricsTableTable,
          TrackLyricsTableData,
          $$TrackLyricsTableTableFilterComposer,
          $$TrackLyricsTableTableOrderingComposer,
          $$TrackLyricsTableTableAnnotationComposer,
          $$TrackLyricsTableTableCreateCompanionBuilder,
          $$TrackLyricsTableTableUpdateCompanionBuilder,
          (TrackLyricsTableData, $$TrackLyricsTableTableReferences),
          TrackLyricsTableData,
          PrefetchHooks Function({bool trackId})
        > {
  $$TrackLyricsTableTableTableManager(
    _$AppDatabase db,
    $TrackLyricsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackLyricsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackLyricsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackLyricsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> plainText = const Value.absent(),
                Value<String?> syncedText = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<bool> isInstrumental = const Value.absent(),
                Value<double?> matchConfidence = const Value.absent(),
                Value<String?> matchedTitle = const Value.absent(),
                Value<String?> matchedArtist = const Value.absent(),
                Value<int?> matchedDurationMs = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackLyricsTableCompanion(
                trackId: trackId,
                source: source,
                sourceId: sourceId,
                plainText: plainText,
                syncedText: syncedText,
                language: language,
                contentHash: contentHash,
                isInstrumental: isInstrumental,
                matchConfidence: matchConfidence,
                matchedTitle: matchedTitle,
                matchedArtist: matchedArtist,
                matchedDurationMs: matchedDurationMs,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String source,
                Value<String?> sourceId = const Value.absent(),
                required String plainText,
                Value<String?> syncedText = const Value.absent(),
                Value<String?> language = const Value.absent(),
                required String contentHash,
                Value<bool> isInstrumental = const Value.absent(),
                Value<double?> matchConfidence = const Value.absent(),
                Value<String?> matchedTitle = const Value.absent(),
                Value<String?> matchedArtist = const Value.absent(),
                Value<int?> matchedDurationMs = const Value.absent(),
                required DateTime fetchedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TrackLyricsTableCompanion.insert(
                trackId: trackId,
                source: source,
                sourceId: sourceId,
                plainText: plainText,
                syncedText: syncedText,
                language: language,
                contentHash: contentHash,
                isInstrumental: isInstrumental,
                matchConfidence: matchConfidence,
                matchedTitle: matchedTitle,
                matchedArtist: matchedArtist,
                matchedDurationMs: matchedDurationMs,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackLyricsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
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
                                    $$TrackLyricsTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$TrackLyricsTableTableReferences
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

typedef $$TrackLyricsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackLyricsTableTable,
      TrackLyricsTableData,
      $$TrackLyricsTableTableFilterComposer,
      $$TrackLyricsTableTableOrderingComposer,
      $$TrackLyricsTableTableAnnotationComposer,
      $$TrackLyricsTableTableCreateCompanionBuilder,
      $$TrackLyricsTableTableUpdateCompanionBuilder,
      (TrackLyricsTableData, $$TrackLyricsTableTableReferences),
      TrackLyricsTableData,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$LyricsResolutionStateTableTableCreateCompanionBuilder =
    LyricsResolutionStateTableCompanion Function({
      required String trackId,
      required String status,
      Value<String?> provider,
      Value<int> metadataRevision,
      Value<int> attemptCount,
      Value<String?> lastErrorCode,
      Value<String?> lastError,
      Value<DateTime?> nextRetryAt,
      Value<DateTime?> lastAttemptAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LyricsResolutionStateTableTableUpdateCompanionBuilder =
    LyricsResolutionStateTableCompanion Function({
      Value<String> trackId,
      Value<String> status,
      Value<String?> provider,
      Value<int> metadataRevision,
      Value<int> attemptCount,
      Value<String?> lastErrorCode,
      Value<String?> lastError,
      Value<DateTime?> nextRetryAt,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LyricsResolutionStateTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LyricsResolutionStateTableTable,
          LyricsResolutionStateTableData
        > {
  $$LyricsResolutionStateTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.lyricsResolutionStateTable.trackId,
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

class $$LyricsResolutionStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $LyricsResolutionStateTableTable> {
  $$LyricsResolutionStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metadataRevision => $composableBuilder(
    column: $table.metadataRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$LyricsResolutionStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LyricsResolutionStateTableTable> {
  $$LyricsResolutionStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metadataRevision => $composableBuilder(
    column: $table.metadataRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$LyricsResolutionStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LyricsResolutionStateTableTable> {
  $$LyricsResolutionStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get metadataRevision => $composableBuilder(
    column: $table.metadataRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$LyricsResolutionStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LyricsResolutionStateTableTable,
          LyricsResolutionStateTableData,
          $$LyricsResolutionStateTableTableFilterComposer,
          $$LyricsResolutionStateTableTableOrderingComposer,
          $$LyricsResolutionStateTableTableAnnotationComposer,
          $$LyricsResolutionStateTableTableCreateCompanionBuilder,
          $$LyricsResolutionStateTableTableUpdateCompanionBuilder,
          (
            LyricsResolutionStateTableData,
            $$LyricsResolutionStateTableTableReferences,
          ),
          LyricsResolutionStateTableData,
          PrefetchHooks Function({bool trackId})
        > {
  $$LyricsResolutionStateTableTableTableManager(
    _$AppDatabase db,
    $LyricsResolutionStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricsResolutionStateTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LyricsResolutionStateTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LyricsResolutionStateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<int> metadataRevision = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricsResolutionStateTableCompanion(
                trackId: trackId,
                status: status,
                provider: provider,
                metadataRevision: metadataRevision,
                attemptCount: attemptCount,
                lastErrorCode: lastErrorCode,
                lastError: lastError,
                nextRetryAt: nextRetryAt,
                lastAttemptAt: lastAttemptAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String status,
                Value<String?> provider = const Value.absent(),
                Value<int> metadataRevision = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LyricsResolutionStateTableCompanion.insert(
                trackId: trackId,
                status: status,
                provider: provider,
                metadataRevision: metadataRevision,
                attemptCount: attemptCount,
                lastErrorCode: lastErrorCode,
                lastError: lastError,
                nextRetryAt: nextRetryAt,
                lastAttemptAt: lastAttemptAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LyricsResolutionStateTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
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
                                    $$LyricsResolutionStateTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$LyricsResolutionStateTableTableReferences
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

typedef $$LyricsResolutionStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LyricsResolutionStateTableTable,
      LyricsResolutionStateTableData,
      $$LyricsResolutionStateTableTableFilterComposer,
      $$LyricsResolutionStateTableTableOrderingComposer,
      $$LyricsResolutionStateTableTableAnnotationComposer,
      $$LyricsResolutionStateTableTableCreateCompanionBuilder,
      $$LyricsResolutionStateTableTableUpdateCompanionBuilder,
      (
        LyricsResolutionStateTableData,
        $$LyricsResolutionStateTableTableReferences,
      ),
      LyricsResolutionStateTableData,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$LyricsResolutionTaskTableTableCreateCompanionBuilder =
    LyricsResolutionTaskTableCompanion Function({
      required String id,
      required String trackId,
      required String status,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastErrorCode,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LyricsResolutionTaskTableTableUpdateCompanionBuilder =
    LyricsResolutionTaskTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> status,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastErrorCode,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LyricsResolutionTaskTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LyricsResolutionTaskTableTable,
          LyricsResolutionTaskTableData
        > {
  $$LyricsResolutionTaskTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.lyricsResolutionTaskTable.trackId,
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

class $$LyricsResolutionTaskTableTableFilterComposer
    extends Composer<_$AppDatabase, $LyricsResolutionTaskTableTable> {
  $$LyricsResolutionTaskTableTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$LyricsResolutionTaskTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LyricsResolutionTaskTableTable> {
  $$LyricsResolutionTaskTableTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$LyricsResolutionTaskTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LyricsResolutionTaskTableTable> {
  $$LyricsResolutionTaskTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$LyricsResolutionTaskTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LyricsResolutionTaskTableTable,
          LyricsResolutionTaskTableData,
          $$LyricsResolutionTaskTableTableFilterComposer,
          $$LyricsResolutionTaskTableTableOrderingComposer,
          $$LyricsResolutionTaskTableTableAnnotationComposer,
          $$LyricsResolutionTaskTableTableCreateCompanionBuilder,
          $$LyricsResolutionTaskTableTableUpdateCompanionBuilder,
          (
            LyricsResolutionTaskTableData,
            $$LyricsResolutionTaskTableTableReferences,
          ),
          LyricsResolutionTaskTableData,
          PrefetchHooks Function({bool trackId})
        > {
  $$LyricsResolutionTaskTableTableTableManager(
    _$AppDatabase db,
    $LyricsResolutionTaskTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricsResolutionTaskTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LyricsResolutionTaskTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LyricsResolutionTaskTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricsResolutionTaskTableCompanion(
                id: id,
                trackId: trackId,
                status: status,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String status,
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LyricsResolutionTaskTableCompanion.insert(
                id: id,
                trackId: trackId,
                status: status,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LyricsResolutionTaskTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
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
                                    $$LyricsResolutionTaskTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$LyricsResolutionTaskTableTableReferences
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

typedef $$LyricsResolutionTaskTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LyricsResolutionTaskTableTable,
      LyricsResolutionTaskTableData,
      $$LyricsResolutionTaskTableTableFilterComposer,
      $$LyricsResolutionTaskTableTableOrderingComposer,
      $$LyricsResolutionTaskTableTableAnnotationComposer,
      $$LyricsResolutionTaskTableTableCreateCompanionBuilder,
      $$LyricsResolutionTaskTableTableUpdateCompanionBuilder,
      (
        LyricsResolutionTaskTableData,
        $$LyricsResolutionTaskTableTableReferences,
      ),
      LyricsResolutionTaskTableData,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$TrackEmotionAnalysisTableTableCreateCompanionBuilder =
    TrackEmotionAnalysisTableCompanion Function({
      required String id,
      required String trackId,
      required String representation,
      required String modelId,
      required String modelVersion,
      required String preprocessingVersion,
      required String contentRevision,
      required int audioRevision,
      Value<double?> valence,
      Value<double?> arousal,
      Value<double?> rawValence,
      Value<double?> rawArousal,
      Value<int> moodDistributionVersion,
      Value<String?> moodDistributionJson,
      Value<String?> temporalSummaryJson,
      required DateTime analyzedAt,
      Value<int> rowid,
    });
typedef $$TrackEmotionAnalysisTableTableUpdateCompanionBuilder =
    TrackEmotionAnalysisTableCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> representation,
      Value<String> modelId,
      Value<String> modelVersion,
      Value<String> preprocessingVersion,
      Value<String> contentRevision,
      Value<int> audioRevision,
      Value<double?> valence,
      Value<double?> arousal,
      Value<double?> rawValence,
      Value<double?> rawArousal,
      Value<int> moodDistributionVersion,
      Value<String?> moodDistributionJson,
      Value<String?> temporalSummaryJson,
      Value<DateTime> analyzedAt,
      Value<int> rowid,
    });

final class $$TrackEmotionAnalysisTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackEmotionAnalysisTableTable,
          TrackEmotionAnalysisTableData
        > {
  $$TrackEmotionAnalysisTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.trackEmotionAnalysisTable.trackId,
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

  static MultiTypedResultKey<
    $TrackEmotionSegmentTableTable,
    List<TrackEmotionSegmentTableData>
  >
  _trackEmotionSegmentTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackEmotionSegmentTable,
        aliasName: $_aliasNameGenerator(
          db.trackEmotionAnalysisTable.id,
          db.trackEmotionSegmentTable.analysisId,
        ),
      );

  $$TrackEmotionSegmentTableTableProcessedTableManager
  get trackEmotionSegmentTableRefs {
    final manager = $$TrackEmotionSegmentTableTableTableManager(
      $_db,
      $_db.trackEmotionSegmentTable,
    ).filter((f) => f.analysisId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackEmotionSegmentTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackEmotionAnalysisTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackEmotionAnalysisTableTable> {
  $$TrackEmotionAnalysisTableTableFilterComposer({
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

  ColumnFilters<String> get representation => $composableBuilder(
    column: $table.representation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preprocessingVersion => $composableBuilder(
    column: $table.preprocessingVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentRevision => $composableBuilder(
    column: $table.contentRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rawValence => $composableBuilder(
    column: $table.rawValence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rawArousal => $composableBuilder(
    column: $table.rawArousal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moodDistributionVersion => $composableBuilder(
    column: $table.moodDistributionVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodDistributionJson => $composableBuilder(
    column: $table.moodDistributionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get temporalSummaryJson => $composableBuilder(
    column: $table.temporalSummaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
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

  Expression<bool> trackEmotionSegmentTableRefs(
    Expression<bool> Function($$TrackEmotionSegmentTableTableFilterComposer f)
    f,
  ) {
    final $$TrackEmotionSegmentTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackEmotionSegmentTable,
          getReferencedColumn: (t) => t.analysisId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackEmotionSegmentTableTableFilterComposer(
                $db: $db,
                $table: $db.trackEmotionSegmentTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TrackEmotionAnalysisTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackEmotionAnalysisTableTable> {
  $$TrackEmotionAnalysisTableTableOrderingComposer({
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

  ColumnOrderings<String> get representation => $composableBuilder(
    column: $table.representation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preprocessingVersion => $composableBuilder(
    column: $table.preprocessingVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentRevision => $composableBuilder(
    column: $table.contentRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rawValence => $composableBuilder(
    column: $table.rawValence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rawArousal => $composableBuilder(
    column: $table.rawArousal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moodDistributionVersion => $composableBuilder(
    column: $table.moodDistributionVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodDistributionJson => $composableBuilder(
    column: $table.moodDistributionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get temporalSummaryJson => $composableBuilder(
    column: $table.temporalSummaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
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
}

class $$TrackEmotionAnalysisTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackEmotionAnalysisTableTable> {
  $$TrackEmotionAnalysisTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get representation => $composableBuilder(
    column: $table.representation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preprocessingVersion => $composableBuilder(
    column: $table.preprocessingVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentRevision => $composableBuilder(
    column: $table.contentRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get audioRevision => $composableBuilder(
    column: $table.audioRevision,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valence =>
      $composableBuilder(column: $table.valence, builder: (column) => column);

  GeneratedColumn<double> get arousal =>
      $composableBuilder(column: $table.arousal, builder: (column) => column);

  GeneratedColumn<double> get rawValence => $composableBuilder(
    column: $table.rawValence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rawArousal => $composableBuilder(
    column: $table.rawArousal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get moodDistributionVersion => $composableBuilder(
    column: $table.moodDistributionVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moodDistributionJson => $composableBuilder(
    column: $table.moodDistributionJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get temporalSummaryJson => $composableBuilder(
    column: $table.temporalSummaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => column,
  );

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

  Expression<T> trackEmotionSegmentTableRefs<T extends Object>(
    Expression<T> Function($$TrackEmotionSegmentTableTableAnnotationComposer a)
    f,
  ) {
    final $$TrackEmotionSegmentTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackEmotionSegmentTable,
          getReferencedColumn: (t) => t.analysisId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackEmotionSegmentTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackEmotionSegmentTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TrackEmotionAnalysisTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackEmotionAnalysisTableTable,
          TrackEmotionAnalysisTableData,
          $$TrackEmotionAnalysisTableTableFilterComposer,
          $$TrackEmotionAnalysisTableTableOrderingComposer,
          $$TrackEmotionAnalysisTableTableAnnotationComposer,
          $$TrackEmotionAnalysisTableTableCreateCompanionBuilder,
          $$TrackEmotionAnalysisTableTableUpdateCompanionBuilder,
          (
            TrackEmotionAnalysisTableData,
            $$TrackEmotionAnalysisTableTableReferences,
          ),
          TrackEmotionAnalysisTableData,
          PrefetchHooks Function({
            bool trackId,
            bool trackEmotionSegmentTableRefs,
          })
        > {
  $$TrackEmotionAnalysisTableTableTableManager(
    _$AppDatabase db,
    $TrackEmotionAnalysisTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackEmotionAnalysisTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TrackEmotionAnalysisTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackEmotionAnalysisTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> representation = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> preprocessingVersion = const Value.absent(),
                Value<String> contentRevision = const Value.absent(),
                Value<int> audioRevision = const Value.absent(),
                Value<double?> valence = const Value.absent(),
                Value<double?> arousal = const Value.absent(),
                Value<double?> rawValence = const Value.absent(),
                Value<double?> rawArousal = const Value.absent(),
                Value<int> moodDistributionVersion = const Value.absent(),
                Value<String?> moodDistributionJson = const Value.absent(),
                Value<String?> temporalSummaryJson = const Value.absent(),
                Value<DateTime> analyzedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackEmotionAnalysisTableCompanion(
                id: id,
                trackId: trackId,
                representation: representation,
                modelId: modelId,
                modelVersion: modelVersion,
                preprocessingVersion: preprocessingVersion,
                contentRevision: contentRevision,
                audioRevision: audioRevision,
                valence: valence,
                arousal: arousal,
                rawValence: rawValence,
                rawArousal: rawArousal,
                moodDistributionVersion: moodDistributionVersion,
                moodDistributionJson: moodDistributionJson,
                temporalSummaryJson: temporalSummaryJson,
                analyzedAt: analyzedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String representation,
                required String modelId,
                required String modelVersion,
                required String preprocessingVersion,
                required String contentRevision,
                required int audioRevision,
                Value<double?> valence = const Value.absent(),
                Value<double?> arousal = const Value.absent(),
                Value<double?> rawValence = const Value.absent(),
                Value<double?> rawArousal = const Value.absent(),
                Value<int> moodDistributionVersion = const Value.absent(),
                Value<String?> moodDistributionJson = const Value.absent(),
                Value<String?> temporalSummaryJson = const Value.absent(),
                required DateTime analyzedAt,
                Value<int> rowid = const Value.absent(),
              }) => TrackEmotionAnalysisTableCompanion.insert(
                id: id,
                trackId: trackId,
                representation: representation,
                modelId: modelId,
                modelVersion: modelVersion,
                preprocessingVersion: preprocessingVersion,
                contentRevision: contentRevision,
                audioRevision: audioRevision,
                valence: valence,
                arousal: arousal,
                rawValence: rawValence,
                rawArousal: rawArousal,
                moodDistributionVersion: moodDistributionVersion,
                moodDistributionJson: moodDistributionJson,
                temporalSummaryJson: temporalSummaryJson,
                analyzedAt: analyzedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackEmotionAnalysisTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({trackId = false, trackEmotionSegmentTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackEmotionSegmentTableRefs)
                      db.trackEmotionSegmentTable,
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
                        if (trackId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.trackId,
                                    referencedTable:
                                        $$TrackEmotionAnalysisTableTableReferences
                                            ._trackIdTable(db),
                                    referencedColumn:
                                        $$TrackEmotionAnalysisTableTableReferences
                                            ._trackIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackEmotionSegmentTableRefs)
                        await $_getPrefetchedData<
                          TrackEmotionAnalysisTableData,
                          $TrackEmotionAnalysisTableTable,
                          TrackEmotionSegmentTableData
                        >(
                          currentTable: table,
                          referencedTable:
                              $$TrackEmotionAnalysisTableTableReferences
                                  ._trackEmotionSegmentTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackEmotionAnalysisTableTableReferences(
                                db,
                                table,
                                p0,
                              ).trackEmotionSegmentTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.analysisId == item.id,
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

typedef $$TrackEmotionAnalysisTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackEmotionAnalysisTableTable,
      TrackEmotionAnalysisTableData,
      $$TrackEmotionAnalysisTableTableFilterComposer,
      $$TrackEmotionAnalysisTableTableOrderingComposer,
      $$TrackEmotionAnalysisTableTableAnnotationComposer,
      $$TrackEmotionAnalysisTableTableCreateCompanionBuilder,
      $$TrackEmotionAnalysisTableTableUpdateCompanionBuilder,
      (
        TrackEmotionAnalysisTableData,
        $$TrackEmotionAnalysisTableTableReferences,
      ),
      TrackEmotionAnalysisTableData,
      PrefetchHooks Function({bool trackId, bool trackEmotionSegmentTableRefs})
    >;
typedef $$TrackEmotionSegmentTableTableCreateCompanionBuilder =
    TrackEmotionSegmentTableCompanion Function({
      required String analysisId,
      required int segmentIndex,
      required int startMs,
      required int endMs,
      required double valence,
      required double arousal,
      Value<int> moodDistributionVersion,
      required String moodDistributionJson,
      Value<int> rowid,
    });
typedef $$TrackEmotionSegmentTableTableUpdateCompanionBuilder =
    TrackEmotionSegmentTableCompanion Function({
      Value<String> analysisId,
      Value<int> segmentIndex,
      Value<int> startMs,
      Value<int> endMs,
      Value<double> valence,
      Value<double> arousal,
      Value<int> moodDistributionVersion,
      Value<String> moodDistributionJson,
      Value<int> rowid,
    });

final class $$TrackEmotionSegmentTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackEmotionSegmentTableTable,
          TrackEmotionSegmentTableData
        > {
  $$TrackEmotionSegmentTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackEmotionAnalysisTableTable _analysisIdTable(_$AppDatabase db) =>
      db.trackEmotionAnalysisTable.createAlias(
        $_aliasNameGenerator(
          db.trackEmotionSegmentTable.analysisId,
          db.trackEmotionAnalysisTable.id,
        ),
      );

  $$TrackEmotionAnalysisTableTableProcessedTableManager get analysisId {
    final $_column = $_itemColumn<String>('analysis_id')!;

    final manager = $$TrackEmotionAnalysisTableTableTableManager(
      $_db,
      $_db.trackEmotionAnalysisTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_analysisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackEmotionSegmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $TrackEmotionSegmentTableTable> {
  $$TrackEmotionSegmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moodDistributionVersion => $composableBuilder(
    column: $table.moodDistributionVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodDistributionJson => $composableBuilder(
    column: $table.moodDistributionJson,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackEmotionAnalysisTableTableFilterComposer get analysisId {
    final $$TrackEmotionAnalysisTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.analysisId,
          referencedTable: $db.trackEmotionAnalysisTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackEmotionAnalysisTableTableFilterComposer(
                $db: $db,
                $table: $db.trackEmotionAnalysisTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrackEmotionSegmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackEmotionSegmentTableTable> {
  $$TrackEmotionSegmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moodDistributionVersion => $composableBuilder(
    column: $table.moodDistributionVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodDistributionJson => $composableBuilder(
    column: $table.moodDistributionJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackEmotionAnalysisTableTableOrderingComposer get analysisId {
    final $$TrackEmotionAnalysisTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.analysisId,
          referencedTable: $db.trackEmotionAnalysisTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackEmotionAnalysisTableTableOrderingComposer(
                $db: $db,
                $table: $db.trackEmotionAnalysisTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrackEmotionSegmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackEmotionSegmentTableTable> {
  $$TrackEmotionSegmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<double> get valence =>
      $composableBuilder(column: $table.valence, builder: (column) => column);

  GeneratedColumn<double> get arousal =>
      $composableBuilder(column: $table.arousal, builder: (column) => column);

  GeneratedColumn<int> get moodDistributionVersion => $composableBuilder(
    column: $table.moodDistributionVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moodDistributionJson => $composableBuilder(
    column: $table.moodDistributionJson,
    builder: (column) => column,
  );

  $$TrackEmotionAnalysisTableTableAnnotationComposer get analysisId {
    final $$TrackEmotionAnalysisTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.analysisId,
          referencedTable: $db.trackEmotionAnalysisTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackEmotionAnalysisTableTableAnnotationComposer(
                $db: $db,
                $table: $db.trackEmotionAnalysisTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TrackEmotionSegmentTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackEmotionSegmentTableTable,
          TrackEmotionSegmentTableData,
          $$TrackEmotionSegmentTableTableFilterComposer,
          $$TrackEmotionSegmentTableTableOrderingComposer,
          $$TrackEmotionSegmentTableTableAnnotationComposer,
          $$TrackEmotionSegmentTableTableCreateCompanionBuilder,
          $$TrackEmotionSegmentTableTableUpdateCompanionBuilder,
          (
            TrackEmotionSegmentTableData,
            $$TrackEmotionSegmentTableTableReferences,
          ),
          TrackEmotionSegmentTableData,
          PrefetchHooks Function({bool analysisId})
        > {
  $$TrackEmotionSegmentTableTableTableManager(
    _$AppDatabase db,
    $TrackEmotionSegmentTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackEmotionSegmentTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TrackEmotionSegmentTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackEmotionSegmentTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> analysisId = const Value.absent(),
                Value<int> segmentIndex = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<double> valence = const Value.absent(),
                Value<double> arousal = const Value.absent(),
                Value<int> moodDistributionVersion = const Value.absent(),
                Value<String> moodDistributionJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackEmotionSegmentTableCompanion(
                analysisId: analysisId,
                segmentIndex: segmentIndex,
                startMs: startMs,
                endMs: endMs,
                valence: valence,
                arousal: arousal,
                moodDistributionVersion: moodDistributionVersion,
                moodDistributionJson: moodDistributionJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String analysisId,
                required int segmentIndex,
                required int startMs,
                required int endMs,
                required double valence,
                required double arousal,
                Value<int> moodDistributionVersion = const Value.absent(),
                required String moodDistributionJson,
                Value<int> rowid = const Value.absent(),
              }) => TrackEmotionSegmentTableCompanion.insert(
                analysisId: analysisId,
                segmentIndex: segmentIndex,
                startMs: startMs,
                endMs: endMs,
                valence: valence,
                arousal: arousal,
                moodDistributionVersion: moodDistributionVersion,
                moodDistributionJson: moodDistributionJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackEmotionSegmentTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({analysisId = false}) {
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
                    if (analysisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.analysisId,
                                referencedTable:
                                    $$TrackEmotionSegmentTableTableReferences
                                        ._analysisIdTable(db),
                                referencedColumn:
                                    $$TrackEmotionSegmentTableTableReferences
                                        ._analysisIdTable(db)
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

typedef $$TrackEmotionSegmentTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackEmotionSegmentTableTable,
      TrackEmotionSegmentTableData,
      $$TrackEmotionSegmentTableTableFilterComposer,
      $$TrackEmotionSegmentTableTableOrderingComposer,
      $$TrackEmotionSegmentTableTableAnnotationComposer,
      $$TrackEmotionSegmentTableTableCreateCompanionBuilder,
      $$TrackEmotionSegmentTableTableUpdateCompanionBuilder,
      (TrackEmotionSegmentTableData, $$TrackEmotionSegmentTableTableReferences),
      TrackEmotionSegmentTableData,
      PrefetchHooks Function({bool analysisId})
    >;
typedef $$PersonalMoodAdjustmentTableTableCreateCompanionBuilder =
    PersonalMoodAdjustmentTableCompanion Function({
      required String trackId,
      required double valence,
      required double arousal,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PersonalMoodAdjustmentTableTableUpdateCompanionBuilder =
    PersonalMoodAdjustmentTableCompanion Function({
      Value<String> trackId,
      Value<double> valence,
      Value<double> arousal,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PersonalMoodAdjustmentTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PersonalMoodAdjustmentTableTable,
          PersonalMoodAdjustmentTableData
        > {
  $$PersonalMoodAdjustmentTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackTableTable _trackIdTable(_$AppDatabase db) =>
      db.trackTable.createAlias(
        $_aliasNameGenerator(
          db.personalMoodAdjustmentTable.trackId,
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

class $$PersonalMoodAdjustmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalMoodAdjustmentTableTable> {
  $$PersonalMoodAdjustmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$PersonalMoodAdjustmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalMoodAdjustmentTableTable> {
  $$PersonalMoodAdjustmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
}

class $$PersonalMoodAdjustmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalMoodAdjustmentTableTable> {
  $$PersonalMoodAdjustmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get valence =>
      $composableBuilder(column: $table.valence, builder: (column) => column);

  GeneratedColumn<double> get arousal =>
      $composableBuilder(column: $table.arousal, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$PersonalMoodAdjustmentTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalMoodAdjustmentTableTable,
          PersonalMoodAdjustmentTableData,
          $$PersonalMoodAdjustmentTableTableFilterComposer,
          $$PersonalMoodAdjustmentTableTableOrderingComposer,
          $$PersonalMoodAdjustmentTableTableAnnotationComposer,
          $$PersonalMoodAdjustmentTableTableCreateCompanionBuilder,
          $$PersonalMoodAdjustmentTableTableUpdateCompanionBuilder,
          (
            PersonalMoodAdjustmentTableData,
            $$PersonalMoodAdjustmentTableTableReferences,
          ),
          PersonalMoodAdjustmentTableData,
          PrefetchHooks Function({bool trackId})
        > {
  $$PersonalMoodAdjustmentTableTableTableManager(
    _$AppDatabase db,
    $PersonalMoodAdjustmentTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalMoodAdjustmentTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PersonalMoodAdjustmentTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PersonalMoodAdjustmentTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<double> valence = const Value.absent(),
                Value<double> arousal = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalMoodAdjustmentTableCompanion(
                trackId: trackId,
                valence: valence,
                arousal: arousal,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required double valence,
                required double arousal,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonalMoodAdjustmentTableCompanion.insert(
                trackId: trackId,
                valence: valence,
                arousal: arousal,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalMoodAdjustmentTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
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
                                    $$PersonalMoodAdjustmentTableTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$PersonalMoodAdjustmentTableTableReferences
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

typedef $$PersonalMoodAdjustmentTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalMoodAdjustmentTableTable,
      PersonalMoodAdjustmentTableData,
      $$PersonalMoodAdjustmentTableTableFilterComposer,
      $$PersonalMoodAdjustmentTableTableOrderingComposer,
      $$PersonalMoodAdjustmentTableTableAnnotationComposer,
      $$PersonalMoodAdjustmentTableTableCreateCompanionBuilder,
      $$PersonalMoodAdjustmentTableTableUpdateCompanionBuilder,
      (
        PersonalMoodAdjustmentTableData,
        $$PersonalMoodAdjustmentTableTableReferences,
      ),
      PersonalMoodAdjustmentTableData,
      PrefetchHooks Function({bool trackId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ListeningSummaryTableTableTableManager get listeningSummaryTable =>
      $$ListeningSummaryTableTableTableManager(_db, _db.listeningSummaryTable);
  $$PlaylistTableTableTableManager get playlistTable =>
      $$PlaylistTableTableTableManager(_db, _db.playlistTable);
  $$TrackTableTableTableManager get trackTable =>
      $$TrackTableTableTableManager(_db, _db.trackTable);
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
  $$TrackEmbeddingTableTableTableManager get trackEmbeddingTable =>
      $$TrackEmbeddingTableTableTableManager(_db, _db.trackEmbeddingTable);
  $$ListeningEventTableTableTableManager get listeningEventTable =>
      $$ListeningEventTableTableTableManager(_db, _db.listeningEventTable);
  $$TrackTemporalEmbeddingTableTableTableManager
  get trackTemporalEmbeddingTable =>
      $$TrackTemporalEmbeddingTableTableTableManager(
        _db,
        _db.trackTemporalEmbeddingTable,
      );
  $$TrackTemporalEmbeddingSegmentTableTableTableManager
  get trackTemporalEmbeddingSegmentTable =>
      $$TrackTemporalEmbeddingSegmentTableTableTableManager(
        _db,
        _db.trackTemporalEmbeddingSegmentTable,
      );
  $$MusicAnalysisTaskTableTableTableManager get musicAnalysisTaskTable =>
      $$MusicAnalysisTaskTableTableTableManager(
        _db,
        _db.musicAnalysisTaskTable,
      );
  $$MusicAnalysisSettingsTableTableTableManager
  get musicAnalysisSettingsTable =>
      $$MusicAnalysisSettingsTableTableTableManager(
        _db,
        _db.musicAnalysisSettingsTable,
      );
  $$SimilarityEvaluationTableTableTableManager get similarityEvaluationTable =>
      $$SimilarityEvaluationTableTableTableManager(
        _db,
        _db.similarityEvaluationTable,
      );
  $$TrackLyricsTableTableTableManager get trackLyricsTable =>
      $$TrackLyricsTableTableTableManager(_db, _db.trackLyricsTable);
  $$LyricsResolutionStateTableTableTableManager
  get lyricsResolutionStateTable =>
      $$LyricsResolutionStateTableTableTableManager(
        _db,
        _db.lyricsResolutionStateTable,
      );
  $$LyricsResolutionTaskTableTableTableManager get lyricsResolutionTaskTable =>
      $$LyricsResolutionTaskTableTableTableManager(
        _db,
        _db.lyricsResolutionTaskTable,
      );
  $$TrackEmotionAnalysisTableTableTableManager get trackEmotionAnalysisTable =>
      $$TrackEmotionAnalysisTableTableTableManager(
        _db,
        _db.trackEmotionAnalysisTable,
      );
  $$TrackEmotionSegmentTableTableTableManager get trackEmotionSegmentTable =>
      $$TrackEmotionSegmentTableTableTableManager(
        _db,
        _db.trackEmotionSegmentTable,
      );
  $$PersonalMoodAdjustmentTableTableTableManager
  get personalMoodAdjustmentTable =>
      $$PersonalMoodAdjustmentTableTableTableManager(
        _db,
        _db.personalMoodAdjustmentTable,
      );
}
