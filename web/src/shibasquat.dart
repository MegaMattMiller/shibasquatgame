import 'package:stagexl/stagexl.dart';
import 'dart:math';
import 'dart:async';

class ShibaSquat extends Sprite {
  ResourceManager _resourceManager;
  bool _paused = false;
  Map<int, bool> keyMap = <int, bool>{};
  ScoreTracker _scoreTracker;
  StaminaTracker staminaTracker;
  Petey _petey;
  GlassPlate _glassPlate;
  TextField _scoreField;
  TextField _staminaField;
  TextField _timeField;
  bool _gameOver = false;
  Timer _timer;
  int _timeRemaining = 60;

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
    _setupTimer();
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

    var scoreFormat = TextFormat('Arial', 72, Color.Black)
      ..align = TextFormatAlign.LEFT
      ..verticalAlign = TextFormatVerticalAlign.CENTER;

    var staminaFormat = TextFormat('Arial', 72, Color.Black)
      ..align = TextFormatAlign.RIGHT
      ..verticalAlign = TextFormatVerticalAlign.CENTER;

    var scoreLabel = TextField('Score', scoreFormat)
      ..x = 20
      ..width = 200
      ..height = 100
      ..addTo(this);

    _scoreField = TextField('0.0', scoreFormat)
      ..x = 20
      ..y = 100
      ..width = 200
      ..height = 100
      ..addTo(this);

    var staminaLabel = TextField('Stamina', staminaFormat)
      ..x = 980 - 20
      ..width = 300
      ..height = 100
      ..addTo(this);

    _staminaField = TextField('0.0', staminaFormat)
      ..x = 1080 - 20
      ..y = 100
      ..width = 200
      ..height = 100
      ..addTo(this);

    var timeFormat = TextFormat('Arial', 80, Color.Black)
      ..align = TextFormatAlign.CENTER
      ..verticalAlign = TextFormatVerticalAlign.CENTER;

    _timeField = TextField(_timeRemaining.toString(), timeFormat)
      ..x = 540
      ..y = 20
      ..width = 200
      ..height = 100
      ..addTo(this);

    _glassPlate = GlassPlate(1280, 720)
      ..useHandCursor = true
      ..mouseEnabled = true
      ..addTo(this);
  }

  void _setupKeys() {
    stage.focus = stage;
    stage.onKeyDown.listen((ke) {
      keyMap[ke.keyCode] = true;
    });
    stage.onKeyUp.listen((ke) {
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
        staminaTracker.isUp = _petey.isUp;
        _gameOver = _petey.gameover;
      });
    stage.juggler.add(_petey);
    addChild(_petey);
  }

  void _setupScoreTracker() {
    _scoreTracker = ScoreTracker(_petey.isUp);
    // stage.juggler.add(_scoreTracker);

    var scoreTimer = Timer.periodic(Duration(milliseconds: 10), (Timer timer) {
      _scoreTracker.advanceTime(0.01);
      if (_gameOver) timer.cancel();
    });

    staminaTracker = StaminaTracker(_petey);
    // stage.juggler.add(staminaTracker);

    var staminaTimer =
        Timer.periodic(Duration(milliseconds: 10), (Timer timer) {
      staminaTracker.advanceTime(0.01);
      if (_gameOver) timer.cancel();
    });

    _timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      _scoreField.text = _scoreTracker.score.toStringAsFixed(1);
      _staminaField.text = staminaTracker.stamina.toStringAsFixed(1);
      if (_gameOver) {
        timer.cancel();
        _handleGameOver();
      }
    });
  }

  void _setupTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
      } else {
        _gameOver = true;
      }
      _timeField.text = _timeRemaining.toString();
      if (_gameOver) timer.cancel();
    });
  }

  void _handleGameOver() {
    var blackout = Bitmap(BitmapData(1280, 720, Color.Black))
      ..alpha = 0.80
      ..addTo(this);

    var gameOverFormat = TextFormat('Arial', 100, Color.DarkRed)
      ..align = TextFormatAlign.CENTER
      ..verticalAlign = TextFormatVerticalAlign.CENTER;

    var gameOverField = TextField('GAME OVER', gameOverFormat)
      ..width = 1280
      ..height = 200
      ..y = 200
      ..addTo(this);

    var scoreFormat = TextFormat('Arial', 100, Color.DarkRed)
      ..align = TextFormatAlign.CENTER
      ..verticalAlign = TextFormatVerticalAlign.CENTER;

    var scoreField = TextField(
        'FINAL SCORE: ${_scoreTracker.score.toStringAsFixed(1)}', scoreFormat)
      ..width = 1280
      ..height = 200
      ..y = 400
      ..addTo(this);
  }
}

class ScoreTracker extends Object implements Animatable {
  bool _isUp = true;
  set isUp(bool value) => _isUp = value;

  num score = 0.0;

  ScoreTracker(this._isUp);

  @override
  bool advanceTime(num deltaTime) {
    if (!_isUp) {
      score += deltaTime * 10;
    }
    return true;
  }
}

class StaminaTracker extends Object implements Animatable {
  Petey _petey;
  bool _isUp = true;
  set isUp(bool value) => _isUp = value;

  num stamina = 100.0;

  StaminaTracker(this._petey);

  @override
  bool advanceTime(num deltaTime) {
    if (_isUp) {
      stamina += deltaTime;
    } else {
      stamina -= deltaTime * 10;
    }
    stamina = stamina.clamp(0.0, 100.0);
    _petey.stamina = stamina;
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
  num stamina = 100.0;
  bool gameover = false;

  Petey(this._resourceManager, this._keyMap) {
    _up = _resourceManager.getBitmapData('up');
    _down = _resourceManager.getBitmapData('down');
    _drawPetey();
  }

  @override
  bool advanceTime(num deltaTime) {
    var lastIsUp = _isUp;
    if (_keyMap[32] == true && stamina > 0.0 && !gameover) {
      _isUp = false;
    } else {
      _isUp = true;
    }
    if (stamina <= 0.1) {
      gameover = true;
      dispatchEvent(Event(Event.CHANGE));
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
