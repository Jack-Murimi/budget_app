import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../categories/providers/category_providers.dart';
import '../../categories/widgets/category_picker.dart';
import '../models/mpesa_parse_result.dart';
import '../services/mpesa_parser.dart';
import '../services/mpesa_result_handler.dart';

/// Opens a bottom sheet for pasting, previewing, categorizing, and
/// deduplicating multiple M-Pesa SMS messages in one batch.
Future<BulkImportSummary?> showBatchMpesaPasteSheet(
  BuildContext context, {
  String initialText = '',
}) {
  return showModalBottomSheet<BulkImportSummary>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BatchMpesaPasteSheet(initialText: initialText),
  );
}

class BatchMpesaPasteSheet extends ConsumerStatefulWidget {
  final String initialText;

  const BatchMpesaPasteSheet({super.key, this.initialText = ''});

  @override
  ConsumerState<BatchMpesaPasteSheet> createState() =>
      _BatchMpesaPasteSheetState();
}

class _BatchMpesaPasteSheetState extends ConsumerState<BatchMpesaPasteSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  List<BatchPreviewItem> _previewItems = const [];
  List<bool> _selected = [];
  final Map<int, int?> _categoryOverrides = {};
  int _unparsedCount = 0;
  bool _hasParsed = false;
  bool _parsing = false;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _parseText();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.clipboardEmpty)),
      );
      return;
    }
    _controller.text = text;
    await _parseText();
  }

  Future<void> _parseText() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _previewItems = const [];
        _selected = [];
        _categoryOverrides.clear();
        _unparsedCount = 0;
        _hasParsed = false;
      });
      return;
    }

    setState(() => _parsing = true);
    try {
      final split = MpesaParser.parseBatch(raw);
      final handler = ref.read(mpesaResultHandlerProvider);
      final preview = await handler.prepareBatchPreview(split.valid);
      if (!mounted) return;

      _categoryOverrides.clear();
      final selected = <bool>[];
      for (var i = 0; i < preview.length; i++) {
        selected.add(!preview[i].isDuplicate);
        _categoryOverrides[i] = preview[i].suggestedCategoryId;
      }

      setState(() {
        _previewItems = preview;
        _selected = selected;
        _unparsedCount = split.unparsedSegments.length;
        _hasParsed = true;
      });
    } finally {
      if (mounted) setState(() => _parsing = false);
    }
  }

  Future<void> _pickCategoryForRow(int index, BatchPreviewItem item) async {
    final picked = await showCategoryPicker(
      context,
      initialType: item.result.resolvedTransactionType,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _categoryOverrides[index] = picked.id;
    });
  }

  Future<void> _importSelected() async {
    if (_importing) return;
    final toImport = <({MpesaParseResult result, int? categoryId})>[];
    for (var i = 0; i < _previewItems.length; i++) {
      if (_selected[i] && !_previewItems[i].isDuplicate) {
        toImport.add((
          result: _previewItems[i].result,
          categoryId: _categoryOverrides[i],
        ));
      }
    }
    if (toImport.isEmpty) return;

    setState(() => _importing = true);
    try {
      final summary = await ref
          .read(mpesaResultHandlerProvider)
          .bulkImportWithOverrides(toImport);
      if (!mounted) return;
      Navigator.of(context).pop(summary);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final categoriesById = ref.watch(categoriesByIdProvider);

    final readyCount =
        _previewItems.where((item) => !item.isDuplicate).length;
    final dupCount = _previewItems.where((item) => item.isDuplicate).length;
    var selectedCount = 0;
    for (var i = 0; i < _previewItems.length; i++) {
      if (_selected[i] && !_previewItems[i].isDuplicate) selectedCount++;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.batchPasteTitle,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: l10n.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.batchPasteHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _parsing ? null : _pasteFromClipboard,
                        icon: const Icon(Icons.content_paste_rounded, size: 18),
                        label: Text(l10n.pasteFromClipboard),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _parsing ? null : _parseText,
                          icon: _parsing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.auto_fix_high_rounded,
                                  size: 18),
                          label: Text(l10n.parseMessages),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_hasParsed) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(
                        avatar: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: cs.primary,
                        ),
                        label: Text(l10n.batchReadyCount(readyCount)),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (dupCount > 0)
                        Chip(
                          avatar: Icon(
                            Icons.content_copy_rounded,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          label: Text(l10n.batchDuplicateCount(dupCount)),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (_unparsedCount > 0)
                        Chip(
                          avatar: Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: cs.error,
                          ),
                          label: Text(l10n.batchUnparsedCount(_unparsedCount)),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: !_hasParsed
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.batchPasteHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : _previewItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.batchImportNothingNew,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          itemCount: _previewItems.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final item = _previewItems[index];
                            final r = item.result;
                            final txType = r.resolvedTransactionType;
                            final amountColor = switch (txType) {
                              'income' => Colors.green.shade700,
                              'transfer' => cs.primary,
                              _ => cs.error,
                            };
                            final catId = _categoryOverrides[index];
                            final catName = catId != null
                                ? (categoriesById[catId]?.name ??
                                    l10n.uncategorized)
                                : l10n.uncategorized;

                            final metaParts = <String>[
                              if (r.mpesaRef.isNotEmpty) r.mpesaRef,
                              DateFormatter.formatDate(r.transactionDate),
                              if (r.transactionCost > 0)
                                '+${CurrencyFormatter.format(r.transactionCost)}',
                              if (r.fulizaAmount > 0)
                                'Fuliza ${CurrencyFormatter.format(r.fulizaAmount)}',
                            ];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _selected[index],
                                    onChanged: item.isDuplicate
                                        ? null
                                        : (val) => setState(
                                              () => _selected[index] =
                                                  val ?? false,
                                            ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                r.autoDescription,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: item.isDuplicate
                                                      ? cs.onSurfaceVariant
                                                      : null,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              CurrencyFormatter.format(
                                                  r.amount),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: item.isDuplicate
                                                    ? cs.onSurfaceVariant
                                                    : amountColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          metaParts.join(' · '),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (item.isDuplicate)
                                          Chip(
                                            label: Text(l10n.duplicateBadge),
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                          )
                                        else if (!item.isFulizaEvent)
                                          ActionChip(
                                            avatar: const Icon(
                                              Icons.category_outlined,
                                              size: 15,
                                            ),
                                            label: Text(catName),
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () =>
                                                _pickCategoryForRow(
                                                    index, item),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        selectedCount == 0 || _importing ? null : _importSelected,
                    child: _importing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.importSelectedCount(selectedCount)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
