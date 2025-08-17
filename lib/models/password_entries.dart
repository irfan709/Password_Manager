import 'package:isar/isar.dart';
import 'package:password_manager/models/password_category.dart';

part 'password_entries.g.dart';

@collection
class PasswordEntries {
  Id id = Isar.autoIncrement;

  @Index()
  String? account;

  @Index()
  String? username;
  String? password;

  @enumerated
  late PasswordCategory category;
  String? notes;
  DateTime? createdAt;
}
