import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'paywall_event.dart';
import 'paywall_state.dart';

/// BLoC for managing paywall state and subscription purchases
class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  final SubscriptionRepository repository;
  StreamSubscription<bool>? _subscriptionStatusSubscription;

  PaywallBloc({required this.repository}) : super(const PaywallInitial()) {
    on<CheckSubscription>(_onCheckSubscription);
    on<PurchaseRequested>(_onPurchaseRequested);
    on<ClearSubscription>(_onClearSubscription);

    // Listen to subscription status changes
    _subscriptionStatusSubscription = repository.subscriptionStatusStream
        .listen((isSubscribed) {
          if (isSubscribed) {
            add(const CheckSubscription());
          }
        });
  }

  Future<void> _onCheckSubscription(
    CheckSubscription event,
    Emitter<PaywallState> emit,
  ) async {
    try {
      final isSubscribed = await repository.isSubscribed();
      if (isSubscribed) {
        emit(const PaywallSubscribed());
      } else {
        emit(const PaywallInitial());
      }
    } catch (e) {
      emit(const PaywallError(message: 'Failed to check subscription status'));
    }
  }

  Future<void> _onPurchaseRequested(
    PurchaseRequested event,
    Emitter<PaywallState> emit,
  ) async {
    try {
      emit(const PaywallLoading());

      // Simulate purchase delay
      await Future.delayed(const Duration(seconds: 2));

      await repository.purchaseSubscription(event.subscriptionId);
      emit(const PaywallSuccess());
    } catch (e) {
      emit(PaywallError(message: 'Purchase failed: ${e.toString()}'));
    }
  }

  Future<void> _onClearSubscription(
    ClearSubscription event,
    Emitter<PaywallState> emit,
  ) async {
    try {
      await repository.clearSubscription();
      emit(const PaywallInitial());
    } catch (e) {
      emit(PaywallError(message: 'Failed to clear subscription'));
    }
  }

  @override
  Future<void> close() {
    _subscriptionStatusSubscription?.cancel();
    return super.close();
  }
}
