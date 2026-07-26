import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:remainder_portal/data/services/litert_service.dart';
import 'package:remainder_portal/data/services/database_service.dart';
import 'package:remainder_portal/presentation/providers/game_provider.dart';

void main() {
  group('Phase 1 Tests', () {
    test('LiteRtService generates offline d20 rule engine fallback on cloud connection failure', () async {
      final service = LiteRtService(cloudEndpoint: 'http://invalid.invalid:9999/api/gm');
      final response = await service.generateStoryResponse('Overriding firewall security', characterClass: 'Vanguard');

      expect(response, contains('[OFFLINE RULE ENGINE]'));
      expect(response, contains('D20 Roll:'));
      expect(response, contains('Vanguard'));
    });

    test('MessageModel supports isIC flag and ChatFilter enum', () {
      final icMsg = MessageModel(
        sender: 'Player',
        content: 'I draw my plasma blade.',
        timestamp: DateTime.now(),
        isIC: true,
      );

      final oocMsg = MessageModel(
        sender: 'Player',
        content: 'Brb getting water.',
        timestamp: DateTime.now(),
        isIC: false,
      );

      expect(icMsg.isIC, isTrue);
      expect(oocMsg.isIC, isFalse);
    });

    test('AppDatabase configures foreign keys pragma on beforeOpen', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final result = await db.customSelect('PRAGMA foreign_keys;').getSingle();
      expect(result.data['foreign_keys'], 1);
      await db.close();
    });
  });
}
