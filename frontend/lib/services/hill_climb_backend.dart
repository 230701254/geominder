// lib/services/hill_climb_backend.dart
import 'dart:math';

Future<bool> checkHillClimbTrigger(double distance) async {
  double threshold = 100; // initial limit
  double bestDistance = distance;

  for (int i = 0; i < 10; i++) {
    double step = Random().nextDouble() * 10 - 5;
    double newDistance = bestDistance + step;

    if (newDistance.abs() < bestDistance.abs()) {
      bestDistance = newDistance;
    }
  }

  // trigger if optimized distance is under threshold
  return bestDistance < threshold;
}
