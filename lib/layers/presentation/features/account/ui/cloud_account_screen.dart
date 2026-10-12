import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/legal_links.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/services/cloud/cloud_offline_library.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/auth_rules.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_account_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/auth_fields.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/app_surface.dart';

class CloudAccountScreen extends StatelessWidget {
  const CloudAccountScreen({super.key, this.initialRegister = false});

  /// Opens the form on "Create account" (first-run "Get started").
  final bool initialRegister;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(context.tr('cloud.title'), style: AppText.display3),
      ),
      body: BlocBuilder<CloudAccountCubit, CloudAccountState>(
        builder: (context, state) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              children: [
                ...switch (state.status) {
                  CloudAccountStatus.loading => const [
                    Center(child: CircularProgressIndicator()),
                  ],
                  CloudAccountStatus.unconfigured => [
                    Text(
                      context.tr('cloud.unconfigured'),
                      style: AppText.bodyM,
                    ),
                  ],
                  CloudAccountStatus.signedOut => [
                    _AuthForm(state: state, initialRegister: initialRegister),
                  ],
                  CloudAccountStatus.signedIn => [_AccountPanel(state: state)],
                },
                if (state.status != CloudAccountStatus.signedIn)
                  const _SettingsEntry(),
                const SizedBox(height: AppSpacing.l),
                const LegalLinks(showAccountDeletion: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String cloudErrorText(BuildContext context, OwlSonicApiException error) {
  if (error.isNetwork) return context.tr('cloud.errors.network');
  final request = error.requestId == null ? '' : ' (${error.requestId})';
  return '${error.message}$request';
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.state, this.initialRegister = false});
  final CloudAccountState state;
  final bool initialRegister;

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _register = widget.initialRegister;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<CloudAccountCubit>();
    if (_register) {
      // 201 means "code sent", not "signed in": continue on the code screen.
      if (await cubit.register(_email.text, _password.text) && mounted) {
        await _openVerify();
      }
    } else {
      await cubit.login(_email.text, _password.text);
    }
  }

  Future<void> _openVerify() async {
    await context.pushNamed(AppRouterNames.verifyEmail);
    if (mounted) await context.read<CloudAccountCubit>().refreshPending();
  }

  Future<void> _forgotPassword() async {
    final email = await context.pushNamed<String>(
      AppRouterNames.forgotPassword,
      queryParameters: {
        if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      },
    );
    if (email == null || !mounted) return;
    // Password reset never signs in: back to login with the address filled.
    _email.text = email;
    _password.clear();
    context.read<CloudAccountCubit>().clearError();
  }

  void _setMode(bool register) {
    context.read<CloudAccountCubit>().clearError();
    setState(() => _register = register);
  }

  bool _isPendingEmail(CloudAccountState state) {
    final pending = state.pendingEmail;
    return pending != null &&
        pending.toLowerCase() == _email.text.trim().toLowerCase();
  }

  /// Error text plus the one action that moves the user forward.
  Widget _error(CloudAccountState state) {
    final error = state.error!;
    var message = authMessageFor(error);
    Widget? action;
    if (error.code == 'EMAIL_NOT_VERIFIED') {
      if (_isPendingEmail(state)) {
        action = TextButton(
          key: const ValueKey('cloud-continue-verification'),
          onPressed: _openVerify,
          child: Text(context.tr('auth.login.continueVerification')),
        );
      } else {
        // Verification is bound to the registering installation, so another
        // device finishes by registering again with the same address.
        message = const AuthMessage('auth.errors.emailNotVerifiedOtherDevice');
        action = TextButton(
          key: const ValueKey('cloud-create-again'),
          onPressed: () => _setMode(true),
          child: Text(context.tr('auth.login.createAgain')),
        );
      }
    } else if (error.code == 'EMAIL_ALREADY_REGISTERED') {
      action = TextButton(
        key: const ValueKey('cloud-login-instead'),
        onPressed: () => _setMode(false),
        child: Text(context.tr('auth.login.haveAccountLogin')),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthStatusLine(error: message),
        ?action,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    String? tr(String? key) => key == null ? null : context.tr(key);
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.tr('cloud.signedOutTitle'), style: AppText.display3),
            const SizedBox(height: AppSpacing.s),
            Text(context.tr('cloud.signedOutIntro'), style: AppText.bodyM),
            if (state.pendingEmail != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _PendingCard(email: state.pendingEmail!, onContinue: _openVerify),
            ],
            const SizedBox(height: AppSpacing.xl),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(context.tr('cloud.login')),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(context.tr('cloud.register')),
                ),
              ],
              selected: {_register},
              onSelectionChanged: state.submitting
                  ? null
                  : (value) => _setMode(value.single),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              key: const ValueKey('cloud-email'),
              controller: _email,
              enabled: !state.submitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(labelText: context.tr('cloud.email')),
              validator: (value) =>
                  tr(CloudAccountCubit.validateEmail(value ?? '')),
            ),
            const SizedBox(height: AppSpacing.m),
            PasswordField(
              key: const ValueKey('cloud-password'),
              controller: _password,
              label: context.tr('cloud.password'),
              enabled: !state.submitting,
              showRequirement: _register,
              autofillHint: _register
                  ? AutofillHints.newPassword
                  : AutofillHints.password,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              // Older accounts keep their passwords: the 8-character rule
              // applies to new passwords only.
              validator: (value) => tr(
                _register
                    ? AuthRules.validateNewPassword(value ?? '')
                    : CloudAccountCubit.validatePassword(value ?? ''),
              ),
            ),
            if (state.error != null) _error(state),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              key: const ValueKey('cloud-submit'),
              onPressed: state.submitting ? null : _submit,
              child: BusyLabel(
                busy: state.submitting,
                label: context.tr(_register ? 'cloud.register' : 'cloud.login'),
              ),
            ),
            if (!_register)
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  key: const ValueKey('cloud-forgot-password'),
                  onPressed: state.submitting ? null : _forgotPassword,
                  child: Text(context.tr('auth.login.forgot')),
                ),
              ),
            const SizedBox(height: AppSpacing.m),
            Text(
              context.tr('cloud.uploadNotice'),
              key: const ValueKey('cloud-upload-notice'),
              style: AppText.bodyM.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Offered after an app restart while a registration waits for its code.
class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.email, required this.onContinue});
  final String email;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('cloud-pending-card'),
    padding: const EdgeInsets.all(AppSpacing.l),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.cardBR,
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.tr('auth.pending.title'), style: AppText.label),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.tr('auth.pending.body', namedArgs: {'email': email}),
          style: AppText.bodyXS,
        ),
        const SizedBox(height: AppSpacing.m),
        OutlinedButton(
          key: const ValueKey('cloud-pending-continue'),
          onPressed: onContinue,
          child: Text(context.tr('auth.pending.action')),
        ),
      ],
    ),
  );
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({required this.state});
  final CloudAccountState state;

  static String _bytes(int value) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = value.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.tr('cloud.deleteAccount'), style: AppText.display3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('cloud.deleteAccountConfirm'),
              style: AppText.bodyM,
            ),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.tr('cloud.password'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(
              context.tr('cloud.deleteAccount'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (password == null || password.isEmpty || !context.mounted) return;
    await context.read<CloudAccountCubit>().deleteAccount(password);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CloudAccountCubit>();
    final usage = state.usage;
    final email = state.user?.email ?? '';
    final limited =
        usage != null && !usage.unlimited && usage.limitBytes != null;
    final fraction = limited && usage.limitBytes! > 0
        ? (usage.usedBytes / usage.limitBytes!).clamp(0.0, 1.0)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Identity
        AppSurface(
          key: const ValueKey('account-identity'),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surface3,
                child: Text(
                  email.isEmpty ? '' : email.characters.first.toUpperCase(),
                  style: AppText.display3,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: AppText.display3.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('cloud.settingsRowSignedIn'),
                      style: AppText.bodyM,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        // Storage and sync
        AppSurface(
          key: const ValueKey('account-storage'),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('cloud.cloudStorageTitle'), style: AppText.label),
              if (usage != null) ...[
                const SizedBox(height: AppSpacing.s),
                Text(
                  usage.unlimited || usage.limitBytes == null
                      ? context.tr(
                          'cloud.storageUnlimited',
                          namedArgs: {'used': _bytes(usage.usedBytes)},
                        )
                      : context.tr(
                          'cloud.storageUsed',
                          namedArgs: {
                            'used': _bytes(usage.usedBytes),
                            'limit': _bytes(usage.limitBytes!),
                          },
                        ),
                  style: AppText.bodyL.copyWith(
                    color: usage.overLimit ? AppColors.error : AppColors.text,
                  ),
                ),
                if (fraction != null) ...[
                  const SizedBox(height: AppSpacing.s),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 4,
                      backgroundColor: AppColors.surface3,
                      color: usage.overLimit
                          ? AppColors.error
                          : AppColors.accent,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Icon(
                    switch (state.sync.phase) {
                      CloudSyncPhase.syncing => Icons.sync_rounded,
                      CloudSyncPhase.failed => Icons.error_outline_rounded,
                      CloudSyncPhase.idle => Icons.check_circle_outline,
                    },
                    size: 16,
                    color: state.sync.phase == CloudSyncPhase.failed
                        ? AppColors.error
                        : AppColors.textSub,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      context.tr(switch (state.sync.phase) {
                        CloudSyncPhase.syncing => 'cloud.syncing',
                        CloudSyncPhase.failed => 'cloud.syncFailed',
                        CloudSyncPhase.idle => 'cloud.synced',
                      }),
                      style: AppText.bodyM,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (state.migrationCount > 0 || state.migrating) ...[
          const SizedBox(height: AppSpacing.l),
          _MigrationCard(state: state),
        ],
        // On this device
        const SizedBox(height: AppSpacing.xl),
        Text(context.tr('cloud.storageModeTitle'), style: AppText.label),
        const SizedBox(height: AppSpacing.s),
        AppSurface(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StorageModeSelector(
                value: state.storageMode,
                onChanged: cubit.setStorageMode,
              ),
              if (state.storageMode == DeviceStorageMode.offline)
                if (cubit.offlineProgress case final progress?)
                  ValueListenableBuilder<OfflineProgress>(
                    valueListenable: progress,
                    builder: (context, value, _) => OfflineProgressView(
                      progress: value,
                      onRetry: cubit.retryOffline,
                    ),
                  ),
            ],
          ),
        ),
        // Devices
        const SizedBox(height: AppSpacing.xl),
        Text(context.tr('cloud.devices'), style: AppText.label),
        const SizedBox(height: AppSpacing.s),
        AppSurface(
          key: const ValueKey('account-devices'),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: state.devices.isEmpty
              ? _DevicesUnavailable(
                  failed: state.error != null,
                  onRetry: cubit.refresh,
                )
              : Column(
                  children: [
                    for (var i = 0; i < state.devices.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, color: AppColors.border),
                      _DeviceTile(device: state.devices[i]),
                    ],
                  ],
                ),
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.m),
          Text(
            cloudErrorText(context, state.error!),
            style: AppText.bodyS.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        const _SettingsEntry(topPadding: 0),
        const SizedBox(height: AppSpacing.l),
        OutlinedButton(
          onPressed: state.submitting ? null : cubit.logout,
          child: Text(context.tr('cloud.logout')),
        ),
        // Destructive, kept apart from routine account actions.
        const SizedBox(height: AppSpacing.xxxl),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: AppSpacing.s),
        TextButton(
          key: const ValueKey('account-delete'),
          onPressed: state.submitting ? null : () => _confirmDelete(context),
          child: Text(
            context.tr('cloud.deleteAccount'),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

/// The device list is empty when it has not loaded or could not be loaded;
/// say so instead of showing a bare heading.
class _DevicesUnavailable extends StatelessWidget {
  const _DevicesUnavailable({required this.failed, required this.onRetry});

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    key: const ValueKey('account-devices-unavailable'),
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
    child: Row(
      children: [
        Expanded(
          child: Text(
            context.tr(
              failed ? 'cloud.devicesFailed' : 'cloud.devicesUnavailable',
            ),
            style: AppText.bodyM,
          ),
        ),
        TextButton(onPressed: onRetry, child: Text(context.tr('common.retry'))),
      ],
    ),
  );
}

/// Settings stay reachable from Account on every platform and state.
class _SettingsEntry extends StatelessWidget {
  const _SettingsEntry({this.topPadding = AppSpacing.xxl});

  final double topPadding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: topPadding),
    child: ListTile(
      key: const ValueKey('account-settings-entry'),
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.settings_outlined, color: AppColors.textSub),
      title: Text(context.tr('settings.title'), style: AppText.bodyM),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSub,
      ),
      onTap: () => context.pushNamed(AppRouterNames.settings),
    ),
  );
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device});
  final CloudDevice device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(device.deviceName ?? device.platform, style: AppText.bodyL),
      subtitle: Text(
        device.current
            ? context.tr('cloud.thisDevice')
            : DateFormat.yMMMd(
                context.locale.toString(),
              ).format(device.lastSeenAt.toLocal()),
        style: AppText.bodyM.copyWith(fontSize: 12),
      ),
      trailing: device.current
          ? null
          : IconButton(
              tooltip: context.tr('cloud.revokeDevice'),
              icon: const Icon(Icons.logout_rounded, size: 20),
              onPressed: () =>
                  context.read<CloudAccountCubit>().revokeDevice(device.id),
            ),
    );
  }
}

