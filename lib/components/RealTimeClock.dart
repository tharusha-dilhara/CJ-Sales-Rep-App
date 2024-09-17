import 'dart:async';
import 'package:flutter/material.dart';

class RealTimeClock extends StatefulWidget {
  const RealTimeClock({Key? key}) : super(key: key);

  @override
  _RealTimeClockState createState() => _RealTimeClockState();
}

class _RealTimeClockState extends State<RealTimeClock> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(_currentTime),
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
