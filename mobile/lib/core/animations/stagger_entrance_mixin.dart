import 'package:flutter/material.dart';

mixin StaggerEntranceMixin<T extends StatefulWidget> on State<T>
    implements TickerProviderStateMixin<T> {
  late final AnimationController staggerController;

  Duration get staggerDuration => const Duration(milliseconds: 900);
  double get staggerFraction => 0.15;
  double get staggerSlide => 0.06;
  Curve get staggerCurve => Curves.easeOut;

  @override
  void initState() {
    super.initState();
    staggerController = AnimationController(
      vsync: this,
      duration: staggerDuration,
    )..forward();
  }

  @override
  void dispose() {
    staggerController.dispose();
    super.dispose();
  }

  /// returns fade and slide animations for a child at [index] out of [total].
  ({Animation<double> fade, Animation<Offset> slide}) staggerAnim(
    int index,
    int total,
  ) {
    final windowSize = (1.0 - staggerFraction * (total - 1)).clamp(0.2, 1.0);
    final start = (staggerFraction * index).clamp(0.0, 1.0);
    final end = (start + windowSize).clamp(0.0, 1.0);

    final curved = CurvedAnimation(
      parent: staggerController,
      curve: Interval(start, end, curve: staggerCurve),
    );

    return (
      fade: Tween<double>(begin: 0, end: 1).animate(curved),
      slide: Tween<Offset>(
        begin: Offset(0, staggerSlide),
        end: Offset.zero,
      ).animate(curved),
    );
  }
}
