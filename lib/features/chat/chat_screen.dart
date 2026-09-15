import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  ChatMessage? _replyingTo;
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final group = state.selectedGroup;
    final allMessages = ref.watch(selectedGroupMessagesProvider);
    final messages = _query.trim().isEmpty
        ? allMessages
        : allMessages
              .where(
                (message) =>
                    message.body.toLowerCase().contains(_query.toLowerCase()) ||
                    message.senderName.toLowerCase().contains(
                      _query.toLowerCase(),
                    ),
              )
              .toList();
    final sessions = ref.watch(selectedGroupSessionsProvider);
    final upcoming =
        sessions
            .where((session) => session.startsAt.isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3ED),
      appBar: AppBar(
        toolbarHeight: 66,
        leading: IconButton(
          onPressed: () => context.go('/group'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 0,
        title: _searching
            ? TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search this chat',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              )
            : InkWell(
                onTap: () =>
                    _showChatInfo(context, group.name, group.memberCount),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.lime.withValues(alpha: .6),
                      child: Text(group.emoji),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${group.memberCount} members · tap for info',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) _query = '';
            }),
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
          ),
          if (!_searching)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'members') {
                  context.go('/group');
                }
                if (value == 'mute') {
                  showAppSnackBar(context, 'Notifications muted for 8 hours');
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'members',
                  child: Text('Group info & members'),
                ),
                PopupMenuItem(value: 'mute', child: Text('Mute notifications')),
              ],
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (upcoming.isNotEmpty && !_searching)
            _PinnedSessionBar(session: upcoming.first),
          Expanded(
            child: messages.isEmpty
                ? const _NoSearchResults()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return const _DateDivider(label: 'Today');
                      final message = messages[index - 1];
                      return _MessageItem(
                        message: message,
                        onReply: () => _reply(message),
                        onReact: () => ref
                            .read(appControllerProvider.notifier)
                            .toggleMessageReaction(message.id),
                      );
                    },
                  ),
          ),
          if (!_searching)
            _Composer(
              controller: _messageController,
              focusNode: _focusNode,
              replyingTo: _replyingTo,
              onCancelReply: () => setState(() => _replyingTo = null),
              onAttach: () => _showAttachments(context),
              onMention: () {
                _messageController.text = '${_messageController.text}@';
                _messageController.selection = TextSelection.collapsed(
                  offset: _messageController.text.length,
                );
                _focusNode.requestFocus();
              },
              onSend: _send,
            ),
        ],
      ),
    );
  }

  void _reply(ChatMessage message) {
    setState(() => _replyingTo = message);
    _focusNode.requestFocus();
  }

  void _send() {
    final body = _messageController.text;
    if (body.trim().isEmpty) return;
    ref
        .read(appControllerProvider.notifier)
        .sendMessage(
          body,
          replyTo: _replyingTo == null
              ? null
              : '${_replyingTo!.senderName}: ${_replyingTo!.body}',
        );
    _messageController.clear();
    setState(() => _replyingTo = null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachments(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share with the group',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachmentAction(
                  icon: Icons.photo_outlined,
                  label: 'Photo',
                  color: AppColors.blue,
                  onTap: () => Navigator.pop(context),
                ),
                _AttachmentAction(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Document',
                  color: AppColors.orange,
                  onTap: () => Navigator.pop(context),
                ),
                _AttachmentAction(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  color: AppColors.green,
                  onTap: () => Navigator.pop(context),
                ),
                _AttachmentAction(
                  icon: Icons.campaign_outlined,
                  label: 'Poll',
                  color: Colors.purple,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  void _showChatInfo(BuildContext context, String name, int memberCount) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.lime,
                  child: Text('🏏', style: TextStyle(fontSize: 34)),
                ),
                const SizedBox(height: 12),
                Text(name, style: Theme.of(context).textTheme.headlineMedium),
                Text(
                  '$memberCount active members',
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 18),
                const AppCard(
                  color: Color(0xFFEAF4EE),
                  child: Text(
                    'Weekend cricket, good competition, and better banter. Session decisions belong in structured cards so nobody misses the final count.',
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('View members'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: null,
                ),
                const ListTile(
                  leading: Icon(Icons.photo_library_outlined),
                  title: Text('Media, links and documents'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ),
      );
}

class _PinnedSessionBar extends StatelessWidget {
  const _PinnedSessionBar({required this.session});
  final SportSession session;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: InkWell(
      onTap: () => context.go('/sessions/${session.id}'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.push_pin_outlined,
              size: 18,
              color: AppColors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${compactDate.format(session.startsAt)} · ${session.inCount}/${session.capacity} confirmed',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'View',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.green),
          ],
        ),
      ),
    ),
  );
}

class _MessageItem extends StatelessWidget {
  const _MessageItem({
    required this.message,
    required this.onReply,
    required this.onReact,
  });
  final ChatMessage message;
  final VoidCallback onReply;
  final VoidCallback onReact;

