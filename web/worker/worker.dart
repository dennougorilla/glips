import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:image/image.dart';

class MyWorker {
  MyWorker() {
    print('Worker Running');

    dws.onMessage.listen((MessageEvent evt) {
      //Encoding
      evt.data['dataList']
          .map((data) {
            print(data);
            final bytes = Uint8ClampedList.fromList(data);
            return Image.fromBytes(
                evt.data['width'], evt.data['height'], bytes);
          })
          .toList()
          .forEach( (image) => encoder.addFrame(image));
      final bytes = encoder.finish();

      final port = evt.data['port'];
      print(port);
      port.postMessage(bytes);
    });
  }

  DedicatedWorkerGlobalScope dws = DedicatedWorkerGlobalScope.instance;
  GifEncoder encoder = GifEncoder()..repeat = 0;
}

main() {
  MyWorker();
}
