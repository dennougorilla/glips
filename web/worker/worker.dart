import 'dart:html';
import 'dart:typed_data';
import 'package:glips/src/color_quantizations.dart';
import 'package:gifencoder/gifencoder.dart';

class MyWorker {
  MyWorker() {
    print('Worker Running');
    GifBuffer frames;
    dws.onMessage.listen((MessageEvent evt) {
      if (evt.data['status'] == 'init') {
        print('init');
        frames = GifBuffer(evt.data['width'], evt.data['height']);
      }
      if (evt.data['status'] == 'add') {
        print('add');
        final bytes = Uint8ClampedList.fromList(evt.data['data']);
        grayScale(bytes);
        frames.add(bytes);
      }
      if (evt.data['status'] == 'build') {
        print('build');
        final bytes = frames.build(30);
        final port = evt.data['port'];
        print(port);
        port.postMessage(bytes);
      }
    });
  }
  DedicatedWorkerGlobalScope dws = DedicatedWorkerGlobalScope.instance;
}

void main() {
  MyWorker();
}
