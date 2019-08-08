import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular_components/material_slider/material_slider.dart';

import 'package:glips/src/clip.dart';

@Component(
  selector: 'clip-editor',
  template: '''
  <div style = "text-align:center;">
  <canvas #canvas></canvas>
  <p>{{index}}/300</p>
    <material-slider
                   [min]="0"
                   [max]="300"
                   [(value)]="index"
                   [disabled]="false"></material-slider>
    <material-slider [isTwoSided]="true"
                   [min]="0"
                   [max]="300"
                   [(leftValue)]="start"
                   [(value)]="stop"
                   [disabled]="false"></material-slider>
  <p>Start: {{start}} Stop: {{stop}}</p>
  </div>
  ''',
  styles: ['canvas {width: 70%; height: 70%;}'],
  directives: [
    MaterialSliderComponent,
  ],
)
class ClipEditor implements AfterViewInit, AfterChanges {
  @Input()
  Clip clip;

  int index = 0;
  int start = 0;
  int stop = 300;

  @ViewChild('canvas')
  CanvasElement clipCanvas;

  Timer clipRender;

  void renderClip(Clip clip) async {
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

  @override
  void ngAfterViewInit() {
  }

  @override
  void ngAfterChanges() {
    index = 0;
    start = 0;
    stop = 300;
    clipRender?.cancel();
    if (clip != null) {
      renderClip(clip);
    }
  }
}
