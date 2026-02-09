import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Password hasher utility for client-side password hashing.
///
/// Uses SHA-256 to pre-hash passwords before sending to the server.
/// This provides defense-in-depth - the plaintext password never
/// leaves the client, even over HTTPS.
class PasswordHasher {
  /// Hash a password using SHA-256.
  ///
  /// Returns a hex-encoded hash string.
  static String hash(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
