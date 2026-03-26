import 'package:equatable/equatable.dart';

/// States for the Paywall BLoC
abstract class PaywallState extends Equatable {
  const PaywallState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PaywallInitial extends PaywallState {
  const PaywallInitial();
}

/// Loading state
class PaywallLoading extends PaywallState {
  const PaywallLoading();
}

/// Subscription purchased successfully
class PaywallSuccess extends PaywallState {
  const PaywallSuccess();
}

/// Error state with message
class PaywallError extends PaywallState {
  final String message;

  const PaywallError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when subscription is already active
class PaywallSubscribed extends PaywallState {
  const PaywallSubscribed();
}
