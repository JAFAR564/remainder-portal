import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/guild_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/crt_overlay.dart';

class GuildScreen extends ConsumerStatefulWidget {
  const GuildScreen({super.key});

  @override
  ConsumerState<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends ConsumerState<GuildScreen> {
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();
  final _lawsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _lawsController.dispose();
    super.dispose();
  }

  void _onCreateGuild() {
    final name = _nameController.text.trim();
    final tag = _tagController.text.trim();
    if (name.isEmpty || tag.isEmpty) return;

    final profile = ref.read(playerProfileProvider);
    if (profile == null) return;

    ref.read(guildProvider.notifier).createGuild(
          name: name,
          tag: tag,
          masterUserId: profile.id,
          masterName: profile.name,
        );

    _nameController.clear();
    _tagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final guild = ref.watch(guildProvider);
    final governance = ref.watch(governanceProvider);
    final profile = ref.watch(playerProfileProvider);
    final sectorGov = governance['sectors_neon_bastion_4'];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text(
          'SOVEREIGN GUILDS & GOVERNANCE',
          style: TextStyle(
            fontSize: 14,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (guild == null) ...[
                  Card(
                    color: const Color(0xFF161520),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFFF8E3C)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FOUND A SOVEREIGN GUILD',
                            style: TextStyle(
                              color: Color(0xFFFF8E3C),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Establish a permanent organization to govern sector nodes, collect trade tariffs, and author regional laws.',
                            style: TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: const InputDecoration(
                              labelText: 'GUILD NAME',
                              labelStyle: TextStyle(color: Colors.white60, fontSize: 10),
                              filled: true,
                              fillColor: Color(0xFF0A0910),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _tagController,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: const InputDecoration(
                              labelText: 'GUILD TAG (e.g. VNG)',
                              labelStyle: TextStyle(color: Colors.white60, fontSize: 10),
                              filled: true,
                              fillColor: Color(0xFF0A0910),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8E3C),
                              minimumSize: const Size.fromHeight(40),
                            ),
                            onPressed: _onCreateGuild,
                            child: const Text('FOUND GUILD (500 CREDITS)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Guild Header Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161520),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF8E3C)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '[${guild.tag}] ${guild.name.toUpperCase()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'TREASURY: ${guild.treasuryBalance} CR',
                                style: const TextStyle(
                                  color: Color(0xFFFFD166),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          guild.announcement,
                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sector Governance Panel
                  if (sectorGov != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0910),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SECTOR GOVERNANCE & TARIFFS',
                            style: TextStyle(
                              color: Color(0xFF00F0FF),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'NODE: ${sectorGov.sectorId} | TARIFF: ${(sectorGov.taxRate * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sectorGov.sectorLawBody,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Guild Roster
                  const Text(
                    'GUILD CITIZENS & RANKS',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 6),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: guild.members.length,
                    itemBuilder: (context, index) {
                      final m = guild.members[index];
                      return Card(
                        color: const Color(0xFF161520),
                        child: ListTile(
                          title: Text(m.userName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: Text('Joined: ${m.joinedDate.toIso8601String().substring(0, 10)}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8E3C).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(m.rank, style: const TextStyle(color: Color(0xFFFF8E3C), fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
