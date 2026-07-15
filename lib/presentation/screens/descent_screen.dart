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
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text(
          'SECTOR MATRIX SELECTOR',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF161520),
        elevation: 0,
        centerTitle: true,
      ),
      body: CrtOverlay(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF161520), Color(0xFF0F0E17)],
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player HUD
              if (profile != null) ...[
                Card(
                  color: const Color(0xFF161520),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: const BorderSide(color: Color(0xFFFF8E3C), width: 1.0),
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
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ORIGIN: ${profile.origin.toUpperCase()}',
                              style: const TextStyle(color: Color(0xFFFF8E3C), fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'STATS',
                              style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildStatIcon(Icons.bolt, profile.stats.computePower.toString(), const Color(0xFFE53170)),
                                const SizedBox(width: 12),
                                _buildStatIcon(Icons.shield, profile.stats.shieldIntegrity.toString(), const Color(0xFF38B000)),
                                const SizedBox(width: 12),
                                _buildStatIcon(Icons.battery_charging_full, profile.stats.energyReserve.toString(), const Color(0xFF00B4D8)),
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
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
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
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), letterSpacing: 1.0),
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
                                color: const Color(0xFF161520),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1.0,
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
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFFFF8E3C),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        sector.description ?? 'No description coordinates provided.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withValues(alpha: 0.6),
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
                                              color: stability > 0.8 ? const Color(0xFF38B000) : const Color(0xFFFF8E3C),
                                            ),
                                          ),
                                          Text(
                                            'GENRES: ${List<String>.from(sector.attributes['genre_dependencies'] ?? []).join(', ').toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white.withValues(alpha: 0.4),
                                              letterSpacing: 1.0,
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
