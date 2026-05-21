// Eduardo Kairalla - 24024241

// User profile screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/app/theme/theme_controller.dart';
import 'package:mesclainvest/core/models/user_profile.dart';
import 'package:mesclainvest/pages/profile/controllers/profile_controller.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';
import 'package:mesclainvest/shared/widgets/bottom_nav.dart';

// --- PAGE ---

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();

  @override
  void initState() {
    super.initState();
    _controller.loadStats();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        AppState.instance,
        ThemeController.instance,
      ]),
      builder: (context, child) {
        final profile = AppState.instance.profile;

        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                children: [
                  _avatar(profile),
                  const SizedBox(height: 12),
                  _nameAndEmail(profile),
                  const SizedBox(height: 8),
                  _verifiedBadge(),
                  const SizedBox(height: 24),
                  _statsCard(profile),
                  const SizedBox(height: 16),
                  _twoFACard(profile),
                  const SizedBox(height: 16),
                  _menuCard(context),
                  const SizedBox(height: 24),
                  _signOutButton(context),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const SafeArea(
            child: BottomNav(currentIndex: 4),
          ),
        );
      },
    );
  }

  // ── Avatar ────────────────────────────────────────────────────────────────

  Widget _avatar(UserProfile? profile) {
    final initial = (profile?.fullName.isNotEmpty == true)
        ? profile!.fullName[0].toUpperCase()
        : 'U';

    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.textPrimary(context),
          shape: BoxShape.circle,
        ),
        child: profile?.photoUrl != null
            ? ClipOval(
                child: Image.network(
                  profile!.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _avatarInitial(initial),
                ),
              )
            : _avatarInitial(initial),
      ),
    );
  }

  Widget _avatarInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.surfaceColor(context),
        ),
      ),
    );
  }

  // ── Name & email ──────────────────────────────────────────────────────────

  Widget _nameAndEmail(UserProfile? profile) {
    return Column(
      children: [
        Text(
          profile?.fullName ?? '—',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          profile?.email ?? '—',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _verifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted(context),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 14,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(width: 4),
          Text(
            'Perfil Verificado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats card ────────────────────────────────────────────────────────────

  Widget _statsCard(UserProfile? profile) {
    final loading = _controller.isLoadingStats;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    final investimentos = loading ? '...' : '${_controller.totalInvestimentos}';
    final aplicado = loading ? '...' : currency.format(_controller.totalAplicado);
    final favoritas = loading ? '...' : '${_controller.totalFavoritas}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(child: _statColumn(investimentos, 'Investimentos')),
          _verticalDivider(),
          Expanded(child: _statColumn(aplicado, 'Aplicado')),
          _verticalDivider(),
          Expanded(child: _statColumn(favoritas, 'Favoritas')),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.border(context),
    );
  }

  // ── 2FA card ──────────────────────────────────────────────────────────────

  Widget _twoFACard(UserProfile? profile) {
    final enabled = profile?.twoFaEnabled ?? false;
    final isToggling = _controller.isTogglingTwoFA;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lock_outline,
              size: 22,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autenticação 2FA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Proteção extra para sua conta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          isToggling
              ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.textPrimary(context),
                    strokeWidth: 2,
                  ),
                )
              : _switch(value: enabled, onTap: _controller.toggle2FA),
        ],
      ),
    );
  }

  // ── Menu card ─────────────────────────────────────────────────────────────

  Widget _menuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          _menuItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Minha Carteira',
            onTap: () => context.go('/carteira'),
          ),
          _menuDivider(),
          _menuItem(
            icon: Icons.settings_outlined,
            label: 'Configurações',
            onTap: () => context.push('/profile/settings'),
          ),
          _menuDivider(),
          _menuItem(
            icon: Icons.help_outline,
            label: 'Ajuda & Suporte',
            onTap: () => context.push('/profile/help'),
          ),
          _menuDivider(),
          _darkModeItem(context),
          _menuDivider(),
          _menuItem(
            icon: Icons.star_border_rounded,
            label: 'Startups Favoritas',
            onTap: () => context.go('/dashboard?filter=Favoritas'),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isLast ? Radius.zero : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderSoft(context),
      indent: 16,
      endIndent: 16,
    );
  }

  // Pedro Henrique Medeiros dos Reis - 24801656
  // Dark/light mode menu row. The icon swaps between sun (light active) and
  // moon (dark active); tapping flips ThemeController and the whole app
  // animates to the other theme. The switch widget is reused from the 2FA
  // card so the on/off affordance is identical.
  Widget _darkModeItem(BuildContext context) {
    final isDark = ThemeController.instance.isDark;
    final icon = isDark ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined;

    return InkWell(
      onTap: () => ThemeController.instance.toggle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Modo Escuro / Claro',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            _switch(value: isDark, onTap: () => ThemeController.instance.toggle()),
          ],
        ),
      ),
    );
  }

  // Compact on/off switch shared by the 2FA card and the dark mode row.
  Widget _switch({required bool value, required VoidCallback onTap}) {
    final track = value
        ? AppColors.textPrimary(context)
        : AppColors.textPrimary(context).withValues(alpha: 0.3);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: track,
          borderRadius: BorderRadius.circular(50),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Widget _signOutButton(BuildContext context) {
    return AppButton(
      label: 'Sair da Conta',
      variant: AppButtonVariant.secondary,
      icon: Icons.logout_rounded,
      isLoading: _controller.isSigningOut,
      onPressed: () async {
        await _controller.signOut();
        if (context.mounted) context.go('/');
      },
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Em breve!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
