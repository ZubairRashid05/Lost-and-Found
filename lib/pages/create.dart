import 'package:flutter/material.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found/model/draft.dart';
import 'package:lost_and_found/pages/draft.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _Request();
}

class _Request extends State<Request> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _postName;
  String? _postDescription;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedLocation;
  File? selectedImage;
  File? selectedImage2;

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
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _selectedCategory = null;
      _selectedSubcategory = null;
      _selectedLocation = null;
      selectedImage = null;
      selectedImage2 = null;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _saveDraft() async {
    final title = _nameController.text.trim();
    final description = _descriptionController.text.trim();

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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Draft saved.')));
  }

  Future<void> _openDrafts() async {
    final draft = await Navigator.push<RequestDraft>(
      context,
      MaterialPageRoute(builder: (_) => const DraftPage()),
    );
    if (draft == null || !mounted) return;

    setState(() {
      _nameController.text = draft.title;
      _descriptionController.text = draft.description;
      _selectedCategory = draft.category;
      _selectedSubcategory = draft.subcategory;
      _selectedLocation = draft.location;
      selectedImage =
          draft.imagePath != null && File(draft.imagePath!).existsSync()
          ? File(draft.imagePath!)
          : null;
    });
  }

  Future<void> pickImage({bool isSecond = false}) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        if (isSecond) {
          selectedImage2 = File(image.path);
        } else {
          selectedImage = File(image.path);
        }
      });
    }
  }

  Future<String> uploadImage(File image) async {
    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_${image.uri.pathSegments.last}';

    final path = 'posts/$fileName';

    await supabase.storage.from('post_images').upload(path, image);

    final imageUrl = supabase.storage.from('post_images').getPublicUrl(path);

    return imageUrl;
  }

  Future<void> savePost() async {
    // Upload images if they exist
    String? image1Url;
    String? image2Url;

    if (selectedImage != null) {
      image1Url = await uploadImage(selectedImage!);
    }

    if (selectedImage2 != null) {
      image2Url = await uploadImage(selectedImage2!);
    }

    // Insert all post details into Supabase
    final userId = supabase.auth.currentUser?.id;
    final Map<String, dynamic> postData = {
      'name': _postName,
      'description': _postDescription,
      'category': _selectedCategory,
      'subcategory': _selectedSubcategory,
      'last_location': _selectedLocation,
      'image1_url': image1Url,
      'image2_url': image2Url,
    };
    if (userId != null) {
      postData['user_id'] = userId;
    }

    await supabase.from('products').insert(postData);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await savePost();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

      _clearForm();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving post: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                  controller: _nameController,
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
                  maxLength: 30,

                  onSaved: (value) {
                    _postName = value;
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
                  controller: _descriptionController,
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
                    if (value == null || value.isEmpty || value.length < 5) {
                      return 'Please be more descriptive';
                    }
                    return null;
                  },

                  onSaved: (value) {
                    _postDescription = value;
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

              Row(
                children: [
                  Expanded(
                    child: selectedImage == null
                        ? InkWell(
                            onTap: () => pickImage(isSecond: false),
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 35,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Upload an image",
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 16,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedImage = null;
                                        selectedImage2 = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: selectedImage2 != null
                        ? Stack(
                            children: [
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedImage2!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 16,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedImage2 = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: selectedImage != null
                                ? () => pickImage(isSecond: true)
                                : null,
                            child: Opacity(
                              opacity: selectedImage != null ? 1.0 : 0.4,
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 35,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Upload another image",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 19),
                child: Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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
