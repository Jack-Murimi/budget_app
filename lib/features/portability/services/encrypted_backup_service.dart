import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class EncryptedBackupService {
  EncryptedBackupService({Cipher? cipher})
      : _cipher = cipher ?? AesGcm.with256bits();

  final Cipher _cipher;

  Future<String> encrypt(Map<String, dynamic> snapshot,
      {required String passphrase}) async {
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final secretKey = await _deriveKey(passphrase, salt);
    final box = await _cipher.encrypt(
      utf8.encode(jsonEncode(snapshot)),
      secretKey: secretKey,
      nonce: nonce,
    );
    return jsonEncode({
      'format': 'budget-ke-aes-gcm-backup-v1',
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'ciphertext': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  Future<Map<String, dynamic>> decrypt(String encrypted,
      {required String passphrase}) async {
    final envelope = jsonDecode(encrypted) as Map<String, dynamic>;
    if (envelope['format'] != 'budget-ke-aes-gcm-backup-v1') {
      throw FormatException('Unsupported backup format');
    }
    final secretKey = await _deriveKey(
      passphrase,
      base64Decode(envelope['salt'] as String),
    );
    final clear = await _cipher.decrypt(
      SecretBox(
        base64Decode(envelope['ciphertext'] as String),
        nonce: base64Decode(envelope['nonce'] as String),
        mac: Mac(base64Decode(envelope['mac'] as String)),
      ),
      secretKey: secretKey,
    );
    return jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
  }

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 100000, bits: 256)
          .deriveKey(
              secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
