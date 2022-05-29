import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage{
  static const _storage = FlutterSecureStorage();
  static const String usernameKey = 'username';
  static const String passwordKey = 'password';

  static Future setUsername(String username) async =>
      await _storage.write(key: usernameKey, value: username);

  static Future setPassword(String password) async =>
      await _storage.write(key: passwordKey, value: password);

  static Future<String?> getUsername() async =>
      await _storage.read(key: usernameKey);

  static Future<String?> getPassword() async =>
      await _storage.read(key: passwordKey);

  static Future deleteAll() async => await _storage.deleteAll();
}