// Eduardo Kairalla - 24024241

// Header for the startup detail screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- WIDGET ---

class StartupHeader extends StatelessWidget {
  final StartupModel startup;

  const StartupHeader({
    super.key,
    required this.startup,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                context.canPop() ? context.pop() : context.go('/dashboard'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  startup.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  startup.tagline,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 38),
        ],
      ),
    );
  }

}
