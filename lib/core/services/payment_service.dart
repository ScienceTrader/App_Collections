import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/logger.dart';

class PaymentService {
  static const String _tag = 'PaymentService';
  static const String _baseUrl = 'https://api.stripe.com/v1';
  static const String _secretKey = 'sk_test_sua_chave_secreta_aqui'; // Configure sua chave

  /// Criar cliente no Stripe
  static Future<String> createCustomer({
    required String email,
    required String name,
    Map<String, String>? metadata,
  }) async {
    try {
      Logger.info('Criando cliente Stripe para: $email', tag: _tag);
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'name': name,
          if (metadata != null)
            ...metadata.map((key, value) => MapEntry('metadata[$key]', value)),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info('Cliente criado com sucesso', tag: _tag);
        return data['id'];
      } else {
        throw Exception('Falha ao criar cliente: ${response.body}');
      }
    } catch (e) {
          Logger.error('Falha ao criar cliente Stripe', 
          tag: _tag, error: e);
          rethrow;    
          }
  }

  
  static bool _initialized = false;
  
  /// Inicializar o serviço de pagamentos
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      // Configurar Stripe se necessário
      Stripe.publishableKey = 'pk_test_sua_chave_publica_aqui';
      
      _initialized = true;
      Logger.info('PaymentService inicializado', tag: _tag);
    } catch (e) {
      Logger.error('Erro ao inicializar PaymentService: $e', tag: _tag, error: e);
      throw Exception('Falha na inicialização do PaymentService');
    }
  }
  
  

  /// Criar assinatura
  static Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String priceId,
    Map<String, String>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'items[0][price]': priceId,
          'payment_behavior': 'default_incomplete',
          'payment_settings[save_default_payment_method]': 'on_subscription',
          'expand[]': 'latest_invoice.payment_intent',
          if (metadata != null)
            ...metadata.map((key, value) => MapEntry('metadata[$key]', value)),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao criar assinatura: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao criar assinatura: $e');
    }
  }

  /// Cancelar assinatura
  static Future<void> cancelSubscription(
    String subscriptionId, {
    bool atPeriodEnd = true,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          if (atPeriodEnd) 'at_period_end': 'true',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao cancelar assinatura: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao cancelar assinatura: $e');
    }
  }

  /// Criar Payment Intent para pagamento único
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amount, // Em centavos
    required String currency,
    String? customerId,
    Map<String, String>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          if (customerId != null) 'customer': customerId,
          if (metadata != null)
            ...metadata.map((key, value) => MapEntry('metadata[$key]', value)),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao criar Payment Intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao criar Payment Intent: $e');
    }
  }

  /// Confirmar pagamento
  static Future<void> confirmPayment(String clientSecret) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
    } catch (e) {
      throw Exception('Erro ao confirmar pagamento: $e');
    }
  }

  /// Recuperar assinatura
  static Future<Map<String, dynamic>> retrieveSubscription(String subscriptionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao recuperar assinatura: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao recuperar assinatura: $e');
    }
  }
}