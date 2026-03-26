/// VPN Server entity representing a server location
class VpnServer {
  final String id;
  final String name;
  final String country;
  final String countryCode;
  final int ping;
  final bool isPremium;

  const VpnServer({
    required this.id,
    required this.name,
    required this.country,
    required this.countryCode,
    required this.ping,
    this.isPremium = false,
  });

  /// Get ping status color
  String get pingStatus {
    if (ping < 50) return 'Good';
    if (ping < 100) return 'Fair';
    return 'High';
  }
}
