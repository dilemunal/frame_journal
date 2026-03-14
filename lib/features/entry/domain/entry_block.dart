/// Giriş içeriği blokları (metin + görsel + ses).
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

class ImageBlock extends EntryBlock {
  ImageBlock({
    required this.filePath,
    this.heightFactor = 0.5,
  });

  final String filePath;
  final double heightFactor;
}
