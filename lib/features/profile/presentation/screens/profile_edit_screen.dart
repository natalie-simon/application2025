import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/assbt_button.dart';
import '../providers/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  final bool isInitialSetup;
  
  const ProfileEditScreen({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  
  bool _communicationMail = true;
  bool _communicationSms = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingProfile();
    });
  }

  void _loadExistingProfile() {
    final profile = ref.read(profileProvider).profile;
    if (profile != null) {
      _nomController.text = profile.nom ?? '';
      _prenomController.text = profile.prenom ?? '';
      _telephoneController.text = profile.telephone ?? '';
      _communicationMail = profile.communicationMail;
      _communicationSms = profile.communicationSms;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le téléphone est requis';
    }
    
    return null;
  }

  bool _hasExistingAvatar() {
    final profile = ref.read(profileProvider).profile;
    return profile?.avatarId != null;
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              if (_selectedImage != null || _hasExistingAvatar())
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Supprimer la photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    
                    if (_selectedImage != null) {
                      // Supprimer l'image sélectionnée localement
                      setState(() {
                        _selectedImage = null;
                      });
                    } else if (_hasExistingAvatar()) {
                      // Supprimer l'avatar existant sur le serveur
                      try {
                        await ref.read(profileProvider.notifier).deleteAvatar();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Avatar supprimé avec succès !'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur lors de la suppression : $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Mettre à jour le profil avec l'avatar inclus
      await ref.read(profileProvider.notifier).updateProfile(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        communicationMail: _communicationMail,
        communicationSms: _communicationSms,
        avatarFile: _selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil sauvegardé avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );

        // Toujours rediriger vers les activités après la sauvegarde
        context.go('/activities');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde : $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isInitialSetup ? 'Configuration du profil' : 'Modifier le profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !widget.isInitialSetup,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isInitialSetup) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bienvenue !',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pour terminer votre inscription, veuillez compléter votre profil avec vos informations personnelles.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Avatar
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: _selectedImage != null
                        ? Stack(
                            children: [
                              ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _hasExistingAvatar()
                            ? Stack(
                                children: [
                                  ClipOval(
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 32,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ajouter\nune photo',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Prénom
              TextFormField(
                controller: _prenomController,
                textInputAction: TextInputAction.next,
                validator: (value) => _validateRequired(value, 'Le prénom'),
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  hintText: 'Votre prénom',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Nom
              TextFormField(
                controller: _nomController,
                textInputAction: TextInputAction.next,
                validator: (value) => _validateRequired(value, 'Le nom'),
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  hintText: 'Votre nom de famille',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: _validatePhone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone *',
                  hintText: 'Votre numéro de téléphone',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Communication
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Préférences de communication',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Communication par email'),
                        subtitle: const Text('Recevoir les notifications par email'),
                        value: _communicationMail,
                        onChanged: (bool value) {
                          setState(() {
                            _communicationMail = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      SwitchListTile(
                        title: const Text('Communication par SMS'),
                        subtitle: const Text('Recevoir les notifications par SMS'),
                        value: _communicationSms,
                        onChanged: (bool value) {
                          setState(() {
                            _communicationSms = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  if (!widget.isInitialSetup) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: profileState.isLoading ? null : () => context.go('/activities'),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  
                  Expanded(
                    child: AssbtButton(
                      text: widget.isInitialSetup ? 'Terminer' : 'Sauvegarder',
                      onPressed: profileState.isLoading ? null : _saveProfile,
                      isLoading: profileState.isLoading,
                      icon: Icon(widget.isInitialSetup ? Icons.check : Icons.save),
                    ),
                  ),
                ],
              ),

              if (widget.isInitialSetup) ...[
                const SizedBox(height: 16),
                Text(
                  '* Champs obligatoires : nom, prénom et téléphone',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}