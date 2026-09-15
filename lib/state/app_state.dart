import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_data.dart';
import '../domain/models.dart';

class AppState {
  const AppState({
    required this.selectedGroupId,
    required this.sessions,
    required this.payments,
    required this.messages,
    this.notificationCount = 3,
  });
  final String selectedGroupId;
  final List<SportSession> sessions;
  final List<Payment> payments;
  final List<ChatMessage> messages;
  final int notificationCount;

  SportsGroup get selectedGroup =>
      demoGroups.firstWhere((group) => group.id == selectedGroupId);
  bool get canManageSessions =>
      selectedGroup.roles.contains(GroupRole.owner) ||
      selectedGroup.roles.contains(GroupRole.admin);
  bool get canManageFinance =>
      selectedGroup.roles.contains(GroupRole.owner) ||
      selectedGroup.roles.contains(GroupRole.treasurer);

  AppState copyWith({
    String? selectedGroupId,
    List<SportSession>? sessions,
    List<Payment>? payments,
    List<ChatMessage>? messages,
    int? notificationCount,
  }) => AppState(
    selectedGroupId: selectedGroupId ?? this.selectedGroupId,
    sessions: sessions ?? this.sessions,
    payments: payments ?? this.payments,
    messages: messages ?? this.messages,
    notificationCount: notificationCount ?? this.notificationCount,
  );
}

class AppController extends Notifier<AppState> {
  @override
  AppState build() => AppState(
    selectedGroupId: demoGroups.first.id,
    sessions: demoSessions,
    payments: demoPayments,
    messages: demoMessages,
  );

  void selectGroup(String id) => state = state.copyWith(selectedGroupId: id);

  void setRsvp(String sessionId, RsvpStatus status) {
    state = state.copyWith(
      sessions: [
        for (final session in state.sessions)
          if (session.id == sessionId)
            session.copyWith(
              rsvp: status,
              inCount:
                  session.inCount +
                  (session.rsvp != RsvpStatus.inGame &&
                          status == RsvpStatus.inGame
                      ? 1
                      : 0) -
                  (session.rsvp == RsvpStatus.inGame &&
                          status != RsvpStatus.inGame
                      ? 1
                      : 0),
            )
          else
            session,
      ],
    );
  }

  void addSession(SportSession session) =>
      state = state.copyWith(sessions: [session, ...state.sessions]);

  void approvePayment(String id) {
    state = state.copyWith(
      payments: [
        for (final payment in state.payments)
          if (payment.id == id)
            Payment(
              id: payment.id,
              groupId: payment.groupId,
              memberName: payment.memberName,
              amount: payment.amount,
              reference: payment.reference,
              status: PaymentStatus.approved,
              date: payment.date,
            )
          else
            payment,
      ],
    );
  }

  void rejectPayment(String id) {
    state = state.copyWith(
      payments: [
        for (final payment in state.payments)
          if (payment.id == id)
            Payment(
              id: payment.id,
              groupId: payment.groupId,
              memberName: payment.memberName,
              amount: payment.amount,
              reference: payment.reference,
              status: PaymentStatus.rejected,
              date: payment.date,
            )
          else
            payment,
      ],
    );
  }

  void submitPayment(double amount, String reference) {
    state = state.copyWith(
      payments: [
        Payment(
          id: 'p${DateTime.now().microsecondsSinceEpoch}',
          groupId: state.selectedGroupId,
          memberName: 'Sanket Kurle',
          amount: amount,
          reference: reference,
          status: PaymentStatus.pending,
          date: DateTime.now(),
        ),
        ...state.payments,
      ],
    );
  }

  void clearNotifications() => state = state.copyWith(notificationCount: 0);

  void sendMessage(String body, {String? replyTo}) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: 'm${DateTime.now().microsecondsSinceEpoch}',
          groupId: state.selectedGroupId,
          senderName: 'Sanket Kurle',
          senderInitials: 'SK',
          body: trimmed,
          sentAt: DateTime.now(),
          isMine: true,
          replyTo: replyTo,
        ),
      ],
    );
  }

  void toggleMessageReaction(String id) {
    state = state.copyWith(
      messages: [
        for (final message in state.messages)
          if (message.id == id)
            message.copyWith(
              reacted: !message.reacted,
              reactionCount: message.reactionCount + (message.reacted ? -1 : 1),
            )
          else
            message,
      ],
    );
  }
}

final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

final selectedGroupSessionsProvider = Provider<List<SportSession>>((ref) {
  final state = ref.watch(appControllerProvider);
  return state.sessions
      .where((session) => session.groupId == state.selectedGroupId)
      .toList()
    ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
});

final selectedGroupMessagesProvider = Provider<List<ChatMessage>>((ref) {
  final state = ref.watch(appControllerProvider);
  return state.messages
      .where((message) => message.groupId == state.selectedGroupId)
      .toList()
    ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
});
