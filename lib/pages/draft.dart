import 'package:flutter/material.dart';
import 'package:lost_and_found/model/draft.dart';
import 'package:lost_and_found/widgets/draft_product_card.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  List<RequestDraft> drafts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    try {
      final loadedDrafts = await DraftStorage.load();
      if (!mounted) return;
      setState(() {
        drafts = loadedDrafts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _deleteDraft(RequestDraft draft) async {
    await DraftStorage.delete(draft.id);
    if (!mounted) return;
    await _loadDrafts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drafts')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text('Could not load drafts: $errorMessage'));
    }

    if (drafts.isEmpty) {
      return const Center(child: Text('No saved drafts yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var draft in drafts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
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
