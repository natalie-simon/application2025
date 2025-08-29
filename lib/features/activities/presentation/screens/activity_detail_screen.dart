import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/activities_provider.dart';
import '../../data/services/activities_service.dart';
import '../../domain/models/activity_detail.dart';
import '../../domain/models/activity_participant.dart';

final activityDetailProvider = StateNotifierProvider.family<ActivityDetailNotifier, AsyncValue<ActivityDetail>, int>((ref, activityId) {
  final activitiesService = ref.watch(activitiesServiceProvider);
  final authState = ref.watch(authProvider);
  return ActivityDetailNotifier(activitiesService, authState.token, activityId);
});

class ActivityDetailNotifier extends StateNotifier<AsyncValue<ActivityDetail>> {
  final ActivitiesService _activitiesService;
  final String? _token;
  final int _activityId;

  ActivityDetailNotifier(this._activitiesService, this._token, this._activityId) : super(const AsyncValue.loading()) {
    _loadActivityDetail();
  }

  Future<void> _loadActivityDetail() async {
    try {
      final detail = await _activitiesService.getActivityDetailById(_activityId, token: _token);
      state = AsyncValue.data(detail);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> registerForActivity({String? observations}) async {
    if (_token == null) return;

    try {
      await _activitiesService.registerForActivity(_activityId, observations: observations, token: _token!);
      await _loadActivityDetail(); // Recharger les données
    } catch (error) {
      AppLogger.error('Erreur inscription', error: error, tag: 'ACTIVITY_DETAIL');
      rethrow;
    }
  }

  Future<void> unregisterFromActivity() async {
    if (_token == null) return;

    try {
      await _activitiesService.unregisterFromActivity(_activityId, token: _token!);
      await _loadActivityDetail(); // Recharger les données
    } catch (error) {
      AppLogger.error('Erreur désinscription', error: error, tag: 'ACTIVITY_DETAIL');
      rethrow;
    }
  }
}

class ActivityDetailScreen extends ConsumerWidget {
  final int activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityDetailAsync = ref.watch(activityDetailProvider(activityId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'activité'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: activityDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur de chargement', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(activityDetailProvider(activityId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (activity) => _buildActivityDetail(context, ref, activity, currentUser),
      ),
    );
  }

  Widget _buildActivityDetail(BuildContext context, WidgetRef ref, ActivityDetail activity, user) {
    final theme = Theme.of(context);
    final categoryColor = Color(int.parse('FF${activity.categorie.couleur}', radix: 16));
    final isUserRegistered = user != null ? activity.isUserRegistered(user.id) : false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec catégorie
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [categoryColor.withOpacity(0.1), categoryColor.withOpacity(0.05)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity.categorie.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  activity.titre,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Informations principales
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(context, 'Informations', [
                  _buildInfoRow(context, Icons.calendar_today, 'Date', DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(activity.startDateTime)),
                  _buildInfoRow(context, Icons.access_time, 'Horaires', '${DateFormat('HH:mm').format(activity.startDateTime)} - ${DateFormat('HH:mm').format(activity.endDateTime)}'),
                  _buildInfoRow(context, Icons.people, 'Places', '${activity.registeredCount}/${activity.maxParticipants}'),
                  _buildInfoRow(context, Icons.event_available, 'Inscription jusqu\'au', DateFormat('dd/MM/yyyy à HH:mm').format(activity.registrationDeadline)),
                ]),

                if (activity.contenu != null && activity.contenu!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildInfoSection(context, 'Description', [
                    Text(
                      activity.contenu!.replaceAll(RegExp(r'<[^>]*>'), ''), // Remove HTML tags
                      style: theme.textTheme.bodyMedium,
                    ),
                  ]),
                ],

                const SizedBox(height: 32),
                _buildParticipantsSection(context, activity),

                const SizedBox(height: 32),
                _buildActionSection(context, ref, activity, user, isUserRegistered),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context, ActivityDetail activity) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Participants',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${activity.participants.length}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (activity.participants.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  'Aucun participant pour le moment',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        else
          ...activity.participants.map((participant) => _buildParticipantCard(context, participant)),
      ],
    );
  }

  Widget _buildParticipantCard(BuildContext context, ActivityParticipant participant) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    _getParticipantInitial(participant.membre),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getParticipantDisplayName(participant.membre),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Inscrit le ${DateFormat('dd/MM/yyyy').format(participant.registrationDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (participant.observations != null && participant.observations!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Observations :',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      participant.observations!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, WidgetRef ref, ActivityDetail activity, user, bool isUserRegistered) {
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Connectez-vous pour vous inscrire à cette activité',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
      );
    }

    if (activity.isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Activité annulée: ${activity.cancellationReason}',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      );
    }

    if (!activity.isRegistrationOpen) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Les inscriptions sont fermées',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isUserRegistered) ...[
          ElevatedButton.icon(
            onPressed: () => _showUnregisterDialog(context, ref, activity),
            icon: const Icon(Icons.cancel),
            label: const Text('Se désinscrire'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous êtes inscrit à cette activité',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else if (activity.isFull) ...[
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.people),
            label: const Text('Activité complète'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ] else ...[
          ElevatedButton.icon(
            onPressed: () => _showRegisterDialog(context, ref, activity),
            icon: const Icon(Icons.add),
            label: Text('S\'inscrire (${activity.availableSpots} place${activity.availableSpots > 1 ? 's' : ''} disponible${activity.availableSpots > 1 ? 's' : ''})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ],
    );
  }

  void _showRegisterDialog(BuildContext context, WidgetRef ref, ActivityDetail activity) {
    if (activity.categorie.withEquipment) {
      _showEquipmentDialog(context, ref, activity);
    } else {
      _showSimpleRegisterDialog(context, ref, activity);
    }
  }

  void _showSimpleRegisterDialog(BuildContext context, WidgetRef ref, ActivityDetail activity) {
    final observationsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vous voulez vous inscrire à "${activity.titre}" ?'),
            const SizedBox(height: 16),
            TextField(
              controller: observationsController,
              decoration: const InputDecoration(
                labelText: 'Observations (optionnel)',
                hintText: 'Remarques particulières...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(activityDetailProvider(activity.id).notifier)
                    .registerForActivity(observations: observationsController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inscription réussie !')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('S\'inscrire'),
          ),
        ],
      ),
    );
  }

  void _showEquipmentDialog(BuildContext context, WidgetRef ref, ActivityDetail activity) {
    String selectedVest = 'Aucun';
    bool needsTank = false;
    bool needsRegulator = false;
    bool needsNitrox = false;
    final observationsController = TextEditingController();
    
    final vestOptions = ['Aucun', 'Junior', 'XXS', 'XS', 'S', 'M', 'L', 'XL'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Inscription à "${activity.titre}"'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Équipement nécessaire :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Sélecteur de gilet stabilisateur
                const Text('Gilet stabilisateur :'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedVest,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: vestOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedVest = newValue;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Cases à cocher pour les équipements
                CheckboxListTile(
                  title: const Text('Bloc'),
                  value: needsTank,
                  onChanged: (bool? value) {
                    setState(() {
                      needsTank = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                CheckboxListTile(
                  title: const Text('Détendeur'),
                  value: needsRegulator,
                  onChanged: (bool? value) {
                    setState(() {
                      needsRegulator = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                CheckboxListTile(
                  title: const Text('Nitrox (+9€)'),
                  value: needsNitrox,
                  onChanged: (bool? value) {
                    setState(() {
                      needsNitrox = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                const SizedBox(height: 16),
                
                // Champ observations
                TextField(
                  controller: observationsController,
                  decoration: const InputDecoration(
                    labelText: 'Observations supplémentaires (optionnel)',
                    hintText: 'Autres remarques...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                
                if (needsNitrox) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Coût supplémentaire Nitrox : 9€',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Construire les observations avec les équipements
                final equipmentObservations = <String>[];
                equipmentObservations.add('Gilet stabilisateur: $selectedVest');
                equipmentObservations.add('Bloc: ${needsTank ? 'oui' : 'non'}');
                equipmentObservations.add('Détendeur: ${needsRegulator ? 'oui' : 'non'}');
                equipmentObservations.add('Nitrox: ${needsNitrox ? 'oui' : 'non'}');
                
                String finalObservations = equipmentObservations.join(' / ');
                if (observationsController.text.isNotEmpty) {
                  finalObservations += ' / ${observationsController.text}';
                }
                
                try {
                  await ref.read(activityDetailProvider(activity.id).notifier)
                      .registerForActivity(observations: finalObservations);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inscription réussie !')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnregisterDialog(BuildContext context, WidgetRef ref, ActivityDetail activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Désinscription'),
        content: Text('Vous voulez vous désinscrire de "${activity.titre}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(activityDetailProvider(activity.id).notifier).unregisterFromActivity();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Désinscription réussie !')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Se désinscrire'),
          ),
        ],
      ),
    );
  }

  String _getParticipantInitial(Member member) {
    final prenom = member.profil.prenom.trim();
    if (prenom.isNotEmpty) {
      return prenom[0].toUpperCase();
    }
    final nom = member.profil.nom.trim();
    if (nom.isNotEmpty) {
      return nom[0].toUpperCase();
    }
    return member.email[0].toUpperCase();
  }

  String _getParticipantDisplayName(Member member) {
    final displayName = member.profil.displayName.trim();
    return displayName.isNotEmpty ? displayName : member.email;
  }
}