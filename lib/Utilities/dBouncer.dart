import 'dart:async';
import 'dart:ui';

class DBouncer {
  final int milliseconds;
  Timer? _timer;

  DBouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}