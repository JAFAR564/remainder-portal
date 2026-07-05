import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';
import '../../services/profile_service.dart';

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

  @override
  void dispose() {
    _characterNameController.dispose();
    _faceclaimController.dispose();
    super.dispose();
  }

  Future<void> _checkFaceclaimAvailability() async {
    final fcName = _faceclaimController.text.trim();
    if (fcName.isEmpty) return;

    setState(() {
      _isCheckingFaceclaim = true;
      _faceclaimStatus = null;
    });

    // Simulate database lookup latency via Sheets/Supabase
    await Future.delayed(const Duration(seconds: 1));

    // Simple deterministic check logic for simulation
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
    profileAsync.whenData((profile) {
      if (profile != null && !_initialized) {
        _characterNameController.text = profile.characterName;
        _faceclaimController.text = profile.faceclaim;
        _selectedFaction = profile.faction;
        _initialized = true;
      }
    });

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
                    // Profile Editor Card
                    GlassCard(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHARACTER METADATA',
                              style: PortalTheme.statsText.copyWith(
                                fontWeight: FontWeight.bold,
                                color: PortalTheme.infoSlate,
                              ),
                            ),
                            const SizedBox(height: 24.0),

                            // Character Name Input
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

                            // Faction Picker
                            Text('AFFILIATED FACTION', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
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
                            const SizedBox(height: 24.0),

                            // Save Button
                             SpringTapWrapper(
                               onTap: () async {
                                 try {
                                   await ref.read(userProfileProvider.notifier).updateProfile(
                                     characterName: _characterNameController.text.trim(),
                                     faction: _selectedFaction,
                                     faceclaim: _faceclaimController.text.trim(),
                                   );
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     const SnackBar(
                                       content: Text('Character profile successfully updated.'),
                                       backgroundColor: PortalTheme.successMoss,
                                     ),
                                   );
                                 } catch (e) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(
                                       content: Text('Failed to save profile: $e'),
                                       backgroundColor: PortalTheme.alertTerracotta,
                                     ),
                                   );
                                 }
                               },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                decoration: BoxDecoration(
                                  color: PortalTheme.tealNavyAccent,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(
                                  child: Text('SAVE CHANGES', style: PortalTheme.ctaButtonText),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ),
                    const SizedBox(height: 24.0),

                    // Faceclaim registry Reservation checker Card
                    GlassCard(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FACECLAIM REGISTRY CHECKER',
                            style: PortalTheme.statsText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: PortalTheme.infoSlate,
                            ),
                          ),
                            const SizedBox(height: 24.0),

                            // Faceclaim Input
                            Text('FACECLAIM NAME', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
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
                              const SizedBox(height: 16.0),
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
