import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/activities_service.dart';
import '../../domain/models/activity.dart';

class ActivitiesState {
  final List<Activity> activities;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const ActivitiesState({
    this.activities = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  ActivitiesState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  final ActivitiesService _activitiesService;
  final Ref _ref;

  ActivitiesNotifier(this._activitiesService, this._ref) : super(const ActivitiesState()) {
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    AppLogger.info('Chargement des activités', tag: 'ACTIVITIES_PROVIDER');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authState = _ref.read(authProvider);
      final token = authState.token;
      
      if (token == null) {
        throw Exception('Token d\'authentification requis');
      }

      final activities = await _activitiesService.getActivities(token: token);

      state = state.copyWith(
        activities: activities,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      AppLogger.info('${activities.length} activités chargées depuis l\'API', tag: 'ACTIVITIES_PROVIDER');
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des activités', tag: 'ACTIVITIES_PROVIDER', error: e);

      String errorMessage;
      if (e is ActivitiesServiceException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Erreur lors du chargement des activités: ${e.toString()}';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  Future<void> refreshActivities() async {
    AppLogger.info('Rafraîchissement des activités', tag: 'ACTIVITIES_PROVIDER');
    await _loadActivities();
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  List<Activity> getActivitiesForDate(DateTime date) {
    return state.activities.where((activity) {
      final activityDate = activity.startDate;
      return activityDate.year == date.year &&
          activityDate.month == date.month &&
          activityDate.day == date.day;
    }).toList();
  }

  Map<DateTime, List<Activity>> getActivitiesGroupedByDate() {
    final Map<DateTime, List<Activity>> grouped = {};
    
    for (final activity in state.activities) {
      final date = activity.startDate;
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(activity);
    }
    
    return grouped;
  }
}

final activitiesServiceProvider = Provider<ActivitiesService>((ref) {
  return ActivitiesService();
});

final activitiesProvider = StateNotifierProvider<ActivitiesNotifier, ActivitiesState>((ref) {
  final activitiesService = ref.watch(activitiesServiceProvider);
  return ActivitiesNotifier(activitiesService, ref);
});

final activitiesForDateProvider = Provider.family<List<Activity>, DateTime>((ref, date) {
  final activitiesNotifier = ref.watch(activitiesProvider.notifier);
  return activitiesNotifier.getActivitiesForDate(date);
});

final activitiesGroupedByDateProvider = Provider<Map<DateTime, List<Activity>>>((ref) {
  final activitiesState = ref.watch(activitiesProvider);
  final Map<DateTime, List<Activity>> grouped = {};
  
  for (final activity in activitiesState.activities) {
    // Normaliser la date (supprimer l'heure)
    final date = DateTime(
      activity.startDateTime.year,
      activity.startDateTime.month,
      activity.startDateTime.day,
    );
    if (grouped[date] == null) {
      grouped[date] = [];
    }
    grouped[date]!.add(activity);
  }
  
  return grouped;
});