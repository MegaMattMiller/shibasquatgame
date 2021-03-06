import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import './src/shibasquat.dart';

Future<void> main() async {
  StageXL.bitmapDataLoadOptions.corsEnabled = true;

  var options = new StageOptions()
    ..stageAlign = StageAlign.TOP
    ..stageScaleMode = StageScaleMode.SHOW_ALL
    ..inputEventMode = InputEventMode.MouseAndTouch
    ..renderEngine = RenderEngine.WebGL
    ..backgroundColor = Color.White;

  var canvas = html.querySelector('#stage');
  var stage = Stage(canvas, width: 1280, height: 720, options: options);

  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  var textFormat = TextFormat('Arial', 72, Color.Black)
    ..align = TextFormatAlign.CENTER
    ..verticalAlign = TextFormatVerticalAlign.CENTER;

  var startButton = TextField('Start', textFormat)
    ..width = 1280
    ..height = 500
    ..useHandCursor = true
    ..addEventListener(MouseEvent.CLICK, (Event event) async {
      var startButton = event.target as TextField;
      startButton.text = 'Loading...';
      event.target.removeEventListeners(MouseEvent.CLICK);
      var entryPoint = ShibaSquat();
      await entryPoint.init();
      stage.addChild(entryPoint);
      entryPoint.start();
    })
    ..addEventListener(TouchEvent.TOUCH_TAP, (Event event) async {
      var startButton = event.target as TextField;
      startButton.text = 'Loading...';
      event.target.removeEventListeners(TouchEvent.TOUCH_TAP);
      var entryPoint = ShibaSquat();
      await entryPoint.init();
      stage.addChild(entryPoint);
      entryPoint.start();
    })
    ..addTo(stage);

  var instructionsText = '''
    Click or Touch to squat.\nBuild as much score as possible before time or stamina run out!
    ''';

  var instructionsField = TextField(instructionsText, textFormat)
    ..width = 1080
    ..height = 320
    ..x = 100
    ..y = 400
    ..multiline = true
    ..wordWrap = true
    ..addTo(stage);
}
