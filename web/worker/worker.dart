import 'dart:html';
import 'dart:typed_data';
import 'package:glips/src/color_quantizations.dart';
import 'package:gifencoder/gifencoder.dart';

class MyWorker {
  MyWorker() {
    print('Worker Running');

    dws.onMessage.listen((MessageEvent evt) {
      print('listen');
      final frames = GifBuffer(evt.data['width'], evt.data['height']);
      final dataList = evt.data['dataList'];
      for(var i = 0; i < (dataList as List).length; i++) {
        final bytes = Uint8ClampedList.fromList(dataList[i]);
        grayScale(bytes);
        frames.add(bytes);
      }
      final bytes = frames.build(30);
      final port = evt.data['port'];
      print(port);
      port.postMessage(bytes);
    });
  }

  DedicatedWorkerGlobalScope dws = DedicatedWorkerGlobalScope.instance;
}

main() {
  MyWorker();
}
