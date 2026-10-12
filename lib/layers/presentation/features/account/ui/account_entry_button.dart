import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';

/// Home-header entry to the existing OwlSonic Account screen. A small dot
/// marks a signed-in session.
class AccountEntryButton extends StatelessWidget {
  const AccountEntryButton({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CloudSessionCubit, CloudSessionState>(
        buildWhen: (a, b) => a != b,
        builder: (context, session) => IconButton(
          key: const ValueKey('home-account-button'),
          tooltip: context.tr('cloud.title'),
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          onPressed: () => context.pushNamed(AppRouterNames.account),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                session.signedIn
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                size: 22,
              ),
              if (session.signedIn)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    key: const ValueKey('account-signed-in-dot'),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bg, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
