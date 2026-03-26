import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/subscription.dart';
import 'bloc/paywall_bloc.dart';
import 'bloc/paywall_event.dart';
import 'bloc/paywall_state.dart';

/// Paywall page with subscription options
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaywallBloc, PaywallState>(
      listener: (context, state) {
        if (state is PaywallSuccess) {
          // Navigate to main page after successful purchase
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription activated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/main');
        } else if (state is PaywallSubscribed) {
          // Already subscribed, navigate to main page
          context.go('/main');
        } else if (state is PaywallError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // VPN Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF06B6D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'Unlock Premium VPN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  'Get unlimited access to all servers and features',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Features list
                _buildFeatureList(),
                const SizedBox(height: 32),
                // Subscription plans
                _buildSubscriptionPlans(context),
                const SizedBox(height: 24),
                // Continue button
                _buildContinueButton(context),
                const SizedBox(height: 16),
                // Terms
                _buildTermsText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'Unlimited bandwidth',
      '5000+ servers worldwide',
      'Ultra-fast connection speeds',
      'Military-grade encryption',
      'No logs policy',
      'Ad & malware blocking',
    ];

    return Column(
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSubscriptionPlans(BuildContext context) {
    return Column(
      children: Subscription.all.map((subscription) {
        final isYearly = subscription.type == SubscriptionType.yearly;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _SubscriptionCard(
            subscription: subscription,
            onTap: () {
              context.read<PaywallBloc>().add(
                PurchaseRequested(subscriptionId: subscription.id),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return BlocBuilder<PaywallBloc, PaywallState>(
      builder: (context, state) {
        final isLoading = state is PaywallLoading;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    // Default to yearly plan if no selection
                    context.read<PaywallBloc>().add(
                      const PurchaseRequested(subscriptionId: 'yearly_plan'),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF1E3A8A).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTermsText() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 12, color: Colors.grey),
        children: [
          TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(color: Color(0xFF1E3A8A)),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(color: Color(0xFF1E3A8A)),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Subscription card widget
class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;

  const _SubscriptionCard({required this.subscription, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isYearly = subscription.type == SubscriptionType.yearly;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isYearly ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isYearly ? const Color(0xFF1E3A8A) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Radio button
            Radio<Subscription>(
              value: subscription,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xFF1E3A8A),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        subscription.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isYearly
                              ? Colors.white
                              : const Color(0xFF1E3A8A),
                        ),
                      ),
                      if (subscription.discount != null && isYearly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${subscription.discount}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscription.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isYearly ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Price
            Text(
              subscription.formattedPrice,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isYearly ? Colors.white : const Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
