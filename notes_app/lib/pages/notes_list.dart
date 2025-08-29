import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_notes.dart';
import 'edit_notes.dart';
import 'login.dart';

// Main page to display all notes for the logged-in user
class DisplayNotesPage extends StatelessWidget {
  const DisplayNotesPage({super.key});

  // Handles user logout and navigation to login page
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      // AppBar with title and logout button
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: AppBar(
            title: const Text(
              'Your Notes',
              style: TextStyle(
                color: Color(0xFF3CB371),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Color(0xFF3CB371)),
                onPressed: () => _logout(context),
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Decorative top-right circle
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFF3CB371).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Decorative bottom-left circle
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7F50).withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main column for divider and notes list
          Column(
            children: [
              // Divider below AppBar
              const Divider(
                thickness: 1.2,
                color: Color(0xFFF0F4F8),
                height: 0,
              ),
              Expanded(
                child:
                    user == null
                        // Show message if no user is logged in
                        ? const Center(
                          child: Text(
                            'No user logged in',
                            style: TextStyle(color: Color(0xFF1A1A1A)),
                          ),
                        )
                        // StreamBuilder to listen for notes changes in Firebase
                        : StreamBuilder<DatabaseEvent>(
                          stream:
                              FirebaseDatabase.instance
                                  .ref('users/${user.uid}/notes')
                                  .onValue,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Show loading indicator while waiting for data
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF3CB371),
                                ),
                              );
                            }
                            final notesMap =
                                snapshot.data?.snapshot.value
                                    as Map<dynamic, dynamic>?;

                            if (notesMap == null || notesMap.isEmpty) {
                              // Show message if no notes exist
                              return Center(
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  color: const Color(0xFFFFFFFF),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.10),
                                          blurRadius: 16,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      color: Colors.white,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 40,
                                      ),
                                      child: Text(
                                        'No notes yet. Add your first note!',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF3CB371),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Convert notes map to list for display
                            final notesList =
                                notesMap.entries
                                    .map((e) => {...?e.value, 'key': e.key})
                                    .toList();

                            // ListView to display each note
                            return ListView.builder(
                              padding: const EdgeInsets.all(18),
                              itemCount: notesList.length,
                              itemBuilder: (context, index) {
                                final note = notesList[index];
                                final timeStr = note['timestamp'] ?? '';
                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: const Color(0xFFFFFFFF),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.10),
                                          blurRadius: 16,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      color: Colors.white,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 18,
                                          ),
                                      // Note title
                                      title: Text(
                                        note['title'] ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFF1A1A1A),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      // Note content and timestamp
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 6),
                                          Text(
                                            note['content'] ?? '',
                                            style: const TextStyle(
                                              color: Color(0xFF4B4B4B),
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (timeStr.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10.0,
                                              ),
                                              child: Text(
                                                '$timeStr',
                                                style: const TextStyle(
                                                  color: Color(0xFF9E9E9E),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      // Edit and Delete buttons for each note
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => EditNotePage(
                                                          noteKey: note['key'],
                                                          initialTitle:
                                                              note['title'] ??
                                                              '',
                                                          initialContent:
                                                              note['content'] ??
                                                              '',
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Color(0xFF3CB371),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () async {
                                                // Show confirmation dialog before deleting note
                                                final confirm = await showDialog<
                                                  bool
                                                >(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFFE6FFED,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          side:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xFF3CB371,
                                                                ),
                                                              ),
                                                        ),
                                                        title: const Text(
                                                          'Delete Note',
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFF1A1A1A,
                                                            ),
                                                          ),
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to delete this note?',
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFF1A1A1A,
                                                            ),
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  const Color(
                                                                    0xFF9E9E9E,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        24,
                                                                    vertical:
                                                                        10,
                                                                  ),
                                                              textStyle:
                                                                  const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                            ),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                            child: const Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        24,
                                                                    vertical:
                                                                        10,
                                                                  ),
                                                              textStyle:
                                                                  const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                            ),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(true),
                                                            child: const Text(
                                                              'Delete',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                                if (confirm == true) {
                                                  await FirebaseDatabase
                                                      .instance
                                                      .ref(
                                                        'users/${user.uid}/notes/${note['key']}',
                                                      )
                                                      .remove();
                                                }
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ],
      ),
      // Floating action button to add a new note
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3CB371),
        foregroundColor: Colors.white,
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNotesPage()),
          );
        },
      ),
    );
  }
}
