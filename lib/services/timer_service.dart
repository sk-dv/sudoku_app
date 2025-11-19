import 'dart:async';

class TimerService {
  Timer? _timer;
  int _elapsedSeconds = 0;
  final _timeController = StreamController<int>.broadcast();

  Stream<int> get timeStream => _timeController.stream;
  int get elapsedSeconds => _elapsedSeconds;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      _timeController.add(_elapsedSeconds);
    });
  }

  void pause() {
    _timer?.cancel();
  }

  void resume() {
    start();
  }

  void stop() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _timeController.add(_elapsedSeconds);
  }

  void setTime(int seconds) {
    _elapsedSeconds = seconds;
    _timeController.add(_elapsedSeconds);
  }

  void dispose() {
    _timer?.cancel();
    _timeController.close();
  }
}
