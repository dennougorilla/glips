import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular_components/laminate/overlay/module.dart';
import 'package:glips/src/clip_editor/clip_editor_component.dart';
import 'package:angular_components/laminate/components/modal/modal.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_dialog/material_dialog.dart';

import 'src/clip.dart';
import 'src/get_display_media.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  providers: [overlayBindings],
  directives: [
    MaterialButtonComponent,
    MaterialDialogComponent,
    ModalComponent,
  ],
)
class AppComponent implements AfterViewInit {
  Clip clip = Clip();
  Clip canvasData;
  bool showClipEditorDialog = false;

  @ViewChild('screen')
  CanvasElement screenCanvas;

  @override
  void ngAfterViewInit() async {
    final displayMediaOptions = {
      'video': {'cursor': 'never'},
      'audio': false
    };
    final stream = await getDisplayMedia(displayMediaOptions);
    final video = VideoElement()
      ..id = 'video'
      ..autoplay = true
      ..srcObject = stream;

    final screenOption = dumpOptionsInfo(video);
    screenCanvas
      ..width = screenOption['width']
      ..height = screenOption['height'];

    var render = Timer.periodic(const Duration(milliseconds: 33),
        (Timer t) => drawVideo(screenCanvas, video, clip));
  }

  void drawVideo(CanvasElement canvas, VideoElement video, Clip clip) {
    final screenOption = dumpOptionsInfo(video);
    canvas
      ..width = screenOption['width']
      ..height = screenOption['height']
      ..context2D.drawImage(video, 0, 0);

    clip.setImage(
        canvas.context2D.getImageData(0, 0, canvas.width, canvas.height));
  }

  void openEditor() {
    showClipEditorDialog = true;
    canvasData = clip;
  }

  void saveClip() {
    showClipEditorDialog = false;
    canvasData = null;
  }

  Map<dynamic, dynamic> dumpOptionsInfo(VideoElement video) {
    final videoTrack = video.srcObject.getVideoTracks()[0];
    return videoTrack.getSettings();
  }
}
