import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/statistic.dart';
import 'package:openmusic/layers/presentation/blocs/embedding_status/embedding_status_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/history/history_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/statistic/statistic_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // index 2 = twoWeeks, matches StatisticBloc initial load in BlocScope
  int _period = 2;

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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.keyboard_arrow_left, size: 28),
          color: AppColors.text,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  4,
                  AppSpacing.screenH,
                  28,
                ),
                child: Text(
                  context.tr('settings.title'),
                  style: AppText.display1,
                ),
              ),
            ),

            _sectionHeader(context.tr('settings.listening').toUpperCase()),
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

            _sectionHeader(context.tr('settings.library').toUpperCase()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH,
                ),
                child: BlocBuilder<EmbeddingStatusCubit, int>(
                  builder: (context, pendingCount) =>
                      _LibrarySection(pendingCount: pendingCount),
                ),
              ),
            ),

            _sectionHeader(context.tr('settings.app').toUpperCase()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
                child: _AppSection(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  static SliverToBoxAdapter _sectionHeader(String label) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          24,
          AppSpacing.screenH,
          10,
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
        const SizedBox(height: 12),
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
                    state.error.tr(),
                    style: GoogleFonts.figtree(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
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

  static String _sourceLabel(BuildContext context, SourceType type) =>
      context.tr(switch (type) {
        SourceType.localFile => 'library.filterLocal',
        SourceType.soundcloud => 'library.filterSoundcloud',
        SourceType.unknown => 'library.filterUnknown',
      });

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

    final bySource = stats.bySource.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = bySource.isEmpty ? 1 : bySource.first.value;

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
              Text(
                isEmpty ? '—' : _formatTime(context, stats.totalTime),
                style: AppText.display1,
              ),
              const SizedBox(height: 4),
              Text(_periodLabel(context, stats.period), style: AppText.bodyXS),
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
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(
                label: context.tr('settings.sources').toUpperCase(),
                value: bySource.isEmpty ? '—' : '${bySource.length}',
              ),
            ),
          ],
        ),

        if (bySource.isNotEmpty) ...[
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: [
                for (int i = 0; i < bySource.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _SourceBar(
                    name: _sourceLabel(context, bySource[i].key),
                    count: bySource[i].value,
                    fraction: bySource[i].value / maxCount,
                  ),
                ],
              ],
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnim.fast,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
            color: selected ? AppColors.text : AppColors.muted,
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
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label),
          const SizedBox(height: 8),
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

class _SourceBar extends StatelessWidget {
  final String name;
  final int count;
  final double fraction;

  const _SourceBar({
    required this.name,
    required this.count,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 88, child: Text(name, style: AppText.bodyS)),
        Expanded(
          child: SizedBox(
            height: 2,
            child: Stack(
              children: [
                Container(color: AppColors.surface3),
                FractionallySizedBox(
                  widthFactor: fraction.clamp(0.0, 1.0),
                  child: Container(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            style: AppText.bodyXS,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _LibrarySection extends StatelessWidget {
  final int pendingCount;

  const _LibrarySection({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackBloc, TrackState>(
      builder: (context, trackState) {
        final tracks = trackState is TrackLoaded ? trackState.tracks : const [];
        final total = tracks.length;
        final embedded = tracks.where((t) => t.embedding != null).length;
        final fraction = total == 0 ? 0.0 : embedded / total;

        return Column(
          children: [
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('settings.waveReady').toUpperCase(),
                        style: AppText.label,
                      ),
                      const Spacer(),
                      Text(
                        total == 0 ? '—' : '$embedded / $total',
                        style: AppText.bodyXS,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 2,
                      backgroundColor: AppColors.surface3,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('settings.embeddingsDescription'),
                    style: AppText.bodyXS,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Container(
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
                      color: AppColors.muted,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('settings.processingQueue'),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('settings.embeddingsPending'),
                          style: AppText.bodyXS,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: GoogleFonts.figtree(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _AppRow(
            label: context.tr('settings.version'),
            trailing: const Text('0.1.0'),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
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
    );
  }
}

class _AppRow extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final Widget? trailing;

  const _AppRow({required this.label, this.labelColor, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.l,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.figtree(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor ?? AppColors.text,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            DefaultTextStyle(style: AppText.bodyXS, child: trailing!),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
