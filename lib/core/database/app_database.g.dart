// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentJsonMeta = const VerificationMeta(
    'contentJson',
  );
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
    'content_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentimentScoreMeta = const VerificationMeta(
    'sentimentScore',
  );
  @override
  late final GeneratedColumn<double> sentimentScore = GeneratedColumn<double>(
    'sentiment_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUuidMeta = const VerificationMeta(
    'localUuid',
  );
  @override
  late final GeneratedColumn<String> localUuid = GeneratedColumn<String>(
    'local_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentJson,
    entryDate,
    sentimentScore,
    localUuid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_json')) {
      context.handle(
        _contentJsonMeta,
        contentJson.isAcceptableOrUnknown(
          data['content_json']!,
          _contentJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentJsonMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('sentiment_score')) {
      context.handle(
        _sentimentScoreMeta,
        sentimentScore.isAcceptableOrUnknown(
          data['sentiment_score']!,
          _sentimentScoreMeta,
        ),
      );
    }
    if (data.containsKey('local_uuid')) {
      context.handle(
        _localUuidMeta,
        localUuid.isAcceptableOrUnknown(data['local_uuid']!, _localUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_localUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_json'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
      sentimentScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sentiment_score'],
      ),
      localUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_uuid'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final int id;

  /// Rich text content stored as JSON (Quill Delta or similar).
  final String contentJson;

  /// Local date-time of the entry.
  final DateTime entryDate;

  /// Sentiment score from on-device AI, nullable until calculated.
  final double? sentimentScore;

  /// Stable local UUID for matching across sync and devices.
  final String localUuid;
  const JournalEntry({
    required this.id,
    required this.contentJson,
    required this.entryDate,
    this.sentimentScore,
    required this.localUuid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_json'] = Variable<String>(contentJson);
    map['entry_date'] = Variable<DateTime>(entryDate);
    if (!nullToAbsent || sentimentScore != null) {
      map['sentiment_score'] = Variable<double>(sentimentScore);
    }
    map['local_uuid'] = Variable<String>(localUuid);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      contentJson: Value(contentJson),
      entryDate: Value(entryDate),
      sentimentScore: sentimentScore == null && nullToAbsent
          ? const Value.absent()
          : Value(sentimentScore),
      localUuid: Value(localUuid),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<int>(json['id']),
      contentJson: serializer.fromJson<String>(json['contentJson']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      sentimentScore: serializer.fromJson<double?>(json['sentimentScore']),
      localUuid: serializer.fromJson<String>(json['localUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contentJson': serializer.toJson<String>(contentJson),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'sentimentScore': serializer.toJson<double?>(sentimentScore),
      'localUuid': serializer.toJson<String>(localUuid),
    };
  }

  JournalEntry copyWith({
    int? id,
    String? contentJson,
    DateTime? entryDate,
    Value<double?> sentimentScore = const Value.absent(),
    String? localUuid,
  }) => JournalEntry(
    id: id ?? this.id,
    contentJson: contentJson ?? this.contentJson,
    entryDate: entryDate ?? this.entryDate,
    sentimentScore: sentimentScore.present
        ? sentimentScore.value
        : this.sentimentScore,
    localUuid: localUuid ?? this.localUuid,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      contentJson: data.contentJson.present
          ? data.contentJson.value
          : this.contentJson,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      sentimentScore: data.sentimentScore.present
          ? data.sentimentScore.value
          : this.sentimentScore,
      localUuid: data.localUuid.present ? data.localUuid.value : this.localUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('contentJson: $contentJson, ')
          ..write('entryDate: $entryDate, ')
          ..write('sentimentScore: $sentimentScore, ')
          ..write('localUuid: $localUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contentJson, entryDate, sentimentScore, localUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.contentJson == this.contentJson &&
          other.entryDate == this.entryDate &&
          other.sentimentScore == this.sentimentScore &&
          other.localUuid == this.localUuid);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<int> id;
  final Value<String> contentJson;
  final Value<DateTime> entryDate;
  final Value<double?> sentimentScore;
  final Value<String> localUuid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.sentimentScore = const Value.absent(),
    this.localUuid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String contentJson,
    required DateTime entryDate,
    this.sentimentScore = const Value.absent(),
    required String localUuid,
  }) : contentJson = Value(contentJson),
       entryDate = Value(entryDate),
       localUuid = Value(localUuid);
  static Insertable<JournalEntry> custom({
    Expression<int>? id,
    Expression<String>? contentJson,
    Expression<DateTime>? entryDate,
    Expression<double>? sentimentScore,
    Expression<String>? localUuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentJson != null) 'content_json': contentJson,
      if (entryDate != null) 'entry_date': entryDate,
      if (sentimentScore != null) 'sentiment_score': sentimentScore,
      if (localUuid != null) 'local_uuid': localUuid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? contentJson,
    Value<DateTime>? entryDate,
    Value<double?>? sentimentScore,
    Value<String>? localUuid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      contentJson: contentJson ?? this.contentJson,
      entryDate: entryDate ?? this.entryDate,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      localUuid: localUuid ?? this.localUuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (sentimentScore.present) {
      map['sentiment_score'] = Variable<double>(sentimentScore.value);
    }
    if (localUuid.present) {
      map['local_uuid'] = Variable<String>(localUuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('contentJson: $contentJson, ')
          ..write('entryDate: $entryDate, ')
          ..write('sentimentScore: $sentimentScore, ')
          ..write('localUuid: $localUuid')
          ..write(')'))
        .toString();
  }
}

class $TemplateInstancesTable extends TemplateInstances
    with TableInfo<$TemplateInstancesTable, TemplateInstance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateInstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journal_entries (id)',
    ),
  );
  static const VerificationMeta _templateTypeMeta = const VerificationMeta(
    'templateType',
  );
  @override
  late final GeneratedColumn<String> templateType = GeneratedColumn<String>(
    'template_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    templateType,
    payloadJson,
    schemaVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_instances';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateInstance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('template_type')) {
      context.handle(
        _templateTypeMeta,
        templateType.isAcceptableOrUnknown(
          data['template_type']!,
          _templateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateInstance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateInstance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      templateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
    );
  }

  @override
  $TemplateInstancesTable createAlias(String alias) {
    return $TemplateInstancesTable(attachedDatabase, alias);
  }
}

class TemplateInstance extends DataClass
    implements Insertable<TemplateInstance> {
  final int id;
  final int entryId;

  /// Logical type of the template, e.g. 'dive_log', 'tennis', 'nutrition'.
  final String templateType;

  /// Template payload as JSON, schema defined by the template engine.
  final String payloadJson;

  /// Version of the JSON schema used when this instance was created.
  final int schemaVersion;
  const TemplateInstance({
    required this.id,
    required this.entryId,
    required this.templateType,
    required this.payloadJson,
    required this.schemaVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    map['template_type'] = Variable<String>(templateType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  TemplateInstancesCompanion toCompanion(bool nullToAbsent) {
    return TemplateInstancesCompanion(
      id: Value(id),
      entryId: Value(entryId),
      templateType: Value(templateType),
      payloadJson: Value(payloadJson),
      schemaVersion: Value(schemaVersion),
    );
  }

  factory TemplateInstance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateInstance(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      templateType: serializer.fromJson<String>(json['templateType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'templateType': serializer.toJson<String>(templateType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  TemplateInstance copyWith({
    int? id,
    int? entryId,
    String? templateType,
    String? payloadJson,
    int? schemaVersion,
  }) => TemplateInstance(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    templateType: templateType ?? this.templateType,
    payloadJson: payloadJson ?? this.payloadJson,
    schemaVersion: schemaVersion ?? this.schemaVersion,
  );
  TemplateInstance copyWithCompanion(TemplateInstancesCompanion data) {
    return TemplateInstance(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      templateType: data.templateType.present
          ? data.templateType.value
          : this.templateType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateInstance(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('templateType: $templateType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entryId, templateType, payloadJson, schemaVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateInstance &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.templateType == this.templateType &&
          other.payloadJson == this.payloadJson &&
          other.schemaVersion == this.schemaVersion);
}

class TemplateInstancesCompanion extends UpdateCompanion<TemplateInstance> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<String> templateType;
  final Value<String> payloadJson;
  final Value<int> schemaVersion;
  const TemplateInstancesCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.templateType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.schemaVersion = const Value.absent(),
  });
  TemplateInstancesCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required String templateType,
    required String payloadJson,
    this.schemaVersion = const Value.absent(),
  }) : entryId = Value(entryId),
       templateType = Value(templateType),
       payloadJson = Value(payloadJson);
  static Insertable<TemplateInstance> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? templateType,
    Expression<String>? payloadJson,
    Expression<int>? schemaVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (templateType != null) 'template_type': templateType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (schemaVersion != null) 'schema_version': schemaVersion,
    });
  }

  TemplateInstancesCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<String>? templateType,
    Value<String>? payloadJson,
    Value<int>? schemaVersion,
  }) {
    return TemplateInstancesCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      templateType: templateType ?? this.templateType,
      payloadJson: payloadJson ?? this.payloadJson,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (templateType.present) {
      map['template_type'] = Variable<String>(templateType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateInstancesCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('templateType: $templateType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }
}

class $MediaAssetsTable extends MediaAssets
    with TableInfo<$MediaAssetsTable, MediaAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journal_entries (id)',
    ),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transformDataJsonMeta = const VerificationMeta(
    'transformDataJson',
  );
  @override
  late final GeneratedColumn<String> transformDataJson =
      GeneratedColumn<String>(
        'transform_data_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    localPath,
    thumbnailPath,
    transformDataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('transform_data_json')) {
      context.handle(
        _transformDataJsonMeta,
        transformDataJson.isAcceptableOrUnknown(
          data['transform_data_json']!,
          _transformDataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      transformDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transform_data_json'],
      ),
    );
  }

  @override
  $MediaAssetsTable createAlias(String alias) {
    return $MediaAssetsTable(attachedDatabase, alias);
  }
}

class MediaAsset extends DataClass implements Insertable<MediaAsset> {
  final int id;
  final int entryId;

  /// Absolute or app-relative path to the original media.
  final String localPath;

  /// Optional thumbnail path for images.
  final String? thumbnailPath;

  /// JSON-encoded transform metadata (Matrix4, filters, etc.).
  final String? transformDataJson;
  const MediaAsset({
    required this.id,
    required this.entryId,
    required this.localPath,
    this.thumbnailPath,
    this.transformDataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || transformDataJson != null) {
      map['transform_data_json'] = Variable<String>(transformDataJson);
    }
    return map;
  }

  MediaAssetsCompanion toCompanion(bool nullToAbsent) {
    return MediaAssetsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      localPath: Value(localPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      transformDataJson: transformDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(transformDataJson),
    );
  }

  factory MediaAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAsset(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      transformDataJson: serializer.fromJson<String?>(
        json['transformDataJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'localPath': serializer.toJson<String>(localPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'transformDataJson': serializer.toJson<String?>(transformDataJson),
    };
  }

  MediaAsset copyWith({
    int? id,
    int? entryId,
    String? localPath,
    Value<String?> thumbnailPath = const Value.absent(),
    Value<String?> transformDataJson = const Value.absent(),
  }) => MediaAsset(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    localPath: localPath ?? this.localPath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    transformDataJson: transformDataJson.present
        ? transformDataJson.value
        : this.transformDataJson,
  );
  MediaAsset copyWithCompanion(MediaAssetsCompanion data) {
    return MediaAsset(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      transformDataJson: data.transformDataJson.present
          ? data.transformDataJson.value
          : this.transformDataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAsset(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('transformDataJson: $transformDataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entryId, localPath, thumbnailPath, transformDataJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAsset &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.localPath == this.localPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.transformDataJson == this.transformDataJson);
}

class MediaAssetsCompanion extends UpdateCompanion<MediaAsset> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<String> localPath;
  final Value<String?> thumbnailPath;
  final Value<String?> transformDataJson;
  const MediaAssetsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.transformDataJson = const Value.absent(),
  });
  MediaAssetsCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required String localPath,
    this.thumbnailPath = const Value.absent(),
    this.transformDataJson = const Value.absent(),
  }) : entryId = Value(entryId),
       localPath = Value(localPath);
  static Insertable<MediaAsset> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? localPath,
    Expression<String>? thumbnailPath,
    Expression<String>? transformDataJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (localPath != null) 'local_path': localPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (transformDataJson != null) 'transform_data_json': transformDataJson,
    });
  }

  MediaAssetsCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<String>? localPath,
    Value<String?>? thumbnailPath,
    Value<String?>? transformDataJson,
  }) {
    return MediaAssetsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      transformDataJson: transformDataJson ?? this.transformDataJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (transformDataJson.present) {
      map['transform_data_json'] = Variable<String>(transformDataJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('transformDataJson: $transformDataJson')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journal_entries (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, entryId, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final int entryId;

  /// Tag label, e.g. 'work', 'dive', 'tennis'.
  final String label;
  const Tag({required this.id, required this.entryId, required this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    map['label'] = Variable<String>(label);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      label: Value(label),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'label': serializer.toJson<String>(label),
    };
  }

  Tag copyWith({int? id, int? entryId, String? label}) => Tag(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    label: label ?? this.label,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entryId, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.label == this.label);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<String> label;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.label = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required String label,
  }) : entryId = Value(entryId),
       label = Value(label);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? label,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (label != null) 'label': label,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<String>? label,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      label: label ?? this.label,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('classic'),
  );
  static const VerificationMeta _dailyWaterTargetMlMeta =
      const VerificationMeta('dailyWaterTargetMl');
  @override
  late final GeneratedColumn<int> dailyWaterTargetMl = GeneratedColumn<int>(
    'daily_water_target_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2000),
  );
  static const VerificationMeta _autoLockMinutesMeta = const VerificationMeta(
    'autoLockMinutes',
  );
  @override
  late final GeneratedColumn<int> autoLockMinutes = GeneratedColumn<int>(
    'auto_lock_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _biometricLockEnabledMeta =
      const VerificationMeta('biometricLockEnabled');
  @override
  late final GeneratedColumn<bool> biometricLockEnabled = GeneratedColumn<bool>(
    'biometric_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("biometric_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    theme,
    dailyWaterTargetMl,
    autoLockMinutes,
    biometricLockEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('daily_water_target_ml')) {
      context.handle(
        _dailyWaterTargetMlMeta,
        dailyWaterTargetMl.isAcceptableOrUnknown(
          data['daily_water_target_ml']!,
          _dailyWaterTargetMlMeta,
        ),
      );
    }
    if (data.containsKey('auto_lock_minutes')) {
      context.handle(
        _autoLockMinutesMeta,
        autoLockMinutes.isAcceptableOrUnknown(
          data['auto_lock_minutes']!,
          _autoLockMinutesMeta,
        ),
      );
    }
    if (data.containsKey('biometric_lock_enabled')) {
      context.handle(
        _biometricLockEnabledMeta,
        biometricLockEnabled.isAcceptableOrUnknown(
          data['biometric_lock_enabled']!,
          _biometricLockEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      dailyWaterTargetMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_water_target_ml'],
      )!,
      autoLockMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_lock_minutes'],
      )!,
      biometricLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}biometric_lock_enabled'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final int id;

  /// Current theme identifier (e.g. 'classic', 'dark', 'sepia').
  final String theme;

  /// Daily water target in milliliters.
  final int dailyWaterTargetMl;

  /// Auto-lock timeout in minutes (0 = immediately).
  final int autoLockMinutes;

  /// Whether biometric lock is enabled.
  final bool biometricLockEnabled;
  const UserSetting({
    required this.id,
    required this.theme,
    required this.dailyWaterTargetMl,
    required this.autoLockMinutes,
    required this.biometricLockEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme'] = Variable<String>(theme);
    map['daily_water_target_ml'] = Variable<int>(dailyWaterTargetMl);
    map['auto_lock_minutes'] = Variable<int>(autoLockMinutes);
    map['biometric_lock_enabled'] = Variable<bool>(biometricLockEnabled);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      theme: Value(theme),
      dailyWaterTargetMl: Value(dailyWaterTargetMl),
      autoLockMinutes: Value(autoLockMinutes),
      biometricLockEnabled: Value(biometricLockEnabled),
    );
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<int>(json['id']),
      theme: serializer.fromJson<String>(json['theme']),
      dailyWaterTargetMl: serializer.fromJson<int>(json['dailyWaterTargetMl']),
      autoLockMinutes: serializer.fromJson<int>(json['autoLockMinutes']),
      biometricLockEnabled: serializer.fromJson<bool>(
        json['biometricLockEnabled'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'theme': serializer.toJson<String>(theme),
      'dailyWaterTargetMl': serializer.toJson<int>(dailyWaterTargetMl),
      'autoLockMinutes': serializer.toJson<int>(autoLockMinutes),
      'biometricLockEnabled': serializer.toJson<bool>(biometricLockEnabled),
    };
  }

  UserSetting copyWith({
    int? id,
    String? theme,
    int? dailyWaterTargetMl,
    int? autoLockMinutes,
    bool? biometricLockEnabled,
  }) => UserSetting(
    id: id ?? this.id,
    theme: theme ?? this.theme,
    dailyWaterTargetMl: dailyWaterTargetMl ?? this.dailyWaterTargetMl,
    autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
  );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      id: data.id.present ? data.id.value : this.id,
      theme: data.theme.present ? data.theme.value : this.theme,
      dailyWaterTargetMl: data.dailyWaterTargetMl.present
          ? data.dailyWaterTargetMl.value
          : this.dailyWaterTargetMl,
      autoLockMinutes: data.autoLockMinutes.present
          ? data.autoLockMinutes.value
          : this.autoLockMinutes,
      biometricLockEnabled: data.biometricLockEnabled.present
          ? data.biometricLockEnabled.value
          : this.biometricLockEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('dailyWaterTargetMl: $dailyWaterTargetMl, ')
          ..write('autoLockMinutes: $autoLockMinutes, ')
          ..write('biometricLockEnabled: $biometricLockEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    theme,
    dailyWaterTargetMl,
    autoLockMinutes,
    biometricLockEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.theme == this.theme &&
          other.dailyWaterTargetMl == this.dailyWaterTargetMl &&
          other.autoLockMinutes == this.autoLockMinutes &&
          other.biometricLockEnabled == this.biometricLockEnabled);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<int> id;
  final Value<String> theme;
  final Value<int> dailyWaterTargetMl;
  final Value<int> autoLockMinutes;
  final Value<bool> biometricLockEnabled;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.dailyWaterTargetMl = const Value.absent(),
    this.autoLockMinutes = const Value.absent(),
    this.biometricLockEnabled = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.dailyWaterTargetMl = const Value.absent(),
    this.autoLockMinutes = const Value.absent(),
    this.biometricLockEnabled = const Value.absent(),
  });
  static Insertable<UserSetting> custom({
    Expression<int>? id,
    Expression<String>? theme,
    Expression<int>? dailyWaterTargetMl,
    Expression<int>? autoLockMinutes,
    Expression<bool>? biometricLockEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (theme != null) 'theme': theme,
      if (dailyWaterTargetMl != null)
        'daily_water_target_ml': dailyWaterTargetMl,
      if (autoLockMinutes != null) 'auto_lock_minutes': autoLockMinutes,
      if (biometricLockEnabled != null)
        'biometric_lock_enabled': biometricLockEnabled,
    });
  }

  UserSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? theme,
    Value<int>? dailyWaterTargetMl,
    Value<int>? autoLockMinutes,
    Value<bool>? biometricLockEnabled,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      dailyWaterTargetMl: dailyWaterTargetMl ?? this.dailyWaterTargetMl,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (dailyWaterTargetMl.present) {
      map['daily_water_target_ml'] = Variable<int>(dailyWaterTargetMl.value);
    }
    if (autoLockMinutes.present) {
      map['auto_lock_minutes'] = Variable<int>(autoLockMinutes.value);
    }
    if (biometricLockEnabled.present) {
      map['biometric_lock_enabled'] = Variable<bool>(
        biometricLockEnabled.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('dailyWaterTargetMl: $dailyWaterTargetMl, ')
          ..write('autoLockMinutes: $autoLockMinutes, ')
          ..write('biometricLockEnabled: $biometricLockEnabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $TemplateInstancesTable templateInstances =
      $TemplateInstancesTable(this);
  late final $MediaAssetsTable mediaAssets = $MediaAssetsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    journalEntries,
    templateInstances,
    mediaAssets,
    tags,
    userSettings,
  ];
}

typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      required String contentJson,
      required DateTime entryDate,
      Value<double?> sentimentScore,
      required String localUuid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      Value<String> contentJson,
      Value<DateTime> entryDate,
      Value<double?> sentimentScore,
      Value<String> localUuid,
    });

