import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:remainder_portal/data/services/database_service.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Inject a native in-memory database connection for unit testing isolation
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('Drift Schema Offline Ingestion: User profile creation and retrieval works', () async {
    final now = DateTime.now();
    await database.into(database.users).insert(
      UsersCompanion.insert(
        id: 'operator_alpha',
        displayName: 'Kaelen Ally',
        email: 'ally@remainder.net',
        origin: 'Amatsukrion Sync',
        activeSector: 'sectors_neon_bastion_4',
        reputationRanks: const Value('{"Vanguard": 2}'),
        joinedDate: now,
        trustScore: 0.88,
      ),
    );

    final users = await database.select(database.users).get();
    expect(users.length, 1);
    
    final user = users.first;
    expect(user.id, 'operator_alpha');
    expect(user.displayName, 'Kaelen Ally');
    expect(user.origin, 'Amatsukrion Sync');
    expect(user.activeSector, 'sectors_neon_bastion_4');
    expect(user.trustScore, 0.88);
  });

  test('Drift Schema Offline Ingestion: Chat history and sync tracking queues properly', () async {
    final now = DateTime.now();
    
    // Insert story thread session
    await database.into(database.storyThreads).insert(
      StoryThreadsCompanion.insert(
        id: 'session_001',
        userId: 'operator_alpha',
        title: 'Genesis Encounter',
        currentSectorId: 'sectors_neon_bastion_4',
        lastInteraction: now,
      ),
    );

    // Insert pending chat message
    await database.into(database.chatMessages).insert(
      ChatMessagesCompanion.insert(
        id: 'msg_101',
        threadId: 'session_001',
        role: 'user',
        content: 'Analyzing portal signals.',
        timestamp: now,
        syncStatus: const Value(0), // 0: Pending, 1: Synced
      ),
    );

    final messages = await database.select(database.chatMessages).get();
    expect(messages.length, 1);
    
    final message = messages.first;
    expect(message.id, 'msg_101');
    expect(message.threadId, 'session_001');
    expect(message.role, 'user');
    expect(message.content, 'Analyzing portal signals.');
    expect(message.syncStatus, 0);
  });
}
