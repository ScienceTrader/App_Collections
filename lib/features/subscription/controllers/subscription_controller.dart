import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../collections/controllers/collection_controller.dart';


class SubscriptionController extends GetxController {
  static SubscriptionController get to => Get.find();
  
  final isPremium = false.obs;
  final subscriptionExpiry = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    checkSubscriptionStatus();
  }

  void checkSubscriptionStatus() {
    final profile = AuthController.to.userProfile.value;
    if (profile != null) {
      isPremium.value = profile.subscriptionTier == 'premium';
      subscriptionExpiry.value = profile.subscriptionExpiresAt;
      
      if (subscriptionExpiry.value != null && 
          subscriptionExpiry.value!.isBefore(DateTime.now())) {
        isPremium.value = false;
      }
    }
  }

  // Subscription Validations
  bool canAddCategory() {
    if (isPremium.value) return true;
    return CollectionController.to.categories.length < AppConstants.freeCategoriesLimit;
  }

  bool canAddItem() {
    if (isPremium.value) return true;
    return CollectionController.to.items.length < AppConstants.freeItemsLimit;
  }

  bool canGenerateReports() => isPremium.value;

  int get remainingCategories {
    if (isPremium.value) return -1; // Unlimited
    return AppConstants.freeCategoriesLimit - CollectionController.to.categories.length;
  }

  int get remainingItems {
    if (isPremium.value) return -1; // Unlimited
    return AppConstants.freeItemsLimit - CollectionController.to.items.length;
  }

  String getCategoryLimitText() {
    if (isPremium.value) return 'Categorias ilimitadas';
    return '${CollectionController.to.categories.length}/${AppConstants.freeCategoriesLimit} categorias';
  }

  String getItemLimitText() {
    if (isPremium.value) return 'Itens ilimitados';
    return '${CollectionController.to.items.length}/${AppConstants.freeItemsLimit} itens';
  }

  void showUpgradeDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text('Upgrade para Premium'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Este recurso está disponível apenas para usuários Premium.'),
            SizedBox(height: 16),
            Text('Recursos Premium:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildFeatureItem('Coleções ilimitadas'),
            _buildFeatureItem('Analytics detalhados'),
            _buildFeatureItem('Chat com usuários'),
            _buildFeatureItem('Relatórios PDF/Excel'),
            _buildFeatureItem('Suporte prioritário'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.payment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: Text('Ver Planos'),
          ),
        ],
      ),
    );
  }

  void showUpgradeBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upgrade para Premium',
              style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            _buildPlanCard(
              'Mensal',
              'R\$ 9,90',
              'por mês',
              'Mais popular',
              Colors.blue,
              () => _upgradeToPremium('monthly'),
            ),
            SizedBox(height: 12),
            
            _buildPlanCard(
              'Anual',
              'R\$ 99,90',
              'por ano',
              'Economia de 17%',
              Colors.green,
              () => _upgradeToPremium('yearly'),
            ),
            SizedBox(height: 20),
            
            Text(
              'Cancele a qualquer momento • Política de reembolso de 7 dias',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Talvez mais tarde'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    String title,
    String price,
    String period,
    String badge,
    Color badgeColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  Text('$price $period', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Text(feature, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _upgradeToPremium(String planType) async {
    Get.back(); // Fechar bottom sheet
    Get.toNamed(AppRoutes.payment, arguments: planType);
  }

  void showLimitReachedDialog(String feature) {
    Get.dialog(
      AlertDialog(
        title: Text('Limite Atingido'),
        content: Text('Você atingiu o limite de $feature para usuários gratuitos.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Entendi'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              showUpgradeDialog();
            },
            child: Text('Ver Premium'),
          ),
        ],
      ),
    );
  }
}