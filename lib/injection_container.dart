import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/entities/app_settings.dart';
import 'domain/entities/context.dart';
import 'domain/entities/history_entry.dart';
import 'domain/entities/horizon.dart';
import 'domain/entities/inbox_item.dart';
import 'domain/entities/project.dart';
import 'domain/entities/project_step.dart';
import 'domain/entities/processing_choice.dart';
import 'domain/entities/recurrence.dart';
import 'domain/entities/reference_item.dart';
import 'domain/entities/someday_maybe_item.dart';
import 'domain/entities/task.dart';
import 'domain/entities/waiting_for_item.dart';
import 'domain/entities/weekly_review_progress.dart';
import 'domain/repositories/context_repository.dart';
import 'domain/repositories/history_repository.dart';
import 'domain/repositories/horizons_repository.dart';
import 'domain/repositories/inbox_repository.dart';
import 'domain/repositories/project_repository.dart';
import 'domain/repositories/reference_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/repositories/someday_maybe_repository.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/repositories/waiting_for_repository.dart';
import 'domain/repositories/weekly_review_repository.dart';
import 'domain/services/calendar_occurrence_generator.dart';
import 'domain/usecases/activate_someday_maybe_use_case.dart';
import 'domain/usecases/complete_next_action_use_case.dart';
import 'domain/usecases/clear_all_data_use_case.dart';
import 'domain/usecases/create_inbox_item_use_case.dart';
import 'domain/usecases/create_project_use_case.dart';
import 'domain/usecases/ai_suggest_use_case.dart';
import 'domain/usecases/import_backup_use_case.dart';
import 'domain/usecases/log_history_entry_use_case.dart';
import 'domain/usecases/process_inbox_item_use_case.dart';
import 'infrastructure/ai/ai_service.dart';
import 'infrastructure/services/ai_clarify_service.dart';
import 'infrastructure/persistence/repository_factories.dart';

final selectedContextProvider = StateProvider<String>((ref) => '@Anywhere');

final appSettingsControllerProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

final appSettingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(appSettingsControllerProvider).valueOrNull ??
      const AppSettings();
});

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final result = await ref.watch(settingsRepositoryProvider).getSettings();
    return result.match(
      (failure) => throw Exception(failure.message),
      (settings) {
        ref.read(selectedContextProvider.notifier).state =
            settings.defaultContextName;
        return settings;
      },
    );
  }

  Future<bool> setVoiceCaptureEnabled({required bool enabled}) {
    return _update((settings) {
      return settings.copyWith(voiceCaptureEnabled: enabled);
    });
  }

  Future<bool> setDefaultContextName(String contextName) async {
    final success = await _update((settings) {
      return settings.copyWith(defaultContextName: contextName);
    });
    if (success) {
      ref.read(selectedContextProvider.notifier).state = contextName;
    }
    return success;
  }

  Future<bool> setWeeklyReviewDay(int weekday) {
    return _update((settings) {
      return settings.copyWith(weeklyReviewWeekday: weekday);
    });
  }

  Future<bool> setAiEnabled({required bool enabled}) {
    return _update((settings) {
      return settings.copyWith(aiEnabled: enabled);
    });
  }

  Future<bool> setAiBaseUrl(String baseUrl) {
    return _update((settings) {
      final trimmed = baseUrl.trim();
      return settings.copyWith(
        aiBaseUrl: trimmed.isEmpty ? const AppSettings().aiBaseUrl : trimmed,
      );
    });
  }

  Future<bool> setAiModel(String model) {
    return _update((settings) {
      final trimmed = model.trim();
      return settings.copyWith(
        aiModel: trimmed.isEmpty ? const AppSettings().aiModel : trimmed,
      );
    });
  }

  Future<bool> setAiApiKey(String? apiKey) {
    return _update((settings) {
      final trimmed = apiKey?.trim();
      return settings.copyWith(
        aiApiKey: trimmed == null || trimmed.isEmpty ? null : trimmed,
      );
    });
  }

  Future<bool> setVoiceLocaleId(String? localeId) {
    return _update((settings) {
      final trimmed = localeId?.trim();
      return settings.copyWith(
        voiceLocaleId: trimmed == null || trimmed.isEmpty ? null : trimmed,
      );
    });
  }

  Future<bool> _update(
      AppSettings Function(AppSettings settings) update) async {
    final current = state.valueOrNull ?? const AppSettings();
    final next = update(current);
    state = AsyncData(next);
    final result =
        await ref.read(settingsRepositoryProvider).saveSettings(next);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) => true,
    );
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return createSettingsRepository(ref.watch(persistenceStoreProvider.future));
});

final aiClarifyServiceProvider = Provider<AiClarifyService>((ref) {
  return const HttpAiClarifyService();
});

final aiAssistServiceProvider = Provider<AiAssistService>((ref) {
  return const HttpAiAssistService();
});

final aiSuggestUseCaseProvider = Provider<AiSuggestUseCase>((ref) {
  return AiSuggestUseCase(ref.watch(aiAssistServiceProvider));
});

final horizonsRepositoryProvider = Provider<HorizonsRepository>((ref) {
  return createHorizonsRepository(ref.watch(persistenceStoreProvider.future));
});

final weeklyReviewRepositoryProvider = Provider<WeeklyReviewRepository>((ref) {
  return createWeeklyReviewRepository(
    ref.watch(persistenceStoreProvider.future),
  );
});

final persistenceStoreProvider = FutureProvider<Object>((ref) {
  return openPersistenceStore();
});

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  return createInboxRepository(ref.watch(persistenceStoreProvider.future));
});

final contextRepositoryProvider = Provider<ContextRepository>((ref) {
  return createContextRepository(ref.watch(persistenceStoreProvider.future));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return createTaskRepository(ref.watch(persistenceStoreProvider.future));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return createProjectRepository(ref.watch(persistenceStoreProvider.future));
});

final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  return createReferenceRepository(ref.watch(persistenceStoreProvider.future));
});

final somedayMaybeRepositoryProvider = Provider<SomedayMaybeRepository>((ref) {
  return createSomedayMaybeRepository(
      ref.watch(persistenceStoreProvider.future));
});

final waitingForRepositoryProvider = Provider<WaitingForRepository>((ref) {
  return createWaitingForRepository(ref.watch(persistenceStoreProvider.future));
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return createHistoryRepository(ref.watch(persistenceStoreProvider.future));
});

final logHistoryEntryUseCaseProvider = Provider<LogHistoryEntryUseCase>((ref) {
  return LogHistoryEntryUseCase(ref.watch(historyRepositoryProvider));
});

final historyRefreshSignalProvider = StateProvider<int>((ref) => 0);

