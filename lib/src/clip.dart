import 'dart:collection';
import 'dart:html';
class Clip {
  Queue<ImageData> frameQueue = Queue<ImageData>();
  int maxLength = 300;

  void setImage(ImageData image) {
    if (frameQueue.length < maxLength) {
      frameQueue.addLast(image);
    } else {
      frameQueue
      ..removeFirst()
      ..addLast(image);
    }
  }
}