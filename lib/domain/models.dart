enum GroupRole { owner, admin, treasurer, member }

enum SessionStatus { draft, open, confirmed, completed, settled, cancelled }

enum RsvpStatus { inGame, maybe, out, waitlisted, none }

enum AttendanceStatus { present, absent, notMarked }

enum PaymentStatus { pending, approved, rejected }

enum TransactionType {
  openingBalance,
  deposit,
  sessionCharge,
  refund,
  adjustment,
  reversal,
}

enum ChatMessageType { text, system, announcement, session, finance }

class SportsGroup {
  const SportsGroup({
    required this.id,
    required this.name,
    required this.sport,
    required this.memberCount,
    required this.currency,
    required this.roles,
    required this.emoji,
    required this.balance,
    required this.upiId,
  });
  final String id;
  final String name;
  final String sport;
  final int memberCount;
  final String currency;
  final Set<GroupRole> roles;
  final String emoji;
  final double balance;
  final String upiId;
}

class Member {
  const Member({
    required this.id,
    required this.name,
    required this.initials,
    required this.roles,
    required this.balance,
    this.isYou = false,
  });
  final String id;
  final String name;
  final String initials;
  final Set<GroupRole> roles;
  final double balance;
  final bool isYou;
}

class SportSession {
  const SportSession({
    required this.id,
    required this.groupId,
    required this.title,
    required this.venue,
    required this.startsAt,
    required this.status,
    required this.capacity,
    required this.inCount,
    required this.maybeCount,
    required this.estimatedCost,
    required this.rsvp,
    this.attendanceLocked = false,
    this.expenseTotal = 0,
  });
  final String id;
  final String groupId;
  final String title;
  final String venue;
  final DateTime startsAt;
  final SessionStatus status;
  final int capacity;
  final int inCount;
  final int maybeCount;
  final double estimatedCost;
  final RsvpStatus rsvp;
  final bool attendanceLocked;
  final double expenseTotal;

  SportSession copyWith({
    RsvpStatus? rsvp,
    int? inCount,
    SessionStatus? status,
    bool? attendanceLocked,
  }) => SportSession(
    id: id,
    groupId: groupId,
    title: title,
    venue: venue,
    startsAt: startsAt,
    status: status ?? this.status,
    capacity: capacity,
    inCount: inCount ?? this.inCount,
    maybeCount: maybeCount,
    estimatedCost: estimatedCost,
    rsvp: rsvp ?? this.rsvp,
    attendanceLocked: attendanceLocked ?? this.attendanceLocked,
    expenseTotal: expenseTotal,
  );
}

class LedgerTransaction {
  const LedgerTransaction({
    required this.id,
    required this.groupId,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.type,
  });
  final String id;
  final String groupId;
  final String title;
  final String subtitle;
  final DateTime date;
  final double amount;
  final TransactionType type;
}

class Payment {
  const Payment({
    required this.id,
    required this.groupId,
    required this.memberName,
    required this.amount,
    required this.reference,
    required this.status,
    required this.date,
  });
  final String id;
  final String groupId;
  final String memberName;
  final double amount;
  final String reference;
  final PaymentStatus status;
  final DateTime date;
}

class ActivityItem {
  const ActivityItem({
    required this.icon,
    required this.title,
    required this.detail,
    required this.time,
  });
  final String icon;
  final String title;
  final String detail;
  final String time;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderName,
    required this.senderInitials,
    required this.body,
    required this.sentAt,
    this.isMine = false,
    this.type = ChatMessageType.text,
    this.replyTo,
    this.reactionCount = 0,
    this.reacted = false,
  });

  final String id;
  final String groupId;
  final String senderName;
  final String senderInitials;
  final String body;
  final DateTime sentAt;
  final bool isMine;
  final ChatMessageType type;
  final String? replyTo;
  final int reactionCount;
  final bool reacted;

  ChatMessage copyWith({int? reactionCount, bool? reacted}) => ChatMessage(
    id: id,
    groupId: groupId,
    senderName: senderName,
    senderInitials: senderInitials,
    body: body,
    sentAt: sentAt,
    isMine: isMine,
    type: type,
    replyTo: replyTo,
    reactionCount: reactionCount ?? this.reactionCount,
    reacted: reacted ?? this.reacted,
  );
}
