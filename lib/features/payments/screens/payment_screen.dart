import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../../../core/constants/app_constants.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assinatura Premium'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
              ),
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.star,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Upgrade para Premium',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Desbloqueie todo o potencial do app',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Current Status
            Obx(() => _buildCurrentStatusCard()),

            // Plans
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escolha seu plano',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Monthly Plan
                  _buildPlanCard(
                    title: 'Premium Mensal',
                    price: 'R\$ 9,90',
                    period: '/mês',
                    features: AppConstants.subscriptionPlans['monthly']!['features'],
                    isRecommended: false,
                    onTap: () => _selectPlan('monthly'),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Yearly Plan
                  _buildPlanCard(
                    title: 'Premium Anual',
                    price: 'R\$ 99,90',
                    period: '/ano',
                    originalPrice: 'R\$ 118,80',
                    features: AppConstants.subscriptionPlans['yearly']!['features'],
                    isRecommended: true,
                    savings: '2 meses grátis',
                    onTap: () => _selectPlan('yearly'),
                  ),
                ],
              ),
            ),

            // Benefits Section
            _buildBenefitsSection(),

            // FAQ Section
            _buildFAQSection(),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    final isPremium = SubscriptionController.to.isPremium.value;
    
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                isPremium ? Icons.star : Icons.star_border,
                color: isPremium ? Colors.amber : Colors.grey,
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'Premium Ativo' : 'Versão Gratuita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isPremium 
                          ? 'Aproveite todos os recursos premium!'
                          : 'Upgrade para desbloquear recursos avançados',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    String? originalPrice,
    required List features,
    required bool isRecommended,
    String? savings,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isRecommended ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isRecommended 
              ? BorderSide(color: Colors.amber, width: 2)
              : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isRecommended 
                ? LinearGradient(
                    colors: [Colors.amber.shade50, Colors.orange.shade50],
                  )
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    if (isRecommended)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'RECOMENDADO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                if (originalPrice != null) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        originalPrice,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 8),
                      if (savings != null)
                        Text(
                          savings,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
                
                SizedBox(height: 16),
                
                ...features.take(4).map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                
                SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended ? Colors.amber : Colors.grey.shade200,
                      foregroundColor: isRecommended ? Colors.white : Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Escolher Plano',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Por que escolher Premium?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              _buildBenefitItem(
                Icons.inventory,
                'Coleções Ilimitadas',
                'Crie quantas categorias e itens quiser',
              ),
              _buildBenefitItem(
                Icons.analytics,
                'Analytics Avançados',
                'Relatórios detalhados e insights sobre suas coleções',
              ),
              _buildBenefitItem(
                Icons.chat,
                'Chat com Usuários',
                'Converse com outros colecionadores',
              ),
              _buildBenefitItem(
                Icons.rocket_launch,
                'Promoção de Itens',
                'Destaque seus itens no feed social',
              ),
              _buildBenefitItem(
                Icons.picture_as_pdf,
                'Relatórios PDF/Excel',
                'Exporte suas coleções em diversos formatos',
              ),
              _buildBenefitItem(
                Icons.support_agent,
                'Suporte Prioritário',
                'Atendimento rápido e personalizado',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.amber.shade700,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perguntas Frequentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              ExpansionTile(
                title: Text('Posso cancelar a qualquer momento?'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Sim! Você pode cancelar sua assinatura a qualquer momento nas configurações. Continuará tendo acesso aos recursos premium até o final do período pago.',
                    ),
                  ),
                ],
              ),
              
              ExpansionTile(
                title: Text('Como funciona o período gratuito?'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Novos usuários têm 7 dias gratuitos para testar todos os recursos premium. Após esse período, a cobrança será feita automaticamente.',
                    ),
                  ),
                ],
              ),
              
              ExpansionTile(
                title: Text('Meus dados ficam seguros?'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Absolutamente! Utilizamos criptografia de ponta a ponta e seguimos todas as normas de segurança e privacidade. Seus dados nunca são compartilhados com terceiros.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectPlan(String planType) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmar Assinatura'),
        content: Text('Deseja continuar com o plano ${planType == 'monthly' ? 'Mensal' : 'Anual'}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _processPurchase(planType);
            },
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(String planType) {
    // TODO: Implement Stripe payment processing
    Get.snackbar(
      'Info', 
      'Processamento de pagamento em desenvolvimento',
      duration: Duration(seconds: 3),
    );
  }
}