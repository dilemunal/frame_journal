import '../models/journal_template.dart';

/// Static pool of built-in templates available on-device.
///
/// These mirror the original JSON definitions but are fully type-safe.
const List<JournalTemplate> appTemplates = <JournalTemplate>[
  JournalTemplate(
    id: 'dive_log',
    name: 'Dalış Günlüğü',
    type: 'dive_log',
    iconEmoji: '🤿',
    version: 1,
    fields: <TemplateField>[
      TemplateField(
        key: 'site_name',
        label: 'Dalış Noktası',
        type: TemplateFieldType.text,
      ),
      TemplateField(
        key: 'gps',
        label: 'Konum',
        type: TemplateFieldType.geo,
      ),
      TemplateField(
        key: 'max_depth_m',
        label: 'Maksimum Derinlik (m)',
        type: TemplateFieldType.number,
      ),
      TemplateField(
        key: 'bottom_time_min',
        label: 'Taban Süresi (dk)',
        type: TemplateFieldType.number,
      ),
      TemplateField(
        key: 'water_temp_c',
        label: 'Su Sıcaklığı (°C)',
        type: TemplateFieldType.number,
      ),
      TemplateField(
        key: 'visibility_m',
        label: 'Görüş (m)',
        type: TemplateFieldType.number,
      ),
      TemplateField(
        key: 'tank_start_bar',
        label: 'Başlangıç Bar',
        type: TemplateFieldType.number,
      ),
      TemplateField(
        key: 'tank_end_bar',
        label: 'Bitiş Bar',
        type: TemplateFieldType.number,
      ),
      TemplateField(
        key: 'sighting_list',
        label: 'Görülenler',
        type: TemplateFieldType.chips,
      ),
    ],
  ),
  JournalTemplate(
    id: 'tennis_match',
    name: 'Tenis Maçı',
    type: 'tennis',
    iconEmoji: '🎾',
    version: 1,
    fields: <TemplateField>[
      TemplateField(
        key: 'opponent',
        label: 'Rakip',
        type: TemplateFieldType.text,
      ),
      TemplateField(
        key: 'surface',
        label: 'Zemin',
        type: TemplateFieldType.select,
        options: <String>['Hard', 'Clay', 'Grass'],
      ),
      TemplateField(
        key: 'set_score',
        label: 'Set Skoru',
        type: TemplateFieldType.text,
      ),
      TemplateField(
        key: 'serve_pct',
        label: 'İlk Servis %',
        type: TemplateFieldType.number,
      ),
      TemplateField(
        key: 'duration_min',
        label: 'Süre (dk)',
        type: TemplateFieldType.duration,
      ),
    ],
  ),
  JournalTemplate(
    id: 'nutrition_day',
    name: 'Beslenme',
    type: 'nutrition',
    iconEmoji: '🥗',
    version: 1,
    fields: <TemplateField>[
      TemplateField(
        key: 'meals',
        label: 'Öğünler',
        type: TemplateFieldType.repeatGroup,
      ),
      TemplateField(
        key: 'gluten_free',
        label: 'Glütensiz',
        type: TemplateFieldType.boolean,
      ),
      TemplateField(
        key: 'refined_sugar',
        label: 'Rafine Şeker',
        type: TemplateFieldType.boolean,
      ),
      TemplateField(
        key: 'satiety',
        label: 'Tokluk Seviyesi',
        type: TemplateFieldType.rating,
        max: 5,
      ),
    ],
  ),
  JournalTemplate(
    id: 'water_tracking',
    name: 'Su Takibi',
    type: 'water',
    iconEmoji: '💧',
    version: 1,
    fields: <TemplateField>[
      TemplateField(
        key: 'goal_ml',
        label: 'Günlük Hedef (ml)',
        type: TemplateFieldType.number,
      ),
      TemplateField(
        key: 'current_ml',
        label: 'İçilen Su (ml)',
        type: TemplateFieldType.number,
      ),
      TemplateField(
        key: 'reminders_enabled',
        label: 'Hatırlatıcılar',
        type: TemplateFieldType.boolean,
      ),
    ],
  ),
  JournalTemplate(
    id: 'word_puzzle',
    name: 'Kelime Bulmaca',
    type: 'word_puzzle',
    iconEmoji: '🟩',
    version: 1,
    fields: <TemplateField>[
      TemplateField(
        key: 'game_name',
        label: 'Oyun Adı',
        type: TemplateFieldType.text,
      ),
      TemplateField(
        key: 'share_text',
        label: 'Paylaşım Metni',
        type: TemplateFieldType.multiline,
      ),
      TemplateField(
        key: 'streak',
        label: 'Seri (gün)',
        type: TemplateFieldType.number,
      ),
    ],
  ),
];

