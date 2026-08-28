import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:remainder_portal/main.dart' as app;

void main() {
  patrolTest(
    'Cold boots app and navigates across all 5 celestial bottom navbar tabs',
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // If splash screen is visible, wait for transition
      if ($('THE REMAINDER PORTAL').visible) {
        await Future.delayed(const Duration(seconds: 3));
        await $.pumpAndSettle();
      }

      // Verify Dashboard Screen presence
      expect($('DASHBOARD').visible, isTrue);

      // 1. Navigate to NEXUS CHAT tab
      await $('NEXUS CHAT').tap();
      await $.pumpAndSettle();
      expect($('SOVEREIGN REALM & WORLD ARBITER CHAT').visible, isTrue);

      // 2. Navigate to SQUADS tab
      await $('SQUADS').tap();
      await $.pumpAndSettle();
      expect($('SANCTUARY SQUAD MATRIX').visible, isTrue);

      // 3. Navigate to GUILDS tab
      await $('GUILDS').tap();
      await $.pumpAndSettle();
      expect($('SOVEREIGN GUILDS & GOVERNANCE').visible, isTrue);

      // 4. Navigate to SETTINGS tab
      await $('SETTINGS').tap();
      await $.pumpAndSettle();
      expect($('SOVEREIGN REALM & WORLD SETTINGS').visible, isTrue);

      // 5. Navigate back to DASHBOARD tab
      await $('DASHBOARD').tap();
      await $.pumpAndSettle();
      expect($('SOVEREIGN VITALITY & ESSENCE GAUGES').visible, isTrue);
    },
  );
}