final class $$JournalEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry> {
  $$JournalEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TemplateInstancesTable, List<TemplateInstance>>
  _templateInstancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateInstances,
        aliasName: $_aliasNameGenerator(
          db.journalEntries.id,
          db.templateInstances.entryId,
        ),
      );

  $$TemplateInstancesTableProcessedTableManager get templateInstancesRefs {
    final manager = $$TemplateInstancesTableTableManager(
      $_db,
      $_db.templateInstances,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateInstancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MediaAssetsTable, List<MediaAsset>>
  _mediaAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mediaAssets,
    aliasName: $_aliasNameGenerator(
      db.journalEntries.id,
      db.mediaAssets.entryId,
    ),
  );

  $$MediaAssetsTableProcessedTableManager get mediaAssetsRefs {
    final manager = $$MediaAssetsTableTableManager(
      $_db,
      $_db.mediaAssets,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TagsTable, List<Tag>> _tagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tags,
    aliasName: $_aliasNameGenerator(db.journalEntries.id, db.tags.entryId),
  );

  $$TagsTableProcessedTableManager get tagsRefs {
    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
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

  ColumnFilters<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sentimentScore => $composableBuilder(
    column: $table.sentimentScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localUuid => $composableBuilder(
    column: $table.localUuid,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> templateInstancesRefs(
    Expression<bool> Function($$TemplateInstancesTableFilterComposer f) f,
  ) {
    final $$TemplateInstancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateInstances,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateInstancesTableFilterComposer(
            $db: $db,
            $table: $db.templateInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mediaAssetsRefs(
    Expression<bool> Function($$MediaAssetsTableFilterComposer f) f,
  ) {
    final $$MediaAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableFilterComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tagsRefs(
    Expression<bool> Function($$TagsTableFilterComposer f) f,
  ) {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sentimentScore => $composableBuilder(
    column: $table.sentimentScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localUuid => $composableBuilder(
    column: $table.localUuid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<double> get sentimentScore => $composableBuilder(
    column: $table.sentimentScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localUuid =>
      $composableBuilder(column: $table.localUuid, builder: (column) => column);

  Expression<T> templateInstancesRefs<T extends Object>(
    Expression<T> Function($$TemplateInstancesTableAnnotationComposer a) f,
  ) {
    final $$TemplateInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateInstances,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.templateInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> mediaAssetsRefs<T extends Object>(
    Expression<T> Function($$MediaAssetsTableAnnotationComposer a) f,
  ) {
    final $$MediaAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tagsRefs<T extends Object>(
    Expression<T> Function($$TagsTableAnnotationComposer a) f,
  ) {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (JournalEntry, $$JournalEntriesTableReferences),
          JournalEntry,
          PrefetchHooks Function({
            bool templateInstancesRefs,
            bool mediaAssetsRefs,
            bool tagsRefs,
          })
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contentJson = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<double?> sentimentScore = const Value.absent(),
                Value<String> localUuid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                contentJson: contentJson,
                entryDate: entryDate,
                sentimentScore: sentimentScore,
                localUuid: localUuid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentJson,
                required DateTime entryDate,
                Value<double?> sentimentScore = const Value.absent(),
                required String localUuid,
              }) => JournalEntriesCompanion.insert(
                id: id,
                contentJson: contentJson,
                entryDate: entryDate,
                sentimentScore: sentimentScore,
                localUuid: localUuid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JournalEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                templateInstancesRefs = false,
                mediaAssetsRefs = false,
                tagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (templateInstancesRefs) db.templateInstances,
                    if (mediaAssetsRefs) db.mediaAssets,
                    if (tagsRefs) db.tags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (templateInstancesRefs)
                        await $_getPrefetchedData<
                          JournalEntry,
                          $JournalEntriesTable,
                          TemplateInstance
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._templateInstancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).templateInstancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mediaAssetsRefs)
                        await $_getPrefetchedData<
                          JournalEntry,
                          $JournalEntriesTable,
                          MediaAsset
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._mediaAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tagsRefs)
                        await $_getPrefetchedData<
                          JournalEntry,
                          $JournalEntriesTable,
                          Tag
                        >(
                          currentTable: table,
                          referencedTable: $$JournalEntriesTableReferences
                              ._tagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).tagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
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

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (JournalEntry, $$JournalEntriesTableReferences),
      JournalEntry,
      PrefetchHooks Function({
        bool templateInstancesRefs,
        bool mediaAssetsRefs,
        bool tagsRefs,
      })
    >;
typedef $$TemplateInstancesTableCreateCompanionBuilder =
    TemplateInstancesCompanion Function({
      Value<int> id,
      required int entryId,
      required String templateType,
      required String payloadJson,
      Value<int> schemaVersion,
    });
typedef $$TemplateInstancesTableUpdateCompanionBuilder =
    TemplateInstancesCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<String> templateType,
      Value<String> payloadJson,
      Value<int> schemaVersion,
    });

final class $$TemplateInstancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TemplateInstancesTable,
          TemplateInstance
        > {
  $$TemplateInstancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JournalEntriesTable _entryIdTable(_$AppDatabase db) =>
      db.journalEntries.createAlias(
        $_aliasNameGenerator(
          db.templateInstances.entryId,
          db.journalEntries.id,
        ),
      );

  $$JournalEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TemplateInstancesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplateInstancesTable> {
  $$TemplateInstancesTableFilterComposer({
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

  ColumnFilters<String> get templateType => $composableBuilder(
    column: $table.templateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalEntriesTableFilterComposer get entryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableFilterComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateInstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplateInstancesTable> {
  $$TemplateInstancesTableOrderingComposer({
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

  ColumnOrderings<String> get templateType => $composableBuilder(
    column: $table.templateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalEntriesTableOrderingComposer get entryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateInstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplateInstancesTable> {
  $$TemplateInstancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateType => $composableBuilder(
    column: $table.templateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  $$JournalEntriesTableAnnotationComposer get entryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateInstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplateInstancesTable,
          TemplateInstance,
          $$TemplateInstancesTableFilterComposer,
          $$TemplateInstancesTableOrderingComposer,
          $$TemplateInstancesTableAnnotationComposer,
          $$TemplateInstancesTableCreateCompanionBuilder,
          $$TemplateInstancesTableUpdateCompanionBuilder,
          (TemplateInstance, $$TemplateInstancesTableReferences),
          TemplateInstance,
          PrefetchHooks Function({bool entryId})
        > {
  $$TemplateInstancesTableTableManager(
    _$AppDatabase db,
    $TemplateInstancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateInstancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateInstancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateInstancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<String> templateType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
              }) => TemplateInstancesCompanion(
                id: id,
                entryId: entryId,
                templateType: templateType,
                payloadJson: payloadJson,
                schemaVersion: schemaVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required String templateType,
                required String payloadJson,
                Value<int> schemaVersion = const Value.absent(),
              }) => TemplateInstancesCompanion.insert(
                id: id,
                entryId: entryId,
                templateType: templateType,
                payloadJson: payloadJson,
                schemaVersion: schemaVersion,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TemplateInstancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
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
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable:
                                    $$TemplateInstancesTableReferences
                                        ._entryIdTable(db),
                                referencedColumn:
                                    $$TemplateInstancesTableReferences
                                        ._entryIdTable(db)
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

typedef $$TemplateInstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplateInstancesTable,
      TemplateInstance,
      $$TemplateInstancesTableFilterComposer,
      $$TemplateInstancesTableOrderingComposer,
      $$TemplateInstancesTableAnnotationComposer,
      $$TemplateInstancesTableCreateCompanionBuilder,
      $$TemplateInstancesTableUpdateCompanionBuilder,
      (TemplateInstance, $$TemplateInstancesTableReferences),
      TemplateInstance,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$MediaAssetsTableCreateCompanionBuilder =
    MediaAssetsCompanion Function({
      Value<int> id,
      required int entryId,
      required String localPath,
      Value<String?> thumbnailPath,
      Value<String?> transformDataJson,
    });
typedef $$MediaAssetsTableUpdateCompanionBuilder =
    MediaAssetsCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<String> localPath,
      Value<String?> thumbnailPath,
      Value<String?> transformDataJson,
    });

final class $$MediaAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaAssetsTable, MediaAsset> {
  $$MediaAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JournalEntriesTable _entryIdTable(_$AppDatabase db) =>
      db.journalEntries.createAlias(
        $_aliasNameGenerator(db.mediaAssets.entryId, db.journalEntries.id),
      );

  $$JournalEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableFilterComposer({
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

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transformDataJson => $composableBuilder(
    column: $table.transformDataJson,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalEntriesTableFilterComposer get entryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableFilterComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableOrderingComposer({
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

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transformDataJson => $composableBuilder(
    column: $table.transformDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalEntriesTableOrderingComposer get entryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transformDataJson => $composableBuilder(
    column: $table.transformDataJson,
    builder: (column) => column,
  );

  $$JournalEntriesTableAnnotationComposer get entryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaAssetsTable,
          MediaAsset,
          $$MediaAssetsTableFilterComposer,
          $$MediaAssetsTableOrderingComposer,
          $$MediaAssetsTableAnnotationComposer,
          $$MediaAssetsTableCreateCompanionBuilder,
          $$MediaAssetsTableUpdateCompanionBuilder,
          (MediaAsset, $$MediaAssetsTableReferences),
          MediaAsset,
          PrefetchHooks Function({bool entryId})
        > {
  $$MediaAssetsTableTableManager(_$AppDatabase db, $MediaAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> transformDataJson = const Value.absent(),
              }) => MediaAssetsCompanion(
                id: id,
                entryId: entryId,
                localPath: localPath,
                thumbnailPath: thumbnailPath,
                transformDataJson: transformDataJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required String localPath,
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> transformDataJson = const Value.absent(),
              }) => MediaAssetsCompanion.insert(
                id: id,
                entryId: entryId,
                localPath: localPath,
                thumbnailPath: thumbnailPath,
                transformDataJson: transformDataJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
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
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$MediaAssetsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$MediaAssetsTableReferences
                                    ._entryIdTable(db)
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

typedef $$MediaAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaAssetsTable,
      MediaAsset,
      $$MediaAssetsTableFilterComposer,
      $$MediaAssetsTableOrderingComposer,
      $$MediaAssetsTableAnnotationComposer,
      $$MediaAssetsTableCreateCompanionBuilder,
      $$MediaAssetsTableUpdateCompanionBuilder,
      (MediaAsset, $$MediaAssetsTableReferences),
      MediaAsset,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required int entryId,
      required String label,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<String> label,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JournalEntriesTable _entryIdTable(_$AppDatabase db) => db
      .journalEntries
      .createAlias($_aliasNameGenerator(db.tags.entryId, db.journalEntries.id));

  $$JournalEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalEntriesTableFilterComposer get entryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableFilterComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalEntriesTableOrderingComposer get entryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$JournalEntriesTableAnnotationComposer get entryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool entryId})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<String> label = const Value.absent(),
              }) => TagsCompanion(id: id, entryId: entryId, label: label),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required String label,
              }) =>
                  TagsCompanion.insert(id: id, entryId: entryId, label: label),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
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
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$TagsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$TagsTableReferences
                                    ._entryIdTable(db)
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

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<String> theme,
      Value<int> dailyWaterTargetMl,
      Value<int> autoLockMinutes,
      Value<bool> biometricLockEnabled,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<String> theme,
      Value<int> dailyWaterTargetMl,
      Value<int> autoLockMinutes,
      Value<bool> biometricLockEnabled,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
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

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyWaterTargetMl => $composableBuilder(
    column: $table.dailyWaterTargetMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoLockMinutes => $composableBuilder(
    column: $table.autoLockMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get biometricLockEnabled => $composableBuilder(
    column: $table.biometricLockEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyWaterTargetMl => $composableBuilder(
    column: $table.dailyWaterTargetMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoLockMinutes => $composableBuilder(
    column: $table.autoLockMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get biometricLockEnabled => $composableBuilder(
    column: $table.biometricLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<int> get dailyWaterTargetMl => $composableBuilder(
    column: $table.dailyWaterTargetMl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoLockMinutes => $composableBuilder(
    column: $table.autoLockMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get biometricLockEnabled => $composableBuilder(
    column: $table.biometricLockEnabled,
    builder: (column) => column,
  );
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSetting,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
          ),
          UserSetting,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<int> dailyWaterTargetMl = const Value.absent(),
                Value<int> autoLockMinutes = const Value.absent(),
                Value<bool> biometricLockEnabled = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                theme: theme,
                dailyWaterTargetMl: dailyWaterTargetMl,
                autoLockMinutes: autoLockMinutes,
                biometricLockEnabled: biometricLockEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<int> dailyWaterTargetMl = const Value.absent(),
                Value<int> autoLockMinutes = const Value.absent(),
                Value<bool> biometricLockEnabled = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                theme: theme,
                dailyWaterTargetMl: dailyWaterTargetMl,
                autoLockMinutes: autoLockMinutes,
                biometricLockEnabled: biometricLockEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSetting,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
      ),
      UserSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$TemplateInstancesTableTableManager get templateInstances =>
      $$TemplateInstancesTableTableManager(_db, _db.templateInstances);
  $$MediaAssetsTableTableManager get mediaAssets =>
      $$MediaAssetsTableTableManager(_db, _db.mediaAssets);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
}
