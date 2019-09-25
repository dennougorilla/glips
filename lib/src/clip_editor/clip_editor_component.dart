import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_slider/material_slider.dart';
import 'package:glips/src/clip.dart';
import 'package:glips/src/gif.dart';
import 'package:js/js.dart';

@Component(
  selector: 'clip-editor',
  templateUrl: 'clip_editor_component.html',
  styleUrls: ['clip_editor_component.css'],
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

  bool isDown = false;

  final cropRange = CropRange();

  @ViewChild('clipCanvas')
  CanvasElement clipCanvas;

  Timer clipRender;

  void renderClip() async {
    cropRange
      ..bx = 0
      ..by = 0
      ..ex = clip.frameQueue.first.width
      ..ey = clip.frameQueue.first.height;

    frames = clip.frameQueue.toList();

    clipRender = Timer.periodic(const Duration(milliseconds: 33), (Timer t) {
      print('r');
      if (start < index && index < stop) {
        clipCanvas.context2D.putImageData(frames[index], 0, 0);
        clipCanvas.context2D.setStrokeColorRgb(255, 0, 0);
        clipCanvas.context2D.strokeRect(
            cropRange.bx, cropRange.by, cropRange.width, cropRange.height);
        index = index + 1;
      } else {
        index = start;
        clipCanvas.context2D.setStrokeColorRgb(255, 0, 0);
        clipCanvas.context2D.strokeRect(
            cropRange.bx, cropRange.by, cropRange.width, cropRange.height);
        clipCanvas.context2D.putImageData(frames[index], 0, 0);
        index = index + 1;
      }
    });
  }

  void saveClip() {
    final width = cropRange.width;
    final height = cropRange.height;
    final canvas = CanvasElement(width: width, height: height);
    final source = CanvasElement(
        width: clip.frameQueue.first.width,
        height: clip.frameQueue.first.height);
    final gif =
        GIF(Options(workers: 30, quality: 10, width: width, height: height));
    for (var frame in frames.sublist(start, stop)) {
      source.context2D.putImageData(frame, 0, 0);
      canvas.context2D.drawImageScaledFromSource(
          source,
          cropRange.bx,
          cropRange.by,
          cropRange.width,
          cropRange.height,
          0,
          0,
          cropRange.width,
          cropRange.height);
      gif.addFrame(canvas, AddFrameOptions(delay: 33, copy: true));
    }
    gif.on('finished', allowInterop((blob, tmp) {
      window.open(Url.createObjectUrl(blob), 'gif');
    })).render();
  }

  @override
  void ngAfterViewInit() {
    clipCanvas.addEventListener('click', (e) {
      print('click');
      final rect = clipCanvas.getBoundingClientRect();
      if (!isDown) {
        cropRange
          ..bx = (e as MouseEvent).client.x - rect.left.toInt()
          ..by = (e as MouseEvent).client.y - rect.top.toInt()
          ..ex = (e as MouseEvent).client.x - rect.left.toInt()
          ..ey = (e as MouseEvent).client.y - rect.top.toInt();
        isDown = true;
      } else {
        cropRange
          ..ex = (e as MouseEvent).client.x - rect.left.toInt()
          ..ey = (e as MouseEvent).client.y - rect.top.toInt();
        isDown = false;
      }
    }, false);
  }

  @override
  void ngAfterChanges() {
    index = 0;
    start = 0;
    clipRender?.cancel();
    if (clip != null) {
      clipCanvas
        ..width = clip.frameQueue.first.width
        ..height = clip.frameQueue.first.height;

      max = clip.frameQueue.length;
      stop = clip.frameQueue.length;
      renderClip();
    } else {}
  }
}

void setCropRange(Event e) {}

class CropRange {
  int bx, by, ex, ey;

  int get width => ex - bx;
  int get height => ey - by;
}
