import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_slider/material_slider.dart';
import 'package:glips/src/clip.dart';

@Component(
  selector: 'clip-editor',
  templateUrl: 'clip_editor_component.html',
  styles: ['canvas {width: 60%; height: auto;}'],
  directives: [MaterialSliderComponent, MaterialButtonComponent],
)
class ClipEditor implements AfterViewInit, AfterChanges {
  @Input()
  Clip clip;

  int max = 1;
  int index = 0;
  int start = 0;
  int stop = 1;

  @ViewChild('canvas')
  CanvasElement clipCanvas;

  Timer clipRender;

  void renderClip() async {
    final frames = clip.frameQueue.toList();
    clipCanvas
      ..width = frames[0].width
      ..height = frames[0].height;

    clipRender = Timer.periodic(const Duration(milliseconds: 33), (Timer t) {
      if (start < index && index < stop) {
        clipCanvas.context2D.putImageData(frames[index], 0, 0);
        index = index + 1;
      } else {
        index = start;
        clipCanvas.context2D.putImageData(frames[index], 0, 0);
        index = index + 1;
      }
    });
  }

  void saveClip() async {
    final dataList = clip.frameQueue
        .skip(start)
        .toList()
        .sublist(start, stop)
        .map((frame) => frame.data)
        .toList();
    final w = Worker('worker/worker.dart.js');
    final msgChn = MessageChannel();
    w.postMessage({
      'port': msgChn.port1,
      'width': clipCanvas.width,
      'height': clipCanvas.height,
      'dataList': dataList
    }, [
      msgChn.port1
    ]);
    final message = await msgChn.port2.onMessage.first;
    final dataUrl = await createDataUrl(message.data);
    final image = ImageElement()..src = dataUrl;
    document.body.append(image);
  }
  Future<String> createDataUrl(Uint8List bytes) {
  final c = Completer<String>();
  final f = FileReader();
  f.onLoadEnd.listen((ProgressEvent e) {
    if (f.readyState == FileReader.DONE) {
      final String url = f.result;
      c.complete(url.replaceFirst("data:;", "data:image/gif;"));
    }
  });
  f.readAsDataUrl(Blob([bytes]));
  return c.future;
}


  @override
  void ngAfterViewInit() {}

  @override
  void ngAfterChanges() {
    index = 0;
    start = 0;
    clipRender?.cancel();
    if (clip != null) {
      max = clip.frameQueue.length;
      stop = clip.frameQueue.length;
      renderClip();
    }
  }
}
