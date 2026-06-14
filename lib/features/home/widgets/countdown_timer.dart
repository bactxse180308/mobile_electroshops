import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  int _h = 5, _m = 42, _s = 18;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _s--;
        if (_s < 0) {
          _s = 59;
          _m--;
        }
        if (_m < 0) {
          _m = 59;
          _h--;
        }
        if (_h < 0) {
          _h = 5;
          _m = 42;
          _s = 18;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, color: Colors.white70, size: 12),
        const SizedBox(width: AppSizes.p4),
        _Chip(pad(_h)),
        const Text(':', style: TextStyle(color: Colors.white70, fontSize: 12)),
        _Chip(pad(_m)),
        const Text(':', style: TextStyle(color: Colors.white70, fontSize: 12)),
        _Chip(pad(_s)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(AppSizes.r4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
