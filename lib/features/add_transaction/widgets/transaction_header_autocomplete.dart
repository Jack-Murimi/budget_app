import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/models/header_suggestion.dart';
import '../../transactions/providers/transaction_providers.dart';

/// Debounced header text field with history autocomplete suggestions.
class TransactionHeaderAutocomplete extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration decoration;
  final String? Function(String?) validator;
  final ValueChanged<HeaderSuggestion> onSelected;

  const TransactionHeaderAutocomplete({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.decoration,
    required this.validator,
    required this.onSelected,
  });

  @override
  ConsumerState<TransactionHeaderAutocomplete> createState() =>
      _TransactionHeaderAutocompleteState();
}

class _TransactionHeaderAutocompleteState
    extends ConsumerState<TransactionHeaderAutocomplete> {
  static const _debounceDuration = Duration(milliseconds: 250);

  Timer? _debounce;
  Completer<Iterable<HeaderSuggestion>>? _pendingCompleter;

  @override
  void dispose() {
    _debounce?.cancel();
    final pending = _pendingCompleter;
    if (pending != null && !pending.isCompleted) {
      pending.complete(const Iterable<HeaderSuggestion>.empty());
    }
    super.dispose();
  }

  Future<Iterable<HeaderSuggestion>> _debouncedOptions(
    TextEditingValue value,
  ) async {
    final query = value.text.trim();
    _debounce?.cancel();
    final previous = _pendingCompleter;
    if (previous != null && !previous.isCompleted) {
      previous.complete(const Iterable<HeaderSuggestion>.empty());
    }

    if (query.isEmpty) {
      return const Iterable<HeaderSuggestion>.empty();
    }

    final completer = Completer<Iterable<HeaderSuggestion>>();
    _pendingCompleter = completer;
    _debounce = Timer(_debounceDuration, () async {
      if (!mounted) {
        if (!completer.isCompleted) {
          completer.complete(const Iterable<HeaderSuggestion>.empty());
        }
        return;
      }
      try {
        final results = await ref
            .read(transactionRepositoryProvider)
            .getHeaderSuggestions(query);
        if (!completer.isCompleted) {
          completer.complete(results);
        }
      } catch (_) {
        if (!completer.isCompleted) {
          completer.complete(const Iterable<HeaderSuggestion>.empty());
        }
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder so the suggestion list matches the field's width.
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<HeaderSuggestion>(
        textEditingController: widget.controller,
        focusNode: widget.focusNode,
        displayStringForOption: (option) => option.header,
        optionsBuilder: _debouncedOptions,
        onSelected: widget.onSelected,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: widget.decoration,
            validator: widget.validator,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              onFieldSubmitted();
              FocusScope.of(context).nextFocus();
            },
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          final theme = Theme.of(context);
          return Align(
            alignment: AlignmentDirectional.topStart,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerHighest,
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth,
                  maxHeight: 220,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.history, size: 20),
                      title: Text(
                        option.header,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: option.categoryDisplay.isNotEmpty
                          ? Text(
                              option.categoryDisplay,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
