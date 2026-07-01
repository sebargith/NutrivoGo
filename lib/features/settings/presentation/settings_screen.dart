import 'package:flutter/material.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/app_info.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import '../../sync/application/sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.store,
    this.authController,
    this.syncService,
  });

  final NutrivoGoStore? store;
  final AuthController? authController;
  final SyncService? syncService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const _AboutCard(),
                const SizedBox(height: 12),
                _AuthCard(
                  authController: widget.authController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 12),
                _SyncCard(
                  authController: widget.authController,
                  syncService: widget.syncService,
                ),
                const SizedBox(height: 12),
                _StorageCard(store: widget.store),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 36,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppInfo.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppInfo.version}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.authController,
    required this.emailController,
    required this.passwordController,
    required this.onChanged,
  });

  final AuthController? authController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = authController;
    if (controller == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.lock_outline),
          title: Text('Account'),
          subtitle: Text('Authentication is not available in this run.'),
        ),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final user = controller.currentUser;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: user == null
                ? _SignedOutAuthForm(
                    authController: controller,
                    emailController: emailController,
                    passwordController: passwordController,
                    onChanged: onChanged,
                  )
                : _SignedInAccount(
                    authController: controller,
                    email: user.email ?? 'Signed in',
                    onChanged: onChanged,
                  ),
          ),
        );
      },
    );
  }
}

class _SignedOutAuthForm extends StatelessWidget {
  const _SignedOutAuthForm({
    required this.authController,
    required this.emailController,
    required this.passwordController,
    required this.onChanged,
  });

  final AuthController authController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = authController.isBusy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Account', style: theme.textTheme.titleMedium),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !isBusy,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
          enabled: !isBusy,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.password),
          ),
        ),
        const SizedBox(height: 14),
        if (authController.errorMessage != null)
          _StatusText(
            text: authController.errorMessage!,
            icon: Icons.error_outline,
            color: theme.colorScheme.error,
          ),
        if (authController.message != null)
          _StatusText(
            text: authController.message!,
            icon: Icons.info_outline,
            color: theme.colorScheme.primary,
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: isBusy
                  ? null
                  : () => _submit(context, register: false),
              icon: const Icon(Icons.login),
              label: Text(isBusy ? 'Working' : 'Login'),
            ),
            OutlinedButton.icon(
              onPressed: isBusy ? null : () => _submit(context, register: true),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Register'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context, {required bool register}) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || !email.contains('@')) {
      _showMessage(context, 'Enter a valid email.');
      return;
    }
    if (password.length < 6) {
      _showMessage(context, 'Password must be at least 6 characters.');
      return;
    }

    if (register) {
      await authController.register(email: email, password: password);
    } else {
      await authController.signIn(email: email, password: password);
    }
    onChanged();
  }
}

class _SignedInAccount extends StatelessWidget {
  const _SignedInAccount({
    required this.authController,
    required this.email,
    required this.onChanged,
  });

  final AuthController authController;
  final String email;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.account_circle_outlined),
          title: const Text('Account'),
          subtitle: Text(email),
        ),
        if (authController.errorMessage != null)
          _StatusText(
            text: authController.errorMessage!,
            icon: Icons.error_outline,
            color: theme.colorScheme.error,
          ),
        if (authController.message != null)
          _StatusText(
            text: authController.message!,
            icon: Icons.info_outline,
            color: theme.colorScheme.primary,
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: authController.isBusy
              ? null
              : () async {
                  await authController.signOut();
                  onChanged();
                },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}

class _SyncCard extends StatelessWidget {
  const _SyncCard({required this.authController, required this.syncService});

  final AuthController? authController;
  final SyncService? syncService;

  @override
  Widget build(BuildContext context) {
    final service = syncService;
    if (service == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.cloud_off_outlined),
          title: Text('Sync'),
          subtitle: Text('Sync service is not available in this run.'),
        ),
      );
    }

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final isSignedIn = authController?.isSignedIn ?? false;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_syncIcon(service)),
                  title: const Text('Sync'),
                  subtitle: Text(_syncSubtitle(context, service, isSignedIn)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusChip(
                      icon: Icons.pending_actions_outlined,
                      label: '${service.pendingCount} pending',
                    ),
                    _StatusChip(
                      icon: Icons.wifi_off_outlined,
                      label: 'Offline usable',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: !isSignedIn || service.isSyncing
                      ? null
                      : service.sync,
                  icon: Icon(service.isSyncing ? Icons.sync : Icons.cloud_sync),
                  label: Text(service.isSyncing ? 'Syncing' : 'Sync Now'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _syncIcon(SyncService service) {
    if (service.isSyncing) {
      return Icons.sync;
    }
    if (service.status == SyncRunStatus.failed) {
      return Icons.cloud_off_outlined;
    }
    if (service.pendingCount > 0) {
      return Icons.cloud_upload_outlined;
    }
    return Icons.cloud_done_outlined;
  }

  String _syncSubtitle(
    BuildContext context,
    SyncService service,
    bool isSignedIn,
  ) {
    if (!isSignedIn) {
      return 'Sign in to push and pull this device data.';
    }
    final message = service.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }
    final lastSyncedAt = service.lastSyncedAt;
    if (lastSyncedAt != null) {
      final time = MaterialLocalizations.of(
        context,
      ).formatTimeOfDay(TimeOfDay.fromDateTime(lastSyncedAt));
      return 'Last sync today at $time.';
    }
    return 'Ready to sync local changes.';
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.store});

  final NutrivoGoStore? store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productCount = store?.products.length ?? 0;
    final logCount = store?.logItems.length ?? 0;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Storage'),
            subtitle: Text(
              'Local SQLite database on this device',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Local records'),
            subtitle: Text('$productCount products, $logCount visible logs'),
          ),
        ],
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
