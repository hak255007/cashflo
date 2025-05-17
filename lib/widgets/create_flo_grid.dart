import 'package:cashflo/constants.dart';
import 'package:cashflo/screens/home_screen.dart';
import 'package:cashflo/widgets/delete_flo_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

final _firestore = FirebaseFirestore.instance;

class CreateFloGrid extends StatelessWidget {
  const CreateFloGrid({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> getFloStream(String userId) {
    return _firestore
        .collection(kFloCollection)
        .where('flo_users', arrayContains: userId)
        .orderBy('flo_created_at', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("No user signed in."));
    }

    final userId = user.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: getFloStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final floDocs = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // 4 columns
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 3, // square boxes
          ),
          itemCount: floDocs.length,
          itemBuilder: (context, index) {
            final flo = floDocs[index].data();
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate or open details using flo['flo_uuid']
                    Navigator.pushNamed(
                      context,
                      HomeScreen.id,
                      arguments: {
                        'flo_id': flo['flo_id'],
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff5DB8B8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      flo['flo_title'] ?? 'Unnamed',
                      textAlign: TextAlign.center,
                      style: kFloTitleTextStyle,
                    ),
                  ),
                ),

                // Share icon (only for creator)
                if (flo['flo_created_by'] == userId)
                  Positioned(
                    bottom: -9,
                    right: 25,
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        SharePlus.instance.share(ShareParams(
                            text:
                                """💸 Hey! Check out my Flo on CashFlo and track expenses like a boss!
Join using my Flo ID:
📎 ${flo['flo_id']}
1.) Open Cashflo
2.) Click Join
3.) Enter the above Flo ID to join"""));
                      },
                    ),
                  ),

                // Show the delete button only to the users who created the flo
                if (flo['flo_created_by'] == userId)
                  Positioned(
                      bottom: -9,
                      right: -5,
                      child: DeleteFloButton(docId: floDocs[index].id)),
              ],
            );
          },
        );
      },
    );
  }
}
