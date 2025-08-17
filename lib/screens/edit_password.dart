import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_manager/logic/password_bloc/password_bloc.dart';
import 'package:password_manager/logic/password_bloc/password_event.dart';
import 'package:password_manager/models/password_category.dart';
import 'package:password_manager/models/password_entries.dart';

import '../services/encryption_service.dart';

class EditPassword extends StatefulWidget {
  final PasswordEntries? password;

  const EditPassword({super.key, this.password});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  late final TextEditingController _accountNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _noteController;

  bool isPasswordVisible = false;
  String? category;

  @override
  void initState() {
    super.initState();

    _accountNameController = TextEditingController(
      text: widget.password?.account ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.password?.username ?? '',
    );
    _passwordController = TextEditingController();
    _noteController = TextEditingController(text: widget.password?.notes ?? '');
    category =
        widget.password?.category.name ?? PasswordCategory.values.first.name;

    if (widget.password != null && widget.password!.password != null) {
      EncryptionService.decryptText(widget.password!.password!)
          .then((decryptedPassword) {
        if (!mounted) return;
        setState(() {
          _passwordController.text = decryptedPassword;
        });
      })
          .catchError((error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error decrypting password: $error")),
        );
      });
    }
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    final account = _accountNameController.text.trim();
    final username = _usernameController.text.trim();
    final plainText = _passwordController.text.trim();
    final note = _noteController.text.trim();
    final now = DateTime.now();

    if (account.isEmpty || username.isEmpty || plainText.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    final encryptedPassword = await EncryptionService.encryptText(plainText);
    final selectedCategory = PasswordCategory.values.firstWhere(
          (c) => c.name == category,
      orElse: () => PasswordCategory.others,
    );

    if (!mounted) return;
    final bloc = context.read<PasswordBloc>();

    if (widget.password == null) {
      final newPassword =
      PasswordEntries()
        ..account = account
        ..username = username
        ..password = encryptedPassword
        ..category = selectedCategory
        ..notes = note
        ..createdAt = now;

      bloc.add(AddPasswordsEvent(password: newPassword));
    } else {
      final updatedPassword =
      PasswordEntries()
        ..id = widget.password!.id
        ..account = account
        ..username = username
        ..password = encryptedPassword
        ..category = selectedCategory
        ..notes = note
        ..createdAt = now;

      bloc.add(UpdatePasswordEvent(password: updatedPassword));
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final horizontalSpacing = size.width * 0.8;
    final verticalSpacing = size.height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.password == null ? "Add Password" : "Edit Password",
          style: GoogleFonts.roboto(),
        ),
        actions: [
          IconButton(onPressed: _savePassword, icon: const Icon(Icons.save)),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(
                  width: horizontalSpacing,
                  child: TextField(
                    controller: _accountNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Account name (e.g. Netflix)",
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                SizedBox(
                  width: horizontalSpacing,
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Username",
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                SizedBox(
                  width: horizontalSpacing,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Password",
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            tooltip:
                            isPasswordVisible
                                ? 'Hide password'
                                : 'Show password',
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _passwordController.text),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Password copied to clipboard"),
                                ),
                              );
                            },
                            tooltip: "Copy password",
                            icon: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                SizedBox(
                  width: horizontalSpacing,
                  child: DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                    items:
                    PasswordCategory.values
                        .map(
                          (cat) =>
                          DropdownMenuItem<String>(
                            value: cat.name,
                            child: Text(cat.name),
                          ),
                    )
                        .toList(),
                    onChanged: (value) => setState(() => category = value),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                SizedBox(
                  width: horizontalSpacing,
                  height: size.height * 0.25,
                  child: TextField(
                    controller: _noteController,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Note",
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
