// --- Startup balcão page ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Standalone page for the P2P order book of a single startup. Reached from
// the global Balcão hub when the user taps a market in the Startups tab.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/startup/controllers/startup_controller.dart';
import 'package:mesclainvest/pages/startup/widgets/startup_order_book_panel.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- PAGE ---

/// Standalone page that wraps the [StartupOrderBookPanel] for one startup.
///
/// Reached from the global Balcão hub when the user taps a market in the
/// "Startups" tab (route `/startup/:id/balcao`). Owns its own
/// [StartupController] for the metadata (token name, logo, market price) and
/// delegates the actual order book + form to [StartupOrderBookPanel].
class StartupBalcaoPage extends StatefulWidget {
  /// Firestore document id of the startup being traded.
  final String startupId;

  /// Builds the page for the startup identified by [startupId].
  const StartupBalcaoPage({super.key, required this.startupId});

  @override
  State<StartupBalcaoPage> createState() => _StartupBalcaoPageState();
}

class _StartupBalcaoPageState extends State<StartupBalcaoPage> {
  final StartupController _controller = StartupController();

  @override
  void initState() {
    super.initState();
    _controller.load(widget.startupId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground(context),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.textPrimary(context)),
            ),
          );
        }

        if (_controller.errorMessage != null || _controller.startup == null) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground(context),
            appBar: _appBar(title: 'Balcão'),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.textMuted(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _controller.errorMessage ?? 'Startup não encontrada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: AppColors.textSecondary(context)),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Tentar novamente',
                      size: AppButtonSize.small,
                      fullWidth: false,
                      onPressed: () => _controller.load(widget.startupId),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final startup = _controller.startup!;
        final tokenName = startup.tokenName.isEmpty
            ? startup.name
            : startup.tokenName;

        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          appBar: _appBar(
            title: '$tokenName/BRL',
            subtitle: startup.name,
          ),
          body: SafeArea(
            top: false,
            child: StartupOrderBookPanel(startup: startup),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar({required String title, String? subtitle}) {
    return AppBar(
      backgroundColor: AppColors.surfaceColor(context),
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/balcao');
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border(context)),
      ),
    );
  }
}
