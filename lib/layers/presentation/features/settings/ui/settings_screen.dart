import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/core/config/app_links.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_settings.dart';
import 'package:owlsonic/layers/domain/entities/statistic.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/features/statistic/bloc/statistic/statistic_bloc.dart';
import 'package:owlsonic/layers/presentation/features/telemetry/bloc/telemetry/telemetry_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/app_surface.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/legal_links.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // index 2 = twoWeeks, matches StatisticBloc initial load in BlocScope
  int _period = 2;
  final _listeningKey = GlobalKey();
  final _libraryKey = GlobalKey();
  final _appKey = GlobalKey();

  void _goTo(GlobalKey key) {
    final target = key.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 180),
      );
    }
  }

  static const _statsPeriods = [
    StatsPeriod.today,
    StatsPeriod.week,
    StatsPeriod.twoWeeks,
    StatsPeriod.month,
    StatsPeriod.allTime,
  ];

  void _onPeriodChanged(BuildContext context, int index) {
    setState(() => _period = index);
    context.read<StatisticBloc>().add(ChangePeriodEvent(_statsPeriods[index]));
  }

  @override
  Widget build(BuildContext context) {
    final desktop = AppLayout.isDesktopPlatform;
    final showCategories = desktop && MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        scrolledUnderElevation: 0,
        leading: desktop
            ? null
            : IconButton(
                onPressed: context.pop,
                icon: const Icon(Icons.keyboard_arrow_left, size: 28),
                color: AppColors.text,
              ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: desktop ? 1160 : double.infinity,
            ),
            child: Row(
              children: [
                if (showCategories)
                  SizedBox(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18, top: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () => _goTo(_listeningKey),
                            child: Text(context.tr('settings.listening')),
                          ),
                          TextButton(
                            onPressed: () => _goTo(_libraryKey),
                            child: Text(context.tr('settings.library')),
                          ),
                          TextButton(
                            onPressed: () => _goTo(_appKey),
                            child: Text(context.tr('settings.app')),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenH,
                            0,
                            AppSpacing.screenH,
                            8,
                          ),
                          child: Text(
                            context.tr('settings.title'),
                            style: AppText.display1,
                          ),
                        ),
                      ),

                      _sectionHeader(
                        context.tr('settings.listening').toUpperCase(),
                        key: _listeningKey,
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenH,
                          ),
                          child: _ListeningSection(
                            period: _period,
                            onPeriodChange: (i) => _onPeriodChanged(context, i),
                          ),
                        ),
                      ),

                      _sectionHeader(
                        context.tr('settings.library').toUpperCase(),
                        key: _libraryKey,
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenH,
                          ),
                          child:
                              BlocBuilder<
                                MusicAnalysisStatusCubit,
                                MusicAnalysisStatusState
                              >(
                                builder: (context, analysis) =>
                                    _LibrarySection(analysis: analysis),
                              ),
                        ),
                      ),

                      _sectionHeader(
                        context.tr('settings.app').toUpperCase(),
                        key: _appKey,
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenH,
                          ),
                          child: _AppSection(),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: SizedBox(height: desktop ? 32 : 24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static SliverToBoxAdapter _sectionHeader(String label, {Key? key}) {
    return SliverToBoxAdapter(
      child: Padding(
        key: key,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          20,
          AppSpacing.screenH,
          8,
        ),
        child: Text(label, style: AppText.label),
      ),
    );
  }
}

class _ListeningSection extends StatelessWidget {
  final int period;
  final ValueChanged<int> onPeriodChange;

  const _ListeningSection({required this.period, required this.onPeriodChange});

  static const _chipKeys = [
    'settings.todayShort',
    'settings.weekShort',
    'settings.twoWeeksShort',
    'settings.monthShort',
    'settings.allShort',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_chipKeys.length, (i) {
              return _PeriodChip(
                label: context.tr(_chipKeys[i]).toUpperCase(),
                selected: i == period,
                onTap: () => onPeriodChange(i),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        BlocBuilder<StatisticBloc, StatisticState>(
          builder: (context, state) {
            if (state is StatisticsLoaded) {
              return _StatsBody(stats: state.statistics);
            }
            if (state is StatisticsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    state.error.localized(context),
                    style: AppText.bodyM,
                  ),
                ),
              );
            }
            return const _StatsLoading();
          },
        ),
      ],
    );
  }
}

