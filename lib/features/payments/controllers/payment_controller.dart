import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Para widgets Material Design
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/payment_models.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter/material.dart' as material;



class PaymentController extends GetxController {
  static PaymentController get to => Get.find();
  
  final isLoading = false.obs;
  final currentSubscription = Rxn<SubscriptionModel>();
  final paymentHistory = <PaymentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSubscriptionData();
  }

  Future<void> loadSubscriptionData() async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      isLoading.value = true;
      
      final subscriptions = await SupabaseService.getUserSubscriptions(currentUser.id);
      if (subscriptions.isNotEmpty) {
        currentSubscription.value = subscriptions.first;
      }
      
      final payments = await SupabaseService.getUserPayments(currentUser.id);
      paymentHistory.assignAll(payments);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar dados de pagamento: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchaseSubscription(String planType) async {
    final currentUser = AuthController.to.currentUser.value;
    if (currentUser == null) return;

    try {
      isLoading.value = true;
      
      final plan = AppConstants.subscriptionPlans[planType];
      if (plan == null) throw Exception('Plano não encontrado');

      // Create Stripe customer if needed
      String customerId;
      try {
        customerId = await PaymentService.createCustomer(
          email: currentUser.email!,
          name: currentUser.userMetadata?['username'] ?? currentUser.email!,
          metadata: {'user_id': currentUser.id},
        );
      } catch (e) {
        throw Exception('Falha ao criar customer: $e');
      }

      // Create subscription
      final subscriptionData = await PaymentService.createSubscription(
        customerId: customerId,
        priceId: plan['priceId'],
        metadata: {
          'user_id': currentUser.id,
          'plan_type': planType,
        },
      );

      // Get payment intent client secret
      final clientSecret = subscriptionData['latest_invoice']['payment_intent']['client_secret'];
      
      // Show payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'My Collection',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      
      // Save subscription to database
      final subscription = SubscriptionModel(
        userId: currentUser.id,
        stripeSubscriptionId: subscriptionData['id'],
        stripePriceId: plan['priceId'],
        status: subscriptionData['status'],
        amount: plan['price'].toDouble(),
        interval: planType == 'yearly' ? 'year' : 'month',
        currentPeriodStart: DateTime.fromMillisecondsSinceEpoch(
          subscriptionData['current_period_start'] * 1000,
        ),
        currentPeriodEnd: DateTime.fromMillisecondsSinceEpoch(
          subscriptionData['current_period_end'] * 1000,
        ),
      );

      await SupabaseService.saveSubscription(subscription);
      
      // Update user subscription status
      await SupabaseService.updateUser(currentUser.id, {
        'subscription_tier': 'premium',
        'subscription_expires_at': subscription.currentPeriodEnd?.toIso8601String(),
      });

      // Refresh subscription controller
      SubscriptionController.to.checkSubscriptionStatus();
      
      Get.back(); // Close payment screen
      Get.snackbar('Sucesso', 'Assinatura ativada com sucesso! 🎉');
      
    } catch (e) {
      if (e is StripeException) {
        if (e.error.code != FailureCode.Canceled) {
          Get.snackbar('Erro', 'Pagamento falhou: ${e.error.message}');
        }
      } else {
        Get.snackbar('Erro', 'Falha ao processar pagamento: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelSubscription() async {
    final subscription = currentSubscription.value;
    if (subscription == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: const Text('Tem certeza que deseja cancelar sua assinatura? Você continuará tendo acesso aos recursos premium até o final do período pago.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performCancelSubscription();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmar Cancelamento'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCancelSubscription() async {
    try {
      isLoading.value = true;
      
      await PaymentService.cancelSubscription(
        currentSubscription.value!.stripeSubscriptionId,
        atPeriodEnd: true,
      );
      
      await SupabaseService.updateSubscriptionStatus(
        currentSubscription.value!.id!,
        'canceled',
        cancelAtPeriodEnd: true,
      );
      
      loadSubscriptionData();
      Get.snackbar('Sucesso', 'Assinatura cancelada. Você continuará tendo acesso premium até o final do período.');
      
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cancelar assinatura: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showPaymentHistory() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Histórico de Pagamentos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (paymentHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('Nenhum pagamento encontrado'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: paymentHistory.length,
                  itemBuilder: (context, index) {
                    final payment = paymentHistory[index];
                    return material.Card(
                      child: material.ListTile(
                        leading: Icon(
                          payment.status == 'succeeded' ? Icons.check_circle : Icons.error,
                          color: payment.status == 'succeeded' ? Colors.green : Colors.red,
                        ),
                        title: Text('R\$ ${payment.amount.toStringAsFixed(2)}'),
                        subtitle: Text(_formatPaymentDate(payment.createdAt)),
                        trailing: Text(
                          _getPaymentStatusText(payment.status),
                          style: TextStyle(
                            color: payment.status == 'succeeded' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void showSubscriptionDetails() {
    final subscription = currentSubscription.value;
    if (subscription == null) return;

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
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Detalhes da Assinatura',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Plano', subscription.displayName),
                    _buildDetailRow('Status', _getSubscriptionStatusText(subscription.status)),
                    _buildDetailRow('Valor', 'R\$ ${subscription.amount.toStringAsFixed(2)}/${subscription.interval == 'month' ? 'mês' : 'ano'}'),
                    if (subscription.currentPeriodStart != null)
                      _buildDetailRow('Início do período', _formatPaymentDate(subscription.currentPeriodStart)),
                    if (subscription.currentPeriodEnd != null)
                      _buildDetailRow('Renovação', _formatPaymentDate(subscription.currentPeriodEnd)),
                    if (subscription.cancelAtPeriodEnd)
                      _buildDetailRow('Status', 'Cancelamento agendado', color: Colors.orange),
                  ],
                ),
              ),
              
              if (subscription.isActive) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        cancelSubscription();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Cancelar Assinatura'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                color: color ?? Colors.grey.shade700,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPaymentDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPaymentStatusText(String status) {
    switch (status) {
      case 'succeeded':
        return 'Pago';
      case 'failed':
        return 'Falhou';
      case 'pending':
        return 'Pendente';
      default:
        return status;
    }
  }

  String _getSubscriptionStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'canceled':
        return 'Cancelado';
      case 'incomplete':
        return 'Incompleto';
      case 'past_due':
        return 'Em atraso';
      default:
        return status;
    }
  }
}
