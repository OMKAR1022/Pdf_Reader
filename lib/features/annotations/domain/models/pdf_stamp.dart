import 'dart:typed_data';
import 'dart:ui';

class PdfStamp {
  final Uint8List imageBytes;
  final Offset position; // Normalized (0-1)
  final Size size; // Normalized (0-1)

  PdfStamp({
    required this.imageBytes,
    required this.position,
    required this.size,
  });
}
