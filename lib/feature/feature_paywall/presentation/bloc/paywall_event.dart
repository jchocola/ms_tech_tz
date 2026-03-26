/// Events for the Paywall BLoC
abstract class PaywallEvent {
  const PaywallEvent();
}

/// Event to check subscription status
class CheckSubscription extends PaywallEvent {
  const CheckSubscription();
}

/// Event to purchase a subscription
class PurchaseRequested extends PaywallEvent {
  final String subscriptionId;

  const PurchaseRequested({required this.subscriptionId});
}

/// Event to clear subscription (for testing)
class ClearSubscription extends PaywallEvent {
  const ClearSubscription();
}