  @override
  Widget build(BuildContext context) {
    if (message.type == ChatMessageType.system) {
      return _SystemMessage(message: message);
    }
    if (message.type == ChatMessageType.session) {
      return const _SessionMessageCard();
    }
    if (message.type == ChatMessageType.finance) {
      return _FinanceMessageCard(message: message);
    }
    if (message.type == ChatMessageType.announcement) {
      return _AnnouncementCard(
        message: message,
        onReply: onReply,
        onReact: onReact,
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
        message.isMine ? 54 : 0,
        4,
        message.isMine ? 0 : 42,
        4,
      ),
      child: Row(
        mainAxisAlignment: message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMine) ...[
            AvatarInitials(
              message.senderInitials,
              size: 32,
              index: message.senderName.length,
            ),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageActions(context),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    decoration: BoxDecoration(
                      color: message.isMine
                          ? const Color(0xFFDDF4C1)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(17),
                        topRight: const Radius.circular(17),
                        bottomLeft: Radius.circular(message.isMine ? 17 : 4),
                        bottomRight: Radius.circular(message.isMine ? 4 : 17),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!message.isMine)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              message.senderName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.green,
                              ),
                            ),
                          ),
                        if (message.replyTo != null)
                          _ReplyQuote(text: message.replyTo!),
                        Text(message.body),
                        const SizedBox(height: 3),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                timeOnly.format(message.sentAt),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.muted,
                                ),
                              ),
                              if (message.isMine) ...[
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.done_all_rounded,
                                  size: 13,
                                  color: AppColors.blue,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (message.reactionCount > 0)
                    Positioned(
                      right: 8,
                      bottom: -12,
                      child: InkWell(
                        onTap: onReact,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Text(
                            '👍 ${message.reactionCount}',
                            style: TextStyle(
                              fontSize: 10,
                              color: message.reacted
                                  ? AppColors.green
                                  : AppColors.ink,
                            ),
                          ),
                        ),
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

  void _showMessageActions(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final emoji in ['👍', '❤️', '😂', '🙌', '🏏'])
                  TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      onReact();
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(sheetContext);
                onReply();
              },
            ),
            const ListTile(
              leading: Icon(Icons.copy_rounded),
              title: Text('Copy message'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
    decoration: BoxDecoration(
      color: AppColors.green.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(7),
      border: const Border(left: BorderSide(color: AppColors.green, width: 3)),
    ),
    child: Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 10, color: AppColors.muted),
    ),
  );
}

class _SystemMessage extends StatelessWidget {
  const _SystemMessage({required this.message});
  final ChatMessage message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECE3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message.body,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.message,
    required this.onReply,
    required this.onReact,
  });
  final ChatMessage message;
  final VoidCallback onReply;
  final VoidCallback onReact;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
    child: AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.campaign_rounded,
                size: 18,
                color: AppColors.green,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${message.senderName} · Announcement',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeOnly.format(message.sentAt),
                style: const TextStyle(fontSize: 9, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            message.body,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ActionChip(
                avatar: const Text('👍'),
                label: Text('${message.reactionCount}'),
                onPressed: onReact,
              ),
              const SizedBox(width: 7),
              ActionChip(
                avatar: const Icon(Icons.reply_rounded, size: 16),
                label: const Text('Reply'),
                onPressed: onReply,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SessionMessageCard extends ConsumerWidget {
  const _SessionMessageCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final session = state.sessions.firstWhere((item) => item.id == 's1');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.forest,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏏  SESSION',
                    style: TextStyle(
                      color: AppColors.lime,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${compactDate.format(session.startsAt)} · ${timeOnly.format(session.startsAt)}\n${session.venue}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${session.inCount} in',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.green,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          ' · ${session.maybeCount} maybe · ${session.capacity - session.inCount} spots left',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickRsvp(
                          label: 'In',
                          selected: session.rsvp == RsvpStatus.inGame,
                          onTap: () => ref
                              .read(appControllerProvider.notifier)
                              .setRsvp(session.id, RsvpStatus.inGame),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _QuickRsvp(
                          label: 'Maybe',
                          selected: session.rsvp == RsvpStatus.maybe,
                          onTap: () => ref
                              .read(appControllerProvider.notifier)
                              .setRsvp(session.id, RsvpStatus.maybe),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _QuickRsvp(
                          label: 'Out',
                          selected: session.rsvp == RsvpStatus.out,
                          onTap: () => ref
                              .read(appControllerProvider.notifier)
                              .setRsvp(session.id, RsvpStatus.out),
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
  }
}

class _QuickRsvp extends StatelessWidget {
  const _QuickRsvp({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.green : AppColors.canvas,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: selected ? Colors.white : AppColors.ink,
        ),
      ),
    ),
  );
}

class _FinanceMessageCard extends StatelessWidget {
  const _FinanceMessageCard({required this.message});
  final ChatMessage message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
    child: AppCard(
      color: const Color(0xFFFFF8EB),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.payments_outlined, color: AppColors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment submitted',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  message.body,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/finance'),
            child: const Text('Review'),
          ),
        ],
      ),
    ),
  );
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E9DF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.muted,
        ),
      ),
    ),
  );
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onAttach,
    required this.onMention,
    required this.onSend,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ChatMessage? replyingTo;
  final VoidCallback onCancelReply;
  final VoidCallback onAttach;
  final VoidCallback onMention;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingTo != null)
              Container(
                margin: const EdgeInsets.only(left: 42, right: 4, bottom: 6),
                padding: const EdgeInsets.fromLTRB(10, 7, 4, 7),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(10),
                  border: const Border(
                    left: BorderSide(color: AppColors.green, width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            replyingTo!.senderName,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green,
                            ),
                          ),
                          Text(
                            replyingTo!.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onCancelReply,
                      icon: const Icon(Icons.close_rounded, size: 17),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onAttach,
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.green,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Message the group',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      suffixIcon: IconButton(
                        onPressed: onMention,
                        icon: const Icon(
                          Icons.alternate_email_rounded,
                          size: 19,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                const SizedBox(width: 7),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(46, 46),
                  ),
                  onPressed: onSend,
                  icon: const Icon(Icons.send_rounded, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off_rounded, size: 52, color: AppColors.muted),
        SizedBox(height: 10),
        Text(
          'No matching messages',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
