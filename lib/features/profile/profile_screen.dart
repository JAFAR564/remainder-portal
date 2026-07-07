import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';
import '../../services/profile_service.dart';
import '../../services/roster_cache_service.dart';
import 'providers/active_character_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _characterNameController = TextEditingController(text: 'Clara Oswald');
  final _faceclaimController = TextEditingController(text: 'Jenna Coleman');
  String _selectedFaction = 'Chronicles';
  bool _isCheckingFaceclaim = false;
  String? _faceclaimStatus;
  Color? _faceclaimStatusColor;
  bool _initialized = false;

  // Co-op preferences
  String _writingSpeed = 'Daily';
  String _writingStyle = 'Novella';
  bool _lookingForScenes = true;

  // Visibility keys
  String _factionVisibility = 'Public';
  String _faceclaimVisibility = 'Public';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
    });
  }

  @override
  void dispose() {
    _characterNameController.dispose();
    _faceclaimController.dispose();
    super.dispose();
  }

  void _loadPreferences() {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _writingSpeed = prefs.getString('profile_pref_speed') ?? 'Daily';
      _writingStyle = prefs.getString('profile_pref_style') ?? 'Novella';
      _lookingForScenes = prefs.getBool('profile_pref_openness') ?? true;
      _factionVisibility = prefs.getString('profile_visibility_faction') ?? 'Public';
      _faceclaimVisibility = prefs.getString('profile_visibility_faceclaim') ?? 'Public';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('profile_pref_speed', _writingSpeed);
    await prefs.setString('profile_pref_style', _writingStyle);
    await prefs.setBool('profile_pref_openness', _lookingForScenes);
    await prefs.setString('profile_visibility_faction', _factionVisibility);
    await prefs.setString('profile_visibility_faceclaim', _faceclaimVisibility);
  }

  Future<void> _checkFaceclaimAvailability() async {
    final fcName = _faceclaimController.text.trim();
    if (fcName.isEmpty) return;

    setState(() {
      _isCheckingFaceclaim = true;
      _faceclaimStatus = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    final isReserved = fcName.toLowerCase() == 'cillian murphy' ||
        fcName.toLowerCase() == 'cillian';

    setState(() {
      _isCheckingFaceclaim = false;
      if (isReserved) {
        _faceclaimStatus = 'Reserved by Alistair Vance';
        _faceclaimStatusColor = PortalTheme.alertTerracotta;
      } else {
        _faceclaimStatus = 'Available for Reservation';
        _faceclaimStatusColor = PortalTheme.successMoss;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final activeCharAsync = ref.watch(activeCharacterProvider);

    profileAsync.whenData((profile) {
      if (profile != null && !_initialized) {
        _characterNameController.text = profile.characterName;
        _faceclaimController.text = profile.faceclaim;
        _selectedFaction = profile.faction;
        _initialized = true;
      }
    });

    final activeChar = activeCharAsync.value;
    final myCharacters = ref.read(activeCharacterProvider.notifier).getMyCharacters();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COLLECTOR PROFILE SETTINGS',
          style: PortalTheme.statsText.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 13.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PortalTheme.charcoalNearBlackText),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: IridescentOverlay(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: CHARACTER BINDER
                    GlassCard(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHARACTER PORTFOLIO BINDER',
                            style: PortalTheme.statsText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: PortalTheme.infoSlate,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Switch active identities instantly across sectors.',
                            style: PortalTheme.smallText.copyWith(color: PortalTheme.warmGrayBodyText),
                          ),
                          const SizedBox(height: 16.0),
                          if (myCharacters.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('No alternate characters approved yet.', style: PortalTheme.bodyText),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: myCharacters.length,
                              itemBuilder: (context, idx) {
                                final char = myCharacters[idx];
                                final isActive = char.id == activeChar?.id;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isActive ? PortalTheme.tealNavyAccent : PortalTheme.silverGrayBorder.withValues(alpha: 0.3),
                                      width: isActive ? 1.5 : 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: isActive ? PortalTheme.tealNavyAccent.withValues(alpha: 0.05) : Colors.transparent,
                                  ),
                                  child: ListTile(
                                    onTap: () async {
                                      if (!isActive) {
                                        await ref.read(activeCharacterProvider.notifier).switchCharacter(char.id);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Active identity switched to ${char.characterName}!'),
                                              backgroundColor: PortalTheme.successMoss,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: PortalTheme.tealNavyAccent.withValues(alpha: 0.1),
                                      child: Text(
                                        char.characterName[0].toUpperCase(),
                                        style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold, color: PortalTheme.tealNavyAccent),
                                      ),
                                    ),
                                    title: Text(
                                      char.characterName,
                                      style: PortalTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      char.faction.toUpperCase(),
                                      style: PortalTheme.statsText.copyWith(fontSize: 9.0, color: PortalTheme.infoSlate),
                                    ),
                                    trailing: isActive
                                        ? const Icon(Icons.check_circle, color: PortalTheme.tealNavyAccent)
                                        : null,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Section 2: CHARACTER METADATA & TIERED VISIBILITY
                    GlassCard(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IDENTITY & VISIBILITY SETTINGS',
                            style: PortalTheme.statsText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: PortalTheme.infoSlate,
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          // Character Name
                          Text('CHARACTER NAME', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                          const SizedBox(height: 8.0),
                          TextField(
                            controller: _characterNameController,
                            style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PortalTheme.creamBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5)),
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // Faction & Faction Visibility
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('AFFILIATED FACTION', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                              Row(
                                children: [
                                  const Icon(Icons.visibility_outlined, size: 12.0, color: PortalTheme.infoSlate),
                                  const SizedBox(width: 4.0),
                                  DropdownButton<String>(
                                    value: _factionVisibility,
                                    dropdownColor: PortalTheme.creamBg,
                                    underline: const SizedBox(),
                                    style: PortalTheme.statsText.copyWith(fontSize: 9.0, fontWeight: FontWeight.bold, color: PortalTheme.infoSlate),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _factionVisibility = val);
                                    },
                                    items: ['Public', 'Faction-Only', 'Admin-Only'].map((opt) {
                                      return DropdownMenuItem(value: opt, child: Text(opt.toUpperCase()));
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<String>(
                            key: ValueKey(_selectedFaction),
                            initialValue: _selectedFaction,
                            style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                            dropdownColor: PortalTheme.creamBg,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PortalTheme.creamBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                            ),
                            items: ['Chronicles', 'Obsidian Guild', 'Golden Shield', 'Aristocrats'].map((f) {
                              return DropdownMenuItem(value: f, child: Text(f));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedFaction = val);
                            },
                          ),
                          const SizedBox(height: 20.0),

                          // Faceclaim & Faceclaim Visibility
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('FACECLAIM ACTOR', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                              Row(
                                children: [
                                  const Icon(Icons.visibility_outlined, size: 12.0, color: PortalTheme.infoSlate),
                                  const SizedBox(width: 4.0),
                                  DropdownButton<String>(
                                    value: _faceclaimVisibility,
                                    dropdownColor: PortalTheme.creamBg,
                                    underline: const SizedBox(),
                                    style: PortalTheme.statsText.copyWith(fontSize: 9.0, fontWeight: FontWeight.bold, color: PortalTheme.infoSlate),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _faceclaimVisibility = val);
                                    },
                                    items: ['Public', 'Faction-Only', 'Admin-Only'].map((opt) {
                                      return DropdownMenuItem(value: opt, child: Text(opt.toUpperCase()));
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _faceclaimController,
                                  style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: PortalTheme.creamBg,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              SpringTapWrapper(
                                onTap: _isCheckingFaceclaim ? null : _checkFaceclaimAvailability,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                  decoration: BoxDecoration(
                                    color: PortalTheme.lightGraySurface,
                                    border: Border.all(color: PortalTheme.silverGrayBorder),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: _isCheckingFaceclaim
                                      ? const SizedBox(
                                          width: 18.0,
                                          height: 18.0,
                                          child: CircularProgressIndicator(strokeWidth: 2.0),
                                        )
                                      : Text(
                                          'CHECK',
                                          style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          if (_faceclaimStatus != null) ...[
                            const SizedBox(height: 12.0),
                            Text(
                              _faceclaimStatus!,
                              style: PortalTheme.statsText.copyWith(
                                color: _faceclaimStatusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Section 3: CO-OP WRITING PREFERENCES
                    GlassCard(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CO-OP WRITING PREFERENCES',
                            style: PortalTheme.statsText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: PortalTheme.infoSlate,
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          // Writing Speed dropdown
                          Text('WRITING SPEED / PACING', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<String>(
                            initialValue: _writingSpeed,
                            dropdownColor: PortalTheme.creamBg,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PortalTheme.creamBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                            ),
                            items: ['Fast (Live)', 'Daily', 'Weekly'].map((opt) {
                              return DropdownMenuItem(value: opt, child: Text(opt));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _writingSpeed = val);
                            },
                          ),
                          const SizedBox(height: 20.0),

                          // Writing style
                          Text('PROSE STYLE PREFERENCE', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<String>(
                            initialValue: _writingStyle,
                            dropdownColor: PortalTheme.creamBg,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PortalTheme.creamBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                            ),
                            items: ['Novella', 'Paragraphs', 'Speed-Post'].map((opt) {
                              return DropdownMenuItem(value: opt, child: Text(opt));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _writingStyle = val);
                            },
                          ),
                          const SizedBox(height: 20.0),

                          // Looking for scenes toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LOOKING FOR SCENES',
                                    style: PortalTheme.statsText.copyWith(fontSize: 10.0, fontWeight: FontWeight.bold, color: PortalTheme.infoSlate),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Visible to matching co-op writers',
                                    style: PortalTheme.smallText.copyWith(fontSize: 9.0, color: PortalTheme.warmGrayBodyText),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _lookingForScenes,
                                activeThumbColor: PortalTheme.tealNavyAccent,
                                onChanged: (val) {
                                  setState(() => _lookingForScenes = val);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // SAVE ALL CHANGES BUTTON
                    SpringTapWrapper(
                      onTap: () async {
                        try {
                          await ref.read(userProfileProvider.notifier).updateProfile(
                            characterName: _characterNameController.text.trim(),
                            faction: _selectedFaction,
                            faceclaim: _faceclaimController.text.trim(),
                          );
                          await _savePreferences();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Collector profile & settings successfully saved.'),
                                backgroundColor: PortalTheme.successMoss,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save settings: $e'),
                                backgroundColor: PortalTheme.alertTerracotta,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: PortalTheme.tealNavyAccent,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: const [
                            BoxShadow(
                              color: PortalTheme.tealNavyAccent,
                              blurRadius: 10.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('SAVE PROFILE & PREFERENCES', style: PortalTheme.ctaButtonText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
