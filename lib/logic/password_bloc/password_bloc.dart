import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/database/passwords_database.dart';
import 'package:password_manager/logic/password_bloc/password_event.dart';
import 'package:password_manager/logic/password_bloc/password_state.dart';
import 'package:password_manager/models/password_entries.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  final PasswordsDatabase database;

  PasswordBloc({required this.database}) : super(const PasswordInitial()) {
    on<PasswordsFetchEvent>(_onFetchPasswords);
    on<SearchPasswordEvent>(_onSearchPassword);
    on<AddPasswordsEvent>(_onAddPassword);
    on<UpdatePasswordEvent>(_onUpdatePassword);
    on<DeletePasswordEvent>(_onDeletePassword);
  }

  Future<void> _onFetchPasswords(
    PasswordsFetchEvent event,
    Emitter<PasswordState> emit,
  ) async {
    emit(const PasswordLoading());
    await emit.forEach<List<PasswordEntries>>(
      database.showPasswordsStream(),
      onData: (passwords) => PasswordLoaded(passwords: passwords),
      onError: (error, _) => PasswordError(error: error.toString()),
    );
  }

  Future<void> _onSearchPassword(
    SearchPasswordEvent event,
    Emitter<PasswordState> emit,
  ) async {
    emit(const PasswordLoading());
    await emit.forEach<List<PasswordEntries>>(
      database.searchPasswordStream(event.query),
      onData: (passwords) => PasswordLoaded(passwords: passwords),
      onError: (error, _) => PasswordError(error: error.toString()),
    );
  }

  Future<void> _onAddPassword(
    AddPasswordsEvent event,
    Emitter<PasswordState> emit,
  ) async {
    emit(const PasswordLoading());
    try {
      await database.addPassword(event.password);
    } catch (e) {
      emit(PasswordError(error: e.toString()));
    }
  }

  Future<void> _onUpdatePassword(
    UpdatePasswordEvent event,
    Emitter<PasswordState> emit,
  ) async {
    emit(const PasswordLoading());
    try {
      await database.updatePassword(event.password);
    } catch (e) {
      emit(PasswordError(error: e.toString()));
    }
  }

  Future<void> _onDeletePassword(
    DeletePasswordEvent event,
    Emitter<PasswordState> emit,
  ) async {
    emit(const PasswordLoading());
    try {
      await database.deletePassword(event.id);
    } catch (e) {
      emit(PasswordError(error: e.toString()));
    }
  }
}
