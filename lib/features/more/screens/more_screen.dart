import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../../main.dart';
import '../../../shared/widgets/motion.dart';
import '../../accounts/screens/accounts_screen.dart';
import '../../categories/screens/categories_screen.dart';
import '../../debts/screens/bridge_charges_screen.dart';
import '../../debts/screens/debts_screen.dart';
import '../../fuliza/screens/fuliza_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../insights/screens/insights_screen.dart';
import '../../portability/screens/data_portability_screen.dart';
import '../../recurring/screens/recurring_screen.dart';
import '../../settings/settings_screen.dart';
import '../models/more_item_config.dart';

List<MoreSectionConfig> buildMoreSections(
  WidgetRef ref,
  AppLocalizations l10n,
) {
  return [
    MoreSectionConfig(
      header: l10n.sectionMoney,
      items: [
        MoreItemConfig(
          title: l10n.moreAccounts,
          icon: Icons.account_balance_wallet_outlined,
          destination: (_) => const AccountsScreen(),
        ),
        MoreItemConfig(
          title: l10n.moreLoansAndDebts,
          icon: Icons.handshake_outlined,
          destination: (_) => const DebtsScreen(),
        ),
        MoreItemConfig(
          title: l10n.moreBridgeCharges,
          subtitle: l10n.moreBridgeChargesSub,
          icon: Icons.account_balance_outlined,
          destination: (_) => const BridgeChargesScreen(),
        ),
        MoreItemConfig(
          title: l10n.moreFulizaOverdraft,
          icon: Icons.sync_problem_rounded,
          destination: (_) => const FulizaScreen(),
        ),
      ],
    ),
    MoreSectionConfig(
      header: l10n.sectionAutomation,
      items: [
        MoreItemConfig(
          title: l10n.moreRecurringBills,
          icon: Icons.repeat,
          destination: (_) => const RecurringScreen(),
        ),
      ],
    ),
    MoreSectionConfig(
      header: l10n.sectionOrganize,
      items: [
        MoreItemConfig(
          title: l10n.moreCategories,
          icon: Icons.category_outlined,
          destination: (_) => const CategoriesScreen(),
        ),
        MoreItemConfig(
          title: l10n.moreSavingsGoals,
          icon: Icons.savings_outlined,
          destination: (_) => const GoalsScreen(),
        ),
        MoreItemConfig(
          title: l10n.moreInsights,
          icon: Icons.insights_outlined,
          destination: (_) => const InsightsScreen(),
        ),
      ],
    ),
    MoreSectionConfig(
      header: l10n.sectionApp,
      items: [
        MoreItemConfig(
          title: l10n.moreSettings,
          icon: Icons.settings_outlined,
          destination: (_) => const SettingsScreen(),
        ),
        MoreItemConfig(
          title: l10n.moreExportBackup,
          icon: Icons.import_export_outlined,
          destination: (_) => DataPortabilityScreen(db: ref.read(dbProvider)),
        ),
      ],
    ),
  ];
}

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final text = _searchCtrl.text.trim().toLowerCase();
      if (text != _query) {
        setState(() => _query = text);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final allSections = buildMoreSections(ref, l10n);

    final filteredSections = allSections
        .map((section) {
          if (_query.isEmpty) return section;
          final matchingItems = section.items.where((item) {
            final titleMatch = item.title.toLowerCase().contains(_query);
            final subMatch =
                item.subtitle?.toLowerCase().contains(_query) ?? false;
            return titleMatch || subMatch;
          }).toList();
          return MoreSectionConfig(
            header: section.header,
            items: matchingItems,
          );
        })
        .where((section) => section.items.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moreTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: l10n.searchFeaturesHint,
              leading: const Icon(Icons.search),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchCtrl.clear(),
                  ),
              ],
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(
                theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          Expanded(
            child: filteredSections.isEmpty
                ? Center(
                    child: Text(
                      l10n.noMatchingFeatures,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filteredSections.length,
                    itemBuilder: (context, sectionIndex) {
                      final section = filteredSections[sectionIndex];
                      return FadeSlideIn(
                        index: sectionIndex,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 14, 16, 6),
                              child: Text(
                                section.header.toUpperCase(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            Card(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  for (final (idx, item)
                                      in section.items.indexed) ...[
                                    if (idx > 0)
                                      const Divider(
                                        height: 1,
                                        indent: 64,
                                        endIndent: 16,
                                      ),
                                    ListTile(
                                      dense: item.subtitle == null,
                                      minVerticalPadding: 8,
                                      leading: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme.primaryContainer
                                              .withValues(alpha: 0.55),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          item.icon,
                                          size: 19,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      title: Text(
                                        item.title,
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: item.subtitle != null
                                          ? Text(
                                              item.subtitle!,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            )
                                          : null,
                                      trailing: Icon(
                                        Icons.chevron_right_rounded,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) =>
                                                item.destination(ctx),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
