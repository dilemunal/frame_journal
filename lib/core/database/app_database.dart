import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Rich text content stored as JSON (Quill Delta or similar).
  TextColumn get contentJson => text().named('content_json')();

  /// Local date-time of the entry.
  DateTimeColumn get entryDate => dateTime().named('entry_date')();

  /// Sentiment score from on-device AI, nullable until calculated.
  RealColumn get sentimentScore => real().named('sentiment_score').nullable()();

  /// Stable local UUID for matching across sync and devices.
  TextColumn get localUuid => text().named('local_uuid').unique()();
}

class TemplateInstances extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get entryId =>
      integer().named('entry_id').references(JournalEntries, #id)();

  /// Logical type of the template, e.g. 'dive_log', 'tennis', 'nutrition'.
  TextColumn get templateType => text().named('template_type')();

  /// Template payload as JSON, schema defined by the template engine.
  TextColumn get payloadJson => text().named('payload_json')();

  /// Version of the JSON schema used when this instance was created.
  IntColumn get schemaVersion =>
      integer().named('schema_version').withDefault(const Constant(1))();
}

class MediaAssets extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get entryId =>
      integer().named('entry_id').references(JournalEntries, #id)();

  /// Absolute or app-relative path to the original media.
  TextColumn get localPath => text().named('local_path')();

  /// Optional thumbnail path for images.
  TextColumn get thumbnailPath => text().named('thumbnail_path').nullable()();

  /// JSON-encoded transform metadata (Matrix4, filters, etc.).
  TextColumn get transformDataJson =>
      text().named('transform_data_json').nullable()();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get entryId =>
      integer().named('entry_id').references(JournalEntries, #id)();

  /// Tag label, e.g. 'work', 'dive', 'tennis'.
  TextColumn get label => text().named('label')();
}

class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Current theme identifier (e.g. 'classic', 'dark', 'sepia').
  TextColumn get theme =>
      text().named('theme').withDefault(const Constant('classic'))();

  /// Daily water target in milliliters.
  IntColumn get dailyWaterTargetMl => integer()
      .named('daily_water_target_ml')
      .withDefault(const Constant(2000))();

  /// Auto-lock timeout in minutes (0 = immediately).
  IntColumn get autoLockMinutes =>
      integer().named('auto_lock_minutes').withDefault(const Constant(1))();

  /// Whether biometric lock is enabled.
  BoolColumn get biometricLockEnabled => boolean()
      .named('biometric_lock_enabled')
      .withDefault(const Constant(false))();
}

@DriftDatabase(
  tables: [JournalEntries, TemplateInstances, MediaAssets, Tags, UserSettings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
    : super(executor ?? driftDatabase(name: 'journal'));

  @override
  int get schemaVersion => 1;
}
