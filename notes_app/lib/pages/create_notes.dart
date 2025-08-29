import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// AddNotesPage StatefulWidget for adding new notes
class AddNotesPage extends StatefulWidget {
  const AddNotesPage({super.key});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

// State class for AddNotesPage
class _AddNotesPageState extends State<AddNotesPage> {
  // Controllers for title and content input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Loading state for save button
  bool _isLoading = false;

  // Formats DateTime to a readable timestamp string
  String _formatTimestamp(DateTime dt) {
    final day = dt.day;
    String suffix = 'th';
    if (day % 10 == 1 && day != 11)
      suffix = 'st';
    else if (day % 10 == 2 && day != 12)
      suffix = 'nd';
    else if (day % 10 == 3 && day != 13)
      suffix = 'rd';
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day$suffix $month $year - $hour:$minute';
  }

  // Saves the note to Firebase Realtime Database
  Future<void> _saveNote() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Note cannot be empty')));
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final DatabaseReference notesRef = FirebaseDatabase.instance.ref(
      'users/${user.uid}/notes',
    );
    final now = DateTime.now();
    await notesRef.push().set({
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'timestamp': _formatTimestamp(now),
    });
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  // Builds the UI for the Add Notes page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar with shadow and color
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color(0xFF3CB371)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Add Notes',
              style: TextStyle(
                color: Color(0xFF3CB371),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      backgroundColor: Color(0xFFFAFAFA),
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
                color: Color(0xFF3CB371).withOpacity(0.08),
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
                color: Color(0xFFFF7F50).withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main content container
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title input field
                      TextField(
                        controller: _titleController,
                        cursorColor: Color(0xFF3CB371),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Color(0xFF9E9E9E)),
                          filled: true,
                          fillColor: Color(0xFFF0F4F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Color(0xFF1A1A1A)),
                      ),
                      SizedBox(height: 16),
                      // Content input field
                      TextField(
                        controller: _contentController,
                        cursorColor: Color(0xFF3CB371),
                        decoration: InputDecoration(
                          labelText: 'Content',
                          labelStyle: TextStyle(color: Color(0xFF9E9E9E)),
                          filled: true,
                          fillColor: Color(0xFFF0F4F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Color(0xFF1A1A1A)),
                        maxLines: 5,
                      ),
                      SizedBox(height: 24),
                      // Save Note button with loading indicator
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3CB371),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Color(0xFF3CB371),
                            disabledForegroundColor: Colors.white,
                          ),
                          onPressed: _saveNote,
                          child: SizedBox(
                            height: 24,
                            child: Center(
                              child:
                                  _isLoading
                                      ? CircularProgressIndicator(
                                        color: Color(0xFFFF7F50),
                                        strokeWidth: 3,
                                      )
                                      : Text(
                                        'Save Note',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
