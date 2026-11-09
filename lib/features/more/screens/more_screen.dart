import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../accounts/screens/accounts_screen.dart';
import '../../categories/screens/categories_screen.dart';
import '../../debts/screens/debts_screen.dart';
import '../../fuliza/screens/fuliza_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../insights/screens/insights_screen.dart';
import '../../portability/screens/data_portability_screen.dart';
import '../../recurring/screens/recurring_screen.dart';
import '../../settings/settings_screen.dart';
import '../../sms/screens/sms_inbox_screen.dart';
import '../models/more_item_config.dart';

List<MoreSectionConfig> buildMoreSections(WidgetRef ref) {
  return [
    MoreSectionConfig(
      header: 'Money',
      items: [
        MoreItemConfig(
          title: 'Accounts',
          icon: Icons.account_balance_wallet_outlined,
          destination: (_) => const AccountsScreen(),
        ),
        MoreItemConfig(
          title: 'Loans & Debts',
          icon: Icons.handshake_outlined,
          destination: (_) => const DebtsScreen(),
        ),
        MoreItemConfig(
          title: 'Fuliza Overdraft',
          icon: Icons.sync_problem_rounded,
          destination: (_) => const FulizaScreen(),
        ),
      ],
    ),
    MoreSectionConfig(
      header: 'Automation',
      items: [
        MoreItemConfig(
          title: 'Recurring & Bills',
          icon: Icons.repeat,
          destination: (_) => const RecurringScreen(),
        ),
        MoreItemConfig(
          title: 'Scan SMS Inbox',
          subtitle: 'Import M-Pesa SMS from your inbox',
          icon: Icons.sms_outlined,
          destination: (_) => const SmsInboxScreen(),
        ),
      ],
    ),
    MoreSectionConfig(
      header: 'Organize',
      items: [
        MoreItemConfig(
          title: 'Categories',
          icon: Icons.category_outlined,
          destination: (_) => const CategoriesScreen(),
        ),
        MoreItemConfig(
          title: 'Savings Goals',
          icon: Icons.savings_outlined,
          destination: (_) => const GoalsScreen(),
        ),
        MoreItemConfig(
          title: 'Insights & Analytics',
          icon: Icons.insights_outlined,
          destination: (_) => const InsightsScreen(),
        ),
      ],
    ),
    MoreSectionConfig(
      header: 'App',
      items: [
        MoreItemConfig(
          title: 'Settings',
          icon: Icons.settings_outlined,
          destination: (_) => const SettingsScreen(),
        ),
        MoreItemConfig(
          title: 'Export & Backup',
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
    final allSections = buildMoreSections(ref);

    final filteredSections = allSections.map((section) {
      if (_query.isEmpty) return section;
      final matchingItems = section.items.where((item) {
        final titleMatch = item.title.toLowerCase().contains(_query);
        final subMatch = item.subtitle?.toLowerCase().contains(_query) ?? false;
        return titleMatch || subMatch;
      }).toList();
      return MoreSectionConfig(
        header: section.header,
        items: matchingItems,
      );
    }).where((section) => section.items.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: 'Search features...',
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
                      'No matching features found',
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                            child: Text(
                              section.header.toUpperCase(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          ...section.items.map((item) {
                            return ListTile(
                              minVerticalPadding: 12,
                              leading: Icon(
                                item.icon,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              title: Text(
                                item.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: item.subtitle != null
                                  ? Text(item.subtitle!)
                                  : null,
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.outline,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => item.destination(ctx),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
