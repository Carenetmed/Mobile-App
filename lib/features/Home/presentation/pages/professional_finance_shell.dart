import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Home/data/repositories/financial_repository.dart';
import 'package:app_t/features/Home/domain/entities/financial_entities.dart';
import 'package:app_t/features/Home/domain/services/money_formatter.dart';
import 'package:app_t/features/Home/presentation/state/professional_finance_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ProfessionalFinanceShellPage extends StatefulWidget {
  const ProfessionalFinanceShellPage({super.key, this.controller});

  final ProfessionalFinanceController? controller;

  @override
  State<ProfessionalFinanceShellPage> createState() =>
      _ProfessionalFinanceShellPageState();
}

class _ProfessionalFinanceShellPageState
    extends State<ProfessionalFinanceShellPage> {
  late final ProfessionalFinanceController _controller;
  late final bool _ownsController;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  String? _selectedBankCode;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        ProfessionalFinanceController(repository: sl<FinancialRepository>());
    _controller.addListener(_changed);
    _controller.load();
    _controller.loadBanks();
  }

  void _changed() {
    if (!mounted) {
      return;
    }
    if (_priceController.text.isEmpty &&
        _controller.consultationPrice != null) {
      _priceController.text = (_controller.consultationPrice!.amountMinor / 100)
          .toStringAsFixed(2);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    if (_ownsController) {
      _controller.dispose();
    }
    _priceController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarenetColors.white,
      appBar: AppBar(
        title: const Text('Payments & payouts'),
        backgroundColor: CarenetColors.white,
        foregroundColor: CarenetColors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh finances',
            onPressed: _controller.isLoading ? null : _controller.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child:
            _controller.isLoading && _controller.summary == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _controller.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
                    children: [
                      const Text(
                        'Your consultation finances',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'CareNet keeps collection, commission, holds, and '
                        'payout state authoritative on the server.',
                        style: TextStyle(color: CarenetColors.neutral600),
                      ),
                      if (_controller.errorMessage != null)
                        _Notice(
                          message: _controller.errorMessage!,
                          isError: true,
                        ),
                      if (_controller.actionMessage != null)
                        _Notice(message: _controller.actionMessage!),
                      const SizedBox(height: 18),
                      _priceSection(),
                      const SizedBox(height: 16),
                      _balanceSection(),
                      const SizedBox(height: 16),
                      _bankSection(),
                      const SizedBox(height: 16),
                      _activitySection(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _priceSection() {
    final amount = _priceMinor;
    final fee = amount == null ? null : calculatePlatformFeeMinor(amount);
    return _Section(
      title: 'Consultation price',
      icon: Icons.price_change_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set one patient-facing price in Nigerian naira.',
            style: TextStyle(color: CarenetColors.neutral600),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const Key('consultation-price-input'),
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d{0,7}(\.\d{0,2})?'),
              ),
            ],
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Price (NGN)',
              hintText: 'For example, 15000',
              border: OutlineInputBorder(),
              prefixText: 'NGN ',
            ),
          ),
          if (amount != null) ...[
            const SizedBox(height: 12),
            _MetricRow(label: 'Patient pays', value: formatNgnMinor(amount)),
            _MetricRow(
              label: 'CareNet commission (15%)',
              value: formatNgnMinor(fee!),
            ),
            _MetricRow(
              label: 'Estimated professional net',
              value: formatNgnMinor(amount - fee),
              strong: true,
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('save-consultation-price'),
            onPressed:
                amount == null || _controller.isSavingPrice
                    ? null
                    : () => _controller.savePrice(amount),
            icon:
                _controller.isSavingPrice
                    ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save_outlined),
            label: Text(_controller.isSavingPrice ? 'Saving...' : 'Save price'),
          ),
        ],
      ),
    );
  }

  int? get _priceMinor {
    final minor = parseNgnMajorToMinor(_priceController.text);
    if (minor == null) {
      return null;
    }
    return minor >= 10000 && minor <= 100000000 ? minor : null;
  }

  Widget _balanceSection() {
    final summary = _controller.summary;
    if (summary == null) {
      return const _Section(
        title: 'Earnings',
        icon: Icons.account_balance_wallet_outlined,
        child: Text('Earnings are unavailable. Pull to refresh.'),
      );
    }
    return _Section(
      title: 'Earnings',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: [
          _MetricRow(label: 'Held', value: formatNgnMinor(summary.heldMinor)),
          _MetricRow(
            label: 'Eligible',
            value: formatNgnMinor(summary.eligibleMinor),
          ),
          _MetricRow(
            label: 'Available',
            value: formatNgnMinor(summary.availableMinor),
            strong: true,
          ),
          _MetricRow(
            label: 'Processing',
            value: formatNgnMinor(summary.processingMinor),
          ),
          _MetricRow(label: 'Paid', value: formatNgnMinor(summary.paidMinor)),
          if (summary.negativeBalanceMinor < 0)
            _MetricRow(
              label: 'Adjustment balance',
              value: formatNgnMinor(summary.negativeBalanceMinor),
            ),
          if (summary.payoutPaused)
            const _Notice(
              message:
                  'Payouts are paused. Earnings remain recorded while this is reviewed.',
              isError: true,
            ),
          const SizedBox(height: 8),
          const Text(
            'Completed paid consultations are held for 72 hours before '
            'becoming eligible. Available does not mean an instant withdrawal.',
            style: TextStyle(
              fontSize: 12,
              color: CarenetColors.neutral600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankSection() {
    final profile = _controller.payoutProfile;
    final resolution = _controller.pendingResolution;
    return _Section(
      title: 'Payout account',
      icon: Icons.account_balance_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile != null) ...[
            Text(
              profile.accountName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('${profile.bankName} - ${profile.maskedAccountNumber}'),
            const SizedBox(height: 8),
            _StatusPill(label: _payoutProfileLabel(profile)),
            if (profile.coolingUntil != null) ...[
              const SizedBox(height: 8),
              Text(
                'Cooling until ${_date(profile.coolingUntil!)}',
                style: const TextStyle(color: CarenetColors.neutral600),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed:
                  _controller.isDeactivating
                      ? null
                      : _controller.deactivatePayoutProfile,
              icon: const Icon(Icons.link_off_outlined),
              label: const Text('Deactivate payout account'),
            ),
            const Divider(height: 28),
          ],
          if (resolution != null) ...[
            const Text(
              'Confirm resolved account',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(resolution.accountName),
            Text('${resolution.bankName} - ${resolution.maskedAccountNumber}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _controller.isConfirming
                            ? null
                            : _controller.cancelResolution,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    key: const Key('confirm-payout-account'),
                    onPressed:
                        _controller.isConfirming
                            ? null
                            : () async {
                              await _controller.confirmBank();
                              _accountController.clear();
                              setState(() => _selectedBankCode = null);
                            },
                    child: Text(
                      _controller.isConfirming ? 'Confirming...' : 'Confirm',
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            if (_controller.isLoadingBanks && _controller.banks.isEmpty)
              const LinearProgressIndicator()
            else if (_controller.banks.isEmpty)
              const Text(
                'Bank onboarding is temporarily unavailable. '
                'No account details have been saved.',
              )
            else
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    key: const Key('payout-bank-selector'),
                    initialValue: _selectedBankCode,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Nigerian bank',
                      border: OutlineInputBorder(),
                    ),
                    items: _controller.banks
                        .map(
                          (bank) => DropdownMenuItem<String>(
                            value: bank.code,
                            child: Text(bank.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged:
                        (value) => setState(() => _selectedBankCode = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('payout-account-number'),
                    controller: _accountController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: '10-digit account number',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('resolve-payout-account'),
                      onPressed:
                          _selectedBankCode == null ||
                                  _accountController.text.length != 10 ||
                                  _controller.isResolving
                              ? null
                              : () async {
                                await _controller.resolveBank(
                                  bankCode: _selectedBankCode!,
                                  accountNumber: _accountController.text,
                                );
                                _accountController.clear();
                              },
                      icon: const Icon(Icons.verified_user_outlined),
                      label: Text(
                        _controller.isResolving
                            ? 'Resolving...'
                            : 'Resolve account',
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _activitySection() {
    final summary = _controller.summary;
    final ledger = summary?.recentLedger ?? const <ProfessionalLedgerEntry>[];
    final payouts = summary?.payouts ?? const <ProfessionalPayout>[];
    return _Section(
      title: 'Financial activity',
      icon: Icons.receipt_long_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent ledger',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (ledger.isEmpty)
            const Text('No ledger activity yet.')
          else
            ...ledger
                .take(8)
                .map(
                  (entry) => _ActivityRow(
                    title: _codeLabel(entry.descriptionCode),
                    subtitle:
                        '${_date(entry.createdAt)}${entry.reserved ? ' - reserved for payout' : ''}',
                    amount: formatNgnMinor(entry.amountMinor),
                  ),
                ),
          const Divider(height: 28),
          const Text(
            'Payout history',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (payouts.isEmpty)
            const Text('No payouts have been created yet.')
          else
            ...payouts
                .take(8)
                .map(
                  (payout) => _ActivityRow(
                    title: _codeLabel(payout.status),
                    subtitle:
                        '${payout.bankName} - ${payout.maskedAccountNumber}\n'
                        '${_date(payout.createdAt)}'
                        '${payout.failureCode == null ? '' : '\n${_codeLabel(payout.failureCode!)}'}',
                    amount: formatNgnMinor(payout.amountMinor),
                  ),
                ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CarenetColors.neutral100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E8E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: CarenetColors.brand),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFF1F0) : const Color(0xFFE8F5F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE5F4F1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String title;
  final String subtitle;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CarenetColors.neutral600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

String _payoutProfileLabel(ProfessionalPayoutProfile profile) {
  return switch (profile.status) {
    'ACTIVE' => 'Active for payouts',
    'COOLING' => 'Cooling period',
    'REVIEW_REQUIRED' => 'Review required',
    'DEACTIVATED' => 'Deactivated',
    _ => 'Status unavailable',
  };
}

String _codeLabel(String value) {
  final normalized = value
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}');
  return normalized.join(' ');
}

String _date(DateTime value) {
  return DateFormat('d MMM y, h:mm a').format(value.toLocal());
}
