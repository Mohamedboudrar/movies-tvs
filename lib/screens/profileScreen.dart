import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'avatar_picker_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              /// AVATAR
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AvatarPickerScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.deepPurple,
                    backgroundImage: data != null && data['avatar'] != null
                        ? AssetImage(
                      'avatars/Memoji-${data['avatar']}.png',
                    )
                        : null,
                    child: data == null || data['avatar'] == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
              ),


              const SizedBox(height: 16),

              /// NAME
              Center(
                child: Text(
                  data?['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// INFO CARD
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [

                    _infoTile(
                      icon: Icons.email,
                      label: 'Email',
                      value: user.email ?? '-',
                    ),
                    const Divider(height: 1),
                    _infoTile(
                      icon: Icons.favorite,
                      label: 'Favoris',
                      value: data != null
                          ? (data['favouritesCount']?.toString() ?? '0')
                          : '0',
                    ),
                    const Divider(height: 1),
                    _infoTile(
                      icon: Icons.calendar_today,
                      label: 'Compte créé',
                      value: user.metadata.creationTime != null
                          ? user.metadata.creationTime!
                          .toLocal()
                          .toString()
                          .split(' ')
                          .first
                          : '-',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label),
      subtitle: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
