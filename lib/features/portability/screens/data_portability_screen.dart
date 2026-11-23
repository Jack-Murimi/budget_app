import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../services/csv_portability_service.dart';
import '../services/database_backup_service.dart';
import '../services/encrypted_backup_service.dart';

enum _CsvExportChoice { folder, transactions, accounts, categories }

class DataPortabilityScreen extends StatefulWidget {
  const DataPortabilityScreen({
    super.key,
    required this.db,
    this.pickSaveLocation,
    this.pickOpenFile,
    this.pickDirectoryPath,
  });

  final AppDatabase db;
  final Future<FileSaveLocation?> Function({String? suggestedName})?
      pickSaveLocation;
  final Future<XFile?> Function({List<XTypeGroup> acceptedTypeGroups})?
      pickOpenFile;
  final Future<String?> Function()? pickDirectoryPath;

  @override
  State<DataPortabilityScreen> createState() => _DataPortabilityScreenState();
}

class _DataPortabilityScreenState extends State<DataPortabilityScreen> {
  bool _busy = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.portabilityTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_busy) ...[
            const LinearProgressIndicator(),
            if (_statusMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _statusMessage!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
          ],
          Text(l10n.csvHeading, style: Theme.of(context).textTheme.titleLarge),
          Text(l10n.csvDescription),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _busy ? null : _exportCsv,
            icon: const Icon(Icons.download_outlined),
            label: Text(l10n.exportCsvFiles),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _importCsv,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(l10n.importTransactionsCsv),
          ),
          const Divider(height: 40),
          Text(
            l10n.encryptedBackupHeading,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(l10n.encryptedBackupDesc),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _busy ? null : _backup,
            icon: const Icon(Icons.lock_outline),
            label: Text(l10n.createEncryptedBackup),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _restore,
            icon: const Icon(Icons.restore_outlined),
            label: Text(l10n.restoreEncryptedBackup),
          ),
        ],
      ),
    );
  }

  Future<void> _runBusy(
    String status,
    Future<void> Function() action, {
    String? errorMessage,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _statusMessage = status;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        _message(errorMessage ?? context.l10n.operationFailed('$e'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _exportCsv() async {
    final l10n = context.l10n;
    final choice = await showDialog<_CsvExportChoice>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.exportCsvTitle),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, _CsvExportChoice.folder),
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(l10n.exportAllToFolder),
              subtitle: Text(l10n.exportAllCsvSub),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, _CsvExportChoice.transactions),
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(l10n.transactionsCsv),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, _CsvExportChoice.accounts),
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: Text(l10n.accountsCsv),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, _CsvExportChoice.categories),
            child: ListTile(
              leading: const Icon(Icons.category_outlined),
              title: Text(l10n.categoriesCsv),
            ),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;

    final service = CsvPortabilityService(widget.db);
    if (choice == _CsvExportChoice.folder) {
      String? dir;
      try {
        dir = await (widget.pickDirectoryPath ?? getDirectoryPath)();
      } on UnimplementedError {
        if (mounted) {
          _message(l10n.folderPickerUnavailable);
        }
        return;
      }
      if (dir == null || !mounted) return;
      final selectedDir = dir;
      await _runBusy(l10n.exportingCsvFiles, () async {
        final txCsv = await service.exportTransactionsCsv();
        final accCsv = await service.exportAccountsCsv();
        final catCsv = await service.exportCategoriesCsv();
        await File(p.join(selectedDir, 'transactions.csv'))
            .writeAsString(txCsv);
        await File(p.join(selectedDir, 'accounts.csv')).writeAsString(accCsv);
        await File(p.join(selectedDir, 'categories.csv'))
            .writeAsString(catCsv);
        if (mounted) _message(l10n.exported3CsvFiles);
      }, errorMessage: l10n.couldNotWriteCsvFiles);
      return;
    }

    await _runBusy(l10n.preparingCsvExport, () async {
      final (name, data) = switch (choice) {
        _CsvExportChoice.transactions => (
            'transactions.csv',
            await service.exportTransactionsCsv(),
          ),
        _CsvExportChoice.accounts => (
            'accounts.csv',
            await service.exportAccountsCsv(),
          ),
        _CsvExportChoice.categories => (
            'categories.csv',
            await service.exportCategoriesCsv(),
          ),
        _CsvExportChoice.folder => throw StateError('Unreachable'),
      };
      final saved = await _save(name, data);
      if (saved && mounted) _message(l10n.csvExportSaved);
    }, errorMessage: l10n.couldNotExportCsv);
  }

  Future<void> _importCsv() async {
    final l10n = context.l10n;
    XFile? file;
    try {
      file = await (widget.pickOpenFile ?? openFile)(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'CSV', extensions: ['csv'])
        ],
      );
    } catch (e) {
      if (mounted) _message(l10n.couldNotOpenFile('$e'));
      return;
    }
    if (file == null || !mounted) return;
    final selectedFile = file;

    await _runBusy(l10n.importingCsv, () async {
      final content = await selectedFile.readAsString();
      final result =
          await CsvPortabilityService(widget.db).importTransactionsCsv(content);
      if (mounted) {
        _message(
          l10n.importedCsvResult(
            result.imported,
            result.skippedDuplicates,
          ),
        );
      }
    }, errorMessage: l10n.couldNotImportCsv);
  }

  Future<void> _backup() async {
    final l10n = context.l10n;
    final passphrase = await _passphrase(
      context,
      l10n.createBackupTitle,
      requireConfirmation: true,
    );
    if (passphrase == null || !mounted) return;

    await _runBusy(l10n.encryptingBackup, () async {
      final snapshot = await DatabaseBackupService(widget.db).snapshot();
      final encrypted = await EncryptedBackupService()
          .encrypt(snapshot, passphrase: passphrase);
      final saved = await _save('budget-ke-backup.json', encrypted);
      if (saved && mounted) _message(l10n.encryptedBackupSaved);
    }, errorMessage: l10n.couldNotCreateBackup);
  }

  Future<void> _restore() async {
    final l10n = context.l10n;
    XFile? file;
    try {
      file = await (widget.pickOpenFile ?? openFile)(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Backup', extensions: ['json'])
        ],
      );
    } catch (e) {
      if (mounted) _message(l10n.couldNotOpenBackupFile('$e'));
      return;
    }
    if (file == null || !mounted) return;
    final passphrase = await _passphrase(context, l10n.restoreBackupTitle);
    if (passphrase == null || !mounted) return;
    final selectedFile = file;

    await _runBusy(l10n.decryptingRestoringBackup, () async {
      final raw = await selectedFile.readAsString();
      final snapshot = await EncryptedBackupService().decrypt(
        raw,
        passphrase: passphrase,
      );
      if (!mounted || !await _confirmRestore(context)) return;
      await DatabaseBackupService(widget.db).restore(snapshot);
      if (mounted) _message(l10n.backupRestored);
    }, errorMessage: l10n.couldNotRestoreBackup);
  }

  Future<bool> _save(String name, String data) async {
    final location = await (widget.pickSaveLocation ?? getSaveLocation)(
      suggestedName: name,
    );
    if (location == null) return false;
    await XFile.fromData(
      Uint8List.fromList(utf8.encode(data)),
      mimeType: 'text/plain',
      name: name,
    ).saveTo(location.path);
    return true;
  }

  Future<String?> _passphrase(
    BuildContext context,
    String title, {
    bool requireConfirmation = false,
  }) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _PassphraseDialog(
        title: title,
        requireConfirmation: requireConfirmation,
      ),
    );
    return value == null || value.isEmpty ? null : value;
  }

  Future<bool> _confirmRestore(BuildContext context) async {
    final l10n = context.l10n;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.restoreConfirmTitle),
            content: Text(l10n.restoreConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.restore),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class _PassphraseDialog extends StatefulWidget {
  final String title;
  final bool requireConfirmation;

  const _PassphraseDialog({
    required this.title,
    required this.requireConfirmation,
  });

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.passphrase),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return l10n.passphraseRequired;
                }
                if (widget.requireConfirmation && v.length < 8) {
                  return l10n.passphraseMinLength;
                }
                return null;
              },
            ),
            if (widget.requireConfirmation) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.confirmPassphrase),
                validator: (v) {
                  if (v != _controller.text) {
                    return l10n.passphrasesDoNotMatch;
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, _controller.text);
          },
          child: Text(l10n.continueLabel),
        ),
      ],
    );
  }
}
