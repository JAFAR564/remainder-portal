import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/oracle_record.dart';
import '../../data/repositories/sovereign_repository.dart';
import '../providers/sovereign_provider.dart';
import '../providers/utrcs_provider.dart';
import 'celestial_panel.dart';
import 'oracle_chronicle_sheet.dart';

/// Celestial Astrolabe Aether Resonance Oracle Widget wired to persistent SQLite history and active buffs.
class AetherResonanceOracleWidget extends ConsumerStatefulWidget {
  const AetherResonanceOracleWidget({super.key});

  @override
  ConsumerState<AetherResonanceOracleWidget> createState() => _AetherResonanceOracleWidgetState();
}

class _AetherResonanceOracleWidgetState extends ConsumerState<AetherResonanceOracleWidget> {
  bool _isCommuning = false;

  Future<void> _communeWithArbiter(String userId) async {
    setState(() => _isCommuning = true);
    try {
      final record = await ref.read(oracleBuffProvider(userId).notifier).commune(
        costEssence: 25,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Divination complete: D20 [${record.d20Roll}] — ${record.outcomeTier}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
            backgroundColor: const Color(0xFF6E473B),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Divination failed: $e',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCommuning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(utrcsCharacterProvider);
    final userId = character?.id ?? 'utrcs_default_player';
    final oracleStateAsync = ref.watch(activeOracleBuffProvider);

    final oracleState = oracleStateAsync.valueOrNull;
    final latestRecord = oracleState?.latestRecord ?? SovereignRepository.defaultStarterRoll(userId);
    final primaryBuff = oracleState?.primaryBuff;

    return RepaintBoundary(
      child: CelestialPanel(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Header with Flex-Safety & Chronicle action
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF6E473B), size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'AETHER RESONANCE ORACLE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      color: Color(0xFF6E473B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Chronicle ↗ action
                InkWell(
                  key: const Key('open_oracle_chronicle_sheet'),
                  onTap: () => OracleChronicleSheet.show(context),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF6E473B).withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'CHRONICLE ↗',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6E473B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // D20 Badge
                InkWell(
                  key: const Key('oracle_badge_button'),
                  onTap: () => OracleChronicleSheet.show(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF6E473B)),
                    ),
                    child: Text(
                      'D20 ORACLE: ${latestRecord.d20Roll}',
                      style: const TextStyle(
                        color: Color(0xFF6E473B),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tier & Active Buff Indicators (Flex-safe Wrap)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                // Outcome Tier
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEB5A9).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFA78D78), width: 0.8),
                  ),
                  child: Text(
                    latestRecord.outcomeTier,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF291C0E),
                    ),
                  ),
                ),

                // Active Buff Badge
                if (primaryBuff != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6E473B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF6E473B), width: 0.8),
                    ),
                    child: Text(
                      'BUFF: ${primaryBuff.title} (${primaryBuff.remainingSeconds}s)',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6E473B),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F0),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFBEB5A9), width: 0.8),
                    ),
                    child: const Text(
                      'NO ACTIVE BLESSING',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA78D78),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Prophecy Parchment Scroll
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE1D4C2).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA78D78).withValues(alpha: 0.6)),
              ),
              child: Text(
                _isCommuning ? 'Communing with the Cardinal Scribes...' : '“${latestRecord.blessingText}”',
                style: const TextStyle(
                  color: Color(0xFF291C0E),
                  fontSize: 11,
                  height: 1.4,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('oracle_commune_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E473B),
                  foregroundColor: const Color(0xFFE1D4C2),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 1,
                ),
                icon: _isCommuning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE1D4C2)),
                      )
                    : const Icon(Icons.casino_outlined, size: 16),
                label: Text(
                  _isCommuning ? 'DIVINING...' : 'COMMUNE WITH WORLD ARBITER (ROLL D20)',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                onPressed: _isCommuning ? null : () => _communeWithArbiter(userId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
