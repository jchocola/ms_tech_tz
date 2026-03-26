/// Represents a subscription plan type
enum SubscriptionType { monthly, yearly }

/// Subscription entity representing a VPN subscription plan
class Subscription {
  final String id;
  final SubscriptionType type;
  final double price;
  final double? discount;
  final String title;
  final String description;

  const Subscription({
    required this.id,
    required this.type,
    required this.price,
    this.discount,
    required this.title,
    required this.description,
  });

  /// Get the formatted price
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Get the discount percentage if available
  String? get formattedDiscount {
    if (discount == null) return null;
    return '${discount!.toInt()}% OFF';
  }

  /// Monthly subscription plan
  static const monthly = Subscription(
    id: 'monthly_plan',
    type: SubscriptionType.monthly,
    price: 9.99,
    title: 'Monthly Plan',
    description: 'Billed monthly',
  );

  /// Yearly subscription plan with discount
  static const yearly = Subscription(
    id: 'yearly_plan',
    type: SubscriptionType.yearly,
    price: 59.99,
    discount: 50,
    title: 'Yearly Plan',
    description: 'Billed annually',
  );

  /// All available subscriptions
  static List<Subscription> get all => [monthly, yearly];
}
