import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TrustVector { vanguard, arbiter, merchant, hacker }

class EndorsementRecord {
  final String id;
  final String giverId;
  final String receiverId;
  final TrustVector vector;
  final DateTime timestamp;

  EndorsementRecord({
    required this.id,
    required this.giverId,
    required this.receiverId,
    required this.vector,
    required this.timestamp,
  });
}

class TrustState {
  final double vanguardScore;
  final double arbiterScore;
  final double merchantScore;
  final double hackerScore;
  final List<EndorsementRecord> endorsementsGiven;
  final List<EndorsementRecord> endorsementsReceived;

  TrustState({
    this.vanguardScore = 0.5,
    this.arbiterScore = 0.5,
    this.merchantScore = 0.5,
    this.hackerScore = 0.5,
    this.endorsementsGiven = const [],
    this.endorsementsReceived = const [],
  });

  double get overallTrustScore =>
      (vanguardScore + arbiterScore + merchantScore + hackerScore) / 4.0;

  TrustState copyWith({
    double? vanguardScore,
    double? arbiterScore,
    double? merchantScore,
    double? hackerScore,
    List<EndorsementRecord>? endorsementsGiven,
    List<EndorsementRecord>? endorsementsReceived,
  }) {
    return TrustState(
      vanguardScore: vanguardScore ?? this.vanguardScore,
      arbiterScore: arbiterScore ?? this.arbiterScore,
      merchantScore: merchantScore ?? this.merchantScore,
      hackerScore: hackerScore ?? this.hackerScore,
      endorsementsGiven: endorsementsGiven ?? this.endorsementsGiven,
      endorsementsReceived: endorsementsReceived ?? this.endorsementsReceived,
    );
  }
}

class TrustNotifier extends StateNotifier<TrustState> {
  TrustNotifier() : super(TrustState());

  bool canGiveEndorsement() {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
    final givenLast24h = state.endorsementsGiven.where(
      (e) => e.timestamp.isAfter(twentyFourHoursAgo),
    ).length;
    return givenLast24h < 3;
  }

  bool addEndorsement({
    required String giverId,
    required String receiverId,
    required TrustVector vector,
  }) {
    if (!canGiveEndorsement()) return false;

    final record = EndorsementRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      giverId: giverId,
      receiverId: receiverId,
      vector: vector,
      timestamp: DateTime.now(),
    );

    final updatedGiven = [...state.endorsementsGiven, record];
    state = state.copyWith(endorsementsGiven: updatedGiven);
    return true;
  }

  void receiveEndorsement(EndorsementRecord record, {double giverTrust = 0.5}) {
    final updatedReceived = [...state.endorsementsReceived, record];

    // Check reciprocation within 7 days
    final sevenDaysAgo = record.timestamp.subtract(const Duration(days: 7));
    final hasReciprocated = state.endorsementsGiven.any(
      (e) => e.receiverId == record.giverId && e.timestamp.isAfter(sevenDaysAgo),
    );

    final yieldFactor = hasReciprocated ? 0.05 : 0.1;
    final increment = yieldFactor * giverTrust;

    double v = state.vanguardScore;
    double a = state.arbiterScore;
    double m = state.merchantScore;
    double h = state.hackerScore;

    switch (record.vector) {
      case TrustVector.vanguard:
        v = (v + increment).clamp(0.0, 1.0);
        break;
      case TrustVector.arbiter:
        a = (a + increment).clamp(0.0, 1.0);
        break;
      case TrustVector.merchant:
        m = (m + increment).clamp(0.0, 1.0);
        break;
      case TrustVector.hacker:
        h = (h + increment).clamp(0.0, 1.0);
        break;
    }

    state = state.copyWith(
      vanguardScore: v,
      arbiterScore: a,
      merchantScore: m,
      hackerScore: h,
      endorsementsReceived: updatedReceived,
    );
  }
}

final trustProvider = StateNotifierProvider<TrustNotifier, TrustState>((ref) {
  return TrustNotifier();
});
