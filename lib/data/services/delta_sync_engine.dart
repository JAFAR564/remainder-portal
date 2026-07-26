class VectorClock {
  final Map<String, int> clock;

  VectorClock(this.clock);

  factory VectorClock.fromMap(Map<String, dynamic> map) {
    return VectorClock(
      map.map((key, value) => MapEntry(key, value as int)),
    );
  }

  Map<String, int> toMap() => Map<String, int>.from(clock);

  /// Returns 1 if this clock dominates [other], -1 if [other] dominates, or 0 if concurrent (divergent).
  int compare(VectorClock other) {
    bool greater = false;
    bool lesser = false;

    final allKeys = {...clock.keys, ...other.clock.keys};

    for (final k in allKeys) {
      final v1 = clock[k] ?? 0;
      final v2 = other.clock[k] ?? 0;

      if (v1 > v2) greater = true;
      if (v1 < v2) lesser = true;
    }

    if (greater && !lesser) return 1;
    if (lesser && !greater) return -1;
    return 0; // Concurrent / divergent
  }
}

class DeltaEntity {
  final String entityId;
  final String entityType;
  final Map<String, dynamic> data;
  final VectorClock vectorClock;
  final DateTime lastModified;
  final double authorTrustScore;

  DeltaEntity({
    required this.entityId,
    required this.entityType,
    required this.data,
    required this.vectorClock,
    required this.lastModified,
    this.authorTrustScore = 0.5,
  });
}

class ConflictResolutionResult {
  final DeltaEntity winningEntity;
  final String resolutionMethod; // 'LOCAL_DOMINATES', 'REMOTE_DOMINATES', 'LWW_TIMESTAMP', 'TRUST_TIEBREAKER'

  ConflictResolutionResult(this.winningEntity, this.resolutionMethod);
}

class DeltaSyncEngine {
  /// Resolves conflicts between a local offline entity state and a incoming remote delta stream entity.
  ConflictResolutionResult resolveConflict(DeltaEntity local, DeltaEntity remote) {
    final cmp = local.vectorClock.compare(remote.vectorClock);

    if (cmp > 0) {
      return ConflictResolutionResult(local, 'LOCAL_DOMINATES');
    } else if (cmp < 0) {
      return ConflictResolutionResult(remote, 'REMOTE_DOMINATES');
    }

    // Concurrent edit detected - fallback to Last-Write-Wins (LWW) timestamp check
    if (local.lastModified.isAfter(remote.lastModified)) {
      return ConflictResolutionResult(local, 'LWW_TIMESTAMP');
    } else if (remote.lastModified.isAfter(local.lastModified)) {
      return ConflictResolutionResult(remote, 'LWW_TIMESTAMP');
    }

    // Timestamps identical - resolve via author TrustScore tie-breaker
    if (local.authorTrustScore >= remote.authorTrustScore) {
      return ConflictResolutionResult(local, 'TRUST_TIEBREAKER');
    } else {
      return ConflictResolutionResult(remote, 'TRUST_TIEBREAKER');
    }
  }

  /// Processes a batch of local delta updates, resolving any conflicts against remote entities.
  List<DeltaEntity> syncBatch(List<DeltaEntity> localDeltas, List<DeltaEntity> remoteDeltas) {
    final Map<String, DeltaEntity> resolvedMap = {};

    for (final l in localDeltas) {
      resolvedMap[l.entityId] = l;
    }

    for (final r in remoteDeltas) {
      if (resolvedMap.containsKey(r.entityId)) {
        final local = resolvedMap[r.entityId]!;
        final res = resolveConflict(local, r);
        resolvedMap[r.entityId] = res.winningEntity;
      } else {
        resolvedMap[r.entityId] = r;
      }
    }

    return resolvedMap.values.toList();
  }
}
