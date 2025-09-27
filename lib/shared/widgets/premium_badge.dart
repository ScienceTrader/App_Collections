import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/subscription/controllers/subscription_controller.dart';

class PremiumBadge extends StatelessWidget {
  final bool showLabel;
  
  const PremiumBadge({Key? key, this.showLabel = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPremium = SubscriptionController.to.isPremium.value;
      if (!isPremium) return SizedBox();
      
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade400, Colors.amber.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 12, color: Colors.white),
            if (showLabel) ...[
              SizedBox(width: 4),
              Text(
                'PREMIUM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}