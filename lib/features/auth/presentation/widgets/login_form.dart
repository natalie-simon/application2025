import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/assbt_button.dart';
import '../providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _hasLoadedCredentials = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    if (_hasLoadedCredentials) {
      AppLogger.debug('Identifiants déjà chargés, skip', tag: 'LOGIN_FORM');
      return;
    }
    
    AppLogger.info('Tentative de chargement des identifiants sauvegardés dans le formulaire', tag: 'LOGIN_FORM');
    
    final credentials = await ref.read(authProvider.notifier).loadSavedCredentials();
    if (credentials != null) {
      AppLogger.info('Identifiants trouvés, remplissage automatique du formulaire pour: ***@${credentials.email.split('@').last}', tag: 'LOGIN_FORM');
      
      setState(() {
        _emailController.text = credentials.email;
        _passwordController.text = credentials.password;
        _rememberMe = true;
        _hasLoadedCredentials = true;
      });
      
      AppLogger.debug('Formulaire rempli automatiquement avec succès', tag: 'LOGIN_FORM');
    } else {
      AppLogger.info('Aucun identifiant sauvegardé trouvé, formulaire vide', tag: 'LOGIN_FORM');
      setState(() {
        _hasLoadedCredentials = true;
      });
    }
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      ref.read(authProvider.notifier).signIn(email, password, rememberMe: _rememberMe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    // Gérer les changements d'état d'authentification
    ref.listen(authProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        // Nettoyer l'erreur après l'affichage
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            ref.read(authProvider.notifier).clearError();
          }
        });
      }
      
      // Si la connexion réussit, fermer le drawer et aller aux activités
      if (previous?.isAuthenticated == false && next.isAuthenticated && mounted) {
        // Fermer le drawer
        Navigator.of(context).pop();
        // Naviguer vers les activités
        context.go('/activities');
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Connexion',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Champ Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !authState.isLoading,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'votre.email@exemple.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textLight.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'L\'email est requis';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Format d\'email invalide';
              }
              return null;
            },
            onChanged: (value) {
              if (authState.error != null) {
                ref.read(authProvider.notifier).clearError();
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // Champ Mot de passe
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: !authState.isLoading,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Votre mot de passe',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword 
                    ? Icons.visibility_outlined 
                    : Icons.visibility_off_outlined,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textLight.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Le mot de passe est requis';
              }
              if (value!.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
            onChanged: (value) {
              if (authState.error != null) {
                ref.read(authProvider.notifier).clearError();
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // Se souvenir de moi
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: authState.isLoading ? null : (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  'Se souvenir de moi',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Bouton de connexion
          AssbtButton(
            text: authState.isLoading ? 'Connexion...' : 'Se connecter',
            onPressed: authState.isLoading ? null : _handleLogin,
            isLoading: authState.isLoading,
          ),
          
          const SizedBox(height: 16),
          
          // Lien mot de passe oublié
          TextButton(
            onPressed: authState.isLoading ? null : () {
              _showPasswordResetDialog(context);
            },
            child: Text(
              'Mot de passe oublié ?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'votre.email@exemple.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Simuler l'envoi de l'email
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Un email de réinitialisation a été envoyé à ${emailController.text}',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}