import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/assbt_button.dart';
import '../../data/services/registration_service.dart';
import '../providers/auth_provider.dart';

class RegisterForm extends ConsumerStatefulWidget {
  final VoidCallback? onCancel;
  
  const RegisterForm({
    super.key,
    this.onCancel,
  });

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _keyController = TextEditingController();
  final _registrationService = RegistrationService();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 8) {
      return 'Minimum 8 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmation requise';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  String? _validateKey(String? value) {
    if (value == null || value.isEmpty) {
      return 'Clef d\'inscription requise';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentContext = context;
    
    try {
      // Appel à l'API d'inscription
      final responseData = await _registrationService.registerMember(
        email: _emailController.text.trim(),
        motDePasse: _passwordController.text,
        confirmation: _confirmPasswordController.text,
        clef: _keyController.text.trim(),
      );
      
      if (mounted && responseData != null) {
        // Connecter automatiquement l'utilisateur avec les données reçues
        final authNotifier = ref.read(authProvider.notifier);
        
        // Si la réponse contient un token, se connecter automatiquement
        if (responseData.containsKey('token') || responseData.containsKey('accessToken')) {
          final token = responseData['token'] ?? responseData['accessToken'];
          
          // Créer les données utilisateur basiques à partir des infos d'inscription
          final userData = {
            'id': 0, // ID temporaire, sera mis à jour lors du refresh du profil
            'email': _emailController.text.trim(),
            'role': 'USER',
            'est_supprime': false,
          };
          
          await authNotifier.loginWithToken(token, userData);
        }
        
        // Fermer la modal
        if (widget.onCancel != null) {
          widget.onCancel!();
        }
        
        // Afficher message de succès
        if (mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
              content: Text('Compte créé avec succès ! Vous êtes maintenant connecté.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'inscription: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'votre.email@exemple.com',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mot de passe
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.next,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Minimum 8 caractères',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Confirmation mot de passe
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            textInputAction: TextInputAction.next,
            validator: _validateConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmer le mot de passe',
              hintText: 'Retapez votre mot de passe',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Clef d'inscription
          TextFormField(
            controller: _keyController,
            textInputAction: TextInputAction.done,
            validator: _validateKey,
            decoration: const InputDecoration(
              labelText: 'Clef d\'inscription',
              hintText: 'Clef d\'inscription fournie par le club',
              prefixIcon: Icon(Icons.vpn_key_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Boutons
          Row(
            children: [
              if (widget.onCancel != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : widget.onCancel,
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: AssbtButton(
                  text: 'Créer le compte',
                  onPressed: _isLoading ? null : _handleRegister,
                  isLoading: _isLoading,
                  icon: const Icon(Icons.person_add),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}