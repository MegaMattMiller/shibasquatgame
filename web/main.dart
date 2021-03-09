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

  var entryPoint = ShibaSquat();
  await entryPoint.init();
  stage.addChild(entryPoint);
  entryPoint.start();
}
