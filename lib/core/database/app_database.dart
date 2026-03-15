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

  /// Varsayılan şablon id (Bugünü kaydet ile açılacak). null = serbest.
  IntColumn get defaultTemplateId =>
      integer().named('default_template_id').nullable()();
}

// --- Template system (GÖREV 2) ---

class JournalTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class TemplateFields extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId =>
      integer().references(JournalTemplates, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  /// "number" | "text" | "long_text" | "slider" | "photo" | "location" | "select" | "tags" | "weather"
  TextColumn get fieldType => text()();
  TextColumn get options => text().nullable()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();
  TextColumn get unit => text().nullable()();
}

class AppEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  IntColumn get templateId =>
      integer().nullable().references(JournalTemplates, #id)();
  TextColumn get title => text().nullable()();
  TextColumn get freeText => text().nullable()();
  TextColumn get mood => text().nullable()();
  TextColumn get valuesJson => text().nullable()();
  TextColumn get locationJson => text().nullable()();
  TextColumn get weatherJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  /// Zaman kapsülü: bu tarihe kadar içerik gizlenir. null = her zaman görünür.
  DateTimeColumn get unlockAt => dateTime().named('unlock_at').nullable()();
}

/// Günlük ritim tamamlanma kaydı (Ritim ekranı). localDate: YYYY-MM-DD, slotKey: morning|noon|evening
class RhythmCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localDate => text().named('local_date')();
  TextColumn get slotKey => text().named('slot_key')();
  DateTimeColumn get completedAt => dateTime().named('completed_at')();
}

@DriftDatabase(
  tables: [
    JournalEntries,
    TemplateInstances,
    MediaAssets,
    Tags,
    UserSettings,
    JournalTemplates,
    TemplateFields,
    AppEntries,
    RhythmCompletions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
      : super(executor ?? driftDatabase(name: 'journal'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(journalTemplates);
            await migrator.createTable(templateFields);
            await migrator.createTable(appEntries);
          }
          if (from < 3) {
            await migrator.createTable(rhythmCompletions);
          }
          if (from < 4) {
            await migrator.addColumn(
                userSettings, userSettings.defaultTemplateId);
          }
          if (from < 5) {
            await migrator.addColumn(appEntries, appEntries.unlockAt);
          }
        },
      );
}
