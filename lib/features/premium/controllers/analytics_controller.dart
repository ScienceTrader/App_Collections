import 'package:get/get.dart';
import 'package:my_collection_app/core/utils/logger.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/analytics_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';

class AnalyticsController extends GetxController {
  static AnalyticsController get to => Get.find();
  
  final analytics = Rxn<AnalyticsModel>();
  final isLoading = false.obs;
  final selectedPeriod = 'week'.obs; // 'week', 'month', 'year'
  static const String _tag = 'AnalyticsController';

  // Summary metrics
  final totalViews = 0.obs;
  final totalLikes = 0.obs;
  final totalComments = 0.obs;
  final totalShares = 0.obs;
  final engagementRate = 0.0.obs;
  final topCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (SubscriptionController.to.isPremium.value) {
      loadAnalytics();
    }
  }

  Future<void> loadAnalytics() async {
    if (!SubscriptionController.to.isPremium.value) {
      SubscriptionController.to.showUpgradeDialog();
      return;
    }

    try {
      isLoading.value = true;
      final currentUserId = AuthController.to.currentUser.value?.id;
      if (currentUserId == null) return;

      final endDate = DateTime.now();
      final startDate = _getStartDate(endDate);

      analytics.value = await SupabaseService.getAnalytics(
        userId: currentUserId,
        startDate: startDate,
        endDate: endDate,
      );

      _calculateSummaryMetrics();

    } catch (e) {
      Logger.error('Erro ao carregar analytics: $e', tag: 'AnalyticsController', error: e);
      Get.snackbar('Erro', 'Falha ao carregar analytics');
    } finally {
      isLoading.value = false;
    }
  }

  DateTime _getStartDate(DateTime endDate) {
    switch (selectedPeriod.value) {
      case 'week':
        return endDate.subtract(const Duration(days: 7));
      case 'month':
        return endDate.subtract(const Duration(days: 30));
      case 'year':
        return endDate.subtract(const Duration(days: 365));
      default:
        return endDate.subtract(const Duration(days: 7));
    }
  }

  void _calculateSummaryMetrics() {
    final analyticsData = analytics.value;
    if (analyticsData == null) {
      totalViews.value = 0;
      totalLikes.value = 0;
      totalComments.value = 0;
      totalShares.value = 0;
      engagementRate.value = 0.0;
      topCategory.value = '';
      return;
    }

    // Calcular métricas usando os dados do analytics
    totalViews.value = analyticsData.totalViews;
    totalLikes.value = analyticsData.totalLikes;
    totalComments.value = analyticsData.totalComments;
    totalShares.value = 0; // Implementar se necessário
    engagementRate.value = analyticsData.engagementRate;
    
    // Encontrar categoria principal
    if (analyticsData.categoryBreakdown.isNotEmpty) {
      final topCat = analyticsData.categoryBreakdown
          .reduce((a, b) => a.itemCount > b.itemCount ? a : b);
      topCategory.value = topCat.name;
    } else {
      topCategory.value = '';
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadAnalytics();
  }

  Future<void> generateReport() async {
    if (!SubscriptionController.to.isPremium.value) {
      SubscriptionController.to.showUpgradeDialog();
      return;
    }

    try {
      isLoading.value = true;
      
      final pdf = pw.Document();
      final user = AuthController.to.currentUser.value!;
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Relatório Analytics - ${user.userMetadata?['username'] ?? user.email}',style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Período: ${selectedPeriod.value}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Summary Metrics
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Resumo do Engajamento', 
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total de Visualizações: ${totalViews.value}'),
                      pw.Text('Total de Curtidas: ${totalLikes.value}'),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total de Comentários: ${totalComments.value}'),
                      pw.Text('Total de Compartilhamentos: ${totalShares.value}'),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text('Taxa de Engajamento: ${engagementRate.value.toStringAsFixed(2)}%'),
                  if (topCategory.value.isNotEmpty)
                    pw.Text('Categoria Mais Popular: ${topCategory.value}'),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Daily Analytics Table
            pw.Text('Análise Diária', 
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Data', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Views', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Likes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Comentários', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Engagement', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                // Data rows
                // Versão mais limpa:
              ...(analytics.value?.dailyData ?? []).map((dailyAnalytic) => pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${dailyAnalytic.date.day}/${dailyAnalytic.date.month}')),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${dailyAnalytic.items}')),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${dailyAnalytic.likes}')),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${dailyAnalytic.comments}')),
                ],
              )),
              ],
            ),
            
            pw.SizedBox(height: 20),
            
            // Footer
            pw.Text(
              'Relatório gerado em ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ],
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/relatorio_analytics_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'Relatório Analytics - My Collection');
      
      Get.snackbar('Sucesso', 'Relatório gerado e compartilhado!');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao gerar relatório: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> trackEvent(String eventType, {Map<String, dynamic>? metadata}) async {
    final currentUserId = AuthController.to.currentUser.value?.id;
    if (currentUserId == null) return;

    try {
      await SupabaseService.trackAnalyticsEvent(
        userId: currentUserId,
        eventType: eventType,
        metadata: metadata,
      );
    } catch (e) {
      Logger.error('Erro ao rastrear evento: $e', tag: _tag, error: e);
    }
  }
}
