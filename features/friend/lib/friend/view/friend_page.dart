import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_chat/chat/navigation/chat_navigator.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_rongcloud_im/api/im_friend_api.dart';
import 'package:module_rongcloud_im/api/im_group_api.dart';
import 'package:module_utils/module_utils.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage>
    with SingleTickerProviderStateMixin {
  final _api = ImFriendApi();
  final _groupApi = ImGroupApi();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  List<ImFriendUser> _friends = [];
  List<ImFriendUser> _searchHits = [];
  List<ImFriendRequest> _incoming = [];
  bool _loading = true;
  bool _searching = false;
  String? _error;
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _reload();
  }

  @override
  void dispose() {
    _enter.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final friends = await _api.listFriends();
      List<ImFriendRequest> incoming = const [];
      try {
        incoming = await _api.listIncomingRequests();
      } catch (_) {
        // 旧后端无列表接口时不阻断好友页
      }
      if (!mounted) return;
      setState(() {
        _friends = friends;
        _incoming = incoming;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ImFriendApi.friendlyError(e, fallback: '加载失败');
        _loading = false;
      });
    }
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() => _searchHits = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final hits = await _api.search(q);
      if (!mounted) return;
      setState(() {
        _searchHits = hits;
        _searching = false;
      });
    } catch (e) {
      LogUtils.e('[Friend] search', e);
      if (!mounted) return;
      setState(() => _searching = false);
      _toast(ImFriendApi.friendlyError(e, fallback: '搜索失败'));
    }
  }

  Future<void> _request(ImFriendUser u) async {
    HapticFeedback.lightImpact();
    try {
      await _api.requestFriend(u.userId);
      if (!mounted) return;
      _toast('已向 ${u.displayName} 发送好友申请\n对方可在「通讯录 → 新的朋友」同意');
      setState(() {
        _searchHits = _searchHits
            .where((h) => h.userId != u.userId)
            .toList(growable: false);
      });
    } catch (e) {
      if (!mounted) return;
      _toast(ImFriendApi.friendlyError(e, fallback: '申请失败'));
    }
  }

  Future<void> _respond(ImFriendRequest req, {required bool accept}) async {
    HapticFeedback.selectionClick();
    try {
      await _api.respondFriend(req.id, accept: accept);
      if (!mounted) return;
      _toast(accept ? '已添加 ${req.displayName}' : '已拒绝');
      await _reload();
      if (accept && mounted) {
        await _openChat(
          ImFriendUser(
            userId: req.fromUserId,
            displayName: req.displayName,
            avatarUrl: req.avatarUrl,
            phoneMasked: req.phoneMasked,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _toast(ImFriendApi.friendlyError(e, fallback: '处理失败'));
    }
  }

  Future<void> _openChat(ImFriendUser u) async {
    try {
      final ok = await _api.canPrivateChat(u.userId);
      if (!ok) {
        if (mounted) _toast('需先成为好友才能单聊');
        return;
      }
      ChatNavigator.openPrivate(peerImUserId: u.userId);
    } catch (e) {
      if (mounted) {
        _toast(ImFriendApi.friendlyError(e, fallback: '打开会话失败'));
      }
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  Future<void> _createFreeGroup() async {
    if (_friends.isEmpty) {
      _toast('请先添加好友再建群');
      return;
    }
    final nameCtrl = TextEditingController();
    final selected = <String>{};
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: const Text('创建自由群'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: '群名称',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '邀请好友（可选）',
                        style: Theme.of(ctx).textTheme.labelLarge,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _friends.length,
                        itemBuilder: (_, i) {
                          final u = _friends[i];
                          final checked = selected.contains(u.userId);
                          return CheckboxListTile(
                            dense: true,
                            value: checked,
                            title: Text(u.displayName),
                            subtitle: Text(
                              u.userId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onChanged: (v) {
                              setLocal(() {
                                if (v == true) {
                                  selected.add(u.userId);
                                } else {
                                  selected.remove(u.userId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('创建'),
                ),
              ],
            );
          },
        );
      },
    );
    final name = nameCtrl.text.trim();
    nameCtrl.dispose();
    if (ok != true || !mounted) return;
    if (name.isEmpty) {
      _toast('请填写群名称');
      return;
    }
    try {
      final created = await _groupApi.createFreeGroup(
        name: name,
        memberIds: selected.toList(),
      );
      if (!mounted) return;
      _toast('已创建群「${created.name}」');
      await ChatNavigator.openGroup(
        groupId: created.groupId,
        title: created.name,
      );
    } catch (e) {
      if (mounted) {
        _toast(ImFriendApi.friendlyError(e, fallback: '建群失败'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: ChatTheme.background,
      navBar: AppNavBar(
        title: '通讯录',
        showBackButton: true,
        backgroundColor: ChatTheme.background,
        actions: [
          TextButton(
            onPressed: _createFreeGroup,
            child: Text(
              '建群',
              style: ChatTheme.subhead.copyWith(
                color: ChatTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _SearchBar(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  searching: _searching,
                  onSubmitted: (_) => _search(),
                  onSearch: _search,
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() => _searchHits = []);
                  },
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CupertinoActivityIndicator())
                    : _error != null
                        ? _ErrorBody(message: _error!, onRetry: _reload)
                        : RefreshIndicator(
                            onRefresh: _reload,
                            color: ChatTheme.accent,
                            child: CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                if (_searchHits.isNotEmpty) ...[
                                  _sectionHeader('搜索结果'),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        12,
                                      ),
                                      child: DecoratedBox(
                                        decoration:
                                            ChatTheme.groupedCardDecoration,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            ChatTheme.radiusMd,
                                          ),
                                          child: Column(
                                            children: [
                                              for (var i = 0;
                                                  i < _searchHits.length;
                                                  i++) ...[
                                                _UserTile(
                                                  name:
                                                      _searchHits[i]
                                                          .displayName,
                                                  subtitle: _searchHits[i]
                                                          .phoneMasked
                                                          .isEmpty
                                                      ? _searchHits[i].userId
                                                      : _searchHits[i]
                                                          .phoneMasked,
                                                  avatarUrl:
                                                      _searchHits[i].avatarUrl,
                                                  trailing: _PillButton(
                                                    label: '加好友',
                                                    onPressed: () => _request(
                                                      _searchHits[i],
                                                    ),
                                                  ),
                                                ),
                                                if (i < _searchHits.length - 1)
                                                  ChatTheme.groupedDivider(),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                if (_incoming.isNotEmpty) ...[
                                  _sectionHeader(
                                    '新的朋友',
                                    badge: _incoming.length,
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        12,
                                      ),
                                      child: DecoratedBox(
                                        decoration:
                                            ChatTheme.groupedCardDecoration,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            ChatTheme.radiusMd,
                                          ),
                                          child: Column(
                                            children: [
                                              for (var i = 0;
                                                  i < _incoming.length;
                                                  i++) ...[
                                                _IncomingTile(
                                                  request: _incoming[i],
                                                  onAccept: () => _respond(
                                                    _incoming[i],
                                                    accept: true,
                                                  ),
                                                  onReject: () => _respond(
                                                    _incoming[i],
                                                    accept: false,
                                                  ),
                                                ),
                                                if (i < _incoming.length - 1)
                                                  ChatTheme.groupedDivider(),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                _sectionHeader(
                                  '好友',
                                  trailing: '${_friends.length}',
                                ),
                                if (_friends.isEmpty)
                                  const SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: _FriendsEmpty(),
                                  )
                                else
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        32,
                                      ),
                                      child: DecoratedBox(
                                        decoration:
                                            ChatTheme.groupedCardDecoration,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            ChatTheme.radiusMd,
                                          ),
                                          child: Column(
                                            children: [
                                              for (var i = 0;
                                                  i < _friends.length;
                                                  i++) ...[
                                                _UserTile(
                                                  name:
                                                      _friends[i].displayName,
                                                  subtitle: _friends[i]
                                                          .phoneMasked
                                                          .isEmpty
                                                      ? _friends[i].userId
                                                      : _friends[i]
                                                          .phoneMasked,
                                                  avatarUrl:
                                                      _friends[i].avatarUrl,
                                                  onTap: () =>
                                                      _openChat(_friends[i]),
                                                ),
                                                if (i < _friends.length - 1)
                                                  ChatTheme.groupedDivider(),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {int? badge, String? trailing}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          children: [
            Text(title, style: ChatTheme.caption),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: ChatTheme.unreadBadge,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: ChatTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (trailing != null)
              Text(trailing, style: ChatTheme.caption),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.searching,
    required this.onSubmitted,
    required this.onSearch,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool searching;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: onSubmitted,
            textInputAction: TextInputAction.search,
            style: ChatTheme.body,
            decoration: InputDecoration(
              hintText: '手机号或用户 ID',
              hintStyle: ChatTheme.subhead.copyWith(
                color: ChatTheme.labelTertiary,
              ),
              prefixIcon: Icon(
                CupertinoIcons.search,
                size: 18,
                color: ChatTheme.labelTertiary,
              ),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(
                      CupertinoIcons.clear_circled_solid,
                      size: 18,
                      color: ChatTheme.labelTertiary,
                    ),
                    onPressed: onClear,
                  );
                },
              ),
              filled: true,
              fillColor: ChatTheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ChatTheme.radiusLg),
                borderSide: BorderSide(color: ChatTheme.separator),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ChatTheme.radiusLg),
                borderSide: BorderSide(color: ChatTheme.separator),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ChatTheme.radiusLg),
                borderSide: BorderSide(color: ChatTheme.accent, width: 1.2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        AnimatedScale(
          scale: searching ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          child: FilledButton(
            onPressed: searching ? null : onSearch,
            style: FilledButton.styleFrom(
              backgroundColor: ChatTheme.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(72, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ChatTheme.radiusLg),
              ),
            ),
            child: searching
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('搜索'),
          ),
        ),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    this.trailing,
    this.onTap,
  });

  final String name;
  final String subtitle;
  final String avatarUrl;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChatTheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CacheImageUtils.circle(
                avatarUrl,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: ChatTheme.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: ChatTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingTile extends StatelessWidget {
  const _IncomingTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  final ImFriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CacheImageUtils.circle(
            request.avatarUrl,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.displayName,
                  style: ChatTheme.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  request.phoneMasked.isEmpty
                      ? '请求加你为好友'
                      : '${request.phoneMasked} · 请求加你为好友',
                  style: ChatTheme.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _PillButton(
            label: '拒绝',
            outlined: true,
            onPressed: onReject,
          ),
          const SizedBox(width: 8),
          _PillButton(label: '同意', onPressed: onAccept),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: ChatTheme.labelSecondary,
          side: BorderSide(color: ChatTheme.separator),
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label, style: ChatTheme.caption.copyWith(fontSize: 13)),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: ChatTheme.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        label,
        style: ChatTheme.caption.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FriendsEmpty extends StatelessWidget {
  const _FriendsEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ChatTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: ChatTheme.separator),
            ),
            child: Icon(
              CupertinoIcons.person_2,
              size: 34,
              color: ChatTheme.labelTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text('还没有好友', style: ChatTheme.headline),
          const SizedBox(height: 6),
          Text(
            '用上方搜索对方手机号，发送申请后\n对方在「新的朋友」里同意即可聊天',
            style: ChatTheme.subhead,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: ChatTheme.caption),
          const SizedBox(height: 12),
          CupertinoButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
