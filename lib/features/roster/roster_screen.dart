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
        ],
      ),
    );
  }

  Widget _buildRosterGrid(BuildContext context, List<RosterMember> list, {required int crossAxisCount}) {
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
        return SpringTapWrapper(
          onTap: () => _showMemberDetailsDialog(context, member),
          child: GlassCard(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Portrait Image
                _buildPortrait(member.faceclaimImgUrl, member.characterName, size: 90.0, circle: false),
                const SizedBox(width: 16.0),
                // Text Attributes
                Expanded(
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: PortalTheme.successMoss.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              member.status.toUpperCase(),
                              style: PortalTheme.statsText.copyWith(
                                fontSize: 8.0,
                                color: PortalTheme.successMoss,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMemberDetailsDialog(BuildContext context, RosterMember member) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar/Portrait
                _buildPortrait(member.faceclaimImgUrl, member.characterName, size: 140.0, circle: true),
                const SizedBox(height: 24.0),
                Text(
                  member.characterName,
                  style: PortalTheme.displayHeadline.copyWith(fontSize: 24.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'FACTION: ${member.faction.toUpperCase()}',
                  style: PortalTheme.statsText.copyWith(
                    color: PortalTheme.infoSlate,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 16.0),
                // Stats grid
                _buildStatRow('Player', member.playerName),
                const SizedBox(height: 8.0),
                _buildStatRow('Faceclaim', member.faceclaimName),
                const SizedBox(height: 8.0),
                _buildStatRow('Status', member.status),
                const SizedBox(height: 8.0),
                _buildStatRow('Joined', member.joinedDate),
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
      ),
    );
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