final createInboxItemUseCaseProvider = Provider<CreateInboxItemUseCase>((ref) {
  return CreateInboxItemUseCase(ref.watch(inboxRepositoryProvider));
});

final processInboxItemUseCaseProvider = Provider<ProcessInboxItemUseCase>(
  (ref) {
    return ProcessInboxItemUseCase(
      inboxRepository: ref.watch(inboxRepositoryProvider),
      taskRepository: ref.watch(taskRepositoryProvider),
      projectRepository: ref.watch(projectRepositoryProvider),
      somedayMaybeRepository: ref.watch(somedayMaybeRepositoryProvider),
      referenceRepository: ref.watch(referenceRepositoryProvider),
      waitingForRepository: ref.watch(waitingForRepositoryProvider),
      logHistoryEntryUseCase: ref.watch(logHistoryEntryUseCaseProvider),
    );
  },
);

final createProjectUseCaseProvider = Provider<CreateProjectUseCase>((ref) {
  return CreateProjectUseCase(
    ref.watch(projectRepositoryProvider),
    logHistoryEntryUseCase: ref.watch(logHistoryEntryUseCaseProvider),
  );
});

final clearAllDataUseCaseProvider = Provider<ClearAllDataUseCase>((ref) {
  return ClearAllDataUseCase(
    inboxRepository: ref.watch(inboxRepositoryProvider),
    taskRepository: ref.watch(taskRepositoryProvider),
    projectRepository: ref.watch(projectRepositoryProvider),
    somedayMaybeRepository: ref.watch(somedayMaybeRepositoryProvider),
    referenceRepository: ref.watch(referenceRepositoryProvider),
    waitingForRepository: ref.watch(waitingForRepositoryProvider),
    historyRepository: ref.watch(historyRepositoryProvider),
    logHistoryEntryUseCase: ref.watch(logHistoryEntryUseCaseProvider),
  );
});

final importBackupUseCaseProvider = Provider<ImportBackupUseCase>((ref) {
  return ImportBackupUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
    contextRepository: ref.watch(contextRepositoryProvider),
    inboxRepository: ref.watch(inboxRepositoryProvider),
    taskRepository: ref.watch(taskRepositoryProvider),
    projectRepository: ref.watch(projectRepositoryProvider),
    somedayMaybeRepository: ref.watch(somedayMaybeRepositoryProvider),
    referenceRepository: ref.watch(referenceRepositoryProvider),
    waitingForRepository: ref.watch(waitingForRepositoryProvider),
    horizonsRepository: ref.watch(horizonsRepositoryProvider),
    weeklyReviewRepository: ref.watch(weeklyReviewRepositoryProvider),
  );
});

final completeNextActionUseCaseProvider = Provider<CompleteNextActionUseCase>(
  (ref) {
    return CompleteNextActionUseCase(
      taskRepository: ref.watch(taskRepositoryProvider),
      projectRepository: ref.watch(projectRepositoryProvider),
      logHistoryEntryUseCase: ref.watch(logHistoryEntryUseCaseProvider),
    );
  },
);

final activateSomedayMaybeUseCaseProvider =
    Provider<ActivateSomedayMaybeUseCase>(
  (ref) {
    return ActivateSomedayMaybeUseCase(
      projectRepository: ref.watch(projectRepositoryProvider),
      taskRepository: ref.watch(taskRepositoryProvider),
      somedayMaybeRepository: ref.watch(somedayMaybeRepositoryProvider),
      logHistoryEntryUseCase: ref.watch(logHistoryEntryUseCaseProvider),
    );
  },
);

final inboxItemsProvider =
    AsyncNotifierProvider<InboxItemsNotifier, List<InboxItem>>(
  InboxItemsNotifier.new,
);

final inboxActionErrorProvider = StateProvider<String?>((ref) => null);

class InboxItemsNotifier extends AsyncNotifier<List<InboxItem>> {
  @override
  Future<List<InboxItem>> build() async {
    final result = await ref.watch(inboxRepositoryProvider).getAllInboxItems();
    return result.match(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }

  Future<bool> processItem({
    required String itemId,
    required ProcessingRequest request,
  }) async {
    final previousItems = state.valueOrNull;
    ref.read(inboxActionErrorProvider.notifier).state = null;

    final useCase = ref.read(processInboxItemUseCaseProvider);
    final result = await useCase(
      inboxItemId: itemId,
      choice: request.choice,
      title: request.title,
      desiredOutcome: request.desiredOutcome,
      context: request.context,
      targetDate: request.targetDate,
      endDateTime: request.endDateTime,
      notes: request.notes,
      nextActionTitle: request.nextActionTitle,
      reconsiderDate: request.reconsiderDate,
      referenceFolder: request.referenceFolder,
      waitingOn: request.waitingOn,
      waitingForProjectId: request.waitingForProjectId,
      followUpDate: request.followUpDate,
      recurrence: request.recurrence,
      tags: request.tags,
      stepTitles: request.stepTitles,
      projectSteps: request.projectSteps,
    );

    final failure = result.match((failure) => failure, (_) => null);
    if (failure != null) {
      ref.read(inboxActionErrorProvider.notifier).state = failure.message;
      if (previousItems != null) {
        state = AsyncData(previousItems);
      } else {
        state = await AsyncValue.guard(build);
      }
      return false;
    }

    ref
      ..invalidate(allNextActionsProvider)
      ..invalidate(allTasksProvider)
      ..invalidate(activeProjectsProvider)
      ..invalidate(allProjectsProvider)
      ..invalidate(somedayMaybeProvider)
      ..invalidate(referenceProvider)
      ..invalidate(waitingForProvider)
      ..invalidate(allWaitingForProvider)
      ..invalidate(calendarEntriesProvider)
      ..invalidate(visibleCalendarEntriesProvider);
    ref.read(historyRefreshSignalProvider.notifier).state++;
    ref.invalidateSelf();
    return true;
  }

  Future<bool> captureItem({
    required String title,
    String? notes,
    CaptureSource source = CaptureSource.manual,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      state = AsyncError('Capture title is required.', StackTrace.current);
      return false;
    }

    final result = await ref.read(inboxRepositoryProvider).addInboxItem(
          InboxItem(
            id: '',
            title: trimmedTitle,
            notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
            capturedAt: DateTime.now(),
            source: source,
          ),
        );

    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref
          ..invalidateSelf()
          ..invalidate(allProjectsProvider);
        return true;
      },
    );
  }
}

final inboxCountProvider = Provider<int>((ref) {
  return ref.watch(inboxItemsProvider).valueOrNull?.length ?? 0;
});

final contextsStateProvider =
    AsyncNotifierProvider<ContextsNotifier, List<ZoroContext>>(
  ContextsNotifier.new,
);