/// Device-local Stream / Offline choice, shown in Account.
class StorageModeSelector extends StatelessWidget {
  const StorageModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DeviceStorageMode? value;
  final ValueChanged<DeviceStorageMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<DeviceStorageMode>(
      groupValue: value,
      onChanged: (mode) {
        if (mode != null) onChanged(mode);
      },
      child: Column(
        children: [
          RadioListTile<DeviceStorageMode>(
            key: const ValueKey('storage-mode-stream'),
            contentPadding: EdgeInsets.zero,
            value: DeviceStorageMode.stream,
            title: Text(context.tr('cloud.streamMode'), style: AppText.bodyL),
            subtitle: Text(
              context.tr('cloud.streamModeDescription'),
              style: AppText.bodyM.copyWith(fontSize: 12),
            ),
          ),
          RadioListTile<DeviceStorageMode>(
            key: const ValueKey('storage-mode-offline'),
            contentPadding: EdgeInsets.zero,
            value: DeviceStorageMode.offline,
            title: Text(context.tr('cloud.offlineMode'), style: AppText.bodyL),
            subtitle: Text(
              context.tr('cloud.offlineModeDescription'),
              style: AppText.bodyM.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Offline-mode download state: a progress bar while downloading, a summary
/// when done, and why it stopped (low space, connection) with a retry.
class OfflineProgressView extends StatelessWidget {
  const OfflineProgressView({
    super.key,
    required this.progress,
    required this.onRetry,
  });

  final OfflineProgress progress;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final counts = {
      'done': '${progress.onDevice}',
      'total': '${progress.total}',
    };
    final (text, isProblem) = switch (progress.phase) {
      OfflinePhase.idle => (null, false),
      OfflinePhase.downloading => (
        context.tr('cloud.offlineProgress', namedArgs: counts),
        false,
      ),
      OfflinePhase.complete => (
        context.tr('cloud.offlineComplete', namedArgs: counts),
        false,
      ),
      OfflinePhase.lowSpace => (
        progress.freeBytes == null
            ? context.tr('cloud.offlineOutOfSpace')
            : context.tr(
                'cloud.offlineLowSpace',
                namedArgs: {
                  'free': formatBytes(progress.freeBytes!),
                  'reserve': formatBytes(CloudOfflineLibrary.minFreeBytes),
                },
              ),
        true,
      ),
      OfflinePhase.interrupted => (
        context.tr('cloud.offlineInterrupted', namedArgs: counts),
        true,
      ),
    };
    if (text == null) return const SizedBox.shrink();
    return Padding(
      key: const ValueKey('offline-progress'),
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (progress.phase != OfflinePhase.complete)
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 4,
              ),
            ),
          const SizedBox(height: AppSpacing.s),
          Text(
            text,
            style: AppText.bodyM.copyWith(
              fontSize: 12,
              color: isProblem ? AppColors.error : null,
            ),
          ),
          if (isProblem)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onRetry,
                child: Text(context.tr('common.retry')),
              ),
            ),
        ],
      ),
    );
  }
}

