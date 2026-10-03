import 'package:cashflo/screens/add_flo_screen.dart';
import 'package:cashflo/screens/join_flo_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/create_flo_grid.dart';

class CreateFloScreen extends StatefulWidget {
  const CreateFloScreen({super.key});

  static const String id = "create_flo";

  @override
  State<CreateFloScreen> createState() => _CreateFloScreenState();
}

class _CreateFloScreenState extends State<CreateFloScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _username;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkUsername();
  }

  Future<void> _checkUsername() async {
    User? user = _auth.currentUser;
    user ??= (await _auth.signInAnonymously()).user;

    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data()?['username'] != null) {
      setState(() {
        _username = doc.data()!['username'] as String;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUsernameDialog(user!.uid);
      });
    }
  }

  Future<void> _showUsernameDialog(String uid) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Enter your name"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Your name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff087E8B),
              ),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                await _firestore.collection('users').doc(uid).set(
                  {
                    'user_id': uid,
                    'username': name,
                  },
                  SetOptions(merge: true),
                );

                if (mounted) {
                  setState(() => _username = name);
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF5F5F5),
        body: Column(
          children: [
            _buildGreeting(),
            Expanded(child: CreateFloGrid()),
          ],
        ),
        bottomNavigationBar: Container(
          color: const Color(0xffF5F5F5),
          height: 79,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => AddFloScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff087E8B),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    "Create",
                    style: kButtonTextStyle,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => JoinFloScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff087E8B),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    "Join",
                    style: kButtonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_username == null) {
      // Dialog is about to show; keep the space reserved but empty.
      return const SizedBox(height: 24);
    }

    final initial =
        _username!.trim().isNotEmpty ? _username!.trim()[0].toUpperCase() : "?";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xff087E8B),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Hello! $_username",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Color(0xff1A1A1A),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Welcome back",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
