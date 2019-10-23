@JS()
library gif;

import 'dart:html';
import 'package:js/js.dart';

@JS()
class GIF {
  external GIF(Options options);
  external GIF addFrame(
      CanvasElement canvasElement, AddFrameOptions addFrameOptions);
  external GIF on(String string, Function func);
  external GIF render();
}

@JS()
class Promise<T> {
  external Promise(void Function(Function(T), Function) executor);
  external Promise then(void Function(T) onFulfilled, [Function onRejected]);
}

@JS()
@anonymous
class Options {
  external factory Options({int workers, int quality, int width, int height});
  external int get workers;
  external int get quality;
  external int get width;
  external int get height;
}

@JS()
@anonymous
class AddFrameOptions {
  external factory AddFrameOptions({int delay, bool copy});
  external int get delay;
  external bool get copy;
}
