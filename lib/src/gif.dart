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
  external Promise(void executor(void resolve(T result), Function reject));
  external Promise then(void Function(T) onFulfilled, [Function onRejected]);
}

@JS()
@anonymous
class Options {
  external int get workers;
  external int get quality;
  external int get width;
  external int get height;

  external factory Options({int workers, int quality, int width, int height});
}

@JS()
@anonymous
class AddFrameOptions {
  external int get delay;
  external bool get copy;

  external factory AddFrameOptions({int delay, bool copy});
}
