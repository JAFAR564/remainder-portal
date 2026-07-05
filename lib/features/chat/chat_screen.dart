import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';
import '../../services/chat_service.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../models/chat_room.dart';
import '../../models/chat_message.dart';
import '../../models/profile.dart';

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

                  // Default selection
                  if (_selectedRoom == null) {
                    _selectedRoom = rooms.first;
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
        // Sub-header showing channel description
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: PortalTheme.silverGrayBorder, width: 0.5)),
          ),
          child: Row(
            children: [
              Text(
                room.type == 'faction' ? 'RESTRICTED CHAMBER' : 'PUBLIC FORUM',
                style: PortalTheme.statsText.copyWith(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: room.type == 'faction' ? PortalTheme.successMoss : PortalTheme.infoSlate,
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
                          Container(
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
}
