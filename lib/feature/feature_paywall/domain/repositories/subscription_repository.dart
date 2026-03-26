/// Abstract repository interface for subscription management
abstract class SubscriptionRepository {
  /// Check if user has an active subscription
  Future<bool> isSubscribed();

  /// Get the current subscription type (monthly/yearly)
  Future<String?> getSubscriptionType();

  /// Get subscription expiry date
  Future<DateTime?> getSubscriptionExpiry();

  /// Purchase a subscription
  Future<void> purchaseSubscription(String subscriptionId);

  /// Clear subscription data (logout/reset)
  Future<void> clearSubscription();

  /// Stream of subscription status changes
  Stream<bool> get subscriptionStatusStream;
}
