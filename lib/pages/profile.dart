import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Profile Settings section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    "Profile Settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        buildProfileTile(
                          title: 'Account Name',
                          subtitle: 'John Doe',
                          icon: Icons.person,
                        ),
                        const Divider(height: 1),
                        buildProfileTile(
                          title: 'Change Email',
                          subtitle: 'john.doe@email.com',
                          icon: Icons.email,
                        ),
                        const Divider(height: 1),
                        buildProfileTile(
                          title: 'Change Password',
                          subtitle: '********',
                          icon: Icons.lock,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Fixed bottom buttons raised above the floating navigation bar
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        const snackBar = SnackBar(content: Text('Edit Profile pressed'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Edit Profile"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        const snackBar = SnackBar(content: Text('Logged out'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Logout", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      // // trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      // onTap: onTap,
    );
  }
}
