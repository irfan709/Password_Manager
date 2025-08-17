import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_manager/logic/password_bloc/password_bloc.dart';
import 'package:password_manager/logic/password_bloc/password_event.dart';
import 'package:password_manager/logic/password_bloc/password_state.dart';
import 'package:password_manager/screens/edit_password.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PasswordBloc>().add(const PasswordsFetchEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final verticalSpacing = size.height * 0.02;
    return Scaffold(
      appBar: AppBar(
        title: Text("Password Manager", style: GoogleFonts.roboto()),
        actions: [
          IconButton(
            onPressed: () async {
              await showSearch<String>(
                context: context,
                delegate: CustomSearchDelegate(),
              );
              if (context.mounted) {
                context.read<PasswordBloc>().add(const PasswordsFetchEvent());
              }
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: verticalSpacing),
          Text(
            "Your passwords",
            style: GoogleFonts.roboto(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: verticalSpacing),
          Expanded(
            child: BlocBuilder<PasswordBloc, PasswordState>(
              builder: (context, state) {
                if (state is PasswordLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PasswordError) {
                  return Center(
                    child: Text(
                      state.error,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                if (state is PasswordLoaded) {
                  final passwords = state.passwords;
                  if (passwords.isEmpty) {
                    return Center(
                      child: Text(
                        "You haven't added any passwords yet",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: passwords.length,
                    itemBuilder: (context, index) {
                      final password = passwords[index];
                      return ListTile(
                        title: Text(
                          password.account ?? 'No Account',
                          style: GoogleFonts.roboto(),
                        ),
                        subtitle: Text(
                          password.username ?? 'No Username',
                          style: GoogleFonts.poppins(),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPassword(password: password),
                            ),
                          );
                        },
                        onLongPress: () async {
                          final confirmed = await _confirmDelete(context);
                          if (confirmed && context.mounted) {
                            context.read<PasswordBloc>().add(
                              DeletePasswordEvent(id: password.id),
                            );
                          }
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const EditPassword()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Reusable delete confirmation dialog
  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Password"),
            content: const Text(
              "Are you sure you want to delete this password?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    return result ?? false;
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        query = '';
        BlocProvider.of<PasswordBloc>(
          context,
        ).add(const SearchPasswordEvent(query: ''));
        showSuggestions(context);
      },
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      BlocProvider.of<PasswordBloc>(
        context,
      ).add(SearchPasswordEvent(query: query));
    }
    return BlocBuilder<PasswordBloc, PasswordState>(
      builder: (context, state) {
        if (query.isEmpty) {
          return const Center(child: Text('Please enter something to search.'));
        }
        if (state is PasswordLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PasswordError) {
          return Center(child: Text(state.error));
        }
        if (state is PasswordLoaded) {
          final results = state.passwords;
          if (results.isEmpty) {
            return const Center(child: Text('No results found.'));
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final password = results[index];
              return ListTile(
                title: Text(password.account ?? "No Account"),
                subtitle: Text(password.username ?? "No Username"),
                onTap: () {
                  close(context, query);
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPassword(password: password),
                    ),
                  );
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      BlocProvider.of<PasswordBloc>(
        context,
      ).add(SearchPasswordEvent(query: query));
    }
    return BlocBuilder<PasswordBloc, PasswordState>(
      builder: (context, state) {
        if (query.isEmpty) {
          return const Center(child: Text('Start typing to search...'));
        }
        if (state is PasswordLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PasswordError) {
          return Center(child: Text(state.error));
        }
        if (state is PasswordLoaded) {
          final suggestions = state.passwords;
          if (suggestions.isEmpty) {
            return const Center(child: Text('No suggestions available.'));
          }
          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final password = suggestions[index];
              return ListTile(
                title: Text(password.account ?? "No Account"),
                subtitle: Text(password.username ?? "No Username"),
                onTap: () {
                  query = password.account ?? '';
                  showResults(context);
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
