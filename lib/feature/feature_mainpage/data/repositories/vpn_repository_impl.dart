import 'dart:async';
import '../../domain/entities/vpn_server.dart';
import '../../domain/repositories/vpn_repository.dart';

/// Implementation of VpnRepository
class VpnRepositoryImpl implements VpnRepository {
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  VpnServer? _selectedServer;
  bool _isConnected = false;

  // Sample servers list
  final List<VpnServer> _servers = [
    const VpnServer(
      id: 'us_1',
      name: 'New York',
      country: 'United States',
      countryCode: '🇺🇸',
      ping: 45,
    ),
    const VpnServer(
      id: 'us_2',
      name: 'Los Angeles',
      country: 'United States',
      countryCode: '🇺🇸',
      ping: 78,
      isPremium: true,
    ),
    const VpnServer(
      id: 'uk_1',
      name: 'London',
      country: 'United Kingdom',
      countryCode: '🇬🇧',
      ping: 92,
    ),
    const VpnServer(
      id: 'de_1',
      name: 'Frankfurt',
      country: 'Germany',
      countryCode: '🇩🇪',
      ping: 65,
    ),
    const VpnServer(
      id: 'jp_1',
      name: 'Tokyo',
      country: 'Japan',
      countryCode: '🇯🇵',
      ping: 120,
      isPremium: true,
    ),
    const VpnServer(
      id: 'sg_1',
      name: 'Singapore',
      country: 'Singapore',
      countryCode: '🇸🇬',
      ping: 88,
    ),
  ];

  @override
  Future<List<VpnServer>> getServers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _servers;
  }

  @override
  Future<void> connect(String serverId) async {
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));
    _isConnected = true;
    _connectionController.add(true);
  }

  @override
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = false;
    _connectionController.add(false);
  }

  @override
  Future<bool> isConnected() async {
    return _isConnected;
  }

  @override
  Stream<bool> get connectionStatusStream => _connectionController.stream;

  @override
  VpnServer? getSelectedServer() => _selectedServer;

  @override
  void setSelectedServer(VpnServer server) {
    _selectedServer = server;
  }

  /// Dispose resources
  void dispose() {
    _connectionController.close();
  }
}
