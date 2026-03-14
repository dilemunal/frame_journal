import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

import '../../domain/entry_block.dart';
import 'glass_card.dart';

class AudioBlockWidget extends StatefulWidget {
  const AudioBlockWidget({
    super.key,
    required this.block,
    required this.onDelete,
  });

  final AudioBlock block;
  final VoidCallback onDelete;

  @override
  State<AudioBlockWidget> createState() => _AudioBlockWidgetState();
}

class _AudioBlockWidgetState extends State<AudioBlockWidget> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _toggle() async {
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
      if (mounted) setState(() => _isPlaying = true);
      await Future<void>.delayed(widget.block.duration);
      if (mounted) setState(() => _isPlaying = false);
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey(widget.block.filePath),
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: widget.onDelete,
        child: GlassCard(
          opacity: 0.12,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: _toggle,
                icon: Icon(
                  _isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: _isPlaying ? null : 0,
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _fmt(widget.block.duration),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
