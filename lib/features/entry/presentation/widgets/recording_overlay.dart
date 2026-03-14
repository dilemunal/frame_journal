import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingResult {
  const RecordingResult({
    required this.filePath,
    required this.duration,
  });

  final String filePath;
  final Duration duration;
}

class RecordingOverlay extends StatefulWidget {
  const RecordingOverlay({super.key});

  @override
  State<RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends State<RecordingOverlay> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  Duration _duration = Duration.zero;
  Timer? _ticker;
  String? _filePath;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _begin();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _begin() async {
    try {
      final mic = await Permission.microphone.request();
      if (!mounted) return;
      if (!mic.isGranted) {
        Navigator.of(context).pop();
        return;
      }

      await _recorder.openRecorder();
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio');
      await audioDir.create(recursive: true);
      _filePath = '${audioDir.path}/entry_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
      );
      if (!mounted) return;
      setState(() => _isRecording = true);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
        if (!mounted || !_isRecording) return;
        final next = _duration + const Duration(seconds: 1);
        if (next.inSeconds >= 60) {
          await _save();
          return;
        }
        setState(() => _duration = next);
      });
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _cancel() async {
    try {
      _ticker?.cancel();
      if (_isRecording) {
        final path = await _recorder.stopRecorder();
        if (path != null && path.isNotEmpty) {
          final f = File(path);
          if (await f.exists()) await f.delete();
        }
      }
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    try {
      _ticker?.cancel();
      if (!_isRecording) return;
      final path = await _recorder.stopRecorder();
      _isRecording = false;
      if (!mounted) return;
      if (path == null || path.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
      Navigator.of(context).pop(
        RecordingResult(filePath: path, duration: _duration),
      );
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        SafeArea(
          child: Column(
            children: [
              const Spacer(),
              _wave(80, 0.22),
              const SizedBox(height: 8),
              _wave(120, 0.14),
              const SizedBox(height: 8),
              _wave(160, 0.1),
              const SizedBox(height: 24),
              Text(
                _fmt(_duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kaydet için ✓, iptal için ✕',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _action(Icons.close, _cancel),
                  _action(Icons.mic, null),
                  _action(Icons.check, _save),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wave(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.withValues(alpha: alpha),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.25, 1.25),
          duration: 800.ms,
          curve: Curves.easeOut,
        )
        .fadeOut(begin: 1, duration: 800.ms);
  }

  Widget _action(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap == null
              ? Colors.red.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.2),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
