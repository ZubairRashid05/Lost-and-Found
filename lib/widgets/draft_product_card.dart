import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lost_and_found/model/draft.dart';

class DraftProductCard extends StatelessWidget {
  const DraftProductCard({
    super.key,
    required this.draft,
    required this.onDelete,
    required this.onTap,
  });

  final RequestDraft draft;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        draft.imagePath != null && File(draft.imagePath!).existsSync();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: SizedBox(
          width: 72,
          height: 72,
          child: hasImage
              ? Image.file(File(draft.imagePath!), fit: BoxFit.cover)
              : const ColoredBox(
                  color: Color(0xFFEAF5FA),
                  child: Icon(Icons.drafts_outlined, size: 32),
                ),
        ),
        title: Text(
          draft.title.isEmpty ? 'Untitled draft' : draft.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          draft.description.isEmpty ? 'No description yet' : draft.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Delete draft',
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
