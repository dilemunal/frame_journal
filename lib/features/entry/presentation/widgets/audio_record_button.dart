import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_theme.dart';

/// Basılı tutunca kayıt başlar; max 60 sn. Bırakınca [onRecordingDone] ile path + süre döner.
class AudioRecordButton extends StatefulWidget {
  const AudioRecordButton({
    super.key,
    required this.onRecordingDone,
  });

  final void Function(String filePath, Duration duration) onRecordingDone;

  @override
  State<AudioRecordButton> createState() => _AudioRecordButtonState();
}

class _AudioRecordButtonState extends State<AudioRecordButton>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  Duration _recordedDuration = Duration.zero;
  Timer? _durationTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _pulseController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<bool> _requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (_) {
      // Hot restart sonrası plugin kanalı bazen bağlanmaz; izni atla, kayıt yine denenir
      return true;
    }
  }

  void _showPluginError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ses kaydı hazır değil. Uygulamayı durdurup Run (▶) ile yeniden başlatın.',
        ),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;
    final ok = await _requestPermission();
    if (!ok || !mounted) return;
    try {
      await _recorder.openRecorder();
      if (!mounted) return;
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio');
      await audioDir.create(recursive: true);
      final path = '${audioDir.path}/entry_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _recordedDuration = Duration.zero;
      });
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
        if (!mounted) return;
        final d = _recordedDuration + const Duration(seconds: 1);
        if (d.inSeconds >= 60) {
          await _stopRecording();
          return;
        }
        setState(() => _recordedDuration = d);
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isRecording = false);
        _showPluginError();
      }
    }
  }

  Future<void> _stopRecording() async {
    _durationTimer?.cancel();
    _durationTimer = null;
    if (!_isRecording) return;
    try {
      final path = await _recorder.stopRecorder();
      if (mounted && path != null && path.isNotEmpty) {
        widget.onRecordingDone(path, _recordedDuration);
      }
    } catch (_) {}
    if (mounted) setState(() => _isRecording = false);
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        if (!_isRecording) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ses kaydı için butona basılı tutun.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            if (_isRecording) ...[
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) => Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(
                      alpha: 0.5 + 0.5 * _pulseController.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Kayıt ${_formatDuration(_recordedDuration)}',
                style: theme.labelMedium?.copyWith(
                  color: Colors.red.shade700,
                ),
              ),
            ] else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎙️ Ses notu ekle',
                      style: theme.labelMedium?.copyWith(
                        color: AppColors.textMuted(AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      'Basılı tutun',
                      style: theme.labelSmall?.copyWith(
                        color: AppColors.textMuted(AppColors.textPrimary),
                        fontSize: 11,
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
