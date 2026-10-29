import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Settings")),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Profile Settings section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'User name',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email@email.com',

                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                          left: 24,
                          right: 24,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  const snackBar = SnackBar(
                                    content: Text('Save changes pressed'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Save changes"),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  const snackBar = SnackBar(
                                    content: Text('Logged out'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
