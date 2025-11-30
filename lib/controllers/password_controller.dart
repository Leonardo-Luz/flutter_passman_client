import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_passman_client/data/pass_dao.dart';
import 'package:flutter_passman_client/models/passentry.dart';
import 'package:flutter_passman_client/utils/crypt.dart';
import 'package:uuid/uuid.dart';

class PasswordController extends ChangeNotifier {
  final PasswordDao dao = PasswordDao();
  final Uuid uuid = Uuid();

  List<PassEntry> entries = [];
  bool loading = false;

  Future<void> loadPasswords() async {
    loading = true;
    notifyListeners();
    entries = await dao.getAll();
    loading = false;
    notifyListeners();
  }

  Future<void> loadPasswordsByService(String service) async {
    loading = true;
    notifyListeners();
    entries = await dao.getByService(service);
    loading = false;
    notifyListeners();
  }

  Future<void> addRawPassword({
    required String id,
    required String service,
    required String secret,
    required String? description,
  }) async {
    final entry = PassEntry(
      id: id,
      service: service,
      secret: secret,
      description: description,
    );

    await dao.insert(entry);
    entries.add(entry);

    notifyListeners();
  }

  Future<void> addPassword({
    required String service,
    required String masterPassword,
    required String plainPassword,
    required String description,
  }) async {
    final encrypted = await encrypt(masterPassword, plainPassword);
    final entry = PassEntry(
      id: uuid.v4(),
      service: service,
      secret: encrypted,
      description: description,
    );
    await dao.insert(entry);
    entries.add(entry);
    notifyListeners();
  }

  Future<String?> decryptPasswordForEntry({
    required String masterPassword,
    required String secret,
  }) async {
    try {
      return await decrypt(masterPassword, secret);
    } catch (_) {
      return null;
    }
  }

  Future<void> updatePassword({
    required String id,
    required String service,
    required String masterPassword,
    String? plainPassword,
    required String description,
  }) async {
    final index = entries.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw Exception("Password entry not found");
    }
    loading = true;
    notifyListeners();

    final oldEntry = entries[index];

    final encrypted = plainPassword != null && plainPassword.isNotEmpty
        ? await encrypt(masterPassword, plainPassword)
        : oldEntry.secret;

    final updatedEntry = PassEntry(
      id: id,
      service: service,
      secret: encrypted,
      description: description,
    );

    await dao.update(updatedEntry);
    entries[index] = updatedEntry;

    loading = false;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await dao.deleteById(id);
    entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await dao.deleteAll();
    entries.clear();
    notifyListeners();
  }

  Future<void> exportBackup({
    required String path,
    required String masterPassword,
  }) async {
    final all = await dao.getAll();
    final plainText = all
        .map((e) => "${e.id}|${e.service}|${e.secret}|${e.description ?? ""}")
        .join("\n");

    final encrypted = await encrypt(masterPassword, plainText);
    final file = File(path);
    await file.writeAsString(encrypted);
  }

  Future<bool> importBackup({
    required String path,
    required String masterPassword,
  }) async {
    final file = File(path);
    if (!await file.exists()) return false;

    final encrypted = await file.readAsString();

    String decrypted;
    try {
      decrypted = await decrypt(masterPassword, encrypted);
    } catch (_) {
      return false;
    }

    for (final line in decrypted.split("\n")) {
      if (line.trim().isEmpty) continue;

      final parts = line.split("|");
      if (parts.length < 3) continue;

      final id = parts[0];
      final service = parts[1];
      final secret = parts[2];
      final description = parts.length >= 4 && parts[3].isNotEmpty
          ? parts[3]
          : null;

      final entry = PassEntry(
        id: id,
        service: service,
        secret: secret,
        description: description,
      );

      await dao.insert(entry);
    }

    await loadPasswords();
    return true;
  }

  int getPasswordsQty() => entries.length;
}