final contextsProvider = Provider<List<ZoroContext>>((ref) {
  return ref.watch(contextsStateProvider).valueOrNull ??
      ContextsNotifier.defaultContexts;
});

final contextUsageProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(allNextActionsProvider).valueOrNull ?? [];
  return {
    for (final context in ref.watch(contextsProvider))
      context.name:
          tasks.where((task) => task.context.name == context.name).length,
  };
});

class ContextsNotifier extends AsyncNotifier<List<ZoroContext>> {
  static const defaultContexts = [
    ZoroContext(id: 'anywhere', name: '@Anywhere', isDefault: true),
    ZoroContext(id: 'computer', name: '@Computer', isDefault: true),
    ZoroContext(id: 'home', name: '@Home', isDefault: true),
    ZoroContext(id: 'errands', name: '@Errands', isDefault: true),
    ZoroContext(id: 'calls', name: '@Calls', isDefault: true),
  ];

  @override
  Future<List<ZoroContext>> build() async {
    final result = await ref.watch(contextRepositoryProvider).getAllContexts();
    return result.match(
      (failure) => throw Exception(failure.message),
      (contexts) => contexts.isEmpty ? defaultContexts : contexts,
    );
  }

  Future<bool> addContext({required String name, String? description}) async {
    final normalizedName = _normalizeName(name);
    final current = state.valueOrNull ?? defaultContexts;
    if (normalizedName == null || _containsName(current, normalizedName)) {
      return false;
    }

    final result = await ref.read(contextRepositoryProvider).saveContext(
          ZoroContext(
            id: '',
            name: normalizedName,
            description: _cleanDescription(description),
          ),
        );

    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (context) {
        state = AsyncData([...current, context]);
        return true;
      },
    );
  }

  Future<bool> updateContext(ZoroContext context) async {
    final normalizedName = _normalizeName(context.name);
    if (normalizedName == null) {
      return false;
    }

    final current = state.valueOrNull ?? defaultContexts;
    final existing =
        current.where((entry) => entry.id == context.id).firstOrNull;
    if (existing == null || existing.isDefault) {
      return false;
    }

    final duplicate = current.any(
      (entry) =>
          entry.id != context.id &&
          entry.name.toLowerCase() == normalizedName.toLowerCase(),
    );
    if (duplicate) {
      return false;
    }

    final updated = ZoroContext(
      id: existing.id,
      name: normalizedName,
      description: _cleanDescription(context.description),
    );
    final result =
        await ref.read(contextRepositoryProvider).saveContext(updated);

    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (saved) {
        state = AsyncData([
          for (final entry in current) entry.id == saved.id ? saved : entry,
        ]);
        return true;
      },
    );
  }

  Future<bool> deleteContext(String id) async {
    final current = state.valueOrNull ?? defaultContexts;
    final context = current.where((entry) => entry.id == id).firstOrNull;
    if (context == null || context.isDefault) {
      return false;
    }

    final result = await ref.read(contextRepositoryProvider).deleteContext(id);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = AsyncData(
          current.where((entry) => entry.id != id).toList(growable: false),
        );
        if (ref.read(selectedContextProvider) == context.name) {
          ref.read(selectedContextProvider.notifier).state =
              defaultContexts.first.name;
        }
        return true;
      },
    );
  }

  bool _containsName(List<ZoroContext> contexts, String name) {
    return contexts.any(
      (entry) => entry.name.toLowerCase() == name.toLowerCase(),
    );
  }

  String? _normalizeName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final withoutPrefix =
        trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
    final compacted = withoutPrefix
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .join(' ');
    return compacted.isEmpty ? null : '@$compacted';
  }

  String? _cleanDescription(String? description) {
    final value = description?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

final activeProjectsProvider =
    AsyncNotifierProvider<ActiveProjectsNotifier, List<Project>>(
  ActiveProjectsNotifier.new,
);

class ActiveProjectsNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    final result =
        await ref.watch(projectRepositoryProvider).getActiveProjects();
    return result.match(
      (failure) => throw Exception(failure.message),
      (projects) => projects,
    );
  }

  Future<bool> updateProject(Project project) async {
    final result =
        await ref.read(projectRepositoryProvider).updateProject(project);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref
          ..invalidateSelf()
          ..invalidate(allProjectsProvider);
        return true;
      },
    );
  }

  Future<bool> completeProject(String projectId) async {
    final taskFailure = await _completeProjectTasks(projectId);
    if (taskFailure != null) {
      state = AsyncError(taskFailure, StackTrace.current);
      return false;
    }

    final result =
        await ref.read(projectRepositoryProvider).completeProject(projectId);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref
          ..invalidateSelf()
          ..invalidate(allProjectsProvider)
          ..invalidate(allTasksProvider)
          ..invalidate(allNextActionsProvider)
          ..invalidate(projectTasksProvider);
        return true;
      },
    );
  }

  Future<bool> moveProjectToSomeday(Project project) async {
    final now = DateTime.now();
    final reconsiderDate = DateTime(now.year + 1, now.month, now.day);
    final somedayResult =
        await ref.read(somedayMaybeRepositoryProvider).addItem(
              SomedayMaybeItem(
                id: '',
                title: project.title,
                reconsiderDate: reconsiderDate,
                createdAt: now,
                notes: project.desiredOutcome,
                tags: project.tags,
              ),
            );
    final somedayFailure =
        somedayResult.match((failure) => failure, (_) => null);
    if (somedayFailure != null) {
      state = AsyncError(somedayFailure.message, StackTrace.current);
      return false;
    }

    final somedayItem = somedayResult.match((_) => null, (item) => item)!;
    final taskFailure = await _completeProjectTasks(project.id);
    if (taskFailure != null) {
      await ref.read(somedayMaybeRepositoryProvider).deleteItem(somedayItem.id);
      state = AsyncError(taskFailure, StackTrace.current);
      return false;
    }

    final completeResult =
        await ref.read(projectRepositoryProvider).completeProject(project.id);
    final completeFailure =
        completeResult.match((failure) => failure, (_) => null);
    if (completeFailure != null) {
      await ref.read(somedayMaybeRepositoryProvider).deleteItem(somedayItem.id);
      state = AsyncError(completeFailure.message, StackTrace.current);
      return false;
    }

    await ref.read(logHistoryEntryUseCaseProvider)(
      action: HistoryAction.somedayCreated,
      entityType: 'SomedayMaybeItem',
      entityId: somedayItem.id,
      description: 'Moved project "${project.title}" to Someday/Maybe.',
      details: 'Original project was archived.',
    );
    ref
      ..invalidateSelf()
      ..invalidate(allProjectsProvider)
      ..invalidate(allTasksProvider)
      ..invalidate(allNextActionsProvider)
      ..invalidate(projectTasksProvider)
      ..invalidate(somedayMaybeProvider);
    ref.read(historyRefreshSignalProvider.notifier).state++;
    return true;
  }

  Future<String?> _completeProjectTasks(String projectId) async {
    final tasksResult =
        await ref.read(taskRepositoryProvider).getTasksForProject(projectId);
    final taskLoadFailure =
        tasksResult.match((failure) => failure.message, (_) => null);
    if (taskLoadFailure != null) {
      return taskLoadFailure;
    }

    final tasks = tasksResult.match((_) => const <Task>[], (tasks) => tasks);
    for (final task in tasks.where((task) => !task.isCompleted)) {
      final result =
          await ref.read(taskRepositoryProvider).completeTask(task.id);
      final failure = result.match((failure) => failure.message, (_) => null);
      if (failure != null) {
        return failure;
      }
    }
    return null;
  }
}

