import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../models/payment_provider.dart';
import 'account_brand_badge.dart';

sealed class ProviderPickResult {
  const ProviderPickResult();
}

final class PickedProvider extends ProviderPickResult {
  final PaymentProvider provider;
  const PickedProvider(this.provider);
}

final class PickedCustom extends ProviderPickResult {
  const PickedCustom();
}

/// Shows a searchable bottom sheet listing Kenyan banks, mobile money wallets,
/// cash, and an optional Custom Account choice.
Future<ProviderPickResult?> showProviderPickerSheet(
  BuildContext context, {
  PaymentProviderGroup? initialGroup,
  bool allowCustom = true,
}) {
  return showModalBottomSheet<ProviderPickResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ProviderPickerSheet(
      initialGroup: initialGroup,
      allowCustom: allowCustom,
    ),
  );
}

class _ProviderPickerSheet extends StatefulWidget {
  final PaymentProviderGroup? initialGroup;
  final bool allowCustom;

  const _ProviderPickerSheet({
    this.initialGroup,
    required this.allowCustom,
  });

  @override
  State<_ProviderPickerSheet> createState() => _ProviderPickerSheetState();
}

class _ProviderPickerSheetState extends State<_ProviderPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<PaymentProvider> _filter(List<PaymentProvider> source) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.subtitle.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final banks = _filter(PaymentProviders.banks);
    final mobile = _filter(PaymentProviders.mobileMoney);
    final cash = _filter(PaymentProviders.cashWallets);

    final sections = <({String title, List<PaymentProvider> items})>[
      if (widget.initialGroup == PaymentProviderGroup.bank) ...[
        if (banks.isNotEmpty) (title: l10n.kenyanBanks, items: banks),
        if (mobile.isNotEmpty) (title: l10n.mobileMoney, items: mobile),
        if (cash.isNotEmpty) (title: l10n.cashAndCustom, items: cash),
      ] else ...[
        if (mobile.isNotEmpty) (title: l10n.mobileMoney, items: mobile),
        if (banks.isNotEmpty) (title: l10n.kenyanBanks, items: banks),
        if (cash.isNotEmpty) (title: l10n.cashAndCustom, items: cash),
      ],
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text(
                  l10n.chooseProvider,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.searchProvidersHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                for (final section in sections) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Text(
                      section.title.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  for (final provider in section.items)
                    ListTile(
                      leading: AccountBrandBadge.fromProvider(
                        provider,
                        size: 42,
                      ),
                      title: Text(
                        provider.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(provider.subtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context)
                          .pop(PickedProvider(provider)),
                    ),
                ],
                if (widget.allowCustom) ...[
                  if (sections.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                      child: Text(
                        l10n.cashAndCustom.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 21,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.add_card_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      l10n.customAccount,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(l10n.customAccountSub),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        Navigator.of(context).pop(const PickedCustom()),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
