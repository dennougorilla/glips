import 'dart:html';
import 'package:angular/angular.dart';

import 'package:glips/src/get_display_media.dart';

@Component(
  selector: 'screen',
  styles: [''],
  template: ''

  //directives: [],
)
class AppComponent {
  MediaStream stream;
  void startScreenRecord() async {
    stream = await getDisplayMedia();
    final video = VideoElement()
      ..autoplay = true
      ..srcObject = stream;
    document.body.append(video);
  }
}
