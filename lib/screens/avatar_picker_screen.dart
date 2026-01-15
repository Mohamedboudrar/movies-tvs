import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvatarPickerScreen extends StatelessWidget {
  const AvatarPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un avatar'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 20,
        itemBuilder: (context, index) {
          final avatarId = index + 1;

          return GestureDetector(
            onTap: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({'avatar': avatarId});

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage(
                'avatars/Memoji-$avatarId.png',
              ),
            ),
          );
        },
      ),
    );
  }
}
