import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/color_utils.dart';
import '../models/payment_provider.dart';
import '../providers/account_providers.dart';
import 'account_brand_badge.dart';
import 'provider_picker_sheet.dart';

const Map<String, String> accountColorOptions = {
  '#1B5E20': 'Dark Green',
  '#4CAF50': 'Green',
  '#2196F3': 'Blue',
  '#F44336': 'Red',
  '#FF9800': 'Orange',
  '#9C27B0': 'Purple',
  '#009688': 'Teal',
  '#795548': 'Brown',
  '#607D8B': 'Grey',
};

const List<String> accountTypeOptions = [
  'mpesa',
  'cash',
  'bank',
  'airtel',
  'mobile',
  'other',
];

Future<bool?> showAddAccountDialog(
  BuildContext context, {
  PaymentProvider? initialProvider,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AddAccountDialog(initialProvider: initialProvider),
  );
}

class AddAccountDialog extends ConsumerStatefulWidget {
  final PaymentProvider? initialProvider;

  const AddAccountDialog({super.key, this.initialProvider});

  @override
  ConsumerState<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.initialProvider?.name ?? '',
  );
  final _balanceCtrl = TextEditingController();

  late PaymentProvider? _selectedProvider = widget.initialProvider;
  late String _selectedType = widget.initialProvider?.type ?? 'other';
  late String _selectedColor =
      widget.initialProvider?.primaryColorHex ?? '#1B5E20';
  late String _selectedIcon =
      widget.initialProvider?.id ?? 'account_balance_wallet';
  bool _isSaving = false;

  static const _quickProviders = [
    PaymentProviders.equity,
    PaymentProviders.kcb,
    PaymentProviders.coop,
    PaymentProviders.ncba,
    PaymentProviders.absa,
    PaymentProviders.airtel,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  void _applyProvider(PaymentProvider? provider) {
    final prevName = _selectedProvider?.name;
    setState(() {
      _selectedProvider = provider;
      if (provider != null) {
        if (_nameCtrl.text.trim().isEmpty || _nameCtrl.text == prevName) {
          _nameCtrl.text = provider.name;
        }
        _selectedType = provider.type;
        _selectedColor = provider.primaryColorHex;
        _selectedIcon = provider.id;
      } else {
        if (_nameCtrl.text == prevName) {
          _nameCtrl.clear();
        }
        _selectedIcon = 'account_balance_wallet';
        if (!accountColorOptions.containsKey(_selectedColor)) {
          _selectedColor = '#1B5E20';
        }
      }
    });
  }

  Future<void> _openProviderPicker() async {
    final picked = await showProviderPickerSheet(
      context,
      initialGroup: PaymentProviderGroup.bank,
    );
    if (!mounted || picked == null) return;
    switch (picked) {
      case PickedProvider(:final provider):
        _applyProvider(provider);
      case PickedCustom():
        _applyProvider(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final previewColors = _selectedProvider != null
        ? [
            parseHexColor(_selectedProvider!.primaryColorHex),
            parseHexColor(_selectedProvider!.secondaryColorHex),
          ]
        : [
            parseHexColor(_selectedColor),
            Color.lerp(parseHexColor(_selectedColor), Colors.black, 0.3)!,
          ];
    final previewTitle = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : (_selectedProvider?.name ?? l10n.customAccount);
    final previewSubtitle =
        _selectedProvider?.subtitle ?? _selectedType.toUpperCase();

    return AlertDialog(
      title: Text(l10n.addAccount),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live card preview
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: previewColors,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    AccountBrandBadge(
                      icon: _selectedIcon,
                      name: previewTitle,
                      type: _selectedType,
                      colorHex: _selectedColor,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            previewTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            previewSubtitle,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Provider picker trigger + quick bank chips
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _openProviderPicker,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.accountProviderLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: const Icon(Icons.expand_more_rounded),
                  ),
                  child: Text(
                    _selectedProvider?.name ?? l10n.customAccount,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final p in _quickProviders)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          avatar: AccountBrandBadge.fromProvider(p, size: 20),
                          label: Text(p.name),
                          selected: _selectedProvider?.id == p.id,
                          onSelected: (_) => _applyProvider(
                            _selectedProvider?.id == p.id ? null : p,
                          ),
                        ),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.account_balance_rounded, size: 16),
                      label: Text(l10n.moreBanks),
                      onPressed: _openProviderPicker,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Name & Opening balance (kept as the only 2 TextFields)
              TextFormField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.nameRequired,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.enterAccountName
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _balanceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.openingBalance,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_selectedProvider == null) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.type,
                    border: const OutlineInputBorder(),
                  ),
                  initialValue: _selectedType,
                  items: accountTypeOptions
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.colorLabel,
                    border: const OutlineInputBorder(),
                  ),
                  initialValue: accountColorOptions.containsKey(_selectedColor)
                      ? _selectedColor
                      : accountColorOptions.keys.first,
                  items: accountColorOptions.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: parseHexColor(e.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(e.value),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedColor = v);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(l10n.add),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await ref.read(accountRepositoryProvider).insertAccount(
          AccountsCompanion.insert(
            name: _nameCtrl.text.trim(),
            type: Value(_selectedType),
            initialBalance: Value(
              double.tryParse(_balanceCtrl.text.replaceAll(',', '').trim()) ??
                  0.0,
            ),
            colorHex: Value(_selectedColor),
            icon: Value(_selectedIcon),
          ),
        );
    if (mounted) Navigator.pop(context, true);
  }
}
