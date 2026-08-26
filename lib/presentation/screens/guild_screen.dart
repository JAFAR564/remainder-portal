import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/guild_provider.dart';
import '../providers/game_provider.dart';

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
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        title: const Text(
          'SOVEREIGN GUILDS & GOVERNANCE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF6E473B),
            fontFamily: 'serif',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFF6E473B).withValues(alpha: 0.15),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (guild == null) ...[
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFA78D78), width: 1.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FOUND A SOVEREIGN GUILD',
                          style: TextStyle(
                            color: Color(0xFF6E473B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Establish a permanent organization to govern sanctuary nodes, collect trade tariffs, and author regional laws.',
                          style: TextStyle(color: Color(0xFF291C0E), fontSize: 11),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'GUILD NAME',
                            labelStyle: const TextStyle(color: Color(0xFF6E473B), fontSize: 10),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFA78D78)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF6E473B), width: 1.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _tagController,
                          style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'GUILD TAG (e.g. VNG)',
                            labelStyle: const TextStyle(color: Color(0xFF6E473B), fontSize: 10),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFA78D78)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF6E473B), width: 1.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E473B),
                            foregroundColor: const Color(0xFFE1D4C2),
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _onCreateGuild,
                          child: const Text('FOUND GUILD (500 ESSENCE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA78D78), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '[${guild.tag}] ${guild.name.toUpperCase()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6E473B),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF6E473B)),
                            ),
                            child: Text(
                              'TREASURY: ${guild.treasuryBalance} CR',
                              style: const TextStyle(
                                color: Color(0xFF6E473B),
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
                        style: const TextStyle(color: Color(0xFF291C0E), fontSize: 11, fontStyle: FontStyle.italic),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SANCTUARY GOVERNANCE & TARIFFS',
                          style: TextStyle(
                            color: Color(0xFF6E473B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'NODE: ${sectorGov.sectorId} | TARIFF: ${(sectorGov.taxRate * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(color: Color(0xFF291C0E), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sectorGov.sectorLawBody,
                          style: const TextStyle(color: Color(0xFF291C0E), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Guild Roster
                const Text(
                  'GUILD CITIZENS & RANKS',
                  style: TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 6),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: guild.members.length,
                  itemBuilder: (context, index) {
                    final m = guild.members[index];
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFA78D78), width: 1.2),
                      ),
                      child: ListTile(
                        title: Text(m.userName, style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                        subtitle: Text('Joined: ${m.joinedDate.toIso8601String().substring(0, 10)}', style: const TextStyle(color: Color(0xFF6E473B), fontSize: 10)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6E473B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF6E473B)),
                          ),
                          child: Text(m.rank, style: const TextStyle(color: Color(0xFF6E473B), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
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
    );
  }
}
