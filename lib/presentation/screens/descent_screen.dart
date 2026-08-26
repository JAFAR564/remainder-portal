import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder_portal/presentation/providers/game_provider.dart';
import 'package:remainder_portal/presentation/widgets/crt_overlay.dart';
import 'package:remainder_portal/presentation/screens/terminal_screen.dart';

class DescentScreen extends ConsumerWidget {
  const DescentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final repo = ref.watch(okfRepositoryProvider);
    
    // Retrieve all parsed sector concepts
    final sectors = repo.getAllConcepts().where((c) => c.type == 'Spatial_Sector').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        title: const Text(
          'SECTOR MATRIX SELECTOR',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFF6E473B),
            fontFamily: 'serif',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFF6E473B).withValues(alpha: 0.15),
        centerTitle: true,
      ),
      body: CrtOverlay(
        child: Container(
          color: const Color(0xFFE1D4C2),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player HUD
              if (profile != null) ...[
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: const BorderSide(color: Color(0xFFA78D78), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OPERATOR: ${profile.name.toUpperCase()}',
                              style: const TextStyle(color: Color(0xFF291C0E), fontWeight: FontWeight.bold, fontFamily: 'serif'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ORIGIN: ${profile.origin.toUpperCase()}',
                              style: const TextStyle(color: Color(0xFF6E473B), fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'STATS',
                              style: TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildStatIcon(Icons.bolt, profile.stats.computePower.toString(), const Color(0xFF6E473B)),
                                const SizedBox(width: 12),
                                _buildStatIcon(Icons.shield, profile.stats.shieldIntegrity.toString(), const Color(0xFFA78D78)),
                                const SizedBox(width: 12),
                                _buildStatIcon(Icons.battery_charging_full, profile.stats.energyReserve.toString(), const Color(0xFF291C0E)),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
  
              const Text(
                'AVAILABLE SPATIAL SECTORS',
                style: TextStyle(
                  color: Color(0xFF6E473B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
  
              // Sector list
              Expanded(
                child: sectors.isEmpty
                    ? Center(
                        child: Text(
                          'NO SECTORS DISCOVERED YET.\nINITIALIZE REPOSITORY INGEST.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: const Color(0xFF291C0E).withValues(alpha: 0.6), letterSpacing: 1.0, fontFamily: 'monospace'),
                        ),
                      )
                    : ListView.builder(
                        itemCount: sectors.length,
                        itemBuilder: (context, index) {
                          final sector = sectors[index];
                          final stability = double.tryParse(
                                  sector.attributes['environmental_stability']?.toString() ?? '1.0') ??
                              1.0;
                          final stabilityPercentage = (stability * 100).toInt();
  
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InkWell(
                              onTap: () {
                                // Select sector and proceed
                                ref.read(playerProfileProvider.notifier).updateSector(sector.uid ?? '');
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => TerminalScreen(sectorNode: sector),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: const BorderSide(
                                    color: Color(0xFFA78D78),
                                    width: 1.2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            sector.title?.toUpperCase() ?? 'UNKNOWN SECTOR',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF291C0E),
                                              fontFamily: 'serif',
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFF6E473B),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        sector.description ?? 'No description coordinates provided.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: const Color(0xFF291C0E).withValues(alpha: 0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'STABILITY: $stabilityPercentage%',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: stability > 0.8 ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          Text(
                                            'GENRES: ${List<String>.from(sector.attributes['genre_dependencies'] ?? []).join(', ').toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: const Color(0xFF291C0E).withValues(alpha: 0.6),
                                              letterSpacing: 1.0,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: Color(0xFF291C0E), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
