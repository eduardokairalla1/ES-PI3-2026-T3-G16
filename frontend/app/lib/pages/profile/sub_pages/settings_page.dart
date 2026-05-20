// Eduardo Kairalla - 24024241

// Profile settings screen — edit name and avatar.

// --- IMPORTS ---
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/profile/services/profile_service.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- PAGE ---

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ProfileService _service = ProfileService();
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final profile = AppState.instance.profile;
    _nameCtrl = TextEditingController(text: profile?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final uid = AppState.instance.profile?.uid;
    if (uid == null) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final ref = FirebaseStorage.instance.ref('users/$uid/avatar');
      final bytes = await file.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();

      await _service.updateProfile(photoUrl: url);
      AppState.instance.updateProfileLocally(photoUrl: url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada!')),
        );
      }
    } catch (e, stack) {
      debugPrint('Erro ao atualizar foto: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar foto: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _saveProfile() async {
    final profile = AppState.instance.profile;
    final newName = _nameCtrl.text.trim();
    final newPhone = _phoneCtrl.text.trim();

    final nameChanged = newName.isNotEmpty && newName != profile?.fullName;
    final phoneChanged = newPhone.isNotEmpty && newPhone != profile?.phone;

    if (!nameChanged && !phoneChanged) return;

    setState(() => _isSaving = true);

    try {
      await _service.updateProfile(
        fullName: nameChanged ? newName : null,
        phone: phoneChanged ? newPhone : null,
      );
      AppState.instance.updateProfileLocally(
        fullName: nameChanged ? newName : null,
        phone: phoneChanged ? newPhone : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppState.instance.profile;
    final initial = (profile?.fullName.isNotEmpty == true)
        ? profile!.fullName[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        leading: GestureDetector(
          onTap: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
          child: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
        ),
        centerTitle: true,
        title: Text(
          'Configurações',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border(context)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar edit.
            Center(
              child: Stack(
                children: [
                  Container(
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
                  if (_isUploadingPhoto)
                    const Positioned.fill(
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadPhoto,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: AppColors.surfaceColor(context),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Name field.
            Text(
              'NOME COMPLETO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            _editableField(
              controller: _nameCtrl,
              onSubmitted: (_) => _saveProfile(),
            ),

            const SizedBox(height: 16),

            // Phone field.
            Text(
              'TELEFONE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            _editableField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => _saveProfile(),
            ),

            const SizedBox(height: 24),

            // Read-only info fields.
            _infoField('E-MAIL', profile?.email ?? '—'),
            const SizedBox(height: 12),
            _infoField('CPF', profile?.cpf ?? '—'),
            const SizedBox(height: 12),
            _infoField('DATA DE NASCIMENTO', profile?.birthDate ?? '—'),

            const SizedBox(height: 32),

            // Save button.
            AppButton(
              label: 'Salvar',
              isLoading: _isSaving,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarInitial(String initial) {
    return Builder(
      builder: (context) => Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.surfaceColor(context),
          ),
        ),
      ),
    );
  }

  Widget _editableField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onSubmitted,
  }) {
    return Builder(
      builder: (context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceColor(context),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.textPrimary(context)),
          ),
        ),
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
