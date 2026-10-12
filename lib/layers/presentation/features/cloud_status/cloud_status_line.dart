import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';

/// One quiet line about where the music lives and whether it is in sync.
/// Tapping opens Account for details; a failed sync offers Retry instead.
class CloudStatusLine extends StatelessWidget {
  const CloudStatusLine({
    super.key,
    this.padding = EdgeInsets.zero,
    this.minHeight = 32,
  });

  final EdgeInsetsGeometry padding;
  final double minHeight;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CloudStatusCubit, CloudStatusState>(
        builder: (context, status) {
          if (status.kind == CloudStatusKind.hidden ||
              status.kind == CloudStatusKind.checking) {
            return const SizedBox.shrink();
          }
          final failed = status.kind == CloudStatusKind.failed;
          return Padding(
            padding: padding,
            child: InkWell(
              key: const ValueKey('cloud-status-line'),
              borderRadius: BorderRadius.circular(8),
              onTap: failed
                  ? context.read<CloudStatusCubit>().retry
                  : () => context.pushNamed(AppRouterNames.account),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusMark(kind: status.kind),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _message(context, status),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyXS.copyWith(
                          fontSize: 12,
                          color: failed ? AppColors.text : AppColors.textSub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  static String _message(BuildContext context, CloudStatusState status) =>
      switch (status.kind) {
        CloudStatusKind.deviceOnly => context.tr('cloudStatus.deviceOnly'),
        CloudStatusKind.upToDate => context.tr('cloudStatus.upToDate'),
        CloudStatusKind.syncing => context.tr('cloudStatus.syncing'),
        CloudStatusKind.uploading =>
          status.pendingUploads == 1
              ? context.tr('cloudStatus.uploadingOne')
              : context.tr(
                  'cloudStatus.uploading',
                  namedArgs: {'count': '${status.pendingUploads}'},
                ),
        CloudStatusKind.offline => context.tr('cloudStatus.offline'),
        CloudStatusKind.failed => context.tr('cloudStatus.failed'),
        CloudStatusKind.hidden || CloudStatusKind.checking => '',
      };
}

class _StatusMark extends StatelessWidget {
  const _StatusMark({required this.kind});

  final CloudStatusKind kind;

  @override
  Widget build(BuildContext context) {
    if (kind == CloudStatusKind.syncing || kind == CloudStatusKind.uploading) {
      return const SizedBox.square(
        dimension: 10,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: AppColors.muted,
        ),
      );
    }
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (kind) {
          CloudStatusKind.upToDate => AppColors.success,
          CloudStatusKind.failed => AppColors.error,
          _ => AppColors.muted,
        },
      ),
    );
  }
}