class _StatsLoading extends StatelessWidget {
  const _StatsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('settings.listeningTime').toUpperCase(),
                style: AppText.label,
              ),
              const SizedBox(height: 10),
              const _Shimmer(width: 130, height: 34),
              const SizedBox(height: 6),
              const _Shimmer(width: 80, height: 11),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(child: _ShimmerCard()),
            SizedBox(width: 8),
            Expanded(child: _ShimmerCard()),
            SizedBox(width: 8),
            Expanded(child: _ShimmerCard()),
          ],
        ),
      ],
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;
  const _Shimmer({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final Statistic stats;

  const _StatsBody({required this.stats});

  static String _periodLabel(BuildContext context, StatsPeriod period) =>
      context.tr(switch (period) {
        StatsPeriod.today => 'statistics.periodToday',
        StatsPeriod.week => 'statistics.periodWeek',
        StatsPeriod.twoWeeks => 'statistics.periodTwoWeeks',
        StatsPeriod.month => 'statistics.periodMonth',
        StatsPeriod.allTime => 'statistics.periodAll',
      });

  static String _formatTime(BuildContext context, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return context.tr(
        'settings.durationHoursMinutes',
        namedArgs: {'hours': '$hours', 'minutes': '$minutes'},
      );
    }
    if (minutes > 0) {
      return context.tr(
        'settings.durationMinutes',
        namedArgs: {'minutes': '$minutes'},
      );
    }
    return context.tr(
      'settings.durationSeconds',
      namedArgs: {'seconds': '${duration.inSeconds}'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = stats.totalTracks == 0;

    return Column(
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('settings.listeningTime').toUpperCase(),
                style: AppText.label,
              ),
              const SizedBox(height: 6),
              Text(
                isEmpty ? '—' : _formatTime(context, stats.totalTime),
                style: AppText.display1,
              ),
              const SizedBox(height: 2),
              Text(_periodLabel(context, stats.period), style: AppText.bodyM),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: context.tr('settings.tracks').toUpperCase(),
                value: isEmpty ? '—' : '${stats.totalTracks}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(
                label: context.tr('settings.artists').toUpperCase(),
                value: isEmpty ? '—' : '${stats.uniqueArtists}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: AppAnim.fast,
        margin: const EdgeInsets.only(right: 8),
        constraints: const BoxConstraints(minHeight: 40),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.borderAct : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.figtree(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.text : AppColors.textSub,
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarySection extends StatelessWidget {
  final MusicAnalysisStatusState analysis;

  const _LibrarySection({required this.analysis});

  @override
  Widget build(BuildContext context) {
    // Nothing left to do: a quiet line instead of a card with "0 remaining".
    if (analysis.pendingCount == 0) {
      return Padding(
        key: const ValueKey('settings-library-ready'),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 18,
              color: AppColors.textSub,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr('settings.libraryReady'),
                style: AppText.bodyM,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.memory_rounded,
              color: AppColors.textSub,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('settings.analyzingLibrary'),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(
                    'settings.tracksRemaining',
                    namedArgs: {'count': '${analysis.pendingCount}'},
                  ),
                  style: AppText.bodyM,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppSection extends StatelessWidget {
  const _AppSection();

  Future<void> _clearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
        title: Text(
          context.tr('settings.clearHistory'),
          style: AppText.display3,
        ),
        content: Text(
          context.tr('settings.clearHistoryConfirm'),
          style: AppText.bodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('common.cancel'), style: AppText.bodyM),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.tr('common.clear'),
              style: GoogleFonts.figtree(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<HistoryBloc>().add(const ClearHistoryEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TelemetryCubit, TelemetryState>(
      listenWhen: (previous, current) =>
          previous.error?.occurrenceId != current.error?.occurrenceId &&
          current.error != null,
      listener: (context, state) {
        CustomSnackBar.uiError(context, state.error!);
      },
      builder: (context, telemetry) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardBR,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            _AppRow(
              label: context.tr('settings.crashReports'),
              subtitle: context.tr(
                telemetry.available
                    ? 'settings.crashReportsDescription'
                    : 'settings.crashReportsUnavailable',
              ),
              trailing: Switch.adaptive(
                value: telemetry.consentEnabled,
                onChanged: telemetry.available && !telemetry.isUpdating
                    ? context.read<TelemetryCubit>().setConsent
                    : null,
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            _AppRow(
              label: context.tr('settings.usageAnalytics'),
              subtitle: context.tr(
                telemetry.analyticsAvailable
                    ? 'settings.usageAnalyticsDescription'
                    : 'settings.usageAnalyticsUnavailable',
              ),
              trailing: Switch.adaptive(
                value: telemetry.analyticsEnabled,
                onChanged: telemetry.analyticsAvailable && !telemetry.isUpdating
                    ? context.read<TelemetryCubit>().setAnalyticsConsent
                    : null,
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            const _AutoSyncRows(),
            GestureDetector(
              key: const ValueKey('settings-owlsonic-account'),
              onTap: () => context.pushNamed(AppRouterNames.account),
              behavior: HitTestBehavior.opaque,
              child: BlocBuilder<CloudSessionCubit, CloudSessionState>(
                buildWhen: (a, b) => a != b,
                builder: (context, session) => _AppRow(
                  label: context.tr('cloud.settingsRow'),
                  subtitle: context.tr(
                    !session.configured
                        ? 'cloud.settingsRowUnconfigured'
                        : session.signedIn
                        ? 'cloud.settingsRowSignedIn'
                        : 'cloud.settingsRowSignedOut',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textSub,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            GestureDetector(
              key: const ValueKey('settings-about'),
              onTap: () => context.pushNamed(AppRouterNames.about),
              behavior: HitTestBehavior.opaque,
              child: _AppRow(
                label: context.tr('settings.about'),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textSub,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            for (final (key, label, uri) in [
              ('settings-privacy', 'legal.privacy', AppLinks.privacy),
              ('settings-terms', 'legal.terms', AppLinks.terms),
              (
                'settings-account-deletion',
                'legal.accountDeletion',
                AppLinks.accountDeletion,
              ),
              ('settings-support', 'legal.support', AppLinks.support),
            ]) ...[
              GestureDetector(
                key: ValueKey(key),
                onTap: () => openLegalLink(context, uri),
                behavior: HitTestBehavior.opaque,
                child: _AppRow(
                  label: context.tr(label),
                  subtitle: key == 'settings-support'
                      ? context.tr('legal.supportDescription')
                      : null,
                  trailing: const Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: AppColors.textSub,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
            ],
            GestureDetector(
              onTap: () => _clearHistory(context),
              behavior: HitTestBehavior.opaque,
              child: _AppRow(
                label: context.tr('settings.clearPlayHistory'),
                labelColor: AppColors.error,
                trailing: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      title: Text(context.tr('settings.about')),
      backgroundColor: AppColors.bg,
      scrolledUnderElevation: 0,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenH),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.cardBR,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const _VersionRow(),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.border,
                    ),
                    GestureDetector(
                      key: const ValueKey('about-licenses'),
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'OwlSonic',
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: _AppRow(
                        label: context.tr('legal.licenses'),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.textSub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// The installed version and build number, for support requests.
class _VersionRow extends StatelessWidget {
  const _VersionRow();

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: appVersionLabel(),
    builder: (context, snapshot) => _AppRow(
      label: context.tr('settings.version'),
      trailing: SelectableText(
        snapshot.data ?? '…',
        key: const ValueKey('settings-version'),
      ),
    ),
  );
}

/// "1.2.3 (45)" from the platform package info; "unknown" if unavailable.
Future<String> appVersionLabel() async {
  try {
    final info = await PackageInfo.fromPlatform();
    final build = info.buildNumber.trim();
    return build.isEmpty ? info.version : '${info.version} ($build)';
  } catch (_) {
    return 'unknown';
  }
}

/// Auto-sync switches. Hidden in builds without an OwlSonic backend.
class _AutoSyncRows extends StatelessWidget {
  const _AutoSyncRows();

  @override
  Widget build(BuildContext context) {
    if (!getIt.isRegistered<AutoSyncSettings>()) return const SizedBox.shrink();
    final settings = getIt<AutoSyncSettings>();
    return BlocBuilder<CloudSessionCubit, CloudSessionState>(
      buildWhen: (a, b) => a != b,
      builder: (context, session) {
        if (!session.configured) return const SizedBox.shrink();
        return ValueListenableBuilder<AutoSyncPrefs>(
          valueListenable: settings.current,
          builder: (context, prefs, _) => Column(
            children: [
              _AppRow(
                label: context.tr('settings.autoSync'),
                subtitle: context.tr('settings.autoSyncDescription'),
                trailing: Switch.adaptive(
                  key: const ValueKey('settings-auto-sync'),
                  value: prefs.enabled,
                  onChanged: settings.setEnabled,
                ),
              ),
              if (prefs.enabled)
                _AppRow(
                  label: context.tr('settings.wifiOnly'),
                  subtitle: context.tr('settings.wifiOnlyDescription'),
                  trailing: Switch.adaptive(
                    key: const ValueKey('settings-wifi-only'),
                    value: prefs.wifiOnly,
                    onChanged: settings.setWifiOnly,
                  ),
                ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
            ],
          ),
        );
      },
    );
  }
}

class _AppRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final Widget? trailing;

  const _AppRow({
    required this.label,
    this.subtitle,
    this.labelColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.m,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? AppColors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: AppText.bodyM.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            if (trailing != null)
              DefaultTextStyle(
                style: AppText.bodyM.copyWith(fontSize: 12),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l,
        ),
        child: child,
      ),
    );
  }
}
