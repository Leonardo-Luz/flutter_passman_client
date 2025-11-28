import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

const int nonceSize = 12;
const int keySize = 32;
const int pbkdf2Iterations = 100000;

final _aesGcm = AesGcm.with256bits();
final _pbkdf2 = Pbkdf2(
  macAlgorithm: Hmac.sha256(),
  iterations: pbkdf2Iterations,
  bits: keySize * 8,
);

Future<Uint8List> deriveKey(String masterPassword, Uint8List salt) async {
  final secretKey = await _pbkdf2.deriveKey(
    secretKey: SecretKey(utf8.encode(masterPassword)),
    nonce: salt,
  );
  final keyBytes = await secretKey.extractBytes();
  return Uint8List.fromList(keyBytes);
}

Future<String> encrypt(String masterPassword, String plaintext) async {
  final rnd = Random.secure();
  final nonce = Uint8List.fromList(
    List.generate(nonceSize, (_) => rnd.nextInt(256)),
  );

  final keyBytes = await deriveKey(masterPassword, nonce);
  final secretKey = SecretKey(keyBytes);

  final secretBox = await _aesGcm.encrypt(
    utf8.encode(plaintext),
    secretKey: secretKey,
    nonce: nonce,
  );

  // SECRETBOX FORMAT INCLUDES: cipherText + mac.bytes
  final combined = <int>[
    ...nonce,
    ...secretBox.cipherText,
    ...secretBox.mac.bytes,
  ];

  return base64Encode(combined);
}

Future<String> decrypt(String masterPassword, String combinedB64) async {
  final bytes = base64Decode(combinedB64);

  if (bytes.length < nonceSize + 16) {
    throw Exception("Invalid data");
  }

  final nonce = Uint8List.sublistView(bytes, 0, nonceSize);

  // Cipher + MAC
  final cipherPlusMac = Uint8List.sublistView(bytes, nonceSize);

  // Split ciphertext and MAC
  final ciphertext = Uint8List.sublistView(
    cipherPlusMac,
    0,
    cipherPlusMac.length - 16,
  );
  final macBytes = Uint8List.sublistView(
    cipherPlusMac,
    cipherPlusMac.length - 16,
  );

  final mac = Mac(macBytes);

  final keyBytes = await deriveKey(masterPassword, nonce);
  final secretKey = SecretKey(keyBytes);

  final secretBox = SecretBox(ciphertext, nonce: nonce, mac: mac);

  final decrypted = await _aesGcm.decrypt(secretBox, secretKey: secretKey);

  return utf8.decode(decrypted);
}
