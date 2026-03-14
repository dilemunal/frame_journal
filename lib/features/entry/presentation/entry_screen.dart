import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/entry_block.dart';
import 'widgets/atmosphere_strip.dart';
import 'widgets/audio_block_row.dart';
import 'widgets/audio_record_button.dart';
import 'widgets/mood_bar.dart' show MoodBar, moodEmoji;
import 'widgets/prompt_dice_widget.dart';

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
  final List<EntryBlock> _blocks = [TextBlock('')];
  final List<String> _photoPaths = [];
  double _moodValue = 0.5;
  String? _currentPrompt;
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
    _textController.removeListener(_onTextChanged);
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_blocks.isNotEmpty && _blocks.first is TextBlock) {
      _blocks[0] = TextBlock(_textController.text);
    }
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
        if (timestamp == null ||
            DateTime.now().difference(timestamp).inHours >= 24 ||
            text.length <= 10) {
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
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Yarım kalan bir şey var...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                text.length > 40 ? '${text.substring(0, 40)}...' : text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted(AppColors.textPrimary),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _textController.text = text;
                        setState(() {
                          _moodValue = moodValue;
                          if (_blocks.isNotEmpty) _blocks[0] = TextBlock(text);
                        });
                      },
                      child: const Text('Devam Et'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await _clearDraft();
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      child: const Text('Sil, Başla'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _persistDraft();
  }

  String get _freeText =>
      _blocks.whereType<TextBlock>().map((b) => b.text).join('\n\n');

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(source: ImageSource.gallery);
      if (x != null && x.path.isNotEmpty && mounted) {
        setState(() => _photoPaths.add(x.path));
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

  Future<void> _saveEntry() async {
    final text = _freeText.trim();
    if (text.isEmpty) return;
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
    final valuesJsonStr = _photoPaths.isNotEmpty
        ? jsonEncode({'photos': _photoPaths})
        : null;

    await db.into(db.appEntries).insert(
          AppEntriesCompanion.insert(
            userId: kLocalUserId,
            templateId: widget.templateId != null
                ? Value(widget.templateId)
                : const Value.absent(),
            freeText: Value(text),
            mood: Value(moodEmojiStr),
            valuesJson: valuesJsonStr != null ? Value(valuesJsonStr) : const Value.absent(),
            weatherJson: weatherJson != null ? Value(weatherJson) : const Value.absent(),
            locationJson: locationJson != null ? Value(locationJson) : const Value.absent(),
            createdAt: DateTime.now(),
          ),
        );

    await _clearDraft();
    ref.invalidate(recentEntriesProvider);
    ref.invalidate(memoryEntriesProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    // Opak arka plan: mood'a göre hafif soğuk → sıcak ton (şeffaf değil, siyah görünmesin)
    final backgroundColor = Color.lerp(
      const Color(0xFFE8ECF0),
      const Color(0xFFF5EDE4),
      _moodValue,
    )!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _isFocusMode
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  onPressed: () async {
                    await _clearDraft();
                    if (mounted) context.pop();
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: _saveEntry,
                    child: Text(
                      'Kaydet',
                      style: theme.labelLarge?.copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
        body: Column(
          children: [
            if (!_isFocusMode) ...[
              const AtmosphereStrip(),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: Text(
                  'Ruh hali',
                  style: theme.labelSmall?.copyWith(
                    color: AppColors.textMuted(AppColors.textPrimary),
                  ),
                ),
              ),
              MoodBar(
                value: _moodValue,
                onChanged: (v) => setState(() => _moodValue = v),
              ),
            ],
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dy < -300) {
                        setState(() => _isFocusMode = true);
                      } else if (details.velocity.pixelsPerSecond.dy > 300) {
                        setState(() => _isFocusMode = false);
                      }
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_currentPrompt != null)
                            AnimatedOpacity(
                              opacity: _textController.text.isEmpty ? 1.0 : 0.45,
                              duration: const Duration(milliseconds: 300),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: Text(
                                  _currentPrompt!,
                                  style: theme.bodySmall?.copyWith(
                                    color: AppColors.textMuted(AppColors.textPrimary),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          TextField(
                            controller: _textController,
                            onChanged: (_) => setState(() {}),
                            maxLines: null,
                            minLines: 8,
                            style: theme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                              height: _isFocusMode ? 2.0 : 1.8,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Ne düşünüyorsun?',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted(AppColors.textPrimary),
                              ),
                              border: InputBorder.none,
                              filled: false,
                            ),
                          ),
                          ..._blocks.whereType<AudioBlock>().map(
                                (b) => AudioBlockRow(block: b),
                              ),
                          if (!_isFocusMode && _photoPaths.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 72,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _photoPaths.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final path = _photoPaths[i];
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => setState(() => _photoPaths.removeAt(i)),
                                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (!_isFocusMode) ...[
                            OutlinedButton.icon(
                              onPressed: _pickPhoto,
                              icon: const Icon(Icons.photo_library_outlined, size: 20),
                              label: const Text('Fotoğraf ekle'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: BorderSide(color: AppColors.textMuted(AppColors.textPrimary)),
                              ),
                            ),
                            AudioRecordButton(
                              onRecordingDone: (path, duration) {
                                setState(() => _blocks.add(
                                      AudioBlock(filePath: path, duration: duration),
                                    ));
                              },
                            ),
                          ],
                          if (_isFocusMode) ...[
                            const SizedBox(height: 16),
                            Text(
                              '${_freeText.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length} kelime',
                              style: theme.labelSmall?.copyWith(
                                color: AppColors.textMuted(AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!_isFocusMode)
                    Positioned(
                      right: 20,
                      bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                      child: PromptDiceButton(
                        onPromptSelected: (q) =>
                            setState(() => _currentPrompt = q),
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withValues(alpha: 0.8),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
