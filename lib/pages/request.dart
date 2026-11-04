import 'package:flutter/material.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _Request();
}

class _Request extends State<Request> {
  String? _postName;
  String? _postDescription;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedLocation;
  File? selectedImage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, List<String>> categories = {
    "Electronics": ["Phone", "Laptop", "Headphones", "Other"],
    "Clothing": ["Shirt", "Jacket", "Pants", "Shoes", "Other"],
    "Accessories": ["Wallet", "Keys", "Watch", "Other"],
    "Jewellery": ["Necklace", "Ring", "Bracelet", "Other"],
    "Student Essentials": ["Textbooks", "Notebooks", "Other"],
    "Other": ["Other"],
  };

  final List<String> locations = [
    'Library',
    'Business Building',
    'Science Building',
    'Energy & Research Building',
    'SIRC',
    'Sha Hall',
    'Engineering Building',
    'Recreation Centre',
  ];

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post created successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),

      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10),
                child: Text("Title", style: TextStyle(fontSize: 18)),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: "What would you like to call this post?",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 3) {
                      return 'Please enter a title of at least 3 characters';
                    }
                    return null;
                  },

                  onSaved: (value) {
                    _postName = value;
                  },
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10),
                child: Text("Description", style: TextStyle(fontSize: 18)),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "Describe what you're looking for...",
                    // prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  maxLines: 3,
                  maxLength: 500,

                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 20) {
                      return 'Please be more descriptive';
                    }
                    return null;
                  },

                  onSaved: (value) {
                    _postDescription = value;
                  },
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10),
                child: Text(
                  "Category & Subcategory",
                  style: TextStyle(fontSize: 18),
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: "Select a category",
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),

                        items: categories.keys.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),

                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },

                        onChanged: (String? value) {
                          setState(() {
                            _selectedCategory = value;
                            _selectedSubcategory = null;
                          });
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsetsGeometry.only(
                        left: 10,
                        right: 10,
                      ),
                    ),

                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_selectedCategory),
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: "Select a subcategory",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        initialValue: _selectedSubcategory,
                        items: (categories[_selectedCategory] ?? []).map((
                          subcategory,
                        ) {
                          return DropdownMenuItem<String>(
                            value: subcategory,
                            child: Text(
                              subcategory,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),

                        validator: (value) {
                          if (value == null) {
                            return 'Please select a subcategory';
                          }
                          return null;
                        },

                        onChanged: _selectedCategory == null
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedSubcategory = value;
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10),
                child: Text(
                  "Last Known Location",
                  style: TextStyle(fontSize: 18),
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    hintText: "Location",
                    prefixIcon: Icon(Icons.location_on_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),

                  items: locations.map((location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),

                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLocation = newValue;
                    });
                  },
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10),
                child: Text("Upload Image", style: TextStyle(fontSize: 18)),
              ),

              InkWell(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: selectedImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 45,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text("Tap to upload an image"),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
                        ),
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 10, top: 19),
                child: Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text(
                      "Create Post",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