final allNextActionsProvider =
    AsyncNotifierProvider<AllNextActionsNotifier, List<Task>>(
  AllNextActionsNotifier.new,
);

final allTasksProvider = AsyncNotifierProvider<AllTasksNotifier, List<Task>>(
  AllTasksNotifier.new,
);

class AllTasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final result = await ref.watch(taskRepositoryProvider).getAllTasks();
    return result.match(
      (failure) => throw Exception(failure.message),
      (tasks) => tasks,
    );
  }
}

class AllNextActionsNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final result = await ref.watch(taskRepositoryProvider).getAllNextActions();
    return result.match(
      (failure) => throw Exception(failure.message),
      (tasks) => tasks,
    );
  }

  Future<bool> completeTask(String taskId) async {
    final result = await ref.read(completeNextActionUseCaseProvider)(taskId);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref
          ..invalidateSelf()
          ..invalidate(allTasksProvider)
          ..invalidate(activeProjectsProvider)
          ..invalidate(allProjectsProvider)
          ..invalidate(taskDetailProvider(taskId))
          ..invalidate(projectTasksProvider);
        ref.read(historyRefreshSignalProvider.notifier).state++;
        return true;
      },
    );
  }

  Future<bool> updateTask(Task task) async {
    final result = await ref.read(taskRepositoryProvider).updateTask(task);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref
          ..invalidateSelf()
          ..invalidate(allTasksProvider)
          ..invalidate(activeProjectsProvider)
          ..invalidate(allProjectsProvider)
          ..invalidate(projectTasksProvider)
          ..invalidate(taskDetailProvider(task.id));
        return true;
      },
    );
  }
}

final taskDetailProvider = FutureProvider.family<Task, String>(
  (ref, taskId) async {
    final result = await ref.watch(taskRepositoryProvider).getTaskById(taskId);
    return result.match(
      (failure) => throw Exception(failure.message),
      (task) => task,
    );
  },
);

final archiveItemsProvider = Provider<List<ArchiveItem>>((ref) {
  final tasks = ref.watch(allTasksProvider).valueOrNull ?? [];
  final projects = ref.watch(activeProjectsProvider).valueOrNull ?? [];
  final allProjects = ref.watch(allProjectsProvider).valueOrNull ?? projects;

  return [
    for (final task in tasks)
      if (task.isCompleted)
        ArchiveItem(
          id: 'task-${task.id}',
          title: task.title,
          subtitle: task.context.name,
          archivedAt: task.completedAt ?? task.createdAt,
          type: ArchiveItemType.task,
          route: '/task/${task.id}',
        ),
    for (final project in allProjects)
      if (project.isCompleted)
        ArchiveItem(
          id: 'project-${project.id}',
          title: project.title,
          subtitle: project.desiredOutcome,
          archivedAt: project.targetCompletionDate ?? project.createdAt,
          type: ArchiveItemType.project,
          route: '/project/${project.id}',
        ),
  ]..sort((a, b) => b.archivedAt.compareTo(a.archivedAt));
});

final allProjectsProvider =
    AsyncNotifierProvider<AllProjectsNotifier, List<Project>>(
  AllProjectsNotifier.new,
);

class AllProjectsNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    final result = await ref.watch(projectRepositoryProvider).getAllProjects();
    return result.match(
      (failure) => throw Exception(failure.message),
      (projects) => projects,
    );
  }
}

enum ArchiveItemType { task, project }

class ArchiveItem {
  const ArchiveItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.archivedAt,
    required this.type,
    required this.route,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime archivedAt;
  final ArchiveItemType type;
  final String route;
}

final projectTasksProvider = FutureProvider.family<List<Task>, String>(
  (ref, projectId) async {
    final result =
        await ref.watch(taskRepositoryProvider).getTasksForProject(projectId);
    return result.match(
      (failure) => throw Exception(failure.message),
      (tasks) => tasks,
    );
  },
);

final somedayMaybeProvider =
    AsyncNotifierProvider<SomedayMaybeNotifier, List<SomedayMaybeItem>>(
  SomedayMaybeNotifier.new,
);

final referenceSearchProvider = StateProvider<String>((ref) => '');
final referenceFolderFilterProvider = StateProvider<String?>((ref) => null);
final referenceTagFilterProvider = StateProvider<String?>((ref) => null);

final referenceProvider =
    AsyncNotifierProvider<ReferenceNotifier, List<ReferenceItem>>(
  ReferenceNotifier.new,
);

