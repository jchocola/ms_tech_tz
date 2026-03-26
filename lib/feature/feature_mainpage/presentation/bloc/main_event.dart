/// Events for the Main Page BLoC
abstract class MainEvent {
  const MainEvent();
}

/// Event to load VPN servers
class LoadServers extends MainEvent {
  const LoadServers();
}

/// Event to connect to a server
class ConnectToServer extends MainEvent {
  final String serverId;

  const ConnectToServer({required this.serverId});
}

/// Event to disconnect from VPN
class DisconnectServer extends MainEvent {
  const DisconnectServer();
}

/// Event to select a server
class SelectServer extends MainEvent {
  final String serverId;

  const SelectServer({required this.serverId});
}

/// Event to check subscription status
class CheckSubscription extends MainEvent {
  const CheckSubscription();
}

/// Event to update connection status (internal)
class UpdateConnectionEvent extends MainEvent {
  final bool isConnected;

  const UpdateConnectionEvent({required this.isConnected});
}

/// Event to update subscription status (internal)
class UpdateSubscriptionEvent extends MainEvent {
  final bool isSubscribed;

  const UpdateSubscriptionEvent({required this.isSubscribed});
}
