// Eduardo Kairalla - 24024241

// Startup catalog listing page.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/catalog/controllers/catalog_controller.dart';
import 'package:mesclainvest/pages/catalog/widgets/startup_card.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- CONSTANTS ---

const _kStages = [
  (label: 'Todas', value: null),
  (label: 'Nova', value: 'new'),
  (label: 'Em operação', value: 'operating'),
  (label: 'Em expansão', value: 'expanding'),
];

// --- PAGE ---

/// I display the startup catalog listing with search and stage filtering.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

/// State for CatalogPage.
class _CatalogPageState extends State<CatalogPage> {
  final CatalogController _controller = CatalogController();
  final TextEditingController _searchController = TextEditingController();
  int _lastNavVersion = 0;

  @override
  void initState() {
    super.initState();
    _lastNavVersion = AppState.instance.navVersion;
    _controller.load();
    AppState.instance.addListener(_onNavChanged);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onNavChanged);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onNavChanged() {
    if (!mounted) return;
    final v = AppState.instance.navVersion;
    if (v != _lastNavVersion) {
      _lastNavVersion = v;
      _controller.load(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- header ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Startups',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Explore as oportunidades de investimento',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- search field ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) {
                      _controller.filterByName(v);
                      setState(() {});
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar startup...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted(context),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.textMuted(context),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _controller.filterByName('');
                              },
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.textMuted(context),
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceColor(context),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textPrimary(context),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // --- stage filter chips ---
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemCount: _kStages.length,
                    itemBuilder: (context, i) {
                      final stage = _kStages[i];
                      final isActive = _controller.selectedStage == stage.value;

                      return GestureDetector(
                        onTap: () => _controller.filterByStage(stage.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.textPrimary(context)
                                : AppColors.surfaceColor(context),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.textPrimary(context)
                                  : AppColors.border(context),
                            ),
                          ),
                          child: Text(
                            stage.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.surfaceColor(context)
                                  : AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // --- content ---
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        );
      },
    );
  }

  /// I build the main content area based on the current controller state.
  Widget _buildContent() {
    // show loading
    if (_controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.textPrimary(context)),
      );
    }

    // show error
    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_outlined,
                size: 48,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(height: 16),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary(context)),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Tentar novamente',
                size: AppButtonSize.small,
                fullWidth: false,
                onPressed: _controller.load,
              ),
            ],
          ),
        ),
      );
    }

    // show empty state
    if (_controller.startups.isEmpty) {
      final isSearching = _searchController.text.isNotEmpty;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.rocket_launch_outlined,
              size: 48,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Nenhuma startup encontrada\npara "${_searchController.text}".'
                  : 'Nenhuma startup encontrada\nnesta categoria.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary(context)),
            ),
          ],
        ),
      );
    }

    // render list
    return RefreshIndicator(
      color: AppColors.textPrimary(context),
      onRefresh: _controller.load,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: _controller.startups.length,
        itemBuilder: (context, i) {
          final startup = _controller.startups[i];
          return StartupCard(
            startup: startup,
            isFavorite: _controller.isFavorite(startup.id),
            onFavoriteTap: () => _controller.toggleFavorite(startup.id),
            onReturn: () => _controller.load(),
          );
        },
      ),
    );
  }
}
