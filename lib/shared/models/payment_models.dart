class SubscriptionModel {
  final String? id;
  final String userId;
  final String stripeSubscriptionId;
  final String stripePriceId;
  final String status;
  final double amount;
  final String interval;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? createdAt;

  SubscriptionModel({
    this.id,
    required this.userId,
    required this.stripeSubscriptionId,
    required this.stripePriceId,
    required this.status,
    required this.amount,
    required this.interval,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.createdAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      userId: json['user_id'],
      stripeSubscriptionId: json['stripe_subscription_id'],
      stripePriceId: json['stripe_price_id'],
      status: json['status'],
      amount: (json['amount'] as num).toDouble(),
      interval: json['interval'],
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'])
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'])
          : null,
      cancelAtPeriodEnd: json['cancel_at_period_end'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'stripe_subscription_id': stripeSubscriptionId,
      'stripe_price_id': stripePriceId,
      'status': status,
      'amount': amount,
      'interval': interval,
      if (currentPeriodStart != null)
        'current_period_start': currentPeriodStart!.toIso8601String(),
      if (currentPeriodEnd != null)
        'current_period_end': currentPeriodEnd!.toIso8601String(),
      'cancel_at_period_end': cancelAtPeriodEnd,
    };
  }

  bool get isActive => status == 'active';

  String get displayName {
    switch (interval) {
      case 'month':
        return 'Premium Mensal';
      case 'year':
        return 'Premium Anual';
      default:
        return 'Premium';
    }
  }
}

class PaymentModel {
  final String? id;
  final String userId;
  final String stripePaymentIntentId;
  final double amount;
  final String currency;
  final String status;
  final String? subscriptionId;
  final DateTime? createdAt;

  PaymentModel({
    this.id,
    required this.userId,
    required this.stripePaymentIntentId,
    required this.amount,
    this.currency = 'brl',
    required this.status,
    this.subscriptionId,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      userId: json['user_id'],
      stripePaymentIntentId: json['stripe_payment_intent_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'brl',
      status: json['status'],
      subscriptionId: json['subscription_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'amount': amount,
      'currency': currency,
      'status': status,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
    };
  }

  bool get isSuccessful => status == 'succeeded';
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String interval;
  final String priceId;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.interval,
    required this.priceId,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      interval: json['interval'],
      priceId: json['price_id'],
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'interval': interval,
      'price_id': priceId,
      'features': features,
    };
  }
}