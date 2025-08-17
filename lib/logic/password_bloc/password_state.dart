import 'package:flutter/foundation.dart';
import 'package:password_manager/models/password_entries.dart';

@immutable
sealed class PasswordState {
  const PasswordState();
}

final class PasswordInitial extends PasswordState {
  const PasswordInitial();
}

final class PasswordLoading extends PasswordState {
  const PasswordLoading();
}

final class PasswordLoaded extends PasswordState {
  final List<PasswordEntries> passwords;

  const PasswordLoaded({required this.passwords});
}

final class PasswordError extends PasswordState {
  final String error;

  const PasswordError({required this.error});
}
