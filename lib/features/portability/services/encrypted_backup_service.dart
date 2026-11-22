import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class EncryptedBackupService {
  EncryptedBackupService({
    Cipher? cipher,
    int iterations = defaultIterations,
  })  : _cipher = cipher ?? AesGcm.with256bits(),
        _iterations = iterations;

  static const int defaultIterations = 600000;
  static const int legacyIterations = 100000;

  final Cipher _cipher;
  final int _iterations;

  Future<String> encrypt(
    Map<String, dynamic> snapshot, {
    required String passphrase,
  }) async {
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final secretKey = await _deriveKey(passphrase, salt, _iterations);
    final box = await _cipher.encrypt(
      utf8.encode(jsonEncode(snapshot)),
      secretKey: secretKey,
      nonce: nonce,
    );
    return jsonEncode({
      'format': 'budget-ke-aes-gcm-backup-v1',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'ciphertext': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  Future<Map<String, dynamic>> decrypt(
    String encrypted, {
    required String passphrase,
  }) async {
    final envelope = jsonDecode(encrypted) as Map<String, dynamic>;
    if (envelope['format'] != 'budget-ke-aes-gcm-backup-v1') {
      throw const FormatException('Unsupported backup format');
    }
    final rawIter = envelope['iterations'];
    final int iterations;
    if (rawIter == null) {
      iterations = legacyIterations;
    } else if (rawIter is int && rawIter >= 10000 && rawIter <= 2000000) {
      iterations = rawIter;
    } else {
      throw const FormatException('Invalid PBKDF2 iterations');
    }
    final secretKey = await _deriveKey(
      passphrase,
      base64Decode(envelope['salt'] as String),
      iterations,
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

  static Future<SecretKey> _deriveKey(
    String passphrase,
    List<int> salt,
    int iterations,
  ) async {
    final bytes = await Isolate.run(() async {
      final key = await Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: 256,
      ).deriveKey(
        secretKey: SecretKey(utf8.encode(passphrase)),
        nonce: salt,
      );
      return key.extractBytes();
    });
    return SecretKey(bytes);
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