/// "812 MB", "1.4 GB".
String formatBytes(int bytes) {
  const mb = 1024 * 1024;
  const gb = 1024 * mb;
  if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(1)} GB';
  return '${(bytes / mb).round()} MB';
}

class _MigrationCard extends StatelessWidget {
  const _MigrationCard({required this.state});
  final CloudAccountState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CloudAccountCubit>();
    final progress = state.migration;
    return Container(
      key: const ValueKey('cloud-migration-card'),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.tr('cloud.migrationTitle'), style: AppText.label),
          const SizedBox(height: AppSpacing.s),
          Text(
            context.tr(
              'cloud.migrationBody',
              namedArgs: {'count': '${state.migrationCount}'},
            ),
            style: AppText.bodyXS,
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              context.tr(
                'cloud.migrationProgress',
                namedArgs: {
                  'done': '${progress.done}',
                  'total': '${progress.total}',
                },
              ),
              style: AppText.bodyXS,
            ),
            if (progress.failed > 0)
              Text(
                context.tr(
                  'cloud.migrationFailed',
                  namedArgs: {'count': '${progress.failed}'},
                ),
                style: AppText.bodyXS.copyWith(color: AppColors.error),
              ),
          ],
          const SizedBox(height: AppSpacing.m),
          if (state.migrating)
            OutlinedButton(
              onPressed: cubit.stopMigration,
              child: Text(context.tr('common.cancel')),
            )
          else
            FilledButton(
              key: const ValueKey('cloud-migration-start'),
              onPressed: cubit.startMigration,
              child: Text(
                context.tr(
                  'cloud.migrationStart',
                  namedArgs: {'count': '${state.migrationCount}'},
                ),
              ),
            ),
        ],
      ),
    );
  }
}
