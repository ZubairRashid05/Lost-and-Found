import 'package:flutter/material.dart';
import 'package:lost_and_found/model/draft.dart';
import 'package:lost_and_found/widgets/draft_product_card.dart';

// Page for viewing and managing drafts
class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

// Draft page state
class _DraftPageState extends State<DraftPage> {
  // Variables for drafts
  List<RequestDraft> drafts = [];
  bool isLoading = true;
  String? errorMessage;

  // Load drafts on initialization
  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  // Function to load the drafts
  Future<void> _loadDrafts() async {
    try {
      // Loading drafts from local storage
      final loadedDrafts = await DraftStorage.load();
      if (!mounted) return;
      // Update the state with the loaded drafts
      setState(() {
        drafts = loadedDrafts;
        isLoading = false;
      });
      // If there are no drafts, show a message and set isLoading to false
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Function to delete drafts
  Future<void> _deleteDraft(RequestDraft draft) async {
    // Delete the draft from local storage and update the state
    await DraftStorage.delete(draft.id);
    if (!mounted) return;
    await _loadDrafts();
  }

  // Build the draft page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drafts')),
      body: _buildBody(),
    );
  }

  // Build the body of the draft page
  Widget _buildBody() {
    // If the page is loading, show a loading indicator
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // If there was an error loading the drafts, show an error message
    if (errorMessage != null) {
      return Center(child: Text('Could not load drafts: $errorMessage'));
    }

    // If there are no drafts, show a message
    if (drafts.isEmpty) {
      return const Center(child: Text('No saved drafts yet.'));
    }

    // Otherwise, show the list of drafts
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Iterating through all drafts
        for (var draft in drafts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            // Create a card for each draft
            child: DraftProductCard(
              draft: draft,
              onDelete: () => _deleteDraft(draft),
              onTap: () => Navigator.pop(context, draft),
            ),
          ),
      ],
    );
  }
}
