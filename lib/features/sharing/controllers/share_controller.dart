import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/models/user_model.dart';
import 'package:flutter/services.dart';


class ShareController extends GetxController {
  static ShareController get to => Get.find();

  void showShareBottomSheet(ItemModel item, UserModel user) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Compartilhar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Share Options
              ListTile(
                leading: const Icon(Icons.link, color: Colors.blue),
                title: const Text('Copiar link'),
                onTap: () => _copyLink(item, user),
              ),
              
              ListTile(
                leading: const Icon(Icons.message, color: Colors.green),
                title: const Text('WhatsApp'),
                onTap: () => _shareToWhatsApp(item, user),
              ),
              
              ListTile(
                leading: const Icon(Icons.mail, color: Colors.red),
                title: const Text('Email'),
                onTap: () => _shareToEmail(item, user),
              ),
              
              ListTile(
                leading: Icon(Icons.share, color: Colors.grey.shade700),
                title: const Text('Outras opções'),
                onTap: () => _shareGeneric(item, user),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _copyLink(ItemModel item, UserModel user) async{
    try {
    final link = _generateShareLink(item, user);
    
    await Clipboard.setData(ClipboardData(text: link));
    
    Get.back();
    Get.snackbar('Sucesso', 'Link copiado para a área de transferência');
  } catch (e) {
    Get.back();
    Get.snackbar('Erro', 'Falha ao copiar link');
  }
  }

  void _shareToWhatsApp(ItemModel item, UserModel user) {
    final text = _generateShareText(item, user);
    Share.share(text);
    Get.back();
  }

  void _shareToEmail(ItemModel item, UserModel user) {
    final text = _generateShareText(item, user);
    Share.share(text, subject: 'Confira este item: ${item.name}');
    Get.back();
  }

  void _shareGeneric(ItemModel item, UserModel user) {
    final text = _generateShareText(item, user);
    Share.share(text);
    Get.back();
  }

  String _generateShareText(ItemModel item, UserModel user) {
    final userName = user.username ?? user.email ?? 'Um usuário';
    return 'Confira este item incrível: "${item.name}" compartilhado por $userName no My Collection! 🔗 ${_generateShareLink(item, user)}';
  }

  String _generateShareLink(ItemModel item, UserModel user) {
    // Incluir informações adicionais na URL para melhor SEO e compartilhamento
    const baseUrl = 'https://mycollection.app';
    final itemSlug = item.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return '$baseUrl/item/${item.id}/$itemSlug';
  }
}
