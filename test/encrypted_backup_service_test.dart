import 'dart:convert';

import 'package:budget_app/features/portability/services/encrypted_backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encrypts with 600k PBKDF2 iterations and restores JSON with correct passphrase',
      () async {
    const snapshot = {'version': 2, 'accounts': []};
    final service = EncryptedBackupService();

    final encrypted =
        await service.encrypt(snapshot, passphrase: 'correct horse');
    final envelope = jsonDecode(encrypted) as Map<String, dynamic>;
    expect(envelope['iterations'], EncryptedBackupService.defaultIterations);

    final restored =
        await service.decrypt(encrypted, passphrase: 'correct horse');

    expect(encrypted, isNot(contains(jsonEncode(snapshot))));
    expect(restored, snapshot);
    expect(
      () => service.decrypt(encrypted, passphrase: 'wrong passphrase'),
      throwsA(anything),
    );
  });

  test('decrypts legacy v1 envelope without iterations field using 100k iterations',
      () async {
    const snapshot = {'version': 1, 'tables': {}};
    final legacyService = EncryptedBackupService(
      iterations: EncryptedBackupService.legacyIterations,
    );
    final encrypted =
        await legacyService.encrypt(snapshot, passphrase: 'legacy-pass');
    final envelope = jsonDecode(encrypted) as Map<String, dynamic>
      ..remove('iterations');

    final restored = await EncryptedBackupService().decrypt(
      jsonEncode(envelope),
      passphrase: 'legacy-pass',
    );
    expect(restored, snapshot);
  });
}
