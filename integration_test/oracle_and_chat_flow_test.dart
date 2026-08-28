import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:remainder_portal/main.dart' as app;

void main() {
  patrolTest(
    'Interacts with Aether Resonance Oracle and Nexus Chat IC/OOC flow',
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // If splash screen is visible, wait for transition
      if ($('THE REMAINDER PORTAL').visible) {
        await Future.delayed(const Duration(seconds: 3));
        await $.pumpAndSettle();
      }

      // Check Oracle widget on Dashboard
      if ($('COMMUNE WITH ARBITER').visible) {
        await $('COMMUNE WITH ARBITER').tap();
        await $.pumpAndSettle();
      }

      // Navigate to NEXUS CHAT
      await $('NEXUS CHAT').tap();
      await $.pumpAndSettle();

      // Verify chat filter chips
      expect($('ALL CHANNELS').visible, isTrue);
      expect($('IC ROLEPLAY').visible, isTrue);
      expect($('OOC CHAT').visible, isTrue);

      // Tap OOC CHAT chip
      await $('OOC CHAT').tap();
      await $.pumpAndSettle();

      // Tap IC ROLEPLAY chip
      await $('IC ROLEPLAY').tap();
      await $.pumpAndSettle();
    },
  );
}
