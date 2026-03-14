import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entry_block.dart';

/// "Ses notu (0:23) [▶ Play]" satırı.
class AudioBlockRow extends StatefulWidget {
  const AudioBlockRow({super.key, required this.block});

  final AudioBlock block;

  @override
  State<AudioBlockRow> createState() => _AudioBlockRowState();
}

class _AudioBlockRowState extends State<AudioBlockRow> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.stopPlayer();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    try {
      await _player.openPlayer();
      final uri = widget.block.filePath.startsWith('/')
          ? 'file://${widget.block.filePath}'
          : widget.block.filePath;
      await _player.startPlayer(fromURI: uri);
      if (!mounted) return;
      setState(() => _isPlaying = true);
      await Future<void>.delayed(widget.block.duration);
      if (mounted) setState(() => _isPlaying = false);
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Text(
            'Ses notu (${_formatDuration(widget.block.duration)})',
            style: theme.bodySmall?.copyWith(
              color: AppColors.textMuted(AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _togglePlay,
            icon: Icon(
              _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: AppColors.accent,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
