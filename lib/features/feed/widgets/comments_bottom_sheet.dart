import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/models/feed_item_model.dart';
import '../../../shared/models/comment_model.dart';
import '../controllers/feed_controller.dart';
import '../../../core/services/supabase_service.dart';

class CommentsBottomSheet extends StatefulWidget {
  final FeedItemModel feedItem;

  const CommentsBottomSheet({Key? key, required this.feedItem}) : super(key: key);

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final _commentController = TextEditingController();
  final _comments = <CommentModel>[].obs;
  final _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Text(
                  'Comentários',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  '${widget.feedItem.commentsCount}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: Obx(() {
              if (_isLoading.value && _comments.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (_comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.comment_outlined, size: 60, color: Colors.grey.shade400),
                      SizedBox(height: 16),
                      Text('Nenhum comentário ainda'),
                      Text('Seja o primeiro a comentar!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return _buildCommentTile(comment);
                },
              );
            }),
          ),

          // Comment Input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Adicione um comentário...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: comment.user?.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      comment.user!.avatarUrl!,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                  )
                : Icon(Icons.person),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.user?.username ?? 'Usuário',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(comment.content),
                SizedBox(height: 4),
                Text(
                  _formatTime(comment.createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadComments() async {
    try {
      _isLoading.value = true;
      final comments = await SupabaseService.getComments(widget.feedItem.item.id!);
      _comments.assignAll(comments);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar comentários');
    } finally {
      _isLoading.value = false;
    }
  }

  void _addComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    FeedController.to.addComment(widget.feedItem.item.id!, content);
    _commentController.clear();
    
    // Recarregar comentários após adicionar
    _loadComments();
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}