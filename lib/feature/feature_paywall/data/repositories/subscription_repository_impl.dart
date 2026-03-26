import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/subscription_repository.dart';

/// Implementation of SubscriptionRepository using SharedPreferences
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SharedPreferences sharedPreferences;
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  // SharedPreferences keys
  static const String _keySubscribed = 'is_subscribed';
  static const String _keySubscriptionType = 'subscription_type';
  static const String _keySubscriptionExpiry = 'subscription_expiry';

  SubscriptionRepositoryImpl({required this.sharedPreferences});

  @override
  Future<bool> isSubscribed() async {
    return sharedPreferences.getBool(_keySubscribed) ?? false;
  }

  @override
  Future<String?> getSubscriptionType() async {
    return sharedPreferences.getString(_keySubscriptionType);
  }

  @override
  Future<DateTime?> getSubscriptionExpiry() async {
    final timestamp = sharedPreferences.getInt(_keySubscriptionExpiry);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<void> purchaseSubscription(String subscriptionId) async {
    await sharedPreferences.setBool(_keySubscribed, true);
    await sharedPreferences.setString(_keySubscriptionType, subscriptionId);

    // Set expiry date (1 year from now for yearly, 1 month for monthly)
    final expiryDate = subscriptionId == 'yearly_plan'
        ? DateTime.now().add(const Duration(days: 365))
        : DateTime.now().add(const Duration(days: 30));

    await sharedPreferences.setInt(
      _keySubscriptionExpiry,
      expiryDate.millisecondsSinceEpoch,
    );

    // Emit status change
    _statusController.add(true);
  }

  @override
  Future<void> clearSubscription() async {
    await sharedPreferences.remove(_keySubscribed);
    await sharedPreferences.remove(_keySubscriptionType);
    await sharedPreferences.remove(_keySubscriptionExpiry);
    _statusController.add(false);
  }

  @override
  Stream<bool> get subscriptionStatusStream => _statusController.stream;

  /// Dispose resources
  void dispose() {
    _statusController.close();
  }
}
