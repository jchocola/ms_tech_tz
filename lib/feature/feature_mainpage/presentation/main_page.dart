import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/vpn_server.dart';
import 'bloc/main_bloc.dart';
import 'bloc/main_event.dart';
import 'bloc/main_state.dart';

/// Main VPN page with connection controls and server list
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureVPN'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<MainBloc, MainState>(
            builder: (context, state) {
              bool isSubscribed = false;
              if (state is ServersLoaded) {
                isSubscribed = state.isSubscribed;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSubscribed
                          ? const Color(0xFF10B981)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSubscribed
                              ? Icons.workspace_premium
                              : Icons.lock_outline,
                          size: 16,
                          color: isSubscribed ? Colors.white : Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSubscribed ? 'Premium' : 'Free',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSubscribed
                                ? Colors.white
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<MainBloc, MainState>(
        listener: (context, state) {
          if (state is MainError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Column(
          children: [
            // Connection Status Section
            Expanded(flex: 2, child: _buildConnectionStatus(context)),
            // Server List Section
            Expanded(flex: 3, child: _buildServerList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF06B6D4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            bool isConnected = false;
            VpnServer? selectedServer;

            if (state is ServersLoaded) {
              isConnected = state.isConnected;
              selectedServer = state.selectedServer;
            } else if (state is MainConnecting) {
              isConnected = false; // Still connecting
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Connection Indicator
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: state is MainConnecting
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            isConnected
                                ? Icons.check_circle
                                : Icons.shield_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 24),
                  // Status Text
                  Text(
                    state is MainConnecting
                        ? 'Connecting...'
                        : isConnected
                        ? 'Connected'
                        : 'Not Connected',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Server Info
                  Text(
                    selectedServer != null
                        ? '${selectedServer.countryCode} ${selectedServer.name}'
                        : 'Select a server',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Connect/Disconnect Button
                  SizedBox(
                    width: 200,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (state is MainConnecting) return;

                        if (isConnected) {
                          context.read<MainBloc>().add(
                            const DisconnectServer(),
                          );
                        } else if (selectedServer != null) {
                          context.read<MainBloc>().add(
                            ConnectToServer(serverId: selectedServer!.id),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isConnected
                            ? Colors.red
                            : Colors.white,
                        foregroundColor: isConnected
                            ? Colors.white
                            : const Color(0xFF1E3A8A),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        isConnected ? 'Disconnect' : 'Connect',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServerList(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        if (state is MainLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ServersLoaded) {
          final servers = state.servers;
          final selectedServer = state.selectedServer;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Available Servers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: servers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final server = servers[index];
                    final isSelected = selectedServer?.id == server.id;

                    return _ServerCard(
                      server: server,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<MainBloc>().add(
                          SelectServer(serverId: server.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('No servers available'));
      },
    );
  }
}

/// Server card widget
class _ServerCard extends StatelessWidget {
  final VpnServer server;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServerCard({
    required this.server,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E3A8A).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag emoji
            Text(server.countryCode, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            // Server info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        server.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (server.isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    server.country,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Ping indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 16,
                      color: _getPingColor(server.ping),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${server.ping}ms',
                      style: TextStyle(
                        fontSize: 13,
                        color: _getPingColor(server.ping),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  server.pingStatus,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPingColor(int ping) {
    if (ping < 50) return const Color(0xFF10B981); // Green
    if (ping < 100) return Colors.orange;
    return Colors.red;
  }
}
