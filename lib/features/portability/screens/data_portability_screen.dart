import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../services/csv_portability_service.dart';
import '../services/database_backup_service.dart';
import '../services/encrypted_backup_service.dart';

class DataPortabilityScreen extends StatelessWidget {
  const DataPortabilityScreen({super.key, required this.db});
  final AppDatabase db;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Export & backup')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('CSV', style: Theme.of(context).textTheme.titleLarge),
            const Text('Export tables or import standard transaction CSVs.'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _exportCsv(context),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export CSV files'),
            ),
            OutlinedButton.icon(
              onPressed: () => _importCsv(context),
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
              onPressed: () => _backup(context),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Create encrypted backup'),
            ),
            OutlinedButton.icon(
              onPressed: () => _restore(context),
              icon: const Icon(Icons.restore_outlined),
              label: const Text('Restore encrypted backup'),
            ),
          ],
        ),
      );

  Future<void> _exportCsv(BuildContext context) async {
    final service = CsvPortabilityService(db);
    await _save('transactions.csv', await service.exportTransactionsCsv());
    await _save('accounts.csv', await service.exportAccountsCsv());
    await _save('categories.csv', await service.exportCategoriesCsv());
    if (context.mounted) _message(context, 'CSV export saved.');
  }

  Future<void> _importCsv(BuildContext context) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV', extensions: ['csv'])
      ],
    );
    if (file == null) return;
    final result = await CsvPortabilityService(db).importTransactionsCsv(
      await file.readAsString(),
    );
    if (context.mounted) {
      _message(context,
          'Imported ${result.imported}; skipped ${result.skippedDuplicates} duplicates.');
    }
  }

  Future<void> _backup(BuildContext context) async {
    final passphrase = await _passphrase(context, 'Create backup');
    if (passphrase == null) return;
    final snapshot = await DatabaseBackupService(db).snapshot();
    final encrypted = await EncryptedBackupService()
        .encrypt(snapshot, passphrase: passphrase);
    await _save('budget-ke-backup.json', encrypted);
    if (context.mounted) _message(context, 'Encrypted backup saved.');
  }

  Future<void> _restore(BuildContext context) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Backup', extensions: ['json'])
      ],
    );
    if (file == null || !context.mounted) return;
    final passphrase = await _passphrase(context, 'Restore backup');
    if (passphrase == null) return;
    try {
      final snapshot = await EncryptedBackupService().decrypt(
        await file.readAsString(),
        passphrase: passphrase,
      );
      if (!context.mounted || !await _confirmRestore(context)) return;
      await DatabaseBackupService(db).restore(snapshot);
      if (context.mounted) _message(context, 'Backup restored.');
    } catch (_) {
      if (context.mounted) {
        _message(context,
            'Could not restore backup. Check the passphrase and file.');
      }
    }
  }

  Future<void> _save(String name, String data) async {
    final location = await getSaveLocation(suggestedName: name);
    if (location == null) return;
    await XFile.fromData(
      Uint8List.fromList(utf8.encode(data)),
      mimeType: 'text/plain',
      name: name,
    ).saveTo(location.path);
  }

  Future<String?> _passphrase(BuildContext context, String title) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Passphrase'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value == null || value.isEmpty ? null : value;
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

  void _message(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
