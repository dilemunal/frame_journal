import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// 50 soru — kategoriler: günlük yansıma, hafıza, geleceğe, duygu, basit, aktivite.
const List<String> kPromptQuestions = [
  'Bugün seni en çok ne yordu?',
  'Bugün kime şükran duydun?',
  'Bugün ne öğrendin?',
  'En çok ne kaçırmak istemiyorsun?',
  'Bugün seni beklenmedik şekilde kim veya ne etkiledi?',
  'Bugün geriye dönüp baktığında ne hatırlayacaksın?',
  'Bugünün en küçük ama güzel anı ne oldu?',
  'Bugün hangi anı fotoğraf gibi dondurmak isterdin?',
  '5 yıl sonraki sen bugünü nasıl değerlendirirdi?',
  'Bu hafta bir şeyi farklı yapsaydın ne olurdu?',
  'Yarın için kendine ne söylemek istersin?',
  'Şu an tam olarak ne hissediyorsun?',
  'Bugün seni kim mutlu etti?',
  'Neyi bırakmak istiyorsun?',
  'Bugün içinde taşıdığın en ağır şey neydi?',
  'Bugün için bir kelime seç.',
  'En son ne zaman gerçekten güldün?',
  'Bugün bedenine nasıl davrandın?',
  'Bugün seni en çok ne şaşırttı?',
  'Bugün ellerin ne yaptı?',
  'Bugün gittiğin en uzak yer neresi?',
  'Bugün okuduğun, izlediğin veya dinlediğin ne oldu?',
  'Bugün kendine nasıl davrandın?',
  'Bugün hangi kararı verirken zorlandın?',
  'Bugün en değerli anın neydi?',
  'Bugün seni en çok hangi an mutlu etti?',
  'Bugün hangi sesi veya kokuyu hatırlayacaksın?',
  'Bu ayın sonunda nerede olmak istiyorsun?',
  'Bir sonraki güne ne taşımak istiyorsun?',
  'Bugün hangi duygu seni en çok ziyaret etti?',
  'Bugün ne seni güvende hissettirdi?',
  'Bugün en çok hangi renk aklında kaldı?',
  'Bugün seni en iyi hangi cümle özetler?',
  'Bugün en çok hangi aktiviteye zaman ayırdın?',
  'Bugün neyi erteleyip durdun?',
  'Bugün kime veya neye baktığında için ısındı?',
  'Bugünün sana bıraktığı iz ne?',
  'Yarın için tek bir niyetin olsa ne olurdu?',
  'Bugün kime veya neye kızdın?',
  'Bugün neye üzüldün?',
  'Bugün kaç kez derin nefes aldın?',
  'Bugün hangi yemeği veya içeceği fark ettin?',
  'Bugün hangi konuşmayı unutmak istemezsin?',
  'Bugün neyi ilk kez fark ettin?',
  'Geleceğe bırakmak istediğin bir not var mı?',
  'Bugün hangi duyguyla vedalaşmak istersin?',
  'Bugün için tek bir emoji seç.',
  'Bugün hangi soruyu sormaktan çekindin?',
];

/// Fisher-Yates shuffle; seed ile deterministik (aynı gün aynı sıra).
List<String> _shuffledForDay(DateTime date) {
  final seed = date.year * 10000 + date.month * 100 + date.day;
  final rnd = Random(seed);
  final list = List<String>.from(kPromptQuestions);
  for (var i = list.length - 1; i > 0; i--) {
    final j = rnd.nextInt(i + 1);
    final t = list[i];
    list[i] = list[j];
    list[j] = t;
  }
  return list;
}

String _todayKey() {
  final n = DateTime.now();
  return 'shown_prompts_${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// Eski günlere ait prompt anahtarlarını siler.
Future<void> _cleanOldPromptKeys(SharedPreferences prefs) async {
  final prefix = 'shown_prompts_';
  final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
  final today = _todayKey();
  for (final k in keys) {
    if (k != today) await prefs.remove(k);
  }
}

/// Günlük sıralama (Fisher-Yates) ile henüz gösterilmemiş bir sonraki soruyu döner.
/// Gösterilenleri SharedPreferences'ta saklar; bir gün geçince eski kayıtlar silinir.
class PromptQuestions {
  /// Bugün için henüz gösterilmemiş bir soru döner. Hepsi gösterildiyse null.
  static Future<String?> next() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      final shuffled = _shuffledForDay(DateTime.now());
      return shuffled.isNotEmpty ? shuffled.first : null;
    }
    await _cleanOldPromptKeys(prefs);
    final key = _todayKey();
    final raw = prefs.getString(key);
    final shown = raw != null
        ? (jsonDecode(raw) as List<dynamic>).cast<String>()
        : <String>[];
    final shuffled = _shuffledForDay(DateTime.now());
    for (final q in shuffled) {
      if (!shown.contains(q)) {
        shown.add(q);
        await prefs.setString(key, jsonEncode(shown));
        return q;
      }
    }
    return null;
  }
}
