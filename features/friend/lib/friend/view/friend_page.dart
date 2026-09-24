import 'package:flutter/material.dart';
import 'package:module_chat/chat/navigation/chat_navigator.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_rongcloud_im/api/im_friend_api.dart';
import 'package:module_utils/module_utils.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final _api = ImFriendApi();
  final _searchCtrl = TextEditingController();
  List<ImFriendUser> _friends = [];
  List<ImFriendUser> _searchHits = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.listFriends();
      if (!mounted) return;
      setState(() {
        _friends = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    try {
      final hits = await _api.search(q);
      if (!mounted) return;
      setState(() => _searchHits = hits);
    } catch (e) {
      LogUtils.e('[Friend] search', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _request(ImFriendUser u) async {
    try {
      await _api.requestFriend(u.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已向 ${u.displayName} 发送好友申请')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _openChat(ImFriendUser u) async {
    try {
      final ok = await _api.canPrivateChat(u.userId);
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('需先成为好友才能单聊')),
          );
        }
        return;
      }
      ChatNavigator.openPrivate(peerImUserId: u.userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);
    return AppPageScaffold(
      navBar: const AppNavBar(title: '好友'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: '手机号或用户 UUID',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _search, child: const Text('搜索')),
              ],
            ),
          ),
          if (_searchHits.isNotEmpty)
            ..._searchHits.map(
              (u) => ListTile(
                title: Text(u.displayName),
                subtitle: Text(u.phoneMasked.isEmpty ? u.userId : u.phoneMasked),
                trailing: TextButton(onPressed: () => _request(u), child: const Text('加好友')),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: tokens.ink)))
                    : RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView.builder(
                          itemCount: _friends.length,
                          itemBuilder: (_, i) {
                            final u = _friends[i];
                            return ListTile(
                              title: Text(u.displayName),
                              subtitle: Text(u.userId),
                              onTap: () => _openChat(u),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
