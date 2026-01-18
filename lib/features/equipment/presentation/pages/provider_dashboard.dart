import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_drawer.dart';
import 'add_listing_page.dart';

class ProviderDashboard extends ConsumerWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Mode'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Fleet & Services',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Stats Section
            Row(
              children: [
                _buildStatCard(context, 'Earnings', '₹15,400', Icons.account_balance_wallet),
                const SizedBox(width: 16),
                _buildStatCard(context, 'Bookings', '12', Icons.calendar_today),
              ],
            ),
            
            const SizedBox(height: 32),
            Text(
              'My Equipment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Equipment List Placeholder
            Card(
              child: ListTile(
                leading: const Icon(Icons.agriculture),
                title: const Text('Mahindra Arjun 555 DI'),
                subtitle: const Text('Available · ₹500/hr'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddListingPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Equipment'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
