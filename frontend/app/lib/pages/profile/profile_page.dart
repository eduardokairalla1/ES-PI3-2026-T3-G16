/// Eduardo Kairalla - 24024241

/// User profile screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/core/models/user_profile.dart';
import 'package:mesclainvest/pages/profile/controllers/profile_controller.dart';
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
      animation: Listenable.merge([_controller, AppState.instance]),
      builder: (context, child) {
        final profile = AppState.instance.profile;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(),
                Expanded(
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
              ],
            ),
          ),
          bottomNavigationBar: const SafeArea(
            child: BottomNav(currentIndex: 3),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Mescla Invest',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar ────────────────────────────────────────────────────────────────

  Widget _avatar(UserProfile? profile) {
    final initial = (profile?.fullName.isNotEmpty == true)
        ? profile!.fullName[0].toUpperCase()
        : 'U';

    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.black,
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
    );
  }

  Widget _avatarInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.white,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          profile?.email ?? '—',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _verifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 14, color: Colors.black.withValues(alpha: 0.4)),
          const SizedBox(width: 4),
          Text(
            'Perfil Verificado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats card ────────────────────────────────────────────────────────────

  Widget _statsCard(UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD2D2D2)),
      ),
      child: Row(
        children: [
          Expanded(child: _statColumn('0', 'Investimentos')),
          _verticalDivider(),
          Expanded(child: _statColumn('R\$0', 'Aplicado')),
          _verticalDivider(),
          Expanded(child: _statColumn('0', 'Favoritas')),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 48,
      color: Colors.black.withValues(alpha: 0.2),
    );
  }

  // ── 2FA card ──────────────────────────────────────────────────────────────

  Widget _twoFACard(UserProfile? profile) {
    final enabled       = profile?.twoFaEnabled ?? false;
    final isToggling    = _controller.isTogglingTwoFA;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lock_outline,
              size: 22,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Autenticação 2FA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Proteção extra para sua conta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          isToggling
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                )
              : GestureDetector(
                  onTap: _controller.toggle2FA,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 28,
                    decoration: BoxDecoration(
                      color: enabled ? Colors.black : const Color(0xFFBBBBBB),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ── Menu card ─────────────────────────────────────────────────────────────

  Widget _menuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _menuItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Minha Carteira',
            onTap: () => _comingSoon(context),
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
          _menuItem(
            icon: Icons.favorite_outline,
            label: 'Startups Favoritas',
            onTap: () => _comingSoon(context),
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
        top:    isLast ? Radius.zero        : Radius.zero,
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
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: Colors.black87),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return Divider(height: 1, thickness: 1, color: const Color(0xFFD9D9D9), indent: 16, endIndent: 16);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Widget _signOutButton(BuildContext context) {
    return GestureDetector(
      onTap: _controller.isSigningOut
          ? null
          : () async {
              await _controller.signOut();
              if (context.mounted) context.go('/');
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        ),
        child: _controller.isSigningOut
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, size: 24, color: Colors.black),
                  const SizedBox(width: 10),
                  const Text(
                    'Sair da Conta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Em breve!'),
        backgroundColor: Colors.black,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
