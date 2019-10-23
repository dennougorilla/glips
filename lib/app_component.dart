import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular_components/laminate/overlay/module.dart';
import 'package:angular_components/material_icon/material_icon.dart';
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
  styleUrls: [
    'app_component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
  templateUrl: 'app_component.html',
  providers: [overlayBindings],
  directives: [
    MaterialIconComponent,
    MaterialButtonComponent,
    MaterialDialogComponent,
    ModalComponent,
    ClipEditor,
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
    final stream = await getDisplayMedia();
    final video = VideoElement()
      ..id = 'video'
      ..autoplay = true
      ..srcObject = stream;

    Timer.periodic(const Duration(milliseconds: 33),
        (Timer t) => drawVideo(screenCanvas, video, clip));
  }

  void drawVideo(CanvasElement canvas, VideoElement video, Clip clip) {
    final screenOption = dumpOptionsInfo(video);
    canvas
      ..width = screenOption['width'] ~/ 2
      ..height = screenOption['height'] ~/ 2
      ..context2D.scale(0.5, 0.5)
      ..context2D.drawImage(video, 0, 0);

    clip.setImage(
        canvas.context2D.getImageData(0, 0, canvas.width, canvas.height));
  }

  void openEditor() {
    showClipEditorDialog = true;
    canvasData = clip;
  }

  void closeEditor() {
    showClipEditorDialog = false;
    canvasData = null;
  }

  Map<dynamic, dynamic> dumpOptionsInfo(VideoElement video) {
    final videoTrack = video.srcObject.getVideoTracks()[0];
    return videoTrack.getSettings();
  }
}
