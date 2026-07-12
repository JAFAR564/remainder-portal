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
  final _geminiApiKeyController = TextEditingController();
  final _openRouterApiKeyController = TextEditingController();
  final _groqApiKeyController = TextEditingController();
  final _discordWebhookController = TextEditingController();
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
  String _selectedAiProvider = 'Gemini';

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
    _geminiApiKeyController.dispose();
    _openRouterApiKeyController.dispose();
    _groqApiKeyController.dispose();
    _discordWebhookController.dispose();
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
      _selectedAiProvider = prefs.getString('profile_pref_ai_provider') ?? 'Gemini';
      _geminiApiKeyController.text = prefs.getString('google_gemini_api_key') ?? '';
      _openRouterApiKeyController.text = prefs.getString('openrouter_api_key') ?? '';
      _groqApiKeyController.text = prefs.getString('groq_api_key') ?? '';
      _discordWebhookController.text = prefs.getString('discord_webhook_url') ?? '';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('profile_pref_speed', _writingSpeed);
    await prefs.setString('profile_pref_style', _writingStyle);
    await prefs.setBool('profile_pref_openness', _lookingForScenes);
    await prefs.setString('profile_visibility_faction', _factionVisibility);
    await prefs.setString('profile_visibility_faceclaim', _faceclaimVisibility);
    await prefs.setString('profile_pref_ai_provider', _selectedAiProvider);
    await prefs.setString('google_gemini_api_key', _geminiApiKeyController.text.trim());
    await prefs.setString('openrouter_api_key', _openRouterApiKeyController.text.trim());
    await prefs.setString('groq_api_key', _groqApiKeyController.text.trim());
    await prefs.setString('discord_webhook_url', _discordWebhookController.text.trim());
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

                                // Deterministic character stats based on name hash code for gameplay depth
                                final hash = char.characterName.hashCode;
                                final aura = (hash % 40) + 60; // 60 - 99 range
                                final influence = (hash % 50) + 40; // 40 - 89 range
                                final alignment = (hash % 100); // 0 - 100 range

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: SpringTapWrapper(
                                    onTap: () async {
                                      if (!isActive) {
                                        await ref.read(activeCharacterProvider.notifier).switchCharacter(char.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Active identity switched to ${char.characterName}!'),
                                              backgroundColor: PortalTheme.successMoss,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isActive ? PortalTheme.tealNavyAccent : PortalTheme.silverGrayBorder.withValues(alpha: 0.3),
                                          width: isActive ? 1.5 : 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                        color: isActive ? PortalTheme.tealNavyAccent.withValues(alpha: 0.03) : Colors.transparent,
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Title row
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: PortalTheme.tealNavyAccent.withValues(alpha: 0.1),
                                                radius: 16.0,
                                                child: Text(
                                                  char.characterName[0].toUpperCase(),
                                                  style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold, color: PortalTheme.tealNavyAccent, fontSize: 12.0),
                                                ),
                                              ),
                                              const SizedBox(width: 12.0),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      char.characterName,
                                                      style: PortalTheme.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 13.0),
                                                    ),
                                                    Text(
                                                      char.faction.toUpperCase(),
                                                      style: PortalTheme.statsText.copyWith(fontSize: 8.5, color: PortalTheme.infoSlate),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isActive)
                                                const Icon(Icons.check_circle, color: PortalTheme.tealNavyAccent, size: 20.0),
                                            ],
                                          ),
                                          const SizedBox(height: 12.0),
                                          const Divider(),
                                          const SizedBox(height: 8.0),

                                          // Aura stats
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('AURA & REPUTATION', style: PortalTheme.statsText.copyWith(fontSize: 8.0, color: PortalTheme.warmGrayBodyText)),
                                              Text('$aura / 100', style: PortalTheme.statsText.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          const SizedBox(height: 4.0),
                                          LinearProgressIndicator(
                                            value: aura / 100.0,
                                            backgroundColor: PortalTheme.silverGrayBorder.withValues(alpha: 0.3),
                                            valueColor: const AlwaysStoppedAnimation<Color>(PortalTheme.tealNavyAccent),
                                            minHeight: 3.0,
                                          ),
                                          const SizedBox(height: 10.0),

                                          // Faction Influence stats
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('FACTION INFLUENCE', style: PortalTheme.statsText.copyWith(fontSize: 8.0, color: PortalTheme.warmGrayBodyText)),
                                              Text('$influence%', style: PortalTheme.statsText.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          const SizedBox(height: 4.0),
                                          LinearProgressIndicator(
                                            value: influence / 100.0,
                                            backgroundColor: PortalTheme.silverGrayBorder.withValues(alpha: 0.3),
                                            valueColor: const AlwaysStoppedAnimation<Color>(PortalTheme.infoSlate),
                                            minHeight: 3.0,
                                          ),
                                          const SizedBox(height: 10.0),

                                          // Alignment slider
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('ALIGNMENT BIAS', style: PortalTheme.statsText.copyWith(fontSize: 8.0, color: PortalTheme.warmGrayBodyText)),
                                              Text(
                                                alignment < 45 ? 'AETHELGARD' : (alignment > 55 ? 'ELYSIUM' : 'NEUTRAL'),
                                                style: PortalTheme.statsText.copyWith(fontSize: 9.0, fontWeight: FontWeight.bold, color: PortalTheme.tealNavyAccent),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4.0),
                                          SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              trackHeight: 2.0,
                                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
                                              activeTrackColor: PortalTheme.tealNavyAccent,
                                              inactiveTrackColor: PortalTheme.silverGrayBorder.withValues(alpha: 0.2),
                                              overlayColor: Colors.transparent,
                                            ),
                                            child: Slider(
                                              value: alignment.toDouble(),
                                              min: 0.0,
                                              max: 100.0,
                                              onChanged: null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                          const SizedBox(height: 20.0),
                          const Divider(),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('LOCAL AI PROVIDER', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                              DropdownButton<String>(
                                value: _selectedAiProvider,
                                dropdownColor: PortalTheme.creamBg,
                                style: PortalTheme.statsText.copyWith(fontSize: 10.0, fontWeight: FontWeight.bold, color: PortalTheme.tealNavyAccent),
                                underline: const SizedBox(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedAiProvider = val);
                                },
                                items: ['Gemini', 'OpenRouter', 'Groq'].map((provider) {
                                  return DropdownMenuItem(value: provider, child: Text(provider.toUpperCase()));
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          if (_selectedAiProvider == 'Gemini') ...[
                            Text('GOOGLE GEMINI API KEY', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: _geminiApiKeyController,
                              obscureText: true,
                              style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: PortalTheme.creamBg,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                hintText: 'Enter Gemini API key...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5)),
                              ),
                            ),
                          ] else if (_selectedAiProvider == 'OpenRouter') ...[
                            Text('OPENROUTER API KEY', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: _openRouterApiKeyController,
                              obscureText: true,
                              style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: PortalTheme.creamBg,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                hintText: 'Enter OpenRouter API key...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5)),
                              ),
                            ),
                          ] else if (_selectedAiProvider == 'Groq') ...[
                            Text('GROQ API KEY', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: _groqApiKeyController,
                              obscureText: true,
                              style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: PortalTheme.creamBg,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                hintText: 'Enter Groq API key...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5)),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20.0),
                          const Divider(),
                          const SizedBox(height: 20.0),
                          Text('DISCORD WEBHOOK URL (DEBUGGING ALERTS)', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                          const SizedBox(height: 8.0),
                          TextField(
                            controller: _discordWebhookController,
                            obscureText: true,
                            style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PortalTheme.creamBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              hintText: 'Enter Discord Webhook URL...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5)),
                            ),
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

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Collector profile & settings successfully saved.'),
                                backgroundColor: PortalTheme.successMoss,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
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
