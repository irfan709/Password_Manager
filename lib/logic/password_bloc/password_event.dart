import 'package:flutter/foundation.dart';
import 'package:password_manager/models/password_entries.dart';

@immutable
sealed class PasswordEvent {
  const PasswordEvent();
}

final class PasswordsFetchEvent extends PasswordEvent {
  const PasswordsFetchEvent();
}

final class AddPasswordsEvent extends PasswordEvent {
  final PasswordEntries password;

  const AddPasswordsEvent({required this.password});
}

final class UpdatePasswordEvent extends PasswordEvent {
  final PasswordEntries password;

  const UpdatePasswordEvent({required this.password});
}

final class DeletePasswordEvent extends PasswordEvent {
  final int id;

  const DeletePasswordEvent({required this.id});
}

final class SearchPasswordEvent extends PasswordEvent {
  final String query;

  const SearchPasswordEvent({required this.query});
}
