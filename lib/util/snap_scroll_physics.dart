import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Scroll physics that snaps to the nearest multiple of [snapExtent]
/// when the user releases a scroll, creating a "magnetic" scroll effect.
class SnapScrollPhysics extends ScrollPhysics {
  const SnapScrollPhysics({
    required this.snapExtent,
    super.parent,
  });

  final double snapExtent;

  @override
  SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapScrollPhysics(
      snapExtent: snapExtent,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    final double target = position.pixels + velocity * 0.16;
    if (target <= 0) return 0;
    if (target >= position.maxScrollExtent) return position.maxScrollExtent;

    final int snapIndex = (target / snapExtent).round();
    return (snapIndex * snapExtent).clamp(0.0, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);

    if (target != position.pixels) {
      return ScrollSpringSimulation(
        SpringDescription.withDampingRatio(
          mass: 0.5,
          stiffness: 100.0,
          ratio: 1.1,
        ),
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }

    return super.createBallisticSimulation(position, velocity);
  }
}
