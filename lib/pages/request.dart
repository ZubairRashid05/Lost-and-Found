import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found/model/draft.dart';
import 'package:lost_and_found/pages/draft.dart';

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _Request();
}

class _Request extends State<Request> {
  final _postName = TextEditingController();
  final _postDescription = TextEditingController();
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

  @override
  void dispose() {
    _postName.dispose();
    _postDescription.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _postName.clear();
      _postDescription.clear();
      _selectedCategory = null;
      _selectedSubcategory = null;
      _selectedLocation = null;
      selectedImage = null;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _saveDraft() async {
    final title = _postName.text.trim();
    final description = _postDescription.text.trim();

    // Prevent saving an empty draft
    if (title.isEmpty &&
        description.isEmpty &&
        _selectedCategory == null &&
        _selectedSubcategory == null &&
        _selectedLocation == null &&
        selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty draft.')),
      );
      return;
    }

    final draft = RequestDraft(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: _selectedCategory,
      subcategory: _selectedSubcategory,
      location: _selectedLocation,
      imagePath: selectedImage?.path,
      updatedAt: DateTime.now(),
    );

    await DraftStorage.save(draft);

    // Clear form after saving draft
    _clearForm();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved.')),
    );
  }

  Future<void> _openDrafts() async {
    final draft = await Navigator.push<RequestDraft>(
      context,
      MaterialPageRoute(builder: (_) => const DraftPage()),
    );
    if (draft == null || !mounted) return;

    setState(() {
      _postName.text = draft.title;
      _postDescription.text = draft.description;
      _selectedCategory = draft.category;
      _selectedSubcategory = draft.subcategory;
      _selectedLocation = draft.location;
      selectedImage =
          draft.imagePath != null && File(draft.imagePath!).existsSync()
              ? File(draft.imagePath!)
              : null;
    });
  }

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post created successfully!')),
    );

    _clearForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        actions: [
          IconButton(
            onPressed: _saveDraft,
            tooltip: 'Save draft',
            icon: const Icon(Icons.save_outlined),
          ),
          IconButton(
            onPressed: _openDrafts,
            tooltip: 'Open drafts',
            icon: const Icon(Icons.drafts_sharp),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("Title", style: TextStyle(fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: _postName,
                  decoration: const InputDecoration(
                    hintText: "What would you like to call this post?",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty || value.trim().length < 3) {
                      return 'Please enter a title of at least 3 characters';
                    }
                    return null;
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("Description", style: TextStyle(fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: _postDescription,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "Describe what you're looking for...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty || value.trim().length < 20) {
                      return 'Please be more descriptive (at least 20 characters)';
                    }
                    return null;
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Category & Subcategory",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCategory,
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
                    const SizedBox(width: 10),
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
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Last Known Location",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLocation,
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
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
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
                padding: const EdgeInsets.only(bottom: 10, top: 19),
                child: Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text(
                      "Create Post",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
