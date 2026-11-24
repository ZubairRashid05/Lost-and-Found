import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/chat_page.dart';
import 'package:lost_and_found/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _conversations = [];
  RealtimeChannel? _conversationChannel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _subscribeToConversations();
  }

  Future<void> _loadConversations() async {
    final user = UserService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final rows = await _supabase
          .from('conversations')
          .select('id, product_id, user_one, user_two, created_at, updated_at')
          .or('user_one.eq.${user.id},user_two.eq.${user.id}')
          .order('updated_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _conversations = List<Map<String, dynamic>>.from(rows);
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading conversations: $error');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _subscribeToConversations() {
    _conversationChannel = _supabase
        .channel('inbox-conversations')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (_) => _loadConversations(),
        )
        .subscribe();
  }

  @override
  void dispose() {
    if (_conversationChannel != null) {
      _supabase.removeChannel(_conversationChannel!);
    }
    super.dispose();
  }

  String _otherUserId(Map<String, dynamic> conversation, String userId) {
    return conversation['user_one'] == userId
        ? conversation['user_two'] as String
        : conversation['user_one'] as String;
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inbox')),
        body: const Center(child: Text('Sign in to view your messages.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadConversations,
              child: _conversations.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No conversations yet.')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _conversations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        final otherUserId = _otherUserId(conversation, user.id);

                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: const Text(
                              'Conversation',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'User: ${otherUserId.substring(0, 8)}…',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    conversationId:
                                        conversation['id'] as String,
                                    otherUserId: otherUserId,
                                    productId:
                                        conversation['product_id'] as String?,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