class ReferenceNotifier extends AsyncNotifier<List<ReferenceItem>> {
  @override
  Future<List<ReferenceItem>> build() async {
    final result = await ref.watch(referenceRepositoryProvider).getAllItems();
    return result.match(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }

  Future<bool> deleteItem(String id) async {
    final result = await ref.read(referenceRepositoryProvider).deleteItem(id);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }
}

final filteredReferenceProvider = Provider<List<ReferenceItem>>((ref) {
  final items = ref.watch(referenceProvider).valueOrNull ?? const [];
  final query = ref.watch(referenceSearchProvider).trim().toLowerCase();
  final folder = ref.watch(referenceFolderFilterProvider);
  final tag = ref.watch(referenceTagFilterProvider);

  return items.where((item) {
    final matchesQuery = query.isEmpty ||
        item.title.toLowerCase().contains(query) ||
        (item.notes ?? '').toLowerCase().contains(query) ||
        item.tags.any((itemTag) => itemTag.toLowerCase().contains(query));
    final matchesFolder = folder == null || item.folder == folder;
    final matchesTag = tag == null || item.tags.contains(tag);
    return matchesQuery && matchesFolder && matchesTag;
  }).toList(growable: false);
});

final referenceFoldersProvider = Provider<List<String>>((ref) {
  final folders = (ref.watch(referenceProvider).valueOrNull ?? const [])
      .map((item) => item.folder)
      .whereType<String>()
      .where((folder) => folder.trim().isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return folders;
});

final referenceTagsProvider = Provider<List<String>>((ref) {
  final tags = (ref.watch(referenceProvider).valueOrNull ?? const [])
      .expand((item) => item.tags)
      .where((tag) => tag.trim().isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return tags;
});

class SomedayMaybeNotifier extends AsyncNotifier<List<SomedayMaybeItem>> {
  @override
  Future<List<SomedayMaybeItem>> build() async {
    final result =
        await ref.watch(somedayMaybeRepositoryProvider).getAllItems();
    return result.match(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }

  Future<String?> activateAsProject(SomedayMaybeItem item) async {
    final result = await ref.read(activateSomedayMaybeUseCaseProvider)(item);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (project) {
        ref
          ..invalidateSelf()
          ..invalidate(activeProjectsProvider)
          ..invalidate(allProjectsProvider)
          ..invalidate(allTasksProvider)
          ..invalidate(allNextActionsProvider);
        ref.read(historyRefreshSignalProvider.notifier).state++;
        return project.id;
      },
    );
  }

  Future<bool> snoozeItem(String id, DateTime reconsiderDate) async {
    final result = await ref
        .read(somedayMaybeRepositoryProvider)
        .snoozeItem(id, reconsiderDate);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }

  Future<bool> deleteItem(String id) async {
    final result =
        await ref.read(somedayMaybeRepositoryProvider).deleteItem(id);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }
}

final readyToActivateProvider = Provider<List<SomedayMaybeItem>>((ref) {
  final today = DateTime.now();
  return ref
          .watch(somedayMaybeProvider)
          .valueOrNull
          ?.where((item) => !item.reconsiderDate.isAfter(today))
          .toList(growable: false) ??
      const [];
});

final weeklyReviewProgressProvider =
    AsyncNotifierProvider<WeeklyReviewProgressNotifier, WeeklyReviewProgress>(
  WeeklyReviewProgressNotifier.new,
);

final weeklyReviewChecklistProvider = Provider<Set<String>>((ref) {
  return ref.watch(weeklyReviewProgressProvider).valueOrNull?.reviewedStepIds ??
      const {};
});

final weeklyReviewCompletedAtProvider = Provider<DateTime?>((ref) {
  return ref.watch(weeklyReviewProgressProvider).valueOrNull?.completedAt;
});

final backupExportProvider = FutureProvider<String>((ref) async {
  final snapshot = await BackupSnapshot.fromRef(ref);
  return const JsonEncoder.withIndent('  ').convert(snapshot.toJson());
});

class WeeklyReviewProgressNotifier extends AsyncNotifier<WeeklyReviewProgress> {
  @override
  Future<WeeklyReviewProgress> build() async {
    final result =
        await ref.watch(weeklyReviewRepositoryProvider).getProgress();
    return result.match(
      (failure) => throw Exception(failure.message),
      (progress) => progress,
    );
  }

  Future<bool> setReviewed(String id, {required bool reviewed}) {
    return _update((progress) {
      return progress.copyWith(
        reviewedStepIds: {
          ...progress.reviewedStepIds.where((entry) => entry != id),
          if (reviewed) id,
        },
      );
    });
  }

  Future<bool> markComplete(DateTime completedAt) {
    return _update((progress) => progress.copyWith(completedAt: completedAt));
  }

  Future<bool> reset() {
    return _update((_) => const WeeklyReviewProgress());
  }

  Future<bool> _update(
    WeeklyReviewProgress Function(WeeklyReviewProgress progress) update,
  ) async {
    final next = update(state.valueOrNull ?? const WeeklyReviewProgress());
    state = AsyncData(next);
    final result =
        await ref.read(weeklyReviewRepositoryProvider).saveProgress(next);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) => true,
    );
  }
}

class BackupSnapshot {
  const BackupSnapshot({
    required this.generatedAt,
    required this.settings,
    required this.contexts,
    required this.inbox,
    required this.tasks,
    required this.projects,
    required this.reference,
    required this.someday,
    required this.waitingFor,
    required this.horizons,
    required this.weeklyReview,
  });

  final DateTime generatedAt;
  final AppSettings settings;
  final List<ZoroContext> contexts;
  final List<InboxItem> inbox;
  final List<Task> tasks;
  final List<Project> projects;
  final List<ReferenceItem> reference;
  final List<SomedayMaybeItem> someday;
  final List<WaitingForItem> waitingFor;
  final HorizonsOfFocus horizons;
  final WeeklyReviewProgress weeklyReview;

  static Future<BackupSnapshot> fromRef(Ref ref) async {
    return BackupSnapshot(
      generatedAt: DateTime.now(),
      settings: await ref.watch(appSettingsControllerProvider.future),
      contexts: await ref.watch(contextsStateProvider.future),
      inbox: await ref.watch(inboxItemsProvider.future),
      tasks: await ref.watch(allTasksProvider.future),
      projects: await ref.watch(allProjectsProvider.future),
      reference: await ref.watch(referenceProvider.future),
      someday: await ref.watch(somedayMaybeProvider.future),
      waitingFor: await ref.watch(allWaitingForProvider.future),
      horizons: ref.watch(horizonsProvider),
      weeklyReview: await ref.watch(weeklyReviewProgressProvider.future),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'schemaVersion': 1,
      'generatedAt': generatedAt.toIso8601String(),
      'settings': {
        'voiceCaptureEnabled': settings.voiceCaptureEnabled,
        'defaultContextName': settings.defaultContextName,
        'weeklyReviewWeekday': settings.weeklyReviewWeekday,
        'aiEnabled': settings.aiEnabled,
        'aiBaseUrl': settings.aiBaseUrl,
        'aiModel': settings.aiModel,
        'aiApiKey': settings.aiApiKey,
        'voiceLocaleId': settings.voiceLocaleId,
      },
      'contexts': contexts.map(_contextToJson).toList(growable: false),
      'inbox': inbox.map(_inboxToJson).toList(growable: false),
      'tasks': tasks.map(_taskToJson).toList(growable: false),
      'projects': projects.map(_projectToJson).toList(growable: false),
      'reference': reference.map(_referenceToJson).toList(growable: false),
      'someday': someday.map(_somedayToJson).toList(growable: false),
      'waitingFor': waitingFor.map(_waitingForToJson).toList(growable: false),
      'horizons': horizons.horizons.map(_horizonToJson).toList(growable: false),
      'weeklyReview': {
        'reviewedStepIds': weeklyReview.reviewedStepIds.toList(growable: false),
        'completedAt': weeklyReview.completedAt?.toIso8601String(),
      },
    };
  }

