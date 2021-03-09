import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import './src/shibasquat.dart';

Future<void> main() async {
  var options = StageOptions()
    ..backgroundColor = Color.White
    ..renderEngine = RenderEngine.WebGL;

  var canvas = html.querySelector('#stage');
  var stage = Stage(canvas, width: 1280, height: 720, options: options);

  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  var textFormat = TextFormat('Arial', 72, Color.Black)
    ..align = TextFormatAlign.CENTER
    ..verticalAlign = TextFormatVerticalAlign.CENTER;

  var text = TextField('Start', textFormat)
    ..width = 1280
    ..height = 720
    ..useHandCursor = true
    ..addEventListener(MouseEvent.CLICK, (Event event) async {
      var entryPoint = ShibaSquat();
      await entryPoint.init();
      stage.addChild(entryPoint);
      entryPoint.start();
    })
    ..addTo(stage);
}
