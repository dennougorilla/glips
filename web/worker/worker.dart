import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:image/image.dart';

class MyWorker {
  MyWorker() {
    print('Worker Running');

    dws.onMessage.listen((MessageEvent evt) {
      print(evt.data);
      print(evt.data.runtimeType);

      //Encoding
      final dataList = evt.data['dataList'];
      final imageList = dataList.map((data) {
        final bytes = Uint8ClampedList.fromList(data);
        return Image.fromBytes(evt.data['width'], evt.data['height'], bytes);
      }).toList()
        ..forEach(encoder.addFrame);
      print(imageList);
      final bytes = encoder.finish();

      final port = evt.data["port"];
      print(port);
      port.postMessage(bytes);
    });
  }

  DedicatedWorkerGlobalScope dws = DedicatedWorkerGlobalScope.instance;
  GifEncoder encoder = GifEncoder();
  //final frames = clip.frameQueue
  //    .toList()
  //    .map((frame) =>
  //        Image.fromBytes(frame.width ~/ 10, frame.height ~/ 10, frame.data))
  //    .toList();
  //final anim = Animation()..frames = frames;
  //encoder.encodeAnimation(anim);
  //final bytes = encoder.finish();
}

main() {
  MyWorker();
}