  Map<String, Object?> _contextToJson(ZoroContext context) {
    return {
      'id': context.id,
      'name': context.name,
      'description': context.description,
      'isDefault': context.isDefault,
    };
  }

  Map<String, Object?> _inboxToJson(InboxItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'notes': item.notes,
      'capturedAt': item.capturedAt.toIso8601String(),
      'source': item.source.name,
    };
  }

  Map<String, Object?> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'contextName': task.context.name,
      'dueDate': task.dueDate?.toIso8601String(),
      'targetDate': task.targetDate?.toIso8601String(),
      'endDateTime': task.endDateTime?.toIso8601String(),
      'isNextAction': task.isNextAction,
      'isCalendarEvent': task.isCalendarEvent,
      'isCompleted': task.isCompleted,
      'createdAt': task.createdAt.toIso8601String(),
      'completedAt': task.completedAt?.toIso8601String(),
      'projectId': task.projectId,
      'tags': task.tags,
      'energyLevel': task.energyLevel.name,
      'estimatedMinutes': task.estimatedMinutes,
      'recurrenceRule': task.recurrence?.toRRule(),
    };
  }

  Map<String, Object?> _projectToJson(Project project) {
    return {
      'id': project.id,
      'title': project.title,
      'desiredOutcome': project.desiredOutcome,
      'stepIds': project.stepIds,
      'projectSteps':
          project.projectSteps.map((step) => step.toJson()).toList(),
      'currentNextActionId': project.currentNextActionId,
      'targetCompletionDate': project.targetCompletionDate?.toIso8601String(),
      'isCompleted': project.isCompleted,
      'createdAt': project.createdAt.toIso8601String(),
      'tags': project.tags,
      'areaOfFocus': project.areaOfFocus,
      'completedStepCount': project.completedStepCount,
    };
  }

  Map<String, Object?> _somedayToJson(SomedayMaybeItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'reconsiderDate': item.reconsiderDate.toIso8601String(),
      'createdAt': item.createdAt.toIso8601String(),
      'notes': item.notes,
      'tags': item.tags,
    };
  }

  Map<String, Object?> _referenceToJson(ReferenceItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'notes': item.notes,
      'tags': item.tags,
      'folder': item.folder,
      'createdAt': item.createdAt.toIso8601String(),
    };
  }

  Map<String, Object?> _waitingForToJson(WaitingForItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'person': item.person,
      'projectId': item.projectId,
      'followUpDate': item.followUpDate?.toIso8601String(),
      'createdAt': item.createdAt.toIso8601String(),
      'notes': item.notes,
      'tags': item.tags,
      'isResolved': item.isResolved,
    };
  }

  Map<String, Object?> _horizonToJson(Horizon horizon) {
    return {
      'level': horizon.level.name,
      'title': horizon.title,
      'description': horizon.description,
      'alignmentScore': horizon.alignmentScore,
    };
  }
}

final waitingForProvider =
    AsyncNotifierProvider<WaitingForNotifier, List<WaitingForItem>>(
  WaitingForNotifier.new,
);

final waitingForDueProvider = Provider<List<WaitingForItem>>((ref) {
  final today = DateTime.now();
  return ref
          .watch(waitingForProvider)
          .valueOrNull
          ?.where((item) =>
              item.followUpDate != null && !item.followUpDate!.isAfter(today))
          .toList(growable: false) ??
      const [];
});

final allWaitingForProvider = FutureProvider<List<WaitingForItem>>((ref) async {
  final result = await ref.watch(waitingForRepositoryProvider).getAllItems();
  return result.match(
    (failure) => throw Exception(failure.message),
    (items) => items,
  );
});

final resolvedWaitingForProvider = Provider<List<WaitingForItem>>((ref) {
  return ref
          .watch(allWaitingForProvider)
          .valueOrNull
          ?.where((item) => item.isResolved)
          .toList(growable: false) ??
      const [];
});

final waitingForViewProvider =
    StateProvider<WaitingForView>((ref) => WaitingForView.active);

enum WaitingForView { active, resolved }

final selectedCalendarModeProvider =
    StateProvider<CalendarViewMode>((ref) => CalendarViewMode.week);

final selectedCalendarDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final calendarEntriesProvider = Provider<List<CalendarEntry>>((ref) {
  final tasks = ref.watch(allTasksProvider).valueOrNull ?? [];
  final projects = ref.watch(activeProjectsProvider).valueOrNull ?? [];
  final waitingFor = ref.watch(waitingForProvider).valueOrNull ?? [];
  final mode = ref.watch(selectedCalendarModeProvider);
  final selectedDate = ref.watch(selectedCalendarDateProvider);
  final range = CalendarDateRange.from(selectedDate, mode);
  final rangeEnd = DateTime(
    range.end.year,
    range.end.month,
    range.end.day,
    23,
    59,
    59,
  );

  final entries = [
    for (final task in tasks.where((task) => !task.isCompleted)) ...[
      if (task.isCalendarEvent)
        for (final occurrence in calendarOccurrencesForTask(
          task: task,
          rangeStart: range.start,
          rangeEnd: rangeEnd,
        ))
          CalendarEntry(
            id: 'calendar-${occurrence.id}',
            title: task.title,
            subtitle: task.context.name,
            date: occurrence.start,
            type: CalendarEntryType.calendarEvent,
            route: '/task/${task.id}',
            isRecurring: occurrence.isRecurring,
          ),
      if (task.dueDate != null)
        CalendarEntry(
          id: 'task-due-${task.id}',
          title: task.title,
          subtitle: task.context.name,
          date: task.dueDate!,
          type: CalendarEntryType.taskDue,
          route: '/task/${task.id}',
          isRecurring: false,
        ),
      if (!task.isCalendarEvent &&
          task.targetDate != null &&
          !_sameDay(task.targetDate!, task.dueDate))
        CalendarEntry(
          id: 'task-target-${task.id}',
          title: task.title,
          subtitle: task.context.name,
          date: task.targetDate!,
          type: CalendarEntryType.taskTarget,
          route: '/task/${task.id}',
          isRecurring: false,
        ),
    ],
    for (final project in projects)
      if (project.targetCompletionDate != null)
        CalendarEntry(
          id: 'project-${project.id}',
          title: project.title,
          subtitle: project.desiredOutcome,
          date: project.targetCompletionDate!,
          type: CalendarEntryType.projectTarget,
          route: '/project/${project.id}',
          isRecurring: false,
        ),
    for (final item in waitingFor)
      if (item.followUpDate != null)
        CalendarEntry(
          id: 'waiting-${item.id}',
          title: item.title,
          subtitle: 'Waiting on ${item.person}',
          date: item.followUpDate!,
          type: CalendarEntryType.waitingFor,
          route: '/waiting-for',
          isRecurring: false,
        ),
  ]..sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return a.title.compareTo(b.title);
    });

  return entries;
});

