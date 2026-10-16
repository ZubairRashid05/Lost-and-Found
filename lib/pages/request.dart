import 'package:flutter/material.dart';

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _Request();
}

class _Request extends State<Request> {
  String? category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),

      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 12, right: 12, top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 10),
              child: Text("Title", style: TextStyle(fontSize: 18)),
            ),

            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 10),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "What would you like to call this post?",
                  prefixIcon: Icon(Icons.title),
                  // labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 10),
              child: Text("Description", style: TextStyle(fontSize: 18)),
            ),

            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 10),
              child: TextField(
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "Describe what you're looking for",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 10),
              child: Text("Category", style: TextStyle(fontSize: 18)),
            ),

            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 10),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: "Select a category",
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                items:
                    [
                      'Clothing',
                      'Electronics',
                      'Student Essentials (e.g. textbooks, notebooks, etc)',
                      'Other',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    category = newValue;
                  });
                },
              ),
            ),

            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 10, top: 10),
              child: Container(
                alignment: Alignment.center,
                child: ElevatedButton(onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
