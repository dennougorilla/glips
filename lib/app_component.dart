import 'dart:html';
import 'package:angular/angular.dart';

import 'src/get_display_media.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
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