final visibleCalendarEntriesProvider = Provider<List<CalendarEntry>>((ref) {
  final mode = ref.watch(selectedCalendarModeProvider);
  final selectedDate = ref.watch(selectedCalendarDateProvider);
  final range = CalendarDateRange.from(selectedDate, mode);
  return ref
      .watch(calendarEntriesProvider)
      .where((entry) => range.contains(entry.date))
      .toList(growable: false);
});

enum CalendarViewMode { day, week, month }

enum CalendarEntryType {
  taskDue,
  taskTarget,
  calendarEvent,
  projectTarget,
  waitingFor,
}

class CalendarEntry {
  const CalendarEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
    required this.route,
    this.isRecurring = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final CalendarEntryType type;
  final String route;
  final bool isRecurring;
}

class CalendarDateRange {
  const CalendarDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  factory CalendarDateRange.from(DateTime selected, CalendarViewMode mode) {
    final normalized = DateTime(selected.year, selected.month, selected.day);
    return switch (mode) {
      CalendarViewMode.day => CalendarDateRange(
          start: normalized,
          end: normalized,
        ),
      CalendarViewMode.week => CalendarDateRange(
          start: normalized.subtract(Duration(days: normalized.weekday % 7)),
          end: normalized.add(Duration(days: 6 - (normalized.weekday % 7))),
        ),
      CalendarViewMode.month => CalendarDateRange(
          start: DateTime(normalized.year, normalized.month),
          end: DateTime(normalized.year, normalized.month + 1, 0),
        ),
    };
  }

  bool contains(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return !normalized.isBefore(start) && !normalized.isAfter(end);
  }
}

