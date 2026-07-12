import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';
import '../../services/chat_service.dart';
import '../../services/profile_service.dart';
import '../../models/chat_room.dart';
import '../../models/chat_message.dart';
import '../../models/profile.dart';
import '../chronicles/chronicles_screen.dart';
import '../feed/feed_screen.dart';
import 'package:dio/dio.dart';
import '../../services/roster_cache_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  ChatRoom? _selectedRoom;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // Mobile layout state to trace back from room chat to rooms list
  bool _mobileShowChat = false;

  // Scene logger state
  bool _sceneSessionActive = false;
  final List<ChatMessage> _sceneMessages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(chatRoomsProvider);
    final profileAsync = ref.watch(userProfileProvider);

    // Auto-load profile if not cached
    final currentProfile = profileAsync.value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _selectedRoom == null || (!isDesktop && !isTablet && !_mobileShowChat)
                  ? 'FACTION & LOCATION CHANNELS'
                  : _selectedRoom!.name.toUpperCase(),
              style: PortalTheme.statsText.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 13.0,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: (!isDesktop && !isTablet && _mobileShowChat)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: PortalTheme.charcoalNearBlackText),
                    onPressed: () {
                      setState(() {
                        _mobileShowChat = false;
                      });
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back, color: PortalTheme.charcoalNearBlackText),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                  ),
          ),
          body: IridescentOverlay(
            child: SafeArea(
              child: roomsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text('Failed to load chat channels: $err',
                      style: PortalTheme.bodyText.copyWith(color: PortalTheme.alertTerracotta)),
                ),
                data: (rooms) {
                  if (rooms.isEmpty) {
                    return Center(
                      child: Text('No active chat rooms available.', style: PortalTheme.bodyText),
                    );
                  }

                  // Default selection or cross-screen override
                  final overrideRoomId = ref.watch(selectedChatRoomIdProvider);
                  if (overrideRoomId != null) {
                    final matched = rooms.firstWhere((r) => r.id == overrideRoomId, orElse: () => rooms.first);
                    _selectedRoom = matched;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(selectedChatRoomIdProvider.notifier).selectRoom(null);
                    });
                  } else {
                    _selectedRoom ??= rooms.first;
                  }

                  if (isDesktop || isTablet) {
                    // Split screen layout
                    return Row(
                      children: [
                        // Left sidebar: rooms list
                        Container(
                          width: 320.0,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: PortalTheme.silverGrayBorder, width: 1.0),
                            ),
                          ),
                          child: _buildRoomsList(rooms),
                        ),
                        // Right area: active chat
                        Expanded(
                          child: currentProfile == null
                              ? _buildSetupProfilePrompt()
                              : _buildChatArea(_selectedRoom!, currentProfile),
                        ),
                      ],
                    );
                  } else {
                    // Mobile layout: rooms list or active chat
                    if (_mobileShowChat) {
                      return currentProfile == null
                          ? _buildSetupProfilePrompt()
                          : _buildChatArea(_selectedRoom!, currentProfile);
                    } else {
                      return _buildRoomsList(rooms);
                    }
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomsList(List<ChatRoom> rooms) {
    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final isSelected = room.id == _selectedRoom?.id;
        final isFaction = room.type == 'faction';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SpringTapWrapper(
            onTap: () {
              setState(() {
                _selectedRoom = room;
                _mobileShowChat = true;
              });
            },
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              backgroundColor: isSelected
                  ? PortalTheme.tealNavyAccent.withValues(alpha: 0.1)
                  : null,
              hasBorder: isSelected,
              child: Row(
                children: [
                  Icon(
                    isFaction ? Icons.shield_outlined : Icons.explore_outlined,
                    color: isSelected ? PortalTheme.tealNavyAccent : PortalTheme.infoSlate,
                    size: 20.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: PortalTheme.sectionHeader.copyWith(
                            fontSize: 16.0,
                            color: isSelected ? PortalTheme.tealNavyAccent : null,
                          ),
                        ),
                        if (isFaction)
                          Text(
                            'FACTION LOCK: ${room.factionRestriction}',
                            style: PortalTheme.statsText.copyWith(
                              fontSize: 9.0,
                              color: PortalTheme.infoSlate,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetupProfilePrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: GlassCard(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 48.0, color: PortalTheme.infoSlate),
              const SizedBox(height: 16.0),
              Text(
                'PROFILE REQUIRED',
                style: PortalTheme.subsectionHeader.copyWith(fontSize: 20.0),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Please set up your character name and faction in the Profile Settings screen first to enter chat channels.',
                style: PortalTheme.bodyText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(ChatRoom room, Profile currentProfile) {
    final messagesAsync = ref.watch(chatMessagesProvider(room.id));

    // Auto-scroll when data updates
    ref.listen<AsyncValue<List<ChatMessage>>>(chatMessagesProvider(room.id), (prev, next) {
      if (next.hasValue) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        // Sub-header showing channel description and live presence
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: PortalTheme.silverGrayBorder, width: 0.5)),
            color: PortalTheme.lightGraySurface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: room.type == 'faction' ? PortalTheme.successMoss.withValues(alpha: 0.1) : PortalTheme.infoSlate.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: room.type == 'faction' ? PortalTheme.successMoss.withValues(alpha: 0.3) : PortalTheme.infoSlate.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          room.type == 'faction' ? 'RESTRICTED CHAMBER' : 'PUBLIC FORUM',
                          style: PortalTheme.statsText.copyWith(
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                            color: room.type == 'faction' ? PortalTheme.successMoss : PortalTheme.infoSlate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'GRID: S-4',
                        style: PortalTheme.statsText.copyWith(
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                          color: PortalTheme.warmGrayBodyText,
                        ),
                      ),
                    ],
                  ),
                  SpringTapWrapper(
                    onTap: () {
                      if (_sceneSessionActive) {
                        // Gather scene messages from current messages list
                        if (messagesAsync.hasValue) {
                          _sceneMessages.clear();
                          _sceneMessages.addAll(messagesAsync.value!);
                        }
                        _showExportSceneDialog(context, room);
                      } else {
                        setState(() {
                          _sceneSessionActive = true;
                          _sceneMessages.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Narrative Scene session logger active. Write your scene dialogue...'),
                            backgroundColor: PortalTheme.tealNavyAccent,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: _sceneSessionActive ? PortalTheme.alertTerracotta.withValues(alpha: 0.1) : PortalTheme.tealNavyAccent.withValues(alpha: 0.1),
                        border: Border.all(color: _sceneSessionActive ? PortalTheme.alertTerracotta : PortalTheme.tealNavyAccent),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _sceneSessionActive ? Icons.stop_circle_outlined : Icons.play_circle_outlined,
                            size: 11.0,
                            color: _sceneSessionActive ? PortalTheme.alertTerracotta : PortalTheme.tealNavyAccent,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            _sceneSessionActive ? 'FINISH SCENE' : 'START SCENE',
                            style: PortalTheme.statsText.copyWith(
                              fontSize: 9.0,
                              fontWeight: FontWeight.bold,
                              color: _sceneSessionActive ? PortalTheme.alertTerracotta : PortalTheme.tealNavyAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Presence list row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'PRESENT: ',
                      style: PortalTheme.statsText.copyWith(
                        fontSize: 9.0,
                        fontWeight: FontWeight.bold,
                        color: PortalTheme.warmGrayBodyText,
                      ),
                    ),
                    ..._getRoomPresence(room).map((name) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: SpringTapWrapper(
                          onTap: () => _showPresenceProfileDialog(context, name),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              border: Border.all(color: PortalTheme.silverGrayBorder.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 4.0,
                                  height: 4.0,
                                  decoration: const BoxDecoration(color: Color(0xFF66BB6A), shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  name,
                                  style: PortalTheme.bodyText.copyWith(
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.bold,
                                    color: PortalTheme.tealNavyAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Scrollable Messages Area
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Failed to load messages: $err',
                  style: PortalTheme.bodyText.copyWith(color: PortalTheme.alertTerracotta)),
            ),
            data: (messages) {
              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages in this channel. Start the narrative...',
                    style: PortalTheme.bodyText.copyWith(fontStyle: FontStyle.italic),
                  ),
                );
              }

              // Run scroll trigger after load complete
              _scrollToBottom();

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(24.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == currentProfile.id;
                  final senderName = msg.sender?.characterName ?? 'Unknown';
                  final senderFaction = msg.sender?.faction ?? 'Guest';

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          // Sender identity tag
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0),
                            child: Text(
                              '${senderName.toUpperCase()} [${senderFaction.toUpperCase()}]',
                              style: PortalTheme.statsText.copyWith(
                                fontSize: 9.0,
                                color: isMe ? PortalTheme.tealNavyAccent : PortalTheme.infoSlate,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Message Bubble
                          msg.content.startsWith('[DICE ROLL]')
                              ? Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        PortalTheme.tealNavyAccent,
                                        PortalTheme.infoSlate,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: PortalTheme.tealNavyAccent.withValues(alpha: 0.3),
                                        blurRadius: 8.0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.casino, size: 24.0, color: Colors.white),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Text(
                                          msg.content.replaceFirst('[DICE ROLL] ', ''),
                                          style: PortalTheme.bodyText.copyWith(
                                            color: Colors.white,
                                            height: 1.4,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? PortalTheme.tealNavyAccent.withValues(alpha: 0.08)
                                        : PortalTheme.lightGraySurface.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12.0),
                                      topRight: const Radius.circular(12.0),
                                      bottomLeft: isMe ? const Radius.circular(12.0) : Radius.zero,
                                      bottomRight: isMe ? Radius.zero : const Radius.circular(12.0),
                                    ),
                                    border: Border.all(
                                      color: isMe
                                          ? PortalTheme.tealNavyAccent.withValues(alpha: 0.2)
                                          : PortalTheme.silverGrayBorder.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    msg.content,
                                    style: PortalTheme.bodyText.copyWith(
                                      color: PortalTheme.charcoalNearBlackText,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                          // Timestamp
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                            child: Text(
                              _formatTime(msg.createdAt),
                              style: PortalTheme.statsText.copyWith(
                                fontSize: 8.0,
                                color: PortalTheme.warmGrayBodyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Message Composer Input Box
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              SpringTapWrapper(
                onTap: () => _triggerDiceRoll(room.id),
                child: Container(
                  height: 48.0,
                  width: 48.0,
                  margin: const EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                    color: PortalTheme.lightGraySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: PortalTheme.silverGrayBorder),
                  ),
                  child: const Icon(Icons.casino, color: PortalTheme.tealNavyAccent, size: 20.0),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                  decoration: InputDecoration(
                    hintText: 'Speak in-character...',
                    hintStyle: PortalTheme.bodyText.copyWith(color: PortalTheme.warmGrayBodyText),
                    filled: true,
                    fillColor: PortalTheme.creamBg.withValues(alpha: 0.6),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(color: PortalTheme.silverGrayBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(room.id),
                ),
              ),
              const SizedBox(width: 12.0),
              SpringTapWrapper(
                onTap: () => _handleSend(room.id),
                child: Container(
                  height: 48.0,
                  width: 48.0,
                  decoration: const BoxDecoration(
                    color: PortalTheme.tealNavyAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20.0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSend(String roomId) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatMessagesProvider(roomId).notifier).send(text);
    _messageController.clear();
    _scrollToBottom();
  }

  List<String> _getRoomPresence(ChatRoom room) {
    if (room.type == 'faction') {
      return ['Jacob Vance', 'Lorna Stern'];
    }
    return ['Clara Oswald', 'Alistair Vance', 'Lorna Stern'];
  }

  void _showPresenceProfileDialog(BuildContext context, String name) {
    final prefs = ref.read(sharedPreferencesProvider);
    final speed = prefs.getString('profile_pref_speed') ?? 'Daily';
    final style = prefs.getString('profile_pref_style') ?? 'Paragraphs';

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
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: PortalTheme.tealNavyAccent.withValues(alpha: 0.1),
                      radius: 20.0,
                      child: Text(
                        name[0].toUpperCase(),
                        style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0, color: PortalTheme.tealNavyAccent),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: PortalTheme.subsectionHeader.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'CO-OP ACTIVE WRITER',
                          style: PortalTheme.statsText.copyWith(fontSize: 9.0, color: PortalTheme.infoSlate),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 16.0),
                Text(
                  'CO-OP WRITING PREFERENCES',
                  style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText),
                ),
                const SizedBox(height: 8.0),
                Text('WRITING SPEED: $speed', style: PortalTheme.bodyText.copyWith(fontSize: 12.0)),
                const SizedBox(height: 4.0),
                Text('PROSE STYLE: $style', style: PortalTheme.bodyText.copyWith(fontSize: 12.0)),
                const SizedBox(height: 20.0),
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
                        'CLOSE PROFILE VIEW',
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

  void _triggerDiceRoll(String roomId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHOOSE ACTION SKILL CHECK',
              style: PortalTheme.statsText.copyWith(
                fontWeight: FontWeight.bold,
                color: PortalTheme.tealNavyAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            ...['Intellect check', 'Dexterity check', 'Willpower check', 'Pure d20 roll'].map((skill) {
              return ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  final roll = (DateTime.now().millisecond % 20) + 1;
                  final mod = skill.contains('d20') ? 0 : 3;
                  final total = roll + mod;
                  final text = '[DICE ROLL] performed a $skill: rolled $roll ${mod > 0 ? "(+$mod modifier)" : ""} = $total.';
                  ref.read(chatMessagesProvider(roomId).notifier).send(text);
                },
                leading: const Icon(Icons.casino, color: PortalTheme.tealNavyAccent),
                title: Text(skill, style: PortalTheme.bodyText.copyWith(fontWeight: FontWeight.bold)),
              );
            }),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  void _showExportSceneDialog(BuildContext context, ChatRoom room) {
    final titleController = TextEditingController(text: 'Scene: ${room.name} Convergence');
    final descController = TextEditingController(text: 'A narrative event captured from active chat logs.');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450.0),
          child: GlassCard(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPORTER: SCENE SESSION ACTIVE',
                  style: PortalTheme.statsText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PortalTheme.tealNavyAccent,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Review log compile details before publishing to Chronicles.',
                  style: PortalTheme.smallText.copyWith(color: PortalTheme.warmGrayBodyText),
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 16.0),
                Text('SCENE TITLE', style: PortalTheme.statsText.copyWith(fontSize: 9.0, color: PortalTheme.warmGrayBodyText)),
                const SizedBox(height: 6.0),
                TextField(
                  controller: titleController,
                  style: PortalTheme.bodyText,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: PortalTheme.creamBg,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text('DESCRIPTION', style: PortalTheme.statsText.copyWith(fontSize: 9.0, color: PortalTheme.warmGrayBodyText)),
                const SizedBox(height: 6.0),
                TextField(
                  controller: descController,
                  style: PortalTheme.bodyText,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: PortalTheme.creamBg,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: SpringTapWrapper(
                        onTap: () {
                          setState(() {
                            _sceneSessionActive = false;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: PortalTheme.silverGrayBorder),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'CANCEL',
                              style: TextStyle(fontFamily: 'Jost', fontSize: 11.0, fontWeight: FontWeight.bold, color: PortalTheme.charcoalNearBlackText),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: SpringTapWrapper(
                        onTap: () {
                          final List<Map<String, String>> logs = [];
                          for (final msg in _sceneMessages) {
                            logs.add({
                              'author': msg.sender?.characterName ?? 'Unknown',
                              'msg': msg.content,
                            });
                          }

                          final dateStr = 'ERA 3 • YEAR ${150 + ref.read(chroniclesProvider).length}';
                          final node = ChronicleNode(
                            dateStamp: dateStr,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            faction: room.name,
                            characterRelations: [
                              if (logs.isNotEmpty) '${logs.first["author"]} ↔ ${logs.last["author"]} (Convergence Participants)'
                            ],
                            expandedSummary: 'Exported from live chat logs. The active coordinate array registers sync compliance across sectors.',
                            factionShifts: const {
                              'Aethelgard Alliance': 5.0,
                              'Elysium Syndicate': 5.0,
                              'Vanguard Order': 5.0,
                            },
                            transcriptLogs: logs,
                          );

                          ref.read(chroniclesProvider.notifier).addNode(node);

                          _triggerAIFandomReaction(node.title, node.faction);

                          setState(() {
                            _sceneSessionActive = false;
                          });

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Scene successfully exported and published to Chronicles Timeline!'),
                              backgroundColor: PortalTheme.successMoss,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: PortalTheme.tealNavyAccent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'PUBLISH TO TIMELINE',
                              style: TextStyle(fontFamily: 'Jost', fontSize: 11.0, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _triggerAIFandomReaction(String title, String faction) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final provider = prefs.getString('profile_pref_ai_provider') ?? 'Gemini';

    String reactionText = 'New timeline convergence published: "$title" registered across $faction sectors. Core stability holding.';
    final promptText = 'You are a citizen living in the universe of the Remainder Portal. Write a single, highly in-character social reaction post (under 180 characters) reacting to this newly published historical chronicle: Title: "$title", Faction: "$faction". Use sci-fi terminology (like timeline shifts, core sync, sector metrics). Respond with ONLY the raw message text.';

    try {
      if (provider == 'Gemini') {
        String apiKey = prefs.getString('google_gemini_api_key') ?? '';
        if (apiKey.isEmpty) {
          apiKey = const String.fromEnvironment('GEMINI_API_KEY');
        }
        if (apiKey.isNotEmpty) {
          final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
          final payload = {
            'contents': [
              {
                'parts': [
                  {'text': promptText}
                ]
              }
            ]
          };
          final response = await Dio().post(url, data: payload);
          if (response.statusCode == 200) {
            final candidates = response.data['candidates'] as List;
            if (candidates.isNotEmpty) {
              reactionText = (candidates[0]['content']['parts'][0]['text'] as String).trim();
            }
          }
        }
      } else if (provider == 'OpenRouter') {
        final apiKey = prefs.getString('openrouter_api_key') ?? '';
        if (apiKey.isNotEmpty) {
          const url = 'https://openrouter.ai/api/v1/chat/completions';
          final payload = {
            'model': 'meta-llama/llama-3-8b-instruct:free',
            'messages': [
              {'role': 'user', 'content': promptText}
            ]
          };
          final response = await Dio().post(
            url,
            data: payload,
            options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
          );
          if (response.statusCode == 200) {
            final choices = response.data['choices'] as List;
            if (choices.isNotEmpty) {
              reactionText = (choices[0]['message']['content'] as String).trim();
            }
          }
        }
      } else if (provider == 'Groq') {
        final apiKey = prefs.getString('groq_api_key') ?? '';
        if (apiKey.isNotEmpty) {
          const url = 'https://api.groq.com/openai/v1/chat/completions';
          final payload = {
            'model': 'llama3-8b-8192',
            'messages': [
              {'role': 'user', 'content': promptText}
            ]
          };
          final response = await Dio().post(
            url,
            data: payload,
            options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
          );
          if (response.statusCode == 200) {
            final choices = response.data['choices'] as List;
            if (choices.isNotEmpty) {
              reactionText = (choices[0]['message']['content'] as String).trim();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Fandom reaction bot query failed, falling back: $e');
    }

    ref.read(feedProvider.notifier).addPost(
      reactionText,
      'Sanctuary News Network',
      'Neutral Sector',
      'https://images.unsplash.com/photo-1546074177-3de1c64dfc82?auto=format&fit=crop&q=80&w=200',
    );
  }
}
