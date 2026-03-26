import '../entities/vpn_server.dart';

/// Abstract repository interface for VPN operations
abstract class VpnRepository {
  /// Get list of available VPN servers
  Future<List<VpnServer>> getServers();

  /// Connect to a VPN server
  Future<void> connect(String serverId);

  /// Disconnect from VPN
  Future<void> disconnect();

  /// Check if currently connected
  Future<bool> isConnected();

  /// Get current connection status stream
  Stream<bool> get connectionStatusStream;

  /// Get selected server
  VpnServer? getSelectedServer();

  /// Set selected server
  void setSelectedServer(VpnServer server);
}