bool _sameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class WaitingForNotifier extends AsyncNotifier<List<WaitingForItem>> {
  @override
  Future<List<WaitingForItem>> build() async {
    final result = await ref.watch(waitingForRepositoryProvider).getOpenItems();
    return result.match(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }

  Future<bool> addItem({
    required String title,
    required String person,
    DateTime? followUpDate,
    String? notes,
  }) async {
    final cleanTitle = title.trim();
    final cleanPerson = person.trim();
    if (cleanTitle.isEmpty || cleanPerson.isEmpty) {
      state = AsyncError(
        'Waiting For title and person are required.',
        StackTrace.current,
      );
      return false;
    }

    final result = await ref.read(waitingForRepositoryProvider).addItem(
          WaitingForItem(
            id: '',
            title: cleanTitle,
            person: cleanPerson,
            followUpDate: followUpDate,
            createdAt: DateTime.now(),
            notes: _cleanOptional(notes),
            tags: const [],
          ),
        );

    final failure = result.match((failure) => failure, (_) => null);
    if (failure != null) {
      state = AsyncError(failure.message, StackTrace.current);
      return false;
    }

    final item = result.match((_) => null, (item) => item)!;
    await ref.read(logHistoryEntryUseCaseProvider)(
      action: HistoryAction.waitingForCreated,
      entityType: 'WaitingForItem',
      entityId: item.id,
      description: 'Created Waiting For "${item.title}".',
      details: 'Waiting on ${item.person}.',
    );
    ref
      ..invalidateSelf()
      ..invalidate(allWaitingForProvider)
      ..invalidate(historyRepositoryProvider);
    ref.read(historyRefreshSignalProvider.notifier).state++;
    return true;
  }

  Future<bool> updateFollowUpDate(String id, DateTime? followUpDate) async {
    final current = state.valueOrNull ?? [];
    final item = current.where((entry) => entry.id == id).firstOrNull;
    if (item == null) {
      return false;
    }

    final result = await ref.read(waitingForRepositoryProvider).updateItem(
          WaitingForItem(
            id: item.id,
            title: item.title,
            person: item.person,
            projectId: item.projectId,
            followUpDate: followUpDate,
            createdAt: item.createdAt,
            notes: item.notes,
            tags: item.tags,
            isResolved: item.isResolved,
          ),
        );

    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref
          ..invalidateSelf()
          ..invalidate(allWaitingForProvider);
        return true;
      },
    );
  }

  Future<bool> markResolved(String id) async {
    final item =
        state.valueOrNull?.where((entry) => entry.id == id).firstOrNull;
    final result =
        await ref.read(waitingForRepositoryProvider).markResolved(id);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        if (item != null) {
          ref.read(logHistoryEntryUseCaseProvider)(
            action: HistoryAction.waitingForResolved,
            entityType: 'WaitingForItem',
            entityId: item.id,
            description: 'Marked Waiting For "${item.title}" as completed.',
            details: 'Waiting on ${item.person}.',
          );
        }
        ref
          ..invalidateSelf()
          ..invalidate(allWaitingForProvider)
          ..invalidate(historyRepositoryProvider);
        ref.read(historyRefreshSignalProvider.notifier).state++;
        return true;
      },
    );
  }

  Future<bool> deleteItem(String id) async {
    final result = await ref.read(waitingForRepositoryProvider).deleteItem(id);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref
          ..invalidateSelf()
          ..invalidate(allWaitingForProvider);
        return true;
      },
    );
  }

  String? _cleanOptional(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

final horizonsProvider = NotifierProvider<HorizonsNotifier, HorizonsOfFocus>(
  HorizonsNotifier.new,
);

final horizonsAlignmentProvider = Provider<HorizonsAlignmentSummary>((ref) {
  final horizons = ref.watch(horizonsProvider).horizons;
  final alignedCount =
      horizons.where((horizon) => (horizon.alignmentScore ?? 0) >= 0.7).length;
  final describedCount =
      horizons.where((horizon) => horizon.description.trim().isNotEmpty).length;

  return HorizonsAlignmentSummary(
    totalCount: horizons.length,
    alignedCount: alignedCount,
    describedCount: describedCount,
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final globalSearchResultsProvider = Provider<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) {
    return const [];
  }

  final inbox = ref.watch(inboxItemsProvider).valueOrNull ?? [];
  final projects = ref.watch(activeProjectsProvider).valueOrNull ?? [];
  final archived = ref.watch(archiveItemsProvider);
  final tasks = ref.watch(allNextActionsProvider).valueOrNull ?? [];
  final someday = ref.watch(somedayMaybeProvider).valueOrNull ?? [];
  final reference = ref.watch(referenceProvider).valueOrNull ?? [];
  final waitingFor = ref.watch(waitingForProvider).valueOrNull ?? [];
  final horizons = ref.watch(horizonsProvider).horizons;

  return [
    for (final item in inbox)
      if (_matches(query, [item.title, item.notes]))
        SearchResult(
          title: item.title,
          subtitle: item.notes ?? 'Inbox capture',
          category: 'Inbox',
          route: '/processing/${item.id}',
        ),
    for (final project in projects)
      if (_matches(query, [
        project.title,
        project.desiredOutcome,
        project.areaOfFocus,
        ...project.tags,
      ]))
        SearchResult(
          title: project.title,
          subtitle: project.desiredOutcome,
          category: 'Project',
          route: '/project/${project.id}',
        ),
    for (final task in tasks)
      if (_matches(query, [
        task.title,
        task.description,
        task.context.name,
        ...task.tags,
      ]))
        SearchResult(
          title: task.title,
          subtitle: task.context.name,
          category: 'Next Action',
          route: '/task/${task.id}',
        ),
    for (final item in someday)
      if (_matches(query, [item.title, item.notes, ...item.tags]))
        SearchResult(
          title: item.title,
          subtitle:
              'Reconsider ${item.reconsiderDate.month}/${item.reconsiderDate.day}/${item.reconsiderDate.year}',
          category: 'Someday/Maybe',
          route: '/someday',
        ),
    for (final item in reference)
      if (_matches(query, [item.title, item.notes, item.folder, ...item.tags]))
        SearchResult(
          title: item.title,
          subtitle: item.folder ?? 'Reference',
          category: 'Reference',
          route: '/reference',
        ),
    for (final item in waitingFor)
      if (_matches(query, [item.title, item.person, item.notes]))
        SearchResult(
          title: item.title,
          subtitle: 'Waiting on ${item.person}',
          category: 'Waiting For',
          route: '/waiting-for',
        ),
    for (final item in archived)
      if (_matches(query, [item.title, item.subtitle]))
        SearchResult(
          title: item.title,
          subtitle: item.subtitle,
          category: 'Archive',
          route: item.route,
        ),
    for (final horizon in horizons)
      if (_matches(query, [horizon.title, horizon.description]))
        SearchResult(
          title: horizon.title,
          subtitle: horizon.description.isEmpty
              ? 'Horizons of Focus'
              : horizon.description,
          category: 'Horizon',
          route: '/horizons',
        ),
  ];
});

bool _matches(String query, Iterable<String?> values) {
  return values
      .whereType<String>()
      .any((value) => value.toLowerCase().contains(query));
}

class SearchResult {
  const SearchResult({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String category;
  final String route;
}

class HorizonsNotifier extends Notifier<HorizonsOfFocus> {
  static const defaultHorizons = HorizonsOfFocus(
    horizons: [
      Horizon(
        level: HorizonLevel.purposeAndPrinciples,
        title: 'Purpose & Principles',
        description: '',
        alignmentScore: 0.5,
      ),
      Horizon(
        level: HorizonLevel.vision,
        title: 'Vision (3-5 years)',
        description: '',
        alignmentScore: 0.5,
      ),
      Horizon(
        level: HorizonLevel.goals,
        title: 'Goals (1-2 years)',
        description: '',
        alignmentScore: 0.5,
      ),
      Horizon(
        level: HorizonLevel.areasOfFocus,
        title: 'Areas of Focus',
        description: '',
        alignmentScore: 0.5,
      ),
      Horizon(
        level: HorizonLevel.projects,
        title: 'Projects',
        description: '',
        alignmentScore: 0.5,
      ),
      Horizon(
        level: HorizonLevel.nextActions,
        title: 'Next Actions',
        description: '',
        alignmentScore: 0.5,
      ),
    ],
  );

  @override
  HorizonsOfFocus build() {
    _loadPersistedHorizons();
    return defaultHorizons;
  }

  void updateDescription(HorizonLevel level, String description) {
    state = HorizonsOfFocus(
      horizons: [
        for (final horizon in state.horizons)
          horizon.level == level
              ? _copyHorizon(horizon, description: description)
              : horizon,
      ],
    );
    _saveHorizons();
  }

  void updateAlignmentScore(HorizonLevel level, double score) {
    state = HorizonsOfFocus(
      horizons: [
        for (final horizon in state.horizons)
          horizon.level == level
              ? _copyHorizon(horizon, alignmentScore: score)
              : horizon,
      ],
    );
    _saveHorizons();
  }

  Future<void> _loadPersistedHorizons() async {
    final result = await ref.read(horizonsRepositoryProvider).getHorizons();
    result.match(
      (_) {},
      (persisted) {
        if (persisted.horizons.isNotEmpty) {
          state = _mergeWithDefaults(persisted);
        }
      },
    );
  }

  Future<void> _saveHorizons() async {
    await ref.read(horizonsRepositoryProvider).saveHorizons(state);
  }

  HorizonsOfFocus _mergeWithDefaults(HorizonsOfFocus persisted) {
    return HorizonsOfFocus(
      horizons: [
        for (final defaultHorizon in defaultHorizons.horizons)
          persisted.horizons
                  .where((horizon) => horizon.level == defaultHorizon.level)
                  .firstOrNull ??
              defaultHorizon,
      ],
    );
  }

  Horizon _copyHorizon(
    Horizon horizon, {
    String? description,
    double? alignmentScore,
  }) {
    return Horizon(
      level: horizon.level,
      title: horizon.title,
      description: description ?? horizon.description,
      alignmentScore: alignmentScore ?? horizon.alignmentScore,
    );
  }
}

class HorizonsAlignmentSummary {
  const HorizonsAlignmentSummary({
    required this.totalCount,
    required this.alignedCount,
    required this.describedCount,
  });

  final int totalCount;
  final int alignedCount;
  final int describedCount;
}

class ProcessingRequest {
  const ProcessingRequest({
    required this.choice,
    this.title,
    this.desiredOutcome,
    this.context,
    this.targetDate,
    this.endDateTime,
    this.notes,
    this.nextActionTitle,
    this.reconsiderDate,
    this.referenceFolder,
    this.waitingOn,
    this.waitingForProjectId,
    this.followUpDate,
    this.recurrence,
    this.tags = const [],
    this.stepTitles = const [],
    this.projectSteps = const [],
  });

  final ProcessingChoice choice;
  final String? title;
  final String? desiredOutcome;
  final ZoroContext? context;
  final DateTime? targetDate;
  final DateTime? endDateTime;
  final String? notes;
  final String? nextActionTitle;
  final DateTime? reconsiderDate;
  final String? referenceFolder;
  final String? waitingOn;
  final String? waitingForProjectId;
  final DateTime? followUpDate;
  final Recurrence? recurrence;
  final List<String> tags;
  final List<String> stepTitles;
  final List<ProjectStep> projectSteps;
}
