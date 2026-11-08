import 'dart:convert';

import 'package:budget_app/features/portability/services/encrypted_backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encrypts a snapshot and restores its JSON with the correct passphrase',
      () async {
    const snapshot = {'version': 1, 'accounts': []};
    final service = EncryptedBackupService();

    final encrypted =
        await service.encrypt(snapshot, passphrase: 'correct horse');
    final restored =
        await service.decrypt(encrypted, passphrase: 'correct horse');

    expect(encrypted, isNot(contains(jsonEncode(snapshot))));
    expect(restored, snapshot);
    expect(
      () => service.decrypt(encrypted, passphrase: 'wrong passphrase'),
      throwsA(anything),
    );
  });
}
