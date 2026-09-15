import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../data/demo_data.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});
  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  var _treasurerView = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final transactions = demoTransactions
        .where((item) => item.groupId == state.selectedGroupId)
        .toList();
    if (!state.canManageFinance) _treasurerView = false;
    return Scaffold(
      appBar: AppBar(
        title: const GroupSwitcher(),
        actions: [
          IconButton(
            onPressed: () => _showLedgerInfo(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            Future<void>.delayed(const Duration(milliseconds: 450)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Finance',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                if (state.canManageFinance)
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.person_outline_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: true,
                        icon: Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 18,
                        ),
                      ),
                    ],
                    selected: {_treasurerView},
                    onSelectionChanged: (value) =>
                        setState(() => _treasurerView = value.first),
                    showSelectedIcon: false,
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              _treasurerView
                  ? 'Treasurer workspace'
                  : 'Your transparent group ledger',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            if (_treasurerView)
              _TreasurerView(state: state)
            else
              _MemberView(state: state, transactions: transactions),
          ],
        ),
      ),
      floatingActionButton: !_treasurerView
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.lime,
              foregroundColor: AppColors.forest,
              onPressed: () =>
                  _showAddFunds(context, state.selectedGroup.upiId),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add funds',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : null,
    );
  }

  void _showLedgerInfo(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, 0, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How your balance works',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 12),
            Text(
              'Your balance is reconstructed from immutable ledger transactions. Deposits add credit; settled session shares deduct it. Corrections create explicit adjustment or reversal entries—history is never silently edited.',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppColors.green),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'PostgreSQL and the NestJS API remain the source of truth.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  void _showAddFunds(BuildContext context, String upiId) {
    final amount = TextEditingController(text: '1000');
    final reference = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          0,
          22,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add funds',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Pay your treasurer, then submit the reference for approval.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.lime,
                    size: 42,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Treasurer UPI',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                        Text(
                          upiId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: upiId));
                      showAppSnackBar(context, 'UPI ID copied');
                    },
                    icon: const Icon(Icons.copy_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount paid',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reference,
              decoration: const InputDecoration(
                labelText: 'UTR / transaction reference',
                hintText: 'e.g. 327890128911',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(amount.text);
                if (value == null ||
                    value <= 0 ||
                    reference.text.trim().isEmpty) {
                  showAppSnackBar(
                    context,
                    'Enter an amount and payment reference',
                  );
                  return;
                }
                ref
                    .read(appControllerProvider.notifier)
                    .submitPayment(value, reference.text.trim());
                Navigator.pop(sheetContext);
                showAppSnackBar(
                  context,
                  'Payment submitted for treasurer approval',
                );
              },
              child: const Center(child: Text('Submit payment')),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberView extends StatelessWidget {
  const _MemberView({required this.state, required this.transactions});
  final AppState state;
  final List<LedgerTransaction> transactions;
  @override
  Widget build(BuildContext context) {
    final balance = state.selectedGroup.balance;
    final payments = state.payments
        .where(
          (item) =>
              item.groupId == state.selectedGroupId &&
              item.memberName == 'Sanket Kurle',
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.forest, Color(0xFF1C5B43)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                balance >= 0 ? 'Available balance' : 'Amount you owe',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                money(balance.abs()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 39,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.lime,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      balance >= 0
                          ? 'You’re covered for the next game'
                          : 'Add funds to clear your balance',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (payments.isNotEmpty) ...[
          const SizedBox(height: 22),
          const SectionTitle('Payment submissions'),
          const SizedBox(height: 10),
          for (final payment in payments)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaymentTile(payment: payment),
            ),
        ],
        const SizedBox(height: 18),
        const SectionTitle('Transaction history', action: 'Export'),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < transactions.length; i++)
                _TransactionTile(
                  transaction: transactions[i],
                  divider: i < transactions.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.divider});
  final LedgerTransaction transaction;
  final bool divider;
  @override
  Widget build(BuildContext context) {
    final positive = transaction.amount >= 0;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          leading: CircleAvatar(
            backgroundColor: (positive ? AppColors.green : AppColors.red)
                .withValues(alpha: .1),
            child: Icon(
              positive ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: positive ? AppColors.green : AppColors.red,
              size: 18,
            ),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Text(
            '${compactDate.format(transaction.date)} · ${transaction.subtitle}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
          trailing: Text(
            money(transaction.amount, signed: true),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: positive ? AppColors.green : AppColors.red,
            ),
          ),
        ),
        if (divider) const Divider(height: 1, indent: 74),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});
  final Payment payment;
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (payment.status) {
      PaymentStatus.pending => ('Pending', AppColors.orange),
      PaymentStatus.approved => ('Approved', AppColors.green),
      PaymentStatus.rejected => ('Rejected', AppColors.red),
    };
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .1),
            child: Icon(Icons.payments_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  money(payment.amount),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  payment.reference,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          StatusPill(label, color: color),
        ],
      ),
    );
  }
}

class _TreasurerView extends ConsumerWidget {
  const _TreasurerView({required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = state.payments
        .where(
          (item) =>
              item.groupId == state.selectedGroupId &&
              item.status == PaymentStatus.pending,
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Group credit',
                value: '₹8,420',
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Amount owed',
                value: '₹2,860',
                color: AppColors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Pending approvals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            StatusPill('${pending.length} pending', color: AppColors.orange),
          ],
        ),
        const SizedBox(height: 10),
        if (pending.isEmpty)
          const AppCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'All payments reviewed ✓',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          )
        else
          for (final payment in pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        AvatarInitials(
                          payment.memberName
                              .split(' ')
                              .map((word) => word[0])
                              .take(2)
                              .join(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment.memberName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${payment.reference} · ${compactDate.format(payment.date)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          money(payment.amount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref
                                .read(appControllerProvider.notifier)
                                .rejectPayment(payment.id),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => ref
                                .read(appControllerProvider.notifier)
                                .approvePayment(payment.id),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 14),
        const SectionTitle('Member balances', action: 'View all'),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < demoMembers.length; i++)
                Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: AvatarInitials(
                        demoMembers[i].initials,
                        index: i,
                      ),
                      title: Text(
                        demoMembers[i].name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        demoMembers[i].balance >= 0
                            ? 'In credit'
                            : 'Owes group',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Text(
                        money(demoMembers[i].balance, signed: true),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: demoMembers[i].balance >= 0
                              ? AppColors.green
                              : AppColors.red,
                        ),
                      ),
                    ),
                    if (i < demoMembers.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    ),
  );
}
