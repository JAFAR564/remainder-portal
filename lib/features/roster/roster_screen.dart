import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/roster_member.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';
import '../../ui/components/responsive_layout.dart';
import '../../services/chat_service.dart';
import '../../models/chat_room.dart';
import '../../router/app_router.dart';
import '../profile/providers/active_character_provider.dart';
import 'roster_notifier.dart';

class RosterScreen extends ConsumerStatefulWidget {
  const RosterScreen({super.key});

  @override
  ConsumerState<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends ConsumerState<RosterScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  String _selectedFaction = 'ALL';
  String _sortBy = 'NAME_ASC'; // NAME_ASC, NAME_DESC, DATE_JOINED

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  List<RosterMember> _processRoster(List<RosterMember> members) {
    // 1. Filter by Faction
    var filtered = members;
    if (_selectedFaction != 'ALL') {
      filtered = filtered.where((m) => m.faction.toUpperCase() == _selectedFaction).toList();
    }

    // 2. Filter by Search Query (debounced character name or faceclaim name)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) =>
          m.characterName.toLowerCase().contains(_searchQuery) ||
          m.faceclaimName.toLowerCase().contains(_searchQuery)).toList();
    }

    // 3. Sort
    filtered.sort((a, b) {
      if (_sortBy == 'NAME_ASC') {
        return a.characterName.compareTo(b.characterName);
      } else if (_sortBy == 'NAME_DESC') {
        return b.characterName.compareTo(a.characterName);
      } else {
        // Date Joined (reverse chronological - newest first)
        return b.joinedDate.compareTo(a.joinedDate);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final rosterAsync = ref.watch(rosterNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ENNOIA COMMUNITY ROSTER',
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
          child: rosterAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                'Failed to load community roster: $err',
                style: PortalTheme.bodyText.copyWith(color: PortalTheme.alertTerracotta),
              ),
            ),
            data: (members) {
              final processedList = _processRoster(members);

              return Column(
                children: [
                  // Filter and Search Header Panel
                  _buildControlPanel(context),
                  const Divider(height: 1),
                  // List / Grid View
                  Expanded(
                    child: processedList.isEmpty
                        ? Center(
                            child: Text(
                              'No collectors found matching the query.',
                              style: PortalTheme.bodyText,
                            ),
                          )
                        : ResponsiveLayout(
                            mobile: _buildRosterGrid(context, processedList, crossAxisCount: 1),
                            tablet: _buildRosterGrid(context, processedList, crossAxisCount: 2),
                            desktop: _buildRosterGrid(context, processedList, crossAxisCount: 3),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    final factions = ['ALL', 'AETHELGARD ALLIANCE', 'ELYSIUM CHRONO SYNDICATE', 'VANGUARD ORDER'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              // Search Input Field
              Expanded(
                flex: 6,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search character or faceclaim...',
                    prefixIcon: const Icon(Icons.search, color: PortalTheme.infoSlate, size: 20.0),
                    hintStyle: PortalTheme.bodyText.copyWith(color: PortalTheme.warmGrayBodyText),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.8),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: PortalTheme.silverGrayBorder, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: PortalTheme.silverGrayBorder, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              // Sort Dropdown
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    border: Border.all(color: PortalTheme.silverGrayBorder, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _sortBy = val);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'NAME_ASC',
                          child: Text('NAME A-Z', style: PortalTheme.statsText.copyWith(fontSize: 12.0)),
                        ),
                        DropdownMenuItem(
                          value: 'NAME_DESC',
                          child: Text('NAME Z-A', style: PortalTheme.statsText.copyWith(fontSize: 12.0)),
                        ),
                        DropdownMenuItem(
                          value: 'DATE_JOINED',
                          child: Text('NEWEST JOINED', style: PortalTheme.statsText.copyWith(fontSize: 12.0)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          // Faction Horizontal Filters
          SizedBox(
            height: 36.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: factions.length,
              itemBuilder: (context, index) {
                final faction = factions[index];
                final isSelected = _selectedFaction == faction;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      faction == 'ALL' ? 'ALL FACTIONS' : faction,
                      style: PortalTheme.statsText.copyWith(
                        fontSize: 9.0,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : PortalTheme.charcoalNearBlackText,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: PortalTheme.tealNavyAccent,
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFaction = faction);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          // Matchmaker trigger button
          SpringTapWrapper(
            onTap: () => _showPartnerMatchmakerDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: PortalTheme.tealNavyAccent.withValues(alpha: 0.15),
                border: Border.all(color: PortalTheme.tealNavyAccent.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.psychology_alt_outlined, size: 16.0, color: PortalTheme.tealNavyAccent),
                  const SizedBox(width: 8.0),
                  Text(
                    'FIND WRITING PARTNERS (MATCHMAKER)',
                    style: PortalTheme.statsText.copyWith(
                      color: PortalTheme.tealNavyAccent,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
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

  Widget _buildRosterGrid(BuildContext context, List<RosterMember> list, {required int crossAxisCount}) {
    final rooms = ref.watch(chatRoomsProvider).value ?? const [];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        mainAxisExtent: 140.0,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final member = list[index];

        final hash = member.characterName.hashCode.abs();
        final isIdle = hash % 3 == 0;
        final ChatRoom? room = (rooms.isNotEmpty && !isIdle) ? rooms[hash % rooms.length] : null;
        final statusText = room != null ? 'IN: ${room.name.toUpperCase()}' : member.status.toUpperCase();
        final statusColor = room != null ? PortalTheme.tealNavyAccent : PortalTheme.successMoss;

        return SpringTapWrapper(
          onTap: () => _showMemberDetailsDialog(context, member),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                // Faction Accent Stripe
                Container(
                  width: 4.0,
                  height: 140.0,
                  color: _getFactionColor(member.faction),
                ),
                const SizedBox(width: 12.0),
                // Portrait Image
                _buildPortrait(member.faceclaimImgUrl, member.characterName, size: 90.0, circle: false),
                const SizedBox(width: 16.0),
                // Text Attributes
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        member.characterName,
                        style: PortalTheme.sectionHeader.copyWith(fontSize: 16.0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        member.faction.toUpperCase(),
                        style: PortalTheme.statsText.copyWith(
                          fontSize: 9.0,
                          color: PortalTheme.infoSlate,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'FC: ${member.faceclaimName}',
                            style: PortalTheme.smallText.copyWith(
                              color: PortalTheme.warmGrayBodyText,
                              fontSize: 11.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SpringTapWrapper(
                            onTap: room == null
                                ? null
                                : () {
                                    ref.read(selectedChatRoomIdProvider.notifier).selectRoom(room.id);
                                    ref.read(routerProvider).go('/chat');
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.0),
                                border: Border.all(
                                  color: room != null ? PortalTheme.tealNavyAccent.withValues(alpha: 0.3) : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (room != null) ...[
                                    Container(
                                      width: 4.0,
                                      height: 4.0,
                                      decoration: const BoxDecoration(
                                        color: PortalTheme.tealNavyAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                  ],
                                  Text(
                                    statusText,
                                    style: PortalTheme.statsText.copyWith(
                                      fontSize: 8.0,
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMemberDetailsDialog(BuildContext context, RosterMember initialMember) {
    RosterMember activeMember = initialMember;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Dynamically query relations from active roster list
            final allRoster = ref.read(rosterNotifierProvider).value ?? const [];
            final otherMembers = allRoster.where((m) => m.id != activeMember.id).toList();
            RosterMember? ally;
            RosterMember? rival;

            if (otherMembers.isNotEmpty) {
              final sameFaction = otherMembers.where((m) => m.faction == activeMember.faction).toList();
              ally = sameFaction.isNotEmpty ? sameFaction.first : otherMembers.first;

              final diffFaction = otherMembers.where((m) => m.faction != activeMember.faction).toList();
              rival = diffFaction.isNotEmpty ? diffFaction.first : (otherMembers.length > 1 ? otherMembers[1] : null);
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar/Portrait
                      _buildPortrait(activeMember.faceclaimImgUrl, activeMember.characterName, size: 120.0, circle: true),
                      const SizedBox(height: 20.0),
                      Text(
                        activeMember.characterName,
                        style: PortalTheme.displayHeadline.copyWith(fontSize: 22.0),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'FACTION: ${activeMember.faction.toUpperCase()}',
                        style: PortalTheme.statsText.copyWith(
                          color: PortalTheme.infoSlate,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(),
                      const SizedBox(height: 12.0),
                      // Stats grid
                      _buildStatRow('Player', activeMember.playerName),
                      const SizedBox(height: 8.0),
                      _buildStatRow('Faceclaim', activeMember.faceclaimName),
                      const SizedBox(height: 8.0),
                      _buildStatRow('Status', activeMember.status),
                      const SizedBox(height: 8.0),
                      _buildStatRow('Joined', activeMember.joinedDate),
                      
                      const SizedBox(height: 16.0),
                      const Divider(),
                      const SizedBox(height: 12.0),
                      
                      Text(
                        'CHRONICLE BONDS',
                        style: PortalTheme.statsText.copyWith(
                          color: PortalTheme.infoSlate,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      if (ally == null && rival == null)
                        Text('No narrative bonds recorded yet.', style: PortalTheme.smallText)
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (ally != null)
                              Expanded(
                                child: SpringTapWrapper(
                                  onTap: () {
                                    setDialogState(() {
                                      activeMember = ally!;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF66BB6A).withValues(alpha: 0.05),
                                      border: Border.all(color: const Color(0xFF66BB6A).withValues(alpha: 0.2)),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('ALLY', style: TextStyle(color: Color(0xFF66BB6A), fontFamily: 'JetBrains Mono', fontSize: 8.0, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          ally.characterName,
                                          style: PortalTheme.statsText.copyWith(fontSize: 11.0, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          ally.faction.split(' ')[0].toUpperCase(),
                                          style: PortalTheme.statsText.copyWith(fontSize: 8.0, color: PortalTheme.warmGrayBodyText),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (rival != null)
                              Expanded(
                                child: SpringTapWrapper(
                                  onTap: () {
                                    setDialogState(() {
                                      activeMember = rival!;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: PortalTheme.alertTerracotta.withValues(alpha: 0.05),
                                      border: Border.all(color: PortalTheme.alertTerracotta.withValues(alpha: 0.2)),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('RIVAL', style: TextStyle(color: PortalTheme.alertTerracotta, fontFamily: 'JetBrains Mono', fontSize: 8.0, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          rival.characterName,
                                          style: PortalTheme.statsText.copyWith(fontSize: 11.0, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          rival.faction.split(' ')[0].toUpperCase(),
                                          style: PortalTheme.statsText.copyWith(fontSize: 8.0, color: PortalTheme.warmGrayBodyText),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      
                      const SizedBox(height: 24.0),
                      SpringTapWrapper(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: PortalTheme.tealNavyAccent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'DISMISS ARCHIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getFactionColor(String faction) {
    final f = faction.toLowerCase();
    if (f.contains('aethelgard')) return const Color(0xFFFFD700); // Gold
    if (f.contains('elysium')) return const Color(0xFFB388FF); // Violet
    if (f.contains('vanguard')) return const Color(0xFF66BB6A); // Emerald
    return PortalTheme.tealNavyAccent;
  }

  Widget _buildPortrait(String url, String characterName, {double size = 90.0, bool circle = false}) {
    final bool hasImage = url.isNotEmpty && url.startsWith('http');
    
    if (!hasImage) {
      return EnnoiaProfilePlaceholder(label: characterName, size: size, isCircle: circle);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: circle ? BorderRadius.circular(size / 2) : BorderRadius.circular(8.0),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return EnnoiaProfilePlaceholder(label: characterName, size: size, isCircle: circle);
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: PortalTheme.statsText.copyWith(
            fontSize: 10.0,
            color: PortalTheme.warmGrayBodyText,
          ),
        ),
        Text(
          value,
          style: PortalTheme.statsText.copyWith(
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
            color: PortalTheme.charcoalNearBlackText,
          ),
        ),
      ],
    );
  }

  void _showPartnerMatchmakerDialog(BuildContext context) {
    final activeChar = ref.read(activeCharacterProvider).value;
    final roster = ref.read(rosterNotifierProvider).value ?? const [];
    
    // Filter out our own active character
    final candidates = roster.where((m) => m.id != activeChar?.id).toList();
    
    // Compute match score for each candidate
    final matches = candidates.map((m) {
      double score = 65.0; // Base score
      final sameFaction = m.faction == activeChar?.faction;
      
      // Faction dynamics (same faction is good for cohort, different is good for friction!)
      score += sameFaction ? 15.0 : 10.0;
      
      // Activity state
      final hash = m.characterName.hashCode.abs();
      final isWriting = hash % 3 != 0;
      score += isWriting ? 15.0 : 5.0;
      
      // Timezone alignment overlap
      final timezoneOverlap = (hash % 4) + 4; // 4 to 7 hours overlap
      score += (timezoneOverlap > 5) ? 10.0 : 5.0;
      
      return _MatchResult(
        member: m,
        score: score.clamp(50.0, 99.0).toInt(),
        overlapHours: timezoneOverlap,
        matchReason: sameFaction ? 'Same Faction Cohort' : 'Cross-Faction Adversary',
      );
    }).toList();
    
    // Sort by highest match score
    matches.sort((a, b) => b.score.compareTo(a.score));
    final topMatches = matches.take(3).toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400.0),
          child: GlassCard(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NARRATIVE CO-OP MATCHMAKER',
                  style: PortalTheme.statsText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PortalTheme.tealNavyAccent,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Automated recommendation engine matching timezones and faction synergy.',
                  style: PortalTheme.bodyText.copyWith(fontSize: 12.0),
                ),
                const SizedBox(height: 20.0),
                if (topMatches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: Text('No writing candidates registered in database.', style: PortalTheme.smallText)),
                  )
                else
                  ...topMatches.map((match) {
                    final m = match.member;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SpringTapWrapper(
                        onTap: () {
                          Navigator.of(context).pop();
                          _showMemberDetailsDialog(context, m);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: PortalTheme.lightGraySurface.withValues(alpha: 0.15),
                            border: Border.all(color: PortalTheme.silverGrayBorder.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              _buildPortrait(m.faceclaimImgUrl, m.characterName, size: 48.0, circle: true),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          m.characterName,
                                          style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold, fontSize: 13.0),
                                        ),
                                        Text(
                                          '${match.score}% MATCH',
                                          style: PortalTheme.statsText.copyWith(
                                            color: PortalTheme.successMoss,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '${m.faction.toUpperCase()} • ${match.matchReason}',
                                      style: PortalTheme.statsText.copyWith(fontSize: 8.0, color: PortalTheme.infoSlate),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '• Timezone Overlap: ${match.overlapHours} hours',
                                      style: PortalTheme.smallText.copyWith(fontSize: 10.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16.0),
                SpringTapWrapper(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: PortalTheme.tealNavyAccent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Text(
                        'CLOSE MATCHMAKER',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchResult {
  final RosterMember member;
  final int score;
  final int overlapHours;
  final String matchReason;

  const _MatchResult({
    required this.member,
    required this.score,
    required this.overlapHours,
    required this.matchReason,
  });
}

class EnnoiaProfilePlaceholder extends StatelessWidget {
  final String label;
  final double size;
  final bool isCircle;

  const EnnoiaProfilePlaceholder({
    super.key,
    required this.label,
    this.size = 90.0,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: PortalTheme.tealNavyAccent.withValues(alpha: 0.08),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(8.0),
        border: Border.all(color: PortalTheme.silverGrayBorder.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(size * 0.32, size * 0.32),
              painter: _EnnoiaSigilPainter(),
            ),
            if (size > 60) ...[
              const SizedBox(height: 6.0),
              Text(
                label.isNotEmpty ? label[0].toUpperCase() : 'E',
                style: PortalTheme.statsText.copyWith(
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.bold,
                  color: PortalTheme.tealNavyAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EnnoiaSigilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PortalTheme.tealNavyAccent.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw vertical bisecting line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Draw left broken circle
    final rectLeft = Rect.fromLTWH(0, size.height * 0.1, size.width * 0.7, size.height * 0.7);
    canvas.drawArc(rectLeft, 0.5, 5.0, false, paint);

    // Draw right broken circle
    final rectRight = Rect.fromLTWH(size.width * 0.3, size.height * 0.2, size.width * 0.7, size.height * 0.7);
    canvas.drawArc(rectRight, 3.5, 5.0, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

