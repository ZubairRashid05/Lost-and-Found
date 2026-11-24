import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found/model/user.dart';
import 'package:lost_and_found/services/user_service.dart';
import 'package:lost_and_found/widgets/text_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  final String? conversationId;
  final String otherUserId;
  final String? productId;

  const ChatPage({
    super.key,
    this.conversationId,
    required this.otherUserId,
    this.productId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _supabase = Supabase.instance.client;
  final _messageController = TextEditingController();
  String? _conversationId;
  bool _isSending = false;
  UserProfile? _otherUser;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _loadOtherUser();
  }

  Future<void> _loadOtherUser() async {
    debugPrint('Loading chat user: ${widget.otherUserId}');
    final user = await UserService.getUser(widget.otherUserId);
    if (!mounted) return;

    setState(() {
      _otherUser = user;
    });
  }

  Stream<List<Map<String, dynamic>>>? get _messagesStream {
    final conversationId = _conversationId;
    if (conversationId == null) return null;

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
  }

  Future<String> _createConversation(String currentUserId) async {
    final participantIds = [currentUserId, widget.otherUserId]..sort();

    if (widget.productId != null) {
      final existing = await _supabase
          .from('conversations')
          .select('id')
          .eq('product_id', widget.productId!)
          .eq('user_one', participantIds[0])
          .eq('user_two', participantIds[1])
          .maybeSingle();

      final existingId = existing?['id'] as String?;
      if (existingId != null) return existingId;
    }

    final created = await _supabase
        .from('conversations')
        .insert({
          'product_id': widget.productId,
          'user_one': participantIds[0],
          'user_two': participantIds[1],
        })
        .select('id')
        .single();

    return created['id'] as String;
  }

  Future<String> _uploadChatImage(File image, String conversationId) async {
    final user = UserService.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to send images.');
    }

    final extension = image.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().microsecondsSinceEpoch}.$extension';
    final path = 'chat/$conversationId/${user.id}/$fileName';

    // Reuse the app's existing public image bucket.
    await _supabase.storage.from('post_images').upload(path, image);
    return _supabase.storage.from('post_images').getPublicUrl(path);
  }

  Future<String> _getOrCreateConversation(String currentUserId) async {
    if (_conversationId != null) return _conversationId!;

    final conversationId = await _createConversation(currentUserId);
    _conversationId = conversationId;
    return conversationId;
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final text = _messageController.text.trim();
    final user = UserService.currentUser;
    if ((text.isEmpty && imageUrl == null) || user == null || _isSending) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final conversationId = await _getOrCreateConversation(user.id);

      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': user.id,
        'body': text,
        'image_url': imageUrl,
      });

      await _supabase
          .from('conversations')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);

      _messageController.clear();
      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send message: $error')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_isSending) return;

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null || !mounted) return;

    setState(() => _isSending = true);

    try {
      final user = UserService.currentUser;
      if (user == null) {
        throw StateError('You must be signed in to send images.');
      }

      final conversationId = await _getOrCreateConversation(user.id);
      final imageUrl = await _uploadChatImage(File(image.path), conversationId);

      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': user.id,
        'body': '',
        'image_url': imageUrl,
      });

      await _supabase
          .from('conversations')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send image: $error')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = UserService.currentUser?.id;
    final messagesStream = _messagesStream;

    return Scaffold(
      appBar: AppBar(title: Text(_otherUser?.username ?? 'Unknown user')),
      body: Column(
        children: [
          // Text(_otherUser!.username),
          Expanded(
            child: messagesStream == null
                ? const Center(child: Text('Start the conversation.'))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: messagesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Could not load messages.'),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = [...snapshot.data!]
                        ..sort((a, b) {
                          final first = DateTime.parse(
                            a['created_at'] as String,
                          );
                          final second = DateTime.parse(
                            b['created_at'] as String,
                          );
                          return first.compareTo(second);
                        });

                      if (messages.isEmpty) {
                        return const Center(
                          child: Text('Start the conversation.'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMine = message['sender_id'] == currentUserId;

                          return Align(
                            alignment: isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.sizeOf(context).width * 0.78,
                              ),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isMine
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextMessage(
                                body: message['body'] as String? ?? '',
                                imageUrl: message['image_url'] as String?,
                                isMine: isMine,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isSending ? null : _pickAndSendImage,
                    tooltip: 'Send image',
                    icon: const Icon(Icons.image_outlined),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
