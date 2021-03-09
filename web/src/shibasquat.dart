import 'package:stagexl/stagexl.dart';
import 'dart:math';

class ShibaSquat extends Sprite {
  ResourceManager _resourceManager;
  bool _paused = false;
  Map<int, bool> keyMap = <int, bool>{};
  ScoreTracker _scoreTracker;
  Petey _petey;
  GlassPlate _glassPlate;

  bool get paused => _paused;
  set paused(bool value) => _paused = value;

  ShibaSquat();

  Future<void> init() async {
    _resourceManager = ResourceManager();
    await _loadAssets();
    await _buildUi();
  }

  void start() {
    _setupKeys();
    _setupPetey();
    _setupScoreTracker();
    var bgm = _resourceManager.getSound('bgm');
    bgm.play(true);

    addChild(_glassPlate);
  }

  Future<void> _loadAssets() async {
    _resourceManager
      ..addBitmapData('bg', 'images/background.png')
      ..addBitmapData('up', 'images/up.png')
      ..addBitmapData('down', 'images/down.png')
      ..addSound('grunt1', 'sounds/grunt1.mp3')
      ..addSound('grunt2', 'sounds/grunt2.mp3')
      ..addSound('grunt3', 'sounds/grunt3.mp3')
      ..addSound('grunt4', 'sounds/grunt4.mp3')
      ..addSound('bgm', 'sounds/bgm.mp3');

    await _resourceManager.load();
  }

  Future<void> _buildUi() async {
    addChild(Bitmap(_resourceManager.getBitmapData('bg')));
    _glassPlate = GlassPlate(1280, 720)
      ..useHandCursor = true
      ..mouseEnabled = true
      ..addTo(this);
  }

  void _setupKeys() {
    stage.focus = stage;
    stage.onKeyDown.listen((ke) {
      if (![32].contains(ke.keyCode)) return;
      keyMap[ke.keyCode] = true;
    });
    stage.onKeyUp.listen((ke) {
      if (![32].contains(ke.keyCode)) return;
      keyMap[ke.keyCode] = false;
    });
    _glassPlate.addEventListener(TouchEvent.TOUCH_BEGIN, (TouchEvent event) {
      keyMap[32] = true;
    });
    _glassPlate.addEventListener(TouchEvent.TOUCH_END, (TouchEvent event) {
      keyMap[32] = false;
    });
    _glassPlate.addEventListener(MouseEvent.MOUSE_DOWN, (MouseEvent event) {
      keyMap[32] = true;
    });
    _glassPlate.addEventListener(MouseEvent.MOUSE_UP, (MouseEvent event) {
      keyMap[32] = false;
    });
  }

  void _setupPetey() {
    _petey = Petey(_resourceManager, keyMap);
    _petey
      ..scaleX = 0.5
      ..scaleY = 0.5;

    _petey
      ..x = 640 - (_petey.width / 2)
      ..y = 720 - (_petey.height) - 40
      ..addEventListener(Event.CHANGE, (Event event) {
        _scoreTracker.isUp = _petey.isUp;
      });
    stage.juggler.add(_petey);
    addChild(_petey);
  }

  void _setupScoreTracker() {
    _scoreTracker = ScoreTracker(_petey.isUp);
    stage.juggler.add(_scoreTracker);
  }
}

class ScoreTracker extends Object implements Animatable {
  bool _isUp;
  set isUp(bool value) => _isUp = value;

  num score = 0.0;

  ScoreTracker(this._isUp);

  @override
  bool advanceTime(num deltaTime) {
    if (!_isUp) {
      score = score + deltaTime;
      print(score);
    }
    return true;
  }
}

class Petey extends DisplayObjectContainer implements Animatable {
  ResourceManager _resourceManager;
  Map<int, bool> _keyMap = <int, bool>{};
  bool _isUp = true;
  bool get isUp => _isUp;
  BitmapData _up;
  BitmapData _down;
  final _random = Random();

  Petey(this._resourceManager, this._keyMap) {
    _up = _resourceManager.getBitmapData('up');
    _down = _resourceManager.getBitmapData('down');
    _drawPetey();
  }

  @override
  bool advanceTime(num deltaTime) {
    var lastIsUp = _isUp;
    if (_keyMap[32] == true) {
      _isUp = false;
    } else {
      _isUp = true;
    }
    if (_isUp != lastIsUp) {
      dispatchEvent(Event(Event.CHANGE));
      if (_isUp == false) {
        _playGrunt();
      }
    }
    _drawPetey();
    return true;
  }

  void _drawPetey() {
    removeChildren();
    if (_isUp) {
      addChild(Bitmap(_up));
    } else {
      addChild(Bitmap(_down));
    }
  }

  void _playGrunt() {
    var gruntInt = _random.nextInt(4);
    gruntInt++;
    var grunt = _resourceManager.getSound('grunt${gruntInt}');
    grunt.play();
  }
}
