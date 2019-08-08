import 'dart:collection';
import 'dart:html';
class Clip {
  Queue<ImageData> frameQueue = Queue<ImageData>();

  void setImage(ImageData image) {
    if (frameQueue.length < 300) {
      frameQueue.addLast(image);
    } else {
      frameQueue
      ..removeFirst()
      ..addLast(image);
    }
  }
}