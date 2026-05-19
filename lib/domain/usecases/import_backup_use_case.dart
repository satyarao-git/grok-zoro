import 'dart:convert';

import 'package:fpdart/fpdart.dart' hide Task;

import '../../core/utils/failure.dart';
import '../entities/app_settings.dart';
import '../entities/context.dart';
import '../entities/horizon.dart';
import '../entities/inbox_item.dart';
import '../entities/project.dart';
import '../entities/project_step.dart';
import '../entities/recurrence.dart';
import '../entities/reference_item.dart';
import '../entities/someday_maybe_item.dart';
import '../entities/task.dart';
import '../entities/waiting_for_item.dart';
import '../entities/weekly_review_progress.dart';
import '../repositories/context_repository.dart';
import '../repositories/horizons_repository.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/reference_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/someday_maybe_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/waiting_for_repository.dart';
import '../repositories/weekly_review_repository.dart';

class ImportBackupUseCase {
  const ImportBackupUseCase({
    required this.settingsRepository,
    required this.contextRepository,
    required this.inboxRepository,
    required this.taskRepository,
    required this.projectRepository,
    required this.somedayMaybeRepository,
    required this.referenceRepository,
    required this.waitingForRepository,
    required this.horizonsRepository,
    required this.weeklyReviewRepository,
  });

  final SettingsRepository settingsRepository;
  final ContextRepository contextRepository;
  final InboxRepository inboxRepository;
  final TaskRepository taskRepository;
  final ProjectRepository projectRepository;
  final SomedayMaybeRepository somedayMaybeRepository;
  final ReferenceRepository referenceRepository;
  final WaitingForRepository waitingForRepository;
  final HorizonsRepository horizonsRepository;
  final WeeklyReviewRepository weeklyReviewRepository;

  Future<Either<Failure, ImportBackupResult>> call(String jsonText) async {
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) {
        return left(
          const ValidationFailure('The selected file is not a Zoro backup.'),
        );
      }
      final snapshot = BackupImportSnapshot.fromJson(
        Map<String, Object?>.from(decoded),
      );

      for (final action in [
        inboxRepository.clearAll,
        taskRepository.clearAll,
        projectRepository.clearAll,
        somedayMaybeRepository.clearAll,
        referenceRepository.clearAll,
        waitingForRepository.clearAll,
      ]) {
        final failure = await _failureOf(action());
        if (failure != null) {
          return left(failure);
        }
      }

      final contextsResult = await contextRepository.getAllContexts();
      final contextsFailure = contextsResult.match(
        (failure) => failure,
        (contexts) => null,
      );
      if (contextsFailure != null) {
        return left(contextsFailure);
      }
      for (final context in contextsResult.getRight().toNullable() ?? []) {
        final failure = await _failureOf(
          contextRepository.deleteContext(context.id),
        );
        if (failure != null) {
          return left(failure);
        }
      }

      for (final result in [
        settingsRepository.saveSettings(snapshot.settings),
        horizonsRepository.saveHorizons(snapshot.horizons),
        weeklyReviewRepository.saveProgress(snapshot.weeklyReview),
      ]) {
        final failure = await _failureOf(result);
        if (failure != null) {
          return left(failure);
        }
      }

      for (final context in snapshot.contexts) {
        final failure =
            await _failureOf(contextRepository.saveContext(context));
        if (failure != null) {
          return left(failure);
        }
      }
      for (final item in snapshot.inbox) {
        final failure = await _failureOf(inboxRepository.addInboxItem(item));
        if (failure != null) {
          return left(failure);
        }
      }
      for (final task in snapshot.tasks) {
        final failure = await _failureOf(taskRepository.createTask(task));
        if (failure != null) {
          return left(failure);
        }
      }
      for (final project in snapshot.projects) {
        final failure = await _failureOf(projectRepository.createProject(
          project,
        ));
        if (failure != null) {
          return left(failure);
        }
      }
      for (final item in snapshot.reference) {
        final failure = await _failureOf(referenceRepository.addItem(item));
        if (failure != null) {
          return left(failure);
        }
      }
      for (final item in snapshot.someday) {
        final failure = await _failureOf(somedayMaybeRepository.addItem(item));
        if (failure != null) {
          return left(failure);
        }
      }
      for (final item in snapshot.waitingFor) {
        final failure = await _failureOf(waitingForRepository.addItem(item));
        if (failure != null) {
          return left(failure);
        }
      }

      return right(ImportBackupResult.fromSnapshot(snapshot));
    } on FormatException catch (error) {
      return left(ValidationFailure(error.message));
    } catch (error) {
      return left(DatabaseFailure('Could not import backup: $error'));
    }
  }

  Future<Failure?> _failureOf<T>(Future<Either<Failure, T>> future) async {
    final result = await future;
    return result.match((failure) => failure, (_) => null);
  }
}

