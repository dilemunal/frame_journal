import 'package:drift/drift.dart';

import 'app_database.dart';

/// Uygulama açılışında bir kez çalıştırılır; varsayılan 8 şablonu ekler.
Future<void> seedDefaultTemplates(AppDatabase db) async {
  final existing = await db.select(db.journalTemplates).get();
  if (existing.isNotEmpty) return;

  final now = DateTime.now();

  // 1. 🤿 Dalış
  final diveId = await db.into(db.journalTemplates).insert(
    JournalTemplatesCompanion.insert(
      name: 'Dalış Günlüğü',
      icon: '🤿',
      color: '#5B9BD5',
      isDefault: const Value(true),
      createdAt: now,
    ),
  );
  final diveFields = [
    ('Konum', 'location', null, false, null),
    ('Maks. derinlik (m)', 'number', null, true, 'm'),
    ('Süre (dk)', 'number', null, true, 'dk'),
    ('Su sıcaklığı (°C)', 'number', null, false, '°C'),
    ('Görüş mesafesi (m)', 'number', null, false, 'm'),
    ('Dip tipi', 'select', '["Kum","Kayalık","Poseidon çimeni","Karma"]', false, null),
    ('Notlar', 'long_text', null, false, null),
    ('Fotoğraflar', 'photo', null, false, null),
  ];
  for (var i = 0; i < diveFields.length; i++) {
    final (label, type, opts, req, unit) = diveFields[i];
    await db.into(db.templateFields).insert(
      TemplateFieldsCompanion.insert(
        templateId: diveId,
        label: label,
        fieldType: type,
        options: Value(opts),
        isRequired: Value(req),
        sortOrder: i,
        unit: unit != null ? Value(unit) : const Value.absent(),
      ),
    );
  }

  // 2. 🎾 Tenis
  final tennisId = await db.into(db.journalTemplates).insert(
    JournalTemplatesCompanion.insert(
      name: 'Tenis',
      icon: '🎾',
      color: '#70AD47',
      isDefault: const Value(true),
      createdAt: now,
    ),
  );
  const tennisFields = [
    ('Rakip', 'text', null, false),
    ('Skor', 'text', null, false),
    ('Antrenman / Maç', 'select', '["Antrenman","Maç"]', false),
    ('Serve %', 'number', null, false),
    ('Enerji (1-10)', 'slider', null, false),
    ('Notlar', 'long_text', null, false),
  ];
  for (var i = 0; i < tennisFields.length; i++) {
    final row = tennisFields[i];
    await db.into(db.templateFields).insert(
      TemplateFieldsCompanion.insert(
        templateId: tennisId,
        label: row.$1,
        fieldType: row.$2,
        options: Value(row.$3),
        isRequired: Value(row.$4),
        sortOrder: i,
      ),
    );
  }

  // 3–8: Kısa şablonlar (alanlar basit)
  final rest = [
    ('Koşu', '🏃', '#E67E22', [
      ('Mesafe (km)', 'number', 'km'),
      ('Süre (dk)', 'number', 'dk'),
      ('Nabız (bpm)', 'number', 'bpm'),
      ('Rota', 'location', null),
      ('His (1-10)', 'slider', null),
      ('Not', 'long_text', null),
    ]),
    ('Kitap', '📚', '#D4A574', [
      ('Kitap adı', 'text', null),
      ('Yazar', 'text', null),
      ('Sayfa', 'number', null),
      ('Alıntı', 'long_text', null),
      ('Düşünce', 'long_text', null),
      ('Puan (1-10)', 'slider', null),
    ]),
    ('Film', '🎬', '#9B59B6', [
      ('Film adı', 'text', null),
      ('Puan (1-10)', 'slider', null),
      ('İzleme notu', 'long_text', null),
      ('Öneri mi?', 'select', '["Evet","Hayır"]', null),
    ]),
    ('Seyahat', '✈️', '#1ABC9C', [
      ('Konum', 'location', null),
      ('Bugün ne yaptım', 'long_text', null),
      ('Tavsiye eder misin (1-10)', 'slider', null),
    ]),
    ('Antrenman', '🏋️', '#34495E', [
      ('Program adı', 'text', null),
      ('Genel his (1-10)', 'slider', null),
      ('Notlar', 'long_text', null),
    ]),
    ('Meditasyon', '🧘', '#95A5A6', [
      ('Süre (dk)', 'number', 'dk'),
      ('Teknik', 'select', '["Nefes","Vücut tarama","Rehberli","Sessiz"]', null),
      ('His (1-10)', 'slider', null),
      ('Notlar', 'long_text', null),
    ]),
  ];

  for (final t in rest) {
    final tid = await db.into(db.journalTemplates).insert(
      JournalTemplatesCompanion.insert(
        name: t.$1,
        icon: t.$2,
        color: t.$3,
        isDefault: const Value(true),
        createdAt: now,
      ),
    );
    for (var i = 0; i < t.$4.length; i++) {
      final f = t.$4[i] as (String, String, String?);
      final label = f.$1;
      final type = f.$2;
      final unit = f.$3;
      await db.into(db.templateFields).insert(
        TemplateFieldsCompanion.insert(
          templateId: tid,
          label: label,
          fieldType: type,
          sortOrder: i,
          unit: unit != null ? Value(unit) : const Value.absent(),
        ),
      );
    }
  }
}
