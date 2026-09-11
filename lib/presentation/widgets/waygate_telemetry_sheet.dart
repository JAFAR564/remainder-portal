import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sovereign_provider.dart';

/// Modal bottom sheet surfacing genuine Phase 2 / Phase 3 subsystem telemetry,
/// canonical operator trust vector ratings, and un-fabricated P2P mesh status.
class WaygateTelemetrySheet extends ConsumerWidget {
  const WaygateTelemetrySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WaygateTelemetrySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(waygateTelemetryProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40291C0E),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFBEB5A9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Row with Title and Close Action
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.hub_outlined, color: Color(0xFF6E473B), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WAYGATE NETWORK & TELEMETRY',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF291C0E),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'SOVEREIGN REALM BUS & PHASE 2/3 LINK',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8.5,
                        color: Color(0xFFA78D78),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('close_waygate_telemetry_sheet'),
                icon: const Icon(Icons.close, color: Color(0xFF6E473B), size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFBEB5A9), height: 1),
          const SizedBox(height: 12),

          // Scrollable Telemetry Cards
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Subsystem Waygate Badges (Phase 2 & Phase 3)
                  const Text(
                    'SUBSYSTEM DOMAIN CHANNELS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E473B),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTelemetryTile(
                          icon: Icons.swap_horiz,
                          label: 'MARKET / ESCROW',
                          value: '${telemetry.tradePendingCount} PENDING',
                          sub: 'Phase 3 Trade Engine',
                          color: const Color(0xFF291C0E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTelemetryTile(
                          icon: Icons.auto_stories,
                          label: 'CANON / LORE',
                          value: '${telemetry.canonActiveProposalsCount} ACTIVE',
                          sub: 'Phase 2 Chrono-Loom',
                          color: const Color(0xFFA78D78),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTelemetryTile(
                          icon: Icons.shield,
                          label: 'SQUAD CO-OP',
                          value: telemetry.isSquadActive ? 'ROSTER: ${telemetry.squadMemberCount}/5' : 'STANDBY (0/5)',
                          sub: 'Phase 2 Expeditions',
                          color: const Color(0xFF6E473B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTelemetryTile(
                          icon: Icons.fort,
                          label: 'GUILD ALLIANCE',
                          value: telemetry.guildTag ?? 'NO GUILD',
                          sub: 'Phase 2 Governance',
                          color: const Color(0xFF291C0E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Canonical Operator Trust Vector System (Phase 2 trustProvider)
                  const Text(
                    'OPERATOR TRUST VECTOR (PHASE 2 CANON)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E473B),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'OVERALL OPERATOR TRUST',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF291C0E),
                              ),
                            ),
                            Text(
                              '${(telemetry.overallTrustScore * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6E473B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: telemetry.overallTrustScore,
                            backgroundColor: const Color(0xFFBEB5A9).withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6E473B)),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildVectorPill('VANGUARD', telemetry.vanguardScore)),
                            const SizedBox(width: 6),
                            Expanded(child: _buildVectorPill('ARBITER', telemetry.arbiterScore)),
                            const SizedBox(width: 6),
                            Expanded(child: _buildVectorPill('MERCHANT', telemetry.merchantScore)),
                            const SizedBox(width: 6),
                            Expanded(child: _buildVectorPill('HACKER', telemetry.hackerScore)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. P2P Mesh & Relay Telemetry (Un-fabricated & Honest)
                  const Text(
                    'P2P MESH & RELAY PROTOCOL STATUS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E473B),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
                    ),
                    child: Column(
                      children: [
                        _buildStatusRow('Mesh Status', telemetry.p2pMeshStatus, Icons.cell_tower),
                        const Divider(color: Color(0xFFBEB5A9), height: 16),
                        _buildStatusRow('Connected Mesh Peers', '${telemetry.connectedPeersCount} PEERS', Icons.group_off_outlined),
                        const Divider(color: Color(0xFFBEB5A9), height: 16),
                        _buildStatusRow('Local Relay Queue', '${telemetry.relayQueuedCount} EVENTS', Icons.queue_outlined),
                        const Divider(color: Color(0xFFBEB5A9), height: 16),
                        _buildStatusRow('Sync Engine', telemetry.syncEngineStatus, Icons.sync_disabled),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Architectural Disclosure Banner (Contract Compliance)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBEB5A9).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA78D78).withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF6E473B), size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            telemetry.architecturalNotice,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 9.5,
                              height: 1.35,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF291C0E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryTile({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFA78D78).withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF291C0E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 7.5,
              color: Color(0xFFA78D78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVectorPill(String name, double score) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFA78D78).withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA78D78),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${(score * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF291C0E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6E473B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              color: Color(0xFF291C0E),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6E473B),
          ),
        ),
      ],
    );
  }
}
