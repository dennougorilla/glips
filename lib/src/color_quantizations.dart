import 'dart:typed_data';

void grayScale(Uint8ClampedList image) {
  for (var i = 0; i < image.length; i += 4) {
    final l = getLuminanceRgb(image[i], image[i + 1], image[i + 2]);
    image[i] = l;
    image[i + 1] = l;
    image[i + 2] = l;
  }
}

int getLuminanceRgb(int r, int g, int b) =>
    (0.299 * r + 0.587 * g + 0.114 * b).round();
