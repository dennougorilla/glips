import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:image/image.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_slider/material_slider.dart';
import 'package:glips/src/clip.dart';

@Component(
  selector: 'clip-editor',
  template: '''
  <div style = "text-align:center;">
  <canvas #canvas></canvas>
  <p>{{index}}/{{max}}    [{{start}}:{{stop}}]</p>
    <material-slider
                   [min]="0"
                   [(max)]="max"
                   [(value)]="index"
                   [disabled]="false"></material-slider>
    <material-slider [isTwoSided]="true"
                   [min]="0"
                   [(max)]="max"
                   [(leftValue)]="start"
                   [(value)]="stop"
                   [disabled]="false"></material-slider>
  <material-button raised autoFocus clear-size (trigger)="saveClip()">
    Save
  </material-button>
  </div>
  ''',
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
    Worker w = Worker('worker/worker.dart.js');
    MessageChannel msgChn = MessageChannel();
    w.postMessage({
      'port': msgChn.port1,
      'width': clipCanvas.width,
      'height': clipCanvas.height,
      'dataList': dataList
    }, [
      msgChn.port1
    ]);
    final message = await msgChn.port2.onMessage.first;
    print(message.data);
    final bytes = message.data;
    final gif64 = base64.encode(bytes);
    final image = ImageElement()..src = 'data:image/png;base64,${gif64}';
    document.body.append(image);
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
