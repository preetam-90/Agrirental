import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activeRole = ref.watch(userRoleProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.avatarUrl != null 
                  ? NetworkImage(user!.avatarUrl!) 
                  : null,
              child: user?.avatarUrl == null 
                  ? const Icon(Icons.person, size: 40) 
                  : null,
            ),
            accountName: Text(user?.fullName ?? 'User'),
            accountEmail: Text(user?.email ?? user?.phoneNumber ?? ''),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          ListTile(
            title: const Text('Mode Selection'),
            subtitle: Text('Current: ${activeRole.displayName}'),
            trailing: Switch(
              value: activeRole == UserRole.provider,
              onChanged: (isProvider) async {
                final newRole = isProvider ? UserRole.provider : UserRole.farmer;
                final success = await authNotifier.switchRole(newRole);
                if (success) {
                  ref.read(userRoleProvider.notifier).state = newRole;
                  // Close drawer
                  if (context.mounted) Navigator.pop(context);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to switch role')),
                    );
                  }
                }
              },
            ),
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // TODO: Navigate to profile
              Navigator.pop(context);
            },
          ),
          
          const Spacer(),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authNotifier.signOut();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
