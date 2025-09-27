import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/item_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/trending_item_model.dart';
import '../../shared/models/search_models.dart';
import '../../shared/models/comment_model.dart';
import '../../shared/models/notification_model.dart';
import '../../shared/models/payment_models.dart';
import '../../shared/models/analytics_model.dart';



import 'dart:io';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // User Methods
  static Future<UserModel> createUser(UserModel user) async {
    final response =
        await _client.from('users').insert(user.toJson()).select().single();

    return UserModel.fromJson(response);
  }

  /*static Future<UserModel?> getUser(String clerkUserId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('clerk_user_id', clerkUserId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }*/
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      return response; // Retorna Map<String, dynamic>?
    } catch (e) {
      throw Exception('Erro ao carregar perfil: $e');
    }
  }

    static Future<List<UserModel>> getSuggestedUsers(String currentUserId, {int limit = 10}) async {
      try {
        // Usar a função RPC mais inteligente
        final response = await _client.rpc('get_mixed_user_suggestions', params: {
          'current_user_id': currentUserId,
          'limit_count': limit,
        });

        return response.map((user) => UserModel.fromJson(user)).toList();
      } catch (e) {
        // Fallback para função básica se a função mista falhar
        try {
          final response = await _client.rpc('get_suggested_users', params: {
            'current_user_id': currentUserId,
            'limit_count': limit,
          });
          return response.map((user) => UserModel.fromJson(user)).toList();
        } catch (e2) {
          throw Exception('Erro ao buscar usuários sugeridos: $e2');
        }
      }
  }

  static Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      if (query.trim().isEmpty) return [];

      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      // Tentar usar função RPC avançada primeiro
      try {
        final response = await _client.rpc('search_users', params: {
          'search_query': query.trim(),
          'current_user_id': currentUserId,
          'limit_count': limit,
        });

        return response.map((user) => UserModel.fromJson(user)).toList();
      } catch (rpcError) {
        // Fallback para busca básica se RPC falhar
        final response = await _client
            .from('users')
            .select()
            .or('username.ilike.%${query.trim()}%,email.ilike.%${query.trim()}%')
            .limit(limit);

        return response.map((user) => UserModel.fromJson(user)).toList();
      }
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _client
          .from('users')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  // Category Methods
  static Future<List<CategoryModel>> getCategories(String userId) async {
    final response = await _client.from('categories').select('''
          *,
          subcategories:subcategories(count),
          items:items(count)
        ''').eq('user_id', userId).order('created_at');

    return response.map((data) => CategoryModel.fromJson(data)).toList();
  }

  static Future<List<CategoryModel>> getUserCategories(String userId) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('created_at');
      
      return response.map((item) => CategoryModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar categorias: $e');
    }
  }

  static Future<CategoryModel> createCategory(CategoryModel category) async {
    final response = await _client
        .from('categories')
        .insert(category.toJson())
        .select()
        .single();

    return CategoryModel.fromJson(response);
  }

  static Future<void> deleteCategory(String categoryId) async {
    try {
      await _client.from('categories').delete().eq('id', categoryId);
    } catch (e) {
      throw Exception('Erro ao excluir categoria: $e');
    }
  }

  // No SupabaseService
  static Future<List<CategoryModel>> getPopularCategories({int limit = 10}) async {
    try {
      // Buscar categorias mais populares baseado no número de itens
      final response = await _client
          .from('categories')
          .select('''
            *,
            items!inner(id)
          ''')
          .order('item_count', ascending: false)
          .limit(limit);

      return response.map((category) => CategoryModel.fromJson(category)).toList();
    } catch (e) {
      // Se não tiver contagem de itens, usar uma abordagem alternativa
      try {
        final response = await _client
            .from('categories')
            .select()
            .order('created_at', ascending: false)
            .limit(limit);
        
        return response.map((category) => CategoryModel.fromJson(category)).toList();
      } catch (e2) {
        throw Exception('Erro ao carregar categorias populares: $e2');
      }
    }
  }

  // Item Methods
  static Future<List<ItemModel>> getItems({
    required String userId,
    String? categoryId,
    String? subcategoryId,
    String? search,
  }) async {
    var query = _client.from('items').select('''
          *,
          categories(*),
          subcategories(*)
        ''').eq('user_id', userId);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (subcategoryId != null) {
      query = query.eq('subcategory_id', subcategoryId);
    }

    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,description.ilike.%$search%');
    }

    final response = await query.order('created_at', ascending: false);
    return response.map((data) => ItemModel.fromJson(data)).toList();
  }

  static Future<ItemModel?> getItem(String itemId) async {
    try {
      final response = await _client
          .from('items')
          .select('''
            *,
            categories (*)
          ''')
          .eq('id', itemId)
          .single();
      
      return ItemModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao carregar item: $e');
    }
  }

  static Future<ItemModel> createItem(ItemModel item) async {
    final response =
        await _client.from('items').insert(item.toJson()).select('''
          *,
          categories(*),
          subcategories(*)
        ''').single();

    return ItemModel.fromJson(response);
  }

  static Future<void> deleteItem(String itemId) async {
    try {
      await _client.from('items').delete().eq('id', itemId);
    } catch (e) {
      throw Exception('Erro ao excluir item: $e');
    }
  }

  // Storage Methods
  static Future<String> uploadItemImage(
      String filePath, String fileName) async {
    await _client.storage.from('item-images').upload(fileName, File(filePath));

    final publicUrl =
        _client.storage.from('item-images').getPublicUrl(fileName);

    return publicUrl;
  }

  // Upload de arquivo
  static Future<String?> uploadFile(File file, String bucket, String path) async {
    try {
      await _client.storage.from(bucket).upload(path, file);
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw Exception('Erro no upload: $e');
    }
  }

  static Future<void> deleteItemImage(String fileName) async {
    await _client.storage.from('item-images').remove([fileName]);
  }

  // Método para atualizar qualquer campo do item
  static Future<void> updateItem(
      String itemId, Map<String, dynamic> updates) async {
    try {
      await _client.from('items').update(updates).eq('id', itemId);
    } catch (e) {
      throw Exception('Erro ao atualizar item: $e');
    }
  }

  static Future<void> updateItemVisibility(String itemId, bool isPublic) async {
    try {
      await _client
          .from('items')
          .update({
            'is_public': isPublic,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Erro ao atualizar visibilidade: $e');
    }
  }


  // Outros métodos úteis para itens
  static Future<void> updateItemDetails({
    required String itemId,
    String? name,
    String? description,
    String? imageUrl,
    bool? isPublic,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (isPublic != null) updates['is_public'] = isPublic;

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();

        await _client.from('items').update(updates).eq('id', itemId);
      }
    } catch (e) {
      throw Exception('Erro ao atualizar detalhes do item: $e');
    }
  }

  // FEED
  static Future<List<Map<String, dynamic>>> getPublicFeed({
    required int limit,
    required int offset,
    String? currentUserId,
  }) async {
    try {
      final response = await _client
          .from('items')
          .select('''
            *,
            categories (*),
            users (*)
          ''')
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return response;
    } catch (e) {
      throw Exception('Erro ao carregar feed: $e');
    }
  }

  // LIKES
  static Future<void> likeItem(String itemId, String userId) async {
    try {
      await _client.from('likes').insert({
        'item_id': itemId,
        'user_id': userId,
      });
    } catch (e) {
      throw Exception('Erro ao curtir item: $e');
    }
  }

  static Future<void> unlikeItem(String itemId, String userId) async {
    try {
      await _client
          .from('likes')
          .delete()
          .eq('item_id', itemId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Erro ao descurtir item: $e');
    }
  }

  static Future<List<TrendingItemModel>> getTrendingItems({
    required String period,
    required int limit,
    }) async {
    try {
      String dateFilter;
      final now = DateTime.now();
      
      // Definir período para busca
      switch (period) {
        case 'daily':
          dateFilter = now.subtract(Duration(days: 1)).toIso8601String();
          break;
        case 'weekly':
          dateFilter = now.subtract(Duration(days: 7)).toIso8601String();
          break;
        case 'monthly':
          dateFilter = now.subtract(Duration(days: 30)).toIso8601String();
          break;
        default:
          dateFilter = now.subtract(Duration(days: 1)).toIso8601String();
      }

      // Buscar itens com mais engajamento no período
      final response = await _client
          .from('items')
          .select('''
            *,
            categories (*),
            users (*),
            likes!inner(created_at),
            comments!inner(created_at)
          ''')
          .eq('is_public', true)
          .gte('created_at', dateFilter)
          .order('likes_count', ascending: false)
          .limit(limit);

      return response.map((item) => TrendingItemModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar itens em alta: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchItems({
    String? query,
    required SearchFilters filters,
    required int limit,
    int offset = 0,
    String? currentUserId,
  }) async {
    try {
      var queryBuilder = _client
          .from('items')
          .select('''
            *,
            categories (*),
            users (*)
          ''')
          .eq('is_public', true);

      // Aplicar filtros
      if (query != null && query.trim().isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'name.ilike.%$query%,description.ilike.%$query%'
        );
      }

      if (filters.category != null) {
        queryBuilder = queryBuilder.eq('categories.name', filters.category!);
      }

      if (filters.startDate != null) {
        queryBuilder = queryBuilder.gte('created_at', filters.startDate!.toIso8601String());
      }

      if (filters.endDate != null) {
        queryBuilder = queryBuilder.lte('created_at', filters.endDate!.toIso8601String());
      }

      if (filters.isPromoted == true) {
        queryBuilder = queryBuilder.eq('is_promoted', true);
      }

      // Determinar ordenação e executar query
      String orderColumn = 'created_at';
      bool ascending = false;

      switch (filters.sortBy) {
        case 'popular':
          orderColumn = 'likes_count';
          break;
        case 'trending':
          orderColumn = 'likes_count'; // Pode ser melhorado com algoritmo mais complexo
          break;
        case 'recent':
        default:
          orderColumn = 'created_at';
          break;
      }

      final response = await queryBuilder
          .order(orderColumn, ascending: ascending)
          .range(offset, offset + limit - 1);

      return response;
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  static Future<void> addComment(CommentModel comment) async {
    try {
      await _client.from('comments').insert(comment.toJson());
    } catch (e) {
      throw Exception('Erro ao adicionar comentário: $e');
    }
  }

  
  static Future<List<CommentModel>> getComments(String itemId) async {
    try {
      final response = await _client
          .from('comments')
          .select('''
            *,
            users (*)
          ''')
          .eq('item_id', itemId)
          .order('created_at', ascending: true);

      return response.map((comment) => CommentModel.fromJson(comment)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar comentários: $e');
    }
  }

  static Future<void> saveSearchQuery({
    required String userId,
    required String query,
    required Map<String, dynamic> filters,
    required int resultsCount,
  }) async {
    try {
      await _client.from('search_queries').insert({
        'user_id': userId,
        'query': query,
        'filters': filters,
        'results_count': resultsCount,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao salvar query de busca: $e');
    }
  }

  static Future<void> createNotification({
    required String userId,
    required String senderId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? metadata,
    String? itemId,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'sender_id': senderId,
        'type': type,
        'title': title,
        'body': body,
        if (itemId != null) 'item_id': itemId,
        'metadata': metadata,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao criar notificação: $e');
    }
  }

  // No SupabaseService
  static Future<List<Map<String, dynamic>>> getPersonalizedFeed({
    required String currentUserId,
    required int limit,
    required int offset,
  }) async {
    try {
      // Buscar itens baseado em:
      // 1. Usuários seguidos
      // 2. Categorias de interesse do usuário
      // 3. Itens populares

      final followedUserIds = await _getFollowedUserIds(currentUserId);
      final userInterestCategories = await _getUserInterestCategories(currentUserId);

      var query = _client
          .from('items')
          .select('''
            *,
            categories (*),
            users (*)
          ''')
          .eq('is_public', true);

      // Se tem usuários seguidos, priorizar conteúdo deles
      if (followedUserIds.isNotEmpty) {
        query = query.or(
          'user_id.in.(${followedUserIds.join(',')}),category_id.in.(${userInterestCategories.join(',')})'
        );
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response;
    } catch (e) {
      throw Exception('Erro ao carregar feed personalizado: $e');
    }
  }

  static Future<List<String>> _getUserInterestCategories(String userId) async {
    try {
      // Buscar categorias que o usuário mais interage
      final response = await _client
          .from('user_interactions')
          .select('category_id')
          .eq('user_id', userId)
          .limit(10);

      return response.map((item) => item['category_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }
// Método auxiliar para obter IDs dos usuários seguidos

  static Future<List<String>> _getFollowedUserIds(String currentUserId) async {
    try {
      final response = await _client
          .from('follows')
          .select('followed_user_id')
          .eq('follower_user_id', currentUserId);

      return response.map((follow) => follow['followed_user_id'] as String).toList();
    } catch (e) {
      // Se não conseguir buscar ou não existir a tabela, retorna lista vazia
      return [];
    }
  }

  //Notificações

  static Future<List<NotificationModel>> getNotifications({
    required String userId,
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await _client
          .from('notifications')
          .select('''
            *,
            sender:users!sender_id (*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((notification) => NotificationModel.fromJson(notification)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar notificações: $e');
    }
  }

  static Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final count = await _client
          .from('notifications')
          .count(CountOption.exact)
          .eq('user_id', userId)
          .eq('is_read', false);

      return count;
    } catch (e) {
      throw Exception('Erro ao contar notificações não lidas: $e');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Erro ao marcar notificação como lida: $e');
    }
  }

  static Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Erro ao marcar todas as notificações como lidas: $e');
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Erro ao excluir notificação: $e');
    }
  }

  // No SupabaseService
// No SupabaseService
  static Future<List<NotificationModel>> getPendingNotifications(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('''
            *,
            sender:users!sender_id (*)
          ''')
          .eq('user_id', userId)
          .eq('is_read', false)
          .inFilter('type', ['like', 'comment', 'follow', 'system']) // Usar inFilter
          .order('created_at', ascending: false)
          .limit(20);

      return response.map((notification) => NotificationModel.fromJson(notification)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar notificações pendentes: $e');
    }
  }

  static Future<void> updateNotificationSettings(String userId, bool enabled) async {
    try {
      await _client.from('user_notification_settings').upsert({
        'user_id': userId,
        'push_enabled': enabled,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar configurações de notificação: $e');
    }
  }

  // Método para buscar configurações
  static Future<Map<String, dynamic>?> getNotificationSettings(String userId) async {
    try {
      final response = await _client
          .from('user_notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar configurações de notificação: $e');
    }
  }

  // Método para atualizar configurações específicas
  static Future<void> updateSpecificNotificationSettings(
    String userId, {
    bool? pushEnabled,
    bool? emailEnabled,
    bool? likesEnabled,
    bool? commentsEnabled,
    bool? followsEnabled,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (pushEnabled != null) updates['push_enabled'] = pushEnabled;
      if (emailEnabled != null) updates['email_enabled'] = emailEnabled;
      if (likesEnabled != null) updates['likes_enabled'] = likesEnabled;
      if (commentsEnabled != null) updates['comments_enabled'] = commentsEnabled;
      if (followsEnabled != null) updates['follows_enabled'] = followsEnabled;

      await _client.from('user_notification_settings').upsert({
        'user_id': userId,
        ...updates,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar configurações específicas: $e');
    }
  }

  static Future<void> saveUserPushToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      await _client.from('user_push_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': platform,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao salvar token push: $e');
    }
  }

  static Future<String?> getUserPushToken(String userId) async {
    try {
      final response = await _client
          .from('user_push_tokens')
          .select('token')
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();

      return response?['token'];
    } catch (e) {
      return null;
    }
  }


  static Future<List<SubscriptionModel>> getUserSubscriptions(String userId) async {
    try {
      final response = await _client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((sub) => SubscriptionModel.fromJson(sub)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar assinaturas: $e');
    }
  }

  // Método adicional para sugestões por interesses
  static Future<List<UserModel>> getUsersBySimilarInterests(String currentUserId, {int limit = 10}) async {
    try {
      final response = await _client.rpc('get_users_by_similar_interests', params: {
        'current_user_id': currentUserId,
        'limit_count': limit,
      });

      return response.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários por interesses: $e');
    }
  }

  // Método para usuários populares
  static Future<List<UserModel>> getPopularUsers(String currentUserId, {int limit = 10}) async {
    try {
      final response = await _client.rpc('get_popular_users', params: {
        'current_user_id': currentUserId,
        'limit_count': limit,
      });

      return response.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários populares: $e');
    }
  }

  static Future<List<PaymentModel>> getUserPayments(String userId) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((payment) => PaymentModel.fromJson(payment)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar pagamentos: $e');
    }
  }

  static Future<void> saveSubscription(SubscriptionModel subscription) async {
    try {
      await _client.from('subscriptions').insert(subscription.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar assinatura: $e');
    }
  }

  static Future<void> updateSubscriptionStatus(
    String subscriptionId, 
    String status, {
    bool? cancelAtPeriodEnd,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': status};
      if (cancelAtPeriodEnd != null) {
        updateData['cancel_at_period_end'] = cancelAtPeriodEnd;
      }

      await _client
          .from('subscriptions')
          .update(updateData)
          .eq('id', subscriptionId);
    } catch (e) {
      throw Exception('Erro ao atualizar status da assinatura: $e');
    }
  }

  // No SupabaseService
  static Future<AnalyticsModel> getAnalytics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Buscar dados básicos de itens
      final itemsResponse = await _client
          .from('items')
          .select('*, categories(*)')
          .eq('user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      // Buscar dados de likes
      final likesResponse = await _client
          .from('likes')
          .select('*, items!inner(*)')
          .eq('items.user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      // Buscar dados de comentários
      final commentsResponse = await _client
          .from('comments')
          .select('*, items!inner(*)')
          .eq('items.user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      // Buscar dados de visualizações (se existir)
      final viewsResponse = await _client
          .from('item_views')
          .select('*, items!inner(*)')
          .eq('items.user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      return AnalyticsModel.fromData(
        items: itemsResponse,
        likes: likesResponse,
        comments: commentsResponse,
        views: viewsResponse,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Erro ao carregar analytics: $e');
    }
  }
  static Future<void> trackAnalyticsEvent({
    required String userId,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _client.from('analytics_events').insert({
        'user_id': userId,
        'event_type': eventType,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao rastrear evento de analytics: $e');
    }
  }

  static Future<int> getFollowersCount(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('followed_user_id', userId);

      return response.length;
    } catch (e) {
      throw Exception('Erro ao buscar contagem de seguidores: $e');
    }
  }

  static Future<int> getFollowingCount(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_user_id', userId);

      return response.length;
    } catch (e) {
      throw Exception('Erro ao buscar contagem de seguindo: $e');
    }
  }

  static Future<int> getUserItemsCount(String userId) async {
    try {
      final response = await _client
          .from('items')
          .select('id')
          .eq('user_id', userId);

      return response.length;
    } catch (e) {
      throw Exception('Erro ao buscar contagem de itens: $e');
    }
  }

  static Future<int> getUserCategoriesCount(String userId) async {
    try {
      final response = await _client
          .from('categories')
          .select('id')
          .eq('user_id', userId);

      return response.length;
    } catch (e) {
      throw Exception('Erro ao buscar contagem de categorias: $e');
    }
  }

  // Método para seguir usuário
  static Future<void> followUser(String followerId, String followedId) async {
    try {
      await _client.from('follows').insert({
        'follower_user_id': followerId,
        'followed_user_id': followedId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao seguir usuário: $e');
    }
  }

  // Método para deixar de seguir usuário
  static Future<void> unfollowUser(String followerId, String followedId) async {
    try {
      await _client
          .from('follows')
          .delete()
          .eq('follower_user_id', followerId)
          .eq('followed_user_id', followedId);
    } catch (e) {
      throw Exception('Erro ao deixar de seguir usuário: $e');
    }
  }

  // Verificar se está seguindo
  static Future<bool> isFollowingUser(String followerId, String followedId) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_user_id', followerId)
          .eq('followed_user_id', followedId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  static Future<void> savePushToken(String token, String platform) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      await _client.from('push_tokens').upsert({
        'user_id': currentUser.id,
        'token': token,
        'platform': platform,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao salvar token push: $e');
    }
  }

  // Método para remover token (útil no logout)
  static Future<void> removePushToken(String token) async {
    try {
      await _client
          .from('push_tokens')
          .delete()
          .eq('token', token);
    } catch (e) {
      throw Exception('Erro ao remover token push: $e');
    }
  }

  // Método para buscar tokens de um usuário
  static Future<List<String>> getUserPushTokens(String userId) async {
    try {
      final response = await _client
          .from('push_tokens')
          .select('token')
          .eq('user_id', userId);

      return response.map((item) => item['token'] as String).toList();
    } catch (e) {
      throw Exception('Erro ao buscar tokens push: $e');
    }
  }
}
