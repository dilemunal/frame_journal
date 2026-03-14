/// Giriş içeriği blokları (metin + ses).
sealed class EntryBlock {}

class TextBlock extends EntryBlock {
  TextBlock(this.text);
  final String text;
}

class AudioBlock extends EntryBlock {
  AudioBlock({required this.filePath, required this.duration});

  final String filePath;
  final Duration duration;
}
