@JS()
library main;

import 'dart:async';
import 'dart:html';
import 'dart:html_common';
import 'package:js/js.dart';

Future<MediaStream> getDisplayMedia([dynamic constraints]) {
  final completer = Completer<MediaStream>();
  _getDisplayMedia(convertDartToNative_SerializedScriptValue(constraints)).then(
      allowInterop(completer.complete), allowInterop(completer.completeError));
  return completer.future;
}

@JS()
class Promise<T> {
  external Promise(void executor(void resolve(T result), Function reject));
  external Promise then(void Function(T) onFulfilled, [Function onRejected]);
}

@JS('navigator.mediaDevices.getDisplayMedia')
external Promise<MediaStream> _getDisplayMedia([dynamic constraints]);
