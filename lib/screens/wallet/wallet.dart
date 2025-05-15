import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Bucoride_Driver/providers/user.dart';
import 'package:Bucoride_Driver/widgets/app_bar/app_bar.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false).loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final rideEarnings = userProvider.rideEarnings;
    final referralCredits = userProvider.referralCredits;
    final withdrawable = rideEarnings >= 3000;
    final withdrawableBalance = withdrawable ? rideEarnings : 0;

    return Scaffold(
      appBar: CustomAppBar(title: "My Wallet", showNavBack: false, centerTitle: true),
      body: RefreshIndicator(
        onRefresh: userProvider.loadUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header balance section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade600, Colors.indigoAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Available Balance", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      "Ksh ${withdrawableBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      withdrawable ? "Ready to Withdraw" : "Earn at least Ksh 3,000 to withdraw",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Earnings Breakdown Cards
              _buildBreakdownCard(
                title: "Total Ride Earnings",
                value: rideEarnings,
                icon: Icons.directions_car_filled,
                color: Colors.blue.shade100,
              ),
              const SizedBox(height: 12),
              _buildBreakdownCard(
                title: "Referral Credit (For rides only)",
                value: referralCredits,
                icon: Icons.card_giftcard,
                color: Colors.green.shade100,
              ),

              const SizedBox(height: 32),

              // Withdraw Button
              ElevatedButton.icon(
                onPressed: withdrawable
                    ? () {
                        // TODO: Add withdrawal logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Withdrawal initiated!")),
                        );
                      }
                    : null,
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text("Withdraw"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: withdrawable ? Colors.indigo : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (!withdrawable)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "You need a minimum of Ksh 3,000 in ride earnings to withdraw.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            "Ksh ${value.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
