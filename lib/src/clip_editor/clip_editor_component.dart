import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_slider/material_slider.dart';
import 'package:glips/src/clip.dart';
import 'package:glips/src/gif.dart';
import 'package:js/js.dart';

@Component(
  selector: 'clip-editor',
  templateUrl: 'clip_editor_component.html',
  styles: ['canvas {width: 60%; height: auto;}'],
  directives: [MaterialSliderComponent, MaterialButtonComponent],
)
class ClipEditor implements AfterViewInit, AfterChanges {
  @Input()
  Clip clip;

  List<ImageData> frames;

  int max = 1;
  int index = 0;
  int start = 0;
  int stop = 1;

  @ViewChild('canvas')
  CanvasElement clipCanvas;

  Timer clipRender;

  void renderClip() async {
    frames = clip.frameQueue.toList();
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

  void saveClip() {
    final width = clipCanvas.width;
    final height = clipCanvas.height;
    final canvas = CanvasElement(width: width, height: height);
    final gif =
        GIF(Options(workers: 30, quality: 10, width: width, height: height));
    for (var frame in frames.sublist(start, stop)) {
      canvas.context2D.putImageData(frame, 0, 0);
      gif.addFrame(canvas, AddFrameOptions(delay: 33, copy: true));
    }
    gif.on('finished', allowInterop((blob, tmp) {
      window.open(Url.createObjectUrl(blob), 'gif');
    })).render();
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
