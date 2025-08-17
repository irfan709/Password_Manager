import 'package:isar/isar.dart';
import 'package:password_manager/models/password_entries.dart';

class PasswordsDatabase {
  final Isar _isar;

  PasswordsDatabase({required Isar isar}) : _isar = isar;

  Stream<List<PasswordEntries>> showPasswordsStream() {
    return _isar.passwordEntries.where().sortByCreatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  Future<void> addPassword(PasswordEntries password) async {
    await _isar.writeTxn(() => _isar.passwordEntries.put(password));
  }

  Future<void> updatePassword(PasswordEntries password) async {
    await _isar.writeTxn(() => _isar.passwordEntries.put(password));
  }

  Future<void> deletePassword(int id) async {
    await _isar.writeTxn(() => _isar.passwordEntries.delete(id));
  }

  Stream<List<PasswordEntries>> searchPasswordStream(String query) {
    return _isar.passwordEntries
        .filter()
        .group(
          (q) => q
              .accountContains(query, caseSensitive: false)
              .or()
              .usernameContains(query, caseSensitive: false),
        )
        .watch(fireImmediately: true);
  }
}
