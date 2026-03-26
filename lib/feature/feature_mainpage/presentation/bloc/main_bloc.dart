import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../feature_paywall/domain/repositories/subscription_repository.dart';
import '../../domain/repositories/vpn_repository.dart';
import 'main_event.dart';
import 'main_state.dart';

/// BLoC for managing main page state and VPN connections
class MainBloc extends Bloc<MainEvent, MainState> {
  final VpnRepository vpnRepository;
  final SubscriptionRepository subscriptionRepository;
  StreamSubscription<bool>? _connectionStatusSubscription;
  StreamSubscription<bool>? _subscriptionStatusSubscription;

  MainBloc({required this.vpnRepository, required this.subscriptionRepository})
    : super(const MainInitial()) {
    on<LoadServers>(_onLoadServers);
    on<ConnectToServer>(_onConnectToServer);
    on<DisconnectServer>(_onDisconnectServer);
    on<SelectServer>(_onSelectServer);
    on<CheckSubscription>(_onCheckSubscription);
    on<UpdateConnectionEvent>(_onUpdateConnectionEvent);
    on<UpdateSubscriptionEvent>(_onUpdateSubscriptionEvent);

    // Initialize
    _initialize();
  }

  Future<void> _initialize() async {
    // Check subscription status
    add(const CheckSubscription());

    // Load servers
    add(const LoadServers());

    // Listen to connection status changes
    _connectionStatusSubscription = vpnRepository.connectionStatusStream.listen(
      (isConnected) {
        if (state is ServersLoaded) {
          final currentState = state as ServersLoaded;
          add(UpdateConnectionEvent(isConnected: isConnected));
        }
      },
    );

    // Listen to subscription status changes
    _subscriptionStatusSubscription = subscriptionRepository
        .subscriptionStatusStream
        .listen((isSubscribed) {
          if (state is ServersLoaded) {
            final currentState = state as ServersLoaded;
            add(UpdateSubscriptionEvent(isSubscribed: isSubscribed));
          }
        });
  }

  Future<void> _onLoadServers(
    LoadServers event,
    Emitter<MainState> emit,
  ) async {
    try {
      emit(const MainLoading());
      final servers = await vpnRepository.getServers();

      // Auto-select first server
      if (servers.isNotEmpty) {
        vpnRepository.setSelectedServer(servers.first);
      }

      final isSubscribed = await subscriptionRepository.isSubscribed();
      emit(
        ServersLoaded(
          servers: servers,
          selectedServer: vpnRepository.getSelectedServer(),
          isSubscribed: isSubscribed,
        ),
      );
    } catch (e) {
      emit(const MainError(message: 'Failed to load servers'));
    }
  }

  Future<void> _onConnectToServer(
    ConnectToServer event,
    Emitter<MainState> emit,
  ) async {
    try {
      emit(const MainConnecting());
      await vpnRepository.connect(event.serverId);
    } catch (e) {
      emit(MainError(message: 'Connection failed'));
    }
  }

  Future<void> _onDisconnectServer(
    DisconnectServer event,
    Emitter<MainState> emit,
  ) async {
    try {
      await vpnRepository.disconnect();
    } catch (e) {
      emit(MainError(message: 'Disconnect failed'));
    }
  }

  void _onSelectServer(SelectServer event, Emitter<MainState> emit) {
    try {
      if (state is ServersLoaded) {
        final currentState = state as ServersLoaded;
        final server = currentState.servers.firstWhere(
          (s) => s.id == event.serverId,
          orElse: () =>
              currentState.selectedServer ?? currentState.servers.first,
        );

        vpnRepository.setSelectedServer(server);
        emit(currentState.copyWith(selectedServer: server));
      }
    } catch (e) {
      emit(MainError(message: 'Failed to select server'));
    }
  }

  Future<void> _onCheckSubscription(
    CheckSubscription event,
    Emitter<MainState> emit,
  ) async {
    try {
      final isSubscribed = await subscriptionRepository.isSubscribed();
      if (state is ServersLoaded) {
        emit((state as ServersLoaded).copyWith(isSubscribed: isSubscribed));
      }
    } catch (e) {
      // Ignore errors in subscription check
    }
  }

  void _onUpdateConnectionEvent(
    UpdateConnectionEvent event,
    Emitter<MainState> emit,
  ) {
    if (state is ServersLoaded) {
      emit((state as ServersLoaded).copyWith(isConnected: event.isConnected));
    }
  }

  void _onUpdateSubscriptionEvent(
    UpdateSubscriptionEvent event,
    Emitter<MainState> emit,
  ) {
    if (state is ServersLoaded) {
      emit((state as ServersLoaded).copyWith(isSubscribed: event.isSubscribed));
    }
  }

  @override
  Future<void> close() {
    _connectionStatusSubscription?.cancel();
    _subscriptionStatusSubscription?.cancel();
    return super.close();
  }
}
