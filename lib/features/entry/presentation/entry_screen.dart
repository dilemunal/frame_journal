import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/prompt_questions.dart';
import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/entry_block.dart';
import 'widgets/atmosphere_strip.dart';
import 'widgets/audio_block_widget.dart';
import 'widgets/draft_recovery_sheet.dart';
import 'widgets/glass_card.dart';
import 'widgets/keyboard_toolbar.dart';
import 'widgets/mood_bar.dart' show MoodBar, moodEmoji;
import 'widgets/recording_overlay.dart';

class _PromptEntry {
  _PromptEntry(this.question) : controller = TextEditingController();
  final String question;
  final TextEditingController controller;
}

/// Yeni giriş ekranı. Route: /entry/new
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, this.templateId});

  final int? templateId;

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen>
    with WidgetsBindingObserver {
  final _textController = TextEditingController();
  final List<EntryBlock> _blocks = [];
  final List<_PromptEntry> _prompts = [];
  double _moodValue = 0.5;
  bool _isFocusMode = false;
  Timer? _draftTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController.addListener(_onTextChanged);
    _loadDraft();
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    for (final p in _prompts) {
      p.controller.dispose();
    }
    _textController.removeListener(_onTextChanged);
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(seconds: 10), _persistDraft);
  }

  Future<void> _persistDraft() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'draft_entry',
        jsonEncode({
          'text': text,
          'moodValue': _moodValue,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }

  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('draft_entry');
    } catch (_) {}
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('draft_entry');
      if (raw == null || !mounted) return;
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final timestamp = DateTime.tryParse(data['timestamp'] as String? ?? '');
        final text = data['text'] as String? ?? '';
        final moodValue = (data['moodValue'] as num?)?.toDouble() ?? 0.5;
        if (timestamp != null && DateTime.now().difference(timestamp).inHours >= 24) {
          await prefs.remove('draft_entry');
          return;
        }
        if (timestamp == null || text.length <= 10) {
          return;
        }
        if (!mounted) return;
        _showDraftRecoverySheet(text, moodValue);
      } catch (_) {}
    } catch (_) {}
  }

  void _showDraftRecoverySheet(String text, double moodValue) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.black.withValues(alpha: 0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraftRecoverySheet(
        previewText: text,
        onContinue: () {
          Navigator.pop(context);
          _textController.text = text;
          setState(() => _moodValue = moodValue);
        },
        onDiscard: () async {
          await _clearDraft();
          if (!context.mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _persistDraft();
  }

  String get _freeText => _textController.text.trim();

  void _toggleFocusMode() {
    setState(() => _isFocusMode = !_isFocusMode);
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(source: ImageSource.gallery);
      if (x != null && x.path.isNotEmpty && mounted) {
        setState(() => _blocks.add(ImageBlock(filePath: x.path)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Fotoğraf seçilemedi. Uygulamayı durdurup Run (▶) ile yeniden başlatın.',
            ),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _addPrompt() async {
    try {
      final q = await PromptQuestions.next();
      if (q == null || !mounted) return;
      setState(() => _prompts.insert(0, _PromptEntry(q)));
    } catch (_) {}
  }

  Future<void> _openRecordingOverlay() async {
    final result = await showGeneralDialog<RecordingResult>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'recording',
      pageBuilder: (dialogContext, animation, secondaryAnimation) =>
          const RecordingOverlay(),
    );
    if (result != null && mounted) {
      setState(() {
        _blocks.add(AudioBlock(filePath: result.filePath, duration: result.duration));
      });
    }
  }

  Future<void> _saveEntry() async {
    final text = _freeText;
    final promptAnswers = _prompts
        .where((p) => p.controller.text.trim().isNotEmpty)
        .map((p) => '**${p.question}**\n${p.controller.text.trim()}')
        .join('\n\n');
    final fullText = [
      if (text.isNotEmpty) text,
      if (promptAnswers.isNotEmpty) promptAnswers,
    ].join('\n\n---\n\n');

    final content = fullText.trim();
    final mediaBlocks = _blocks.where((b) => b is! TextBlock).toList();
    final imagePaths = mediaBlocks.whereType<ImageBlock>().map((e) => e.filePath).toList();
    final audioItems = mediaBlocks
        .whereType<AudioBlock>()
        .map((e) => {'path': e.filePath, 'durationSec': e.duration.inSeconds})
        .toList();

    final hasAnyContent = content.isNotEmpty || imagePaths.isNotEmpty || audioItems.isNotEmpty;
    if (!hasAnyContent) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bir şeyler yaz.')),
        );
      }
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final asyncAtm = ref.read(atmosphereProvider);
    final atm = asyncAtm.valueOrNull;

    String? weatherJson;
    String? locationJson;
    if (atm != null) {
      if (atm.weather != null) {
        weatherJson = jsonEncode({
          'temp': atm.weather!.temp,
          'condition': atm.weather!.description,
          'emoji': atm.weather!.emoji,
        });
      }
      locationJson = jsonEncode({
        'lat': atm.location.lat,
        'lng': atm.location.lng,
        'name': atm.location.placeName,
      });
    }

    final moodEmojiStr = moodEmoji(_moodValue);
    final valuesJsonStr = (imagePaths.isNotEmpty || audioItems.isNotEmpty)
        ? jsonEncode({
            if (imagePaths.isNotEmpty) 'photos': imagePaths,
            if (audioItems.isNotEmpty) 'audios': audioItems,
          })
        : null;

    try {
      await db.into(db.appEntries).insert(
            AppEntriesCompanion.insert(
              userId: kLocalUserId,
              templateId: widget.templateId != null
                  ? Value(widget.templateId)
                  : const Value.absent(),
              freeText: Value(content),
              mood: Value(moodEmojiStr),
              valuesJson: valuesJsonStr != null
                  ? Value(valuesJsonStr)
                  : const Value.absent(),
              weatherJson: weatherJson != null
                  ? Value(weatherJson)
                  : const Value.absent(),
              locationJson: locationJson != null
                  ? Value(locationJson)
                  : const Value.absent(),
              createdAt: DateTime.now(),
            ),
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaydedilemedi, tekrar dene.')),
        );
      }
      return;
    }

    await _clearDraft();
    ref.invalidate(recentEntriesProvider);
    ref.invalidate(memoryEntriesProvider);
    if (mounted) context.pop();
  }

  Future<void> _handleBack() async {
    final hasPromptText = _prompts.any((p) => p.controller.text.trim().isNotEmpty);
    final hasMedia = _blocks.isNotEmpty;
    final hasContent = _freeText.trim().isNotEmpty || hasPromptText || hasMedia;
    if (!hasContent) {
      if (mounted) context.pop();
      return;
    }
    if (!mounted) return;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkmak istediğine emin misin?'),
        content:
            const Text('Yazdıkların taslak olarak kaydedilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hayır, devam et'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Evet, çık'),
          ),
        ],
      ),
    );
    if (shouldExit == true) {
      await _persistDraft();
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(journalTemplatesProvider);
    JournalTemplate? selectedTemplate;
    templatesAsync.whenData((list) {
      if (widget.templateId == null) return;
      for (final t in list) {
        if (t.id == widget.templateId) {
          selectedTemplate = t;
          break;
        }
      }
    });

    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0.0;
    final hour = DateTime.now().hour;
    final moodOverlay = Color.lerp(
      const Color(0x148FA5BA),
      const Color(0x14D4874E),
      _moodValue,
    )!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/background.webp', fit: BoxFit.cover),
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          color: AppColors.overlayForHour(hour),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: moodOverlay,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _handleBack,
            ),
            title: selectedTemplate == null
                ? null
                : Row(
                    children: [
                      Text(selectedTemplate!.icon),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          selectedTemplate!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
            actions: [
              IconButton(
                tooltip: _isFocusMode ? 'Odaktan cik' : 'Odak modu',
                onPressed: _toggleFocusMode,
                icon: Icon(
                  _isFocusMode
                      ? Icons.center_focus_weak_rounded
                      : Icons.center_focus_strong_rounded,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: _saveEntry,
                child: const Text(
                  'Kaydet',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < -300) {
                setState(() => _isFocusMode = true);
              } else if (details.velocity.pixelsPerSecond.dy > 300) {
                setState(() => _isFocusMode = false);
              }
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    keyboardVisible ? 90 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: _isFocusMode ? 0 : 1,
                        child: const AtmosphereStrip(),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: _isFocusMode ? 0 : 1,
                        child: GlassCard(
                          opacity: 0.12,
                          borderRadius: 16,
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                          child: MoodBar(
                            value: _moodValue,
                            onChanged: (v) => setState(() => _moodValue = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._prompts.map((p) {
                        return Padding(
                          key: ValueKey(p),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: ValueKey(p.question.hashCode ^ p.controller.hashCode),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              setState(() => _prompts.remove(p));
                              p.controller.dispose();
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: GlassCard(
                              borderRadius: 14,
                              opacity: 0.12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🎲 ${p.question}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: p.controller,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                    cursorColor: Colors.white.withValues(alpha: 0.7),
                                    decoration: InputDecoration(
                                      hintText: 'Cevabını yaz...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.4),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.05),
                                      border: InputBorder.none,
                                    ),
                                    maxLines: null,
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .slideY(
                                  begin: -0.3,
                                  end: 0,
                                  duration: 350.ms,
                                  curve: Curves.easeOut,
                                )
                                .fadeIn(duration: 350.ms),
                          ),
                        );
                      }),
                      GlassCard(
                        opacity: 0.08,
                        borderRadius: 20,
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          minLines: 10,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: _isFocusMode ? 2.0 : 1.8,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ne düşünüyorsun?',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_blocks.isNotEmpty)
                        ReorderableColumn(
                          needsLongPressDraggable: true,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              final item = _blocks.removeAt(oldIndex);
                              _blocks.insert(newIndex, item);
                            });
                          },
                          children: List.generate(_blocks.length, (index) {
                            final block = _blocks[index];
                            if (block is AudioBlock) {
                              return AudioBlockWidget(
                                key: ValueKey(block.filePath),
                                block: block,
                                onDelete: () => _confirmDeleteAudio(index, block),
                              );
                            }
                            if (block is ImageBlock) {
                              return _imageBlock(block, index);
                            }
                            return const SizedBox.shrink(key: ValueKey('empty'));
                          }),
                        ),
                      if (_isFocusMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            '${_freeText.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length} kelime',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isFocusMode)
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: _saveEntry,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF8FA5BA),
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                KeyboardToolbar(
                  visible: keyboardVisible && !_isFocusMode,
                  bottomInset: MediaQuery.of(context).viewInsets.bottom,
                  onPickPhoto: _pickPhoto,
                  onRecord: _openRecordingOverlay,
                  onPrompt: _addPrompt,
                  onSave: _saveEntry,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageBlock(ImageBlock block, int index) {
    final height = MediaQuery.of(context).size.width * block.heightFactor;
    return Padding(
      key: ValueKey(block.filePath),
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.file(
              File(block.filePath),
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GlassCard(
                padding: const EdgeInsets.all(4),
                borderRadius: 999,
                child: GestureDetector(
                  onTap: () => setState(() => _blocks.removeAt(index)),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Center(
                child: GestureDetector(
                  onVerticalDragUpdate: (d) {
                    setState(() {
                      final next =
                          (block.heightFactor + d.delta.dy / 300).clamp(0.25, 1.0);
                      _blocks[index] = ImageBlock(
                        filePath: block.filePath,
                        heightFactor: next,
                      );
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAudio(int index, AudioBlock block) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ses notunu sil'),
        content: const Text('Bu ses notu kalici olarak silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgec'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final file = File(block.filePath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      if (index >= 0 && index < _blocks.length) _blocks.removeAt(index);
    });
  }
}