class ImportBackupResult {
  const ImportBackupResult({
    required this.inboxCount,
    required this.taskCount,
    required this.projectCount,
    required this.referenceCount,
    required this.somedayCount,
    required this.waitingForCount,
  });

  final int inboxCount;
  final int taskCount;
  final int projectCount;
  final int referenceCount;
  final int somedayCount;
  final int waitingForCount;

  int get totalImported =>
      inboxCount +
      taskCount +
      projectCount +
      referenceCount +
      somedayCount +
      waitingForCount;

  factory ImportBackupResult.fromSnapshot(BackupImportSnapshot snapshot) {
    return ImportBackupResult(
      inboxCount: snapshot.inbox.length,
      taskCount: snapshot.tasks.length,
      projectCount: snapshot.projects.length,
      referenceCount: snapshot.reference.length,
      somedayCount: snapshot.someday.length,
      waitingForCount: snapshot.waitingFor.length,
    );
  }
}

class BackupImportSnapshot {
  const BackupImportSnapshot({
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

  factory BackupImportSnapshot.fromJson(Map<String, Object?> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != 1) {
      throw const FormatException(
        'Only Zoro backup schema version 1 can be imported.',
      );
    }

    return BackupImportSnapshot(
      settings: _settingsFromJson(_map(json['settings'])),
      contexts: _mapList(json['contexts']).map(_contextFromJson).toList(),
      inbox: _mapList(json['inbox']).map(_inboxFromJson).toList(),
      tasks: _mapList(json['tasks']).map(_taskFromJson).toList(),
      projects: _mapList(json['projects']).map(_projectFromJson).toList(),
      reference: _mapList(json['reference']).map(_referenceFromJson).toList(),
      someday: _mapList(json['someday']).map(_somedayFromJson).toList(),
      waitingFor:
          _mapList(json['waitingFor']).map(_waitingForFromJson).toList(),
      horizons: HorizonsOfFocus(
        horizons: _mapList(json['horizons']).map(_horizonFromJson).toList(),
      ),
      weeklyReview: _weeklyReviewFromJson(_map(json['weeklyReview'])),
    );
  }
}

AppSettings _settingsFromJson(Map<String, Object?> json) {
  const defaults = AppSettings();
  return AppSettings(
    voiceCaptureEnabled:
        json['voiceCaptureEnabled'] as bool? ?? defaults.voiceCaptureEnabled,
    defaultContextName:
        json['defaultContextName'] as String? ?? defaults.defaultContextName,
    weeklyReviewWeekday:
        _intOrNull(json['weeklyReviewWeekday']) ?? defaults.weeklyReviewWeekday,
    aiEnabled: json['aiEnabled'] as bool? ?? defaults.aiEnabled,
    aiBaseUrl: json['aiBaseUrl'] as String? ?? defaults.aiBaseUrl,
    aiModel: json['aiModel'] as String? ?? defaults.aiModel,
    aiApiKey: json['aiApiKey'] as String?,
    voiceLocaleId: json['voiceLocaleId'] as String?,
  );
}

ZoroContext _contextFromJson(Map<String, Object?> json) {
  final name = _requiredString(json, 'name');
  return ZoroContext(
    id: json['id'] as String? ?? '',
    name: name,
    description: json['description'] as String?,
    isDefault: json['isDefault'] as bool? ?? false,
  );
}

InboxItem _inboxFromJson(Map<String, Object?> json) {
  return InboxItem(
    id: json['id'] as String? ?? '',
    title: _requiredString(json, 'title'),
    notes: json['notes'] as String?,
    capturedAt: _requiredDate(json, 'capturedAt'),
    source: CaptureSource.values.firstWhere(
      (source) => source.name == json['source'],
      orElse: () => CaptureSource.manual,
    ),
  );
}

Task _taskFromJson(Map<String, Object?> json) {
  final contextName = json['contextName'] as String? ?? '@Anywhere';
  return Task(
    id: json['id'] as String? ?? '',
    title: _requiredString(json, 'title'),
    description: json['description'] as String?,
    context: ZoroContext(
      id: contextName.replaceAll('@', '').toLowerCase(),
      name: contextName,
    ),
    dueDate: _dateOrNull(json['dueDate']),
    targetDate: _dateOrNull(json['targetDate']),
    endDateTime: _dateOrNull(json['endDateTime']),
    isNextAction: json['isNextAction'] as bool? ?? true,
    isCalendarEvent: json['isCalendarEvent'] as bool? ?? false,
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: _requiredDate(json, 'createdAt'),
    completedAt: _dateOrNull(json['completedAt']),
    projectId: json['projectId'] as String?,
    tags: _strings(json['tags']),
    energyLevel: EnergyLevel.values.firstWhere(
      (level) => level.name == json['energyLevel'],
      orElse: () => EnergyLevel.medium,
    ),
    estimatedMinutes: _intOrNull(json['estimatedMinutes']),
    recurrence: Recurrence.fromRRule(json['recurrenceRule'] as String?),
  );
}

Project _projectFromJson(Map<String, Object?> json) {
  return Project(
    id: json['id'] as String? ?? '',
    title: _requiredString(json, 'title'),
    desiredOutcome: _requiredString(json, 'desiredOutcome'),
    stepIds: _strings(json['stepIds']),
    projectSteps: _projectStepsFromJson(json['projectSteps']),
    currentNextActionId: json['currentNextActionId'] as String?,
    targetCompletionDate: _dateOrNull(json['targetCompletionDate']),
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: _requiredDate(json, 'createdAt'),
    tags: _strings(json['tags']),
    areaOfFocus: json['areaOfFocus'] as String?,
    completedStepCount: _intOrNull(json['completedStepCount']) ?? 0,
  );
}

ReferenceItem _referenceFromJson(Map<String, Object?> json) {
  return ReferenceItem(
    id: json['id'] as String? ?? '',
    title: _requiredString(json, 'title'),
    notes: json['notes'] as String?,
    tags: _strings(json['tags']),
    folder: json['folder'] as String?,
    createdAt: _requiredDate(json, 'createdAt'),
  );
}

SomedayMaybeItem _somedayFromJson(Map<String, Object?> json) {
  return SomedayMaybeItem(
    id: json['id'] as String? ?? '',
    title: _requiredString(json, 'title'),
    reconsiderDate: _requiredDate(json, 'reconsiderDate'),
    createdAt: _requiredDate(json, 'createdAt'),
    notes: json['notes'] as String?,
    tags: _strings(json['tags']),
  );
}

WaitingForItem _waitingForFromJson(Map<String, Object?> json) {
  return WaitingForItem(
    id: json['id'] as String? ?? '',
    title: _requiredString(json, 'title'),
    person: _requiredString(json, 'person'),
    projectId: json['projectId'] as String?,
    followUpDate: _dateOrNull(json['followUpDate']),
    createdAt: _requiredDate(json, 'createdAt'),
    notes: json['notes'] as String?,
    tags: _strings(json['tags']),
    isResolved: json['isResolved'] as bool? ?? false,
  );
}

Horizon _horizonFromJson(Map<String, Object?> json) {
  final rawLevel = json['level'] ?? json['levelName'];
  final level = HorizonLevel.values.firstWhere(
    (entry) => entry.name == rawLevel,
    orElse: () => HorizonLevel.nextActions,
  );
  return Horizon(
    level: level,
    title: json['title'] as String? ?? _defaultHorizonTitle(level),
    description: json['description'] as String? ?? '',
    alignmentScore: (json['alignmentScore'] as num?)?.toDouble(),
  );
}

WeeklyReviewProgress _weeklyReviewFromJson(Map<String, Object?> json) {
  return WeeklyReviewProgress(
    reviewedStepIds: _strings(json['reviewedStepIds']).toSet(),
    completedAt: _dateOrNull(json['completedAt']),
  );
}

List<ProjectStep> _projectStepsFromJson(Object? value) {
  return _mapList(value).map(ProjectStep.fromJson).toList(growable: false);
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return Map<String, Object?>.from(value);
  }
  return const {};
}

List<Map<String, Object?>> _mapList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((entry) => Map<String, Object?>.from(entry))
      .toList(growable: false);
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw FormatException('Backup item is missing "$key".');
}

DateTime _requiredDate(Map<String, Object?> json, String key) {
  final value = _dateOrNull(json[key]);
  if (value != null) {
    return value;
  }
  throw FormatException('Backup item is missing "$key".');
}

DateTime? _dateOrNull(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

int? _intOrNull(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

List<String> _strings(Object? value) {
  if (value is List) {
    return value
        .whereType<String>()
        .where((entry) => entry.trim().isNotEmpty)
        .toList(growable: false);
  }
  return const [];
}

String _defaultHorizonTitle(HorizonLevel level) {
  return switch (level) {
    HorizonLevel.purposeAndPrinciples => 'Purpose & Principles',
    HorizonLevel.vision => 'Vision (3-5 years)',
    HorizonLevel.goals => 'Goals (1-2 years)',
    HorizonLevel.areasOfFocus => 'Areas of Focus',
    HorizonLevel.projects => 'Projects',
    HorizonLevel.nextActions => 'Next Actions',
  };
}
