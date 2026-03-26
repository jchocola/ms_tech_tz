import 'package:equatable/equatable.dart';
import '../../domain/entities/vpn_server.dart';

/// States for the Main Page BLoC
abstract class MainState extends Equatable {
  const MainState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MainInitial extends MainState {
  const MainInitial();
}

/// Loading state
class MainLoading extends MainState {
  const MainLoading();
}

/// Servers loaded successfully
class ServersLoaded extends MainState {
  final List<VpnServer> servers;
  final VpnServer? selectedServer;
  final bool isConnected;
  final bool isSubscribed;

  const ServersLoaded({
    required this.servers,
    this.selectedServer,
    this.isConnected = false,
    this.isSubscribed = false,
  });

  @override
  List<Object?> get props => [
    servers,
    selectedServer,
    isConnected,
    isSubscribed,
  ];

  ServersLoaded copyWith({
    List<VpnServer>? servers,
    VpnServer? selectedServer,
    bool? isConnected,
    bool? isSubscribed,
  }) {
    return ServersLoaded(
      servers: servers ?? this.servers,
      selectedServer: selectedServer ?? this.selectedServer,
      isConnected: isConnected ?? this.isConnected,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }
}

/// Connection in progress
class MainConnecting extends MainState {
  const MainConnecting();
}

/// Error state
class MainError extends MainState {
  final String message;

  const MainError({required this.message});

  @override
  List<Object?> get props => [message];
}
