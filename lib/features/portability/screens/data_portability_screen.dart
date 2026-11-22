import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../services/csv_portability_service.dart';
import '../services/database_backup_service.dart';
import '../services/encrypted_backup_service.dart';

enum _CsvExportChoice { folder, transactions, accounts, categories }

class DataPortabilityScreen extends StatefulWidget {
  const DataPortabilityScreen({super.key, required this.db});
  final AppDatabase db;

  @override
  State<DataPortabilityScreen> createState() => _DataPortabilityScreenState();
}

class _DataPortabilityScreenState extends State<DataPortabilityScreen> {
  bool _busy = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Export & backup')),
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
            Text('CSV', style: Theme.of(context).textTheme.titleLarge),
            const Text('Export tables or import standard transaction CSVs.'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _busy ? null : _exportCsv,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export CSV files'),
            ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _importCsv,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Import transactions CSV'),
            ),
            const Divider(height: 40),
            Text('Encrypted backup',
                style: Theme.of(context).textTheme.titleLarge),
            const Text(
                'Backups use authenticated encryption and a passphrase.'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _busy ? null : _backup,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Create encrypted backup'),
            ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _restore,
              icon: const Icon(Icons.restore_outlined),
              label: const Text('Restore encrypted backup'),
            ),
          ],
        ),
      );

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
        _message(errorMessage ?? 'Operation failed: $e');
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
    final choice = await showDialog<_CsvExportChoice>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Export CSV'),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, _CsvExportChoice.folder),
            child: const ListTile(
              leading: Icon(Icons.folder_outlined),
              title: Text('Export all to folder'),
              subtitle: Text('transactions.csv, accounts.csv, categories.csv'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, _CsvExportChoice.transactions),
            child: const ListTile(
              leading: Icon(Icons.receipt_long_outlined),
              title: Text('Transactions CSV'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, _CsvExportChoice.accounts),
            child: const ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined),
              title: Text('Accounts CSV'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, _CsvExportChoice.categories),
            child: const ListTile(
              leading: Icon(Icons.category_outlined),
              title: Text('Categories CSV'),
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
        dir = await getDirectoryPath();
      } on UnimplementedError {
        if (mounted) {
          _message(
            'Folder selection is unavailable here. Choose a single CSV file instead.',
          );
        }
        return;
      }
      if (dir == null || !mounted) return;
      final selectedDir = dir;
      await _runBusy('Exporting CSV files...', () async {
        final txCsv = await service.exportTransactionsCsv();
        final accCsv = await service.exportAccountsCsv();
        final catCsv = await service.exportCategoriesCsv();
        await File(p.join(selectedDir, 'transactions.csv'))
            .writeAsString(txCsv);
        await File(p.join(selectedDir, 'accounts.csv')).writeAsString(accCsv);
        await File(p.join(selectedDir, 'categories.csv'))
            .writeAsString(catCsv);
        if (mounted) _message('Exported 3 CSV files.');
      }, errorMessage: 'Could not write CSV files.');
      return;
    }

    await _runBusy('Preparing CSV export...', () async {
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
      if (saved && mounted) _message('CSV export saved.');
    }, errorMessage: 'Could not export CSV.');
  }

  Future<void> _importCsv() async {
    XFile? file;
    try {
      file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'CSV', extensions: ['csv'])
        ],
      );
    } catch (e) {
      if (mounted) _message('Could not open file: $e');
      return;
    }
    if (file == null || !mounted) return;
    final selectedFile = file;

    await _runBusy('Importing CSV...', () async {
      final content = await selectedFile.readAsString();
      final result =
          await CsvPortabilityService(widget.db).importTransactionsCsv(content);
      if (mounted) {
        _message(
          'Imported ${result.imported}; skipped ${result.skippedDuplicates} duplicates.',
        );
      }
    }, errorMessage: 'Could not import CSV file.');
  }

  Future<void> _backup() async {
    final passphrase = await _passphrase(
      context,
      'Create backup',
      requireConfirmation: true,
    );
    if (passphrase == null || !mounted) return;

    await _runBusy('Encrypting backup...', () async {
      final snapshot = await DatabaseBackupService(widget.db).snapshot();
      final encrypted = await EncryptedBackupService()
          .encrypt(snapshot, passphrase: passphrase);
      final saved = await _save('budget-ke-backup.json', encrypted);
      if (saved && mounted) _message('Encrypted backup saved.');
    }, errorMessage: 'Could not create encrypted backup.');
  }

  Future<void> _restore() async {
    XFile? file;
    try {
      file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Backup', extensions: ['json'])
        ],
      );
    } catch (e) {
      if (mounted) _message('Could not open backup file: $e');
      return;
    }
    if (file == null || !mounted) return;
    final passphrase = await _passphrase(context, 'Restore backup');
    if (passphrase == null || !mounted) return;
    final selectedFile = file;

    await _runBusy('Decrypting and restoring backup...', () async {
      final raw = await selectedFile.readAsString();
      final snapshot = await EncryptedBackupService().decrypt(
        raw,
        passphrase: passphrase,
      );
      if (!mounted || !await _confirmRestore(context)) return;
      await DatabaseBackupService(widget.db).restore(snapshot);
      if (mounted) _message('Backup restored.');
    },
        errorMessage:
            'Could not restore backup. Check the passphrase and file.');
  }

  Future<bool> _save(String name, String data) async {
    final location = await getSaveLocation(suggestedName: name);
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
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      final value = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Passphrase',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Passphrase is required';
                    }
                    if (requireConfirmation && v.length < 8) {
                      return 'Use at least 8 characters';
                    }
                    return null;
                  },
                ),
                if (requireConfirmation) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm passphrase',
                    ),
                    validator: (v) {
                      if (v != controller.text) {
                        return 'Passphrases do not match';
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogContext, controller.text);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      return value == null || value.isEmpty ? null : value;
    } finally {
      controller.dispose();
      confirmController.dispose();
    }
  }

  Future<bool> _confirmRestore(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Replace current data?'),
          content: const Text(
              'Restoring permanently replaces all current app data.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Restore')),
          ],
        ),
      ) ??
      false;

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
