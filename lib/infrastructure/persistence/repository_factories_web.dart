// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:fpdart/fpdart.dart' hide Task;
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/context.dart';
import '../../domain/entities/horizon.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/inbox_item.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_step.dart';
import '../../domain/entities/recurrence.dart';
import '../../domain/entities/reference_item.dart';
import '../../domain/entities/someday_maybe_item.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/waiting_for_item.dart';
import '../../domain/entities/weekly_review_progress.dart';
import '../../domain/repositories/context_repository.dart';
import '../../domain/repositories/horizons_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/reference_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/someday_maybe_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/waiting_for_repository.dart';
import '../../domain/repositories/weekly_review_repository.dart';

Future<Object> openPersistenceStore() async {
  return WebPersistenceStore.load();
}

InboxRepository createInboxRepository(Future<Object> store) {
  return _WebInboxRepository(
      store.then((value) => value as WebPersistenceStore));
}

TaskRepository createTaskRepository(Future<Object> store) {
  return _WebTaskRepository(
      store.then((value) => value as WebPersistenceStore));
}

ProjectRepository createProjectRepository(Future<Object> store) {
  return _WebProjectRepository(
    store.then((value) => value as WebPersistenceStore),
  );
}

ReferenceRepository createReferenceRepository(Future<Object> store) {
  return _WebReferenceRepository(
    store.then((value) => value as WebPersistenceStore),
  );
}

SomedayMaybeRepository createSomedayMaybeRepository(Future<Object> store) {
  return _WebSomedayMaybeRepository(
    store.then((value) => value as WebPersistenceStore),
  );
}

ContextRepository createContextRepository(Future<Object> store) {
  return _WebContextRepository(
    store.then((value) => value as WebPersistenceStore),
  );
}

WaitingForRepository createWaitingForRepository(Future<Object> store) {
  return _WebWaitingForRepository(
    store.then((value) => value as WebPersistenceStore),
  );
}

HistoryRepository createHistoryRepository(Future<Object> store) {
  return _WebHistoryRepository(
    store.then((value) => value as WebPersistenceStore),
  );
}

SettingsRepository createSettingsRepository(Future<Object> store) {
  return _WebSettingsRepository(
    store.then((value) => value as WebPersistenceStore),
  );
}

HorizonsRepository createHorizonsRepository(Future<Object> store) {
  return _WebHorizonsRepository(
    store.then((value) => value as WebPersistenceStore),
  );
}

WeeklyReviewRepository createWeeklyReviewRepository(Future<Object> store) {
  return _WebWeeklyReviewRepository(
    store.then((value) => value as WebPersistenceStore),
  );
}

class WebPersistenceStore {
  WebPersistenceStore({
    required this.inbox,
    required this.contexts,
    required this.tasks,
    required this.projects,
    required this.reference,
    required this.someday,
    required this.waitingFor,
    required this.history,
    required this.settings,
    required this.horizons,
    required this.weeklyReview,
    required this.nextId,
  });

  static const _key = 'zoro.persistence.v1';

  final List<Map<String, Object?>> inbox;
  final List<Map<String, Object?>> contexts;
  final List<Map<String, Object?>> tasks;
  final List<Map<String, Object?>> projects;
  final List<Map<String, Object?>> reference;
  final List<Map<String, Object?>> someday;
  final List<Map<String, Object?>> waitingFor;
  final List<Map<String, Object?>> history;
  Map<String, Object?> settings;
  List<Map<String, Object?>> horizons;
  Map<String, Object?> weeklyReview;
  int nextId;
  static const _uuid = Uuid();

  static WebPersistenceStore load() {
    final raw = html.window.localStorage[_key];
    if (raw == null) {
      final seeded = _seed();
      seeded.save();
      return seeded;
    }

    final json = jsonDecode(raw) as Map<String, Object?>;
    return WebPersistenceStore(
      inbox: _list(json['inbox']),
      contexts: _list(json['contexts']).isEmpty
          ? _defaultContextRows()
          : _list(json['contexts']),
      tasks: _list(json['tasks']),
      projects: _list(json['projects']),
      reference: _list(json['reference']),
      someday: _list(json['someday']),
      waitingFor: _list(json['waitingFor']),
      history: _list(json['history']),
      settings: Map<String, Object?>.from(
        json['settings'] as Map? ?? _defaultSettingsRow(),
      ),
      horizons: _list(json['horizons']),
      weeklyReview: Map<String, Object?>.from(
        json['weeklyReview'] as Map? ?? _defaultWeeklyReviewRow(),
      ),
      nextId: json['nextId'] as int? ?? 100,
    );
  }

  String takeId() {
    final id = _uuid.v4();
    nextId += 1;
    return id;
  }

  void save() {
    html.window.localStorage[_key] = jsonEncode({
      'inbox': inbox,
      'contexts': contexts,
      'tasks': tasks,
      'projects': projects,
      'reference': reference,
      'someday': someday,
      'waitingFor': waitingFor,
      'history': history,
      'settings': settings,
      'horizons': horizons,
      'weeklyReview': weeklyReview,
      'nextId': nextId,
    });
  }

  static List<Map<String, Object?>> _list(Object? value) {
    return (value as List? ?? const [])
        .map((entry) => Map<String, Object?>.from(entry as Map))
        .toList();
  }

  static WebPersistenceStore _seed() {
    return WebPersistenceStore(
      nextId: 100,
      settings: _defaultSettingsRow(),
      horizons: const [],
      weeklyReview: _defaultWeeklyReviewRow(),
      contexts: _defaultContextRows(),
      inbox: [
        {
          'id': '1',
          'title': 'Launch company website v2',
          'capturedAt': DateTime(2026, 5, 8, 9).toIso8601String(),
          'source': 'manual',
        },
        {
          'id': '2',
          'title': 'Prepare Q2 financial report',
          'capturedAt': DateTime(2026, 5, 8, 10, 30).toIso8601String(),
          'source': 'voice',
        },
      ],
      projects: [
        {
          'id': '10',
          'title': 'Launch Company Website v2',
          'desiredOutcome':
              'A polished, fast website is live and ready for customers.',
          'stepIds': ['20'],
          'currentNextActionId': '20',
          'targetCompletionDate': DateTime(2026, 6, 12).toIso8601String(),
          'createdAt': DateTime(2026, 5, 1).toIso8601String(),
          'tags': ['marketing', 'web'],
          'areaOfFocus': 'Business Development',
          'isCompleted': false,
          'isNextAction': true,
        },
      ],
      tasks: [
        {
          'id': '20',
          'title': 'Review homepage copy in staging',
          'contextName': '@Computer',
          'targetDate': DateTime(2026, 5, 11).toIso8601String(),
          'createdAt': DateTime(2026, 5, 8).toIso8601String(),
          'projectId': '10',
          'tags': ['website'],
          'energyLevel': 'medium',
          'estimatedMinutes': 30,
          'isCompleted': false,
          'isNextAction': true,
        },
        {
          'id': '21',
          'title': 'Call printer about event cards',
          'contextName': '@Calls',
          'createdAt': DateTime(2026, 5, 8).toIso8601String(),
          'tags': ['event'],
          'energyLevel': 'low',
          'estimatedMinutes': 10,
          'isCompleted': false,
        },
      ],
      reference: [
        {
          'id': '35',
          'title': 'Printer invoice PDF',
          'notes': 'Filed for event card vendor records.',
          'folder': 'Receipts',
          'tags': ['event', 'finance'],
          'createdAt': DateTime(2026, 5, 8).toIso8601String(),
        },
      ],
      someday: [
        {
          'id': '30',
          'title': 'Record a short Zoro onboarding video',
          'reconsiderDate': DateTime(2026, 5, 1).toIso8601String(),
          'createdAt': DateTime(2026, 4, 12).toIso8601String(),
          'tags': ['product'],
        },
        {
          'id': '31',
          'title': 'Explore handwritten notes import',
          'reconsiderDate': DateTime(2027, 1, 1).toIso8601String(),
          'createdAt': DateTime(2026, 4, 18).toIso8601String(),
          'tags': ['research'],
        },
      ],
      waitingFor: [
        {
          'id': '40',
          'title': 'Draft website launch quote',
          'person': 'Maya',
          'followUpDate': DateTime(2026, 5, 12).toIso8601String(),
          'createdAt': DateTime(2026, 5, 6).toIso8601String(),
          'notes': 'Need final pricing before publishing vendor page.',
          'isResolved': false,
        },
        {
          'id': '41',
          'title': 'Q2 report source numbers',
          'person': 'Finance Team',
          'followUpDate': DateTime(2026, 5, 15).toIso8601String(),
          'createdAt': DateTime(2026, 5, 7).toIso8601String(),
          'notes': 'Ask for revenue export and expense adjustments.',
          'isResolved': false,
        },
      ],
      history: const [],
    );
  }

  static List<Map<String, Object?>> _defaultContextRows() {
    return [
      {'id': 'context-anywhere', 'name': '@Anywhere', 'isDefault': true},
      {'id': 'context-computer', 'name': '@Computer', 'isDefault': true},
      {'id': 'context-home', 'name': '@Home', 'isDefault': true},
      {'id': 'context-errands', 'name': '@Errands', 'isDefault': true},
      {'id': 'context-calls', 'name': '@Calls', 'isDefault': true},
    ];
  }

  static Map<String, Object?> _defaultSettingsRow() {
    return {
      'voiceCaptureEnabled': true,
      'defaultContextName': '@Anywhere',
      'weeklyReviewWeekday': DateTime.sunday,
      'aiEnabled': _defaultAiEnabled(),
      'aiBaseUrl': _defaultAiBaseUrl(),
      'aiModel': 'gpt-5.2',
      'aiApiKey': null,
      'voiceLocaleId': null,
    };
  }

  static bool _defaultAiEnabled() {
    return !_isLocalWebOrigin(Uri.base);
  }

  static String _defaultAiBaseUrl() {
    final base = Uri.base;
    if (_isLocalWebOrigin(base)) {
      return 'http://127.0.0.1:8787';
    }
    if (base.scheme == 'http' || base.scheme == 'https') {
      return '${base.scheme}://${base.authority}';
    }
    return 'http://127.0.0.1:8787';
  }

  static bool _isLocalWebOrigin(Uri base) {
    final host = base.host.toLowerCase();
    return host.isEmpty ||
        host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1';
  }

  static Map<String, Object?> _defaultWeeklyReviewRow() {
    return {
      'reviewedStepIds': <String>[],
      'completedAt': null,
    };
  }
}

class _WebContextRepository implements ContextRepository {
  const _WebContextRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, void>> deleteContext(String id) async {
    final store = await _store;
    store.contexts.removeWhere((context) => context['id'] == id);
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, List<ZoroContext>>> getAllContexts() async {
    final store = await _store;
    final contexts = store.contexts.map(_contextFromJson).toList()
      ..sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });
    return right(contexts);
  }

  @override
  Future<Either<Failure, ZoroContext>> saveContext(ZoroContext context) async {
    final store = await _store;
    final id = context.id.isEmpty ? store.takeId() : context.id;
    final row = _contextToJson(context, id);
    final index = store.contexts.indexWhere((entry) => entry['id'] == id);
    if (index == -1) {
      store.contexts.add(row);
    } else {
      store.contexts[index] = row;
    }
    store.save();
    return right(_contextFromJson(row));
  }
}

class _WebSettingsRepository implements SettingsRepository {
  const _WebSettingsRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    final store = await _store;
    final settings = _settingsFromJson(store.settings);
    if (!WebPersistenceStore._isLocalWebOrigin(Uri.base) &&
        settings.aiBaseUrl == 'http://127.0.0.1:8787') {
      final migrated = settings.copyWith(
        aiEnabled: true,
        aiBaseUrl: WebPersistenceStore._defaultAiBaseUrl(),
        aiApiKey: null,
      );
      store.settings = _settingsToJson(migrated);
      store.save();
      return right(migrated);
    }
    return right(settings);
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    final store = await _store;
    store.settings = _settingsToJson(settings);
    store.save();
    return right(null);
  }
}

AppSettings _settingsFromJson(Map<String, Object?> json) {
  return AppSettings(
    voiceCaptureEnabled: json['voiceCaptureEnabled'] as bool? ?? true,
    defaultContextName: json['defaultContextName'] as String? ?? '@Anywhere',
    weeklyReviewWeekday: json['weeklyReviewWeekday'] as int? ?? DateTime.sunday,
    aiEnabled:
        json['aiEnabled'] as bool? ?? WebPersistenceStore._defaultAiEnabled(),
    aiBaseUrl:
        json['aiBaseUrl'] as String? ?? WebPersistenceStore._defaultAiBaseUrl(),
    aiModel: json['aiModel'] as String? ?? 'gpt-5.2',
    aiApiKey: json['aiApiKey'] as String?,
    voiceLocaleId: json['voiceLocaleId'] as String?,
  );
}

Map<String, Object?> _settingsToJson(AppSettings settings) {
  return {
    'voiceCaptureEnabled': settings.voiceCaptureEnabled,
    'defaultContextName': settings.defaultContextName,
    'weeklyReviewWeekday': settings.weeklyReviewWeekday,
    'aiEnabled': settings.aiEnabled,
    'aiBaseUrl': settings.aiBaseUrl,
    'aiModel': settings.aiModel,
    'aiApiKey': settings.aiApiKey,
    'voiceLocaleId': settings.voiceLocaleId,
  };
}

class _WebHorizonsRepository implements HorizonsRepository {
  const _WebHorizonsRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, HorizonsOfFocus>> getHorizons() async {
    final store = await _store;
    final horizons = store.horizons.map(_horizonFromJson).toList()
      ..sort((a, b) => a.level.index.compareTo(b.level.index));
    return right(HorizonsOfFocus(horizons: horizons));
  }

  @override
  Future<Either<Failure, void>> saveHorizons(HorizonsOfFocus horizons) async {
    final store = await _store;
    store.horizons =
        horizons.horizons.map(_horizonToJson).toList(growable: false);
    store.save();
    return right(null);
  }
}

Horizon _horizonFromJson(Map<String, Object?> json) {
  final level = HorizonLevel.values.firstWhere(
    (entry) => entry.name == json['levelName'],
    orElse: () => HorizonLevel.nextActions,
  );
  return Horizon(
    level: level,
    title: json['title'] as String? ?? _defaultHorizonTitle(level),
    description: json['description'] as String? ?? '',
    alignmentScore: (json['alignmentScore'] as num?)?.toDouble(),
  );
}

Map<String, Object?> _horizonToJson(Horizon horizon) {
  return {
    'levelName': horizon.level.name,
    'title': horizon.title,
    'description': horizon.description,
    'alignmentScore': horizon.alignmentScore,
  };
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

class _WebWeeklyReviewRepository implements WeeklyReviewRepository {
  const _WebWeeklyReviewRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, WeeklyReviewProgress>> getProgress() async {
    final store = await _store;
    return right(_weeklyReviewFromJson(store.weeklyReview));
  }

  @override
  Future<Either<Failure, void>> saveProgress(
    WeeklyReviewProgress progress,
  ) async {
    final store = await _store;
    store.weeklyReview = _weeklyReviewToJson(progress);
    store.save();
    return right(null);
  }
}

WeeklyReviewProgress _weeklyReviewFromJson(Map<String, Object?> json) {
  return WeeklyReviewProgress(
    reviewedStepIds: _strings(json['reviewedStepIds']).toSet(),
    completedAt: _dateOrNull(json['completedAt']),
  );
}

Map<String, Object?> _weeklyReviewToJson(WeeklyReviewProgress progress) {
  return {
    'reviewedStepIds': progress.reviewedStepIds.toList(growable: false),
    'completedAt': progress.completedAt?.toIso8601String(),
  };
}

class _WebInboxRepository implements InboxRepository {
  const _WebInboxRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, void>> clearAll() async {
    final store = await _store;
    store.inbox.clear();
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, InboxItem>> addInboxItem(InboxItem item) async {
    final store = await _store;
    final row = {
      'id': item.id.isEmpty ? store.takeId() : item.id,
      'title': item.title,
      'notes': item.notes,
      'capturedAt': item.capturedAt.toIso8601String(),
      'source': item.source.name,
    };
    store.inbox.add(row);
    store.save();
    return right(_inboxFromJson(row));
  }

  @override
  Future<Either<Failure, void>> deleteInboxItem(String id) async {
    final store = await _store;
    store.inbox.removeWhere((item) => item['id'] == id);
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, List<InboxItem>>> getAllInboxItems() async {
    final store = await _store;
    final items = store.inbox.map(_inboxFromJson).toList()
      ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return right(items);
  }

  @override
  Future<Either<Failure, InboxItem>> getInboxItemById(String id) async {
    final store = await _store;
    final item = store.inbox.where((entry) => entry['id'] == id).firstOrNull;
    if (item == null) {
      return left(const NotFoundFailure('Inbox item was not found.'));
    }

    return right(_inboxFromJson(item));
  }
}

class _WebTaskRepository implements TaskRepository {
  const _WebTaskRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, void>> clearAll() async {
    final store = await _store;
    store.tasks.clear();
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    final store = await _store;
    final row = _taskToJson(task, task.id.isEmpty ? store.takeId() : task.id);
    store.tasks.add(row);
    store.save();
    return right(_taskFromJson(row));
  }

  @override
  Future<Either<Failure, void>> completeTask(String taskId) async {
    final store = await _store;
    final row = store.tasks.where((task) => task['id'] == taskId).firstOrNull;
    if (row == null) {
      return left(const NotFoundFailure('Task was not found.'));
    }

    row['isCompleted'] = true;
    row['completedAt'] = DateTime.now().toIso8601String();
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, List<Task>>> getAllNextActions() async {
    final store = await _store;
    final tasks = store.tasks
        .map(_taskFromJson)
        .where((task) =>
            !task.isCompleted && task.isNextAction && !task.isCalendarEvent)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return right(tasks);
  }

  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    final store = await _store;
    final tasks = store.tasks.map(_taskFromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return right(tasks);
  }

  @override
  Future<Either<Failure, List<Task>>> getNextActionsByContext(
    String contextName,
  ) async {
    final result = await getAllNextActions();
    return result.map(
      (tasks) => tasks
          .where((task) => task.context.name == contextName)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksForProject(
    String projectId,
  ) async {
    final store = await _store;
    return right(
      store.tasks
          .map(_taskFromJson)
          .where((task) => task.projectId == projectId)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    final store = await _store;
    final row = store.tasks.where((task) => task['id'] == id).firstOrNull;
    if (row == null) {
      return left(const NotFoundFailure('Task was not found.'));
    }

    return right(_taskFromJson(row));
  }

  @override
  Future<Either<Failure, void>> updateTask(Task task) async {
    final store = await _store;
    store.tasks.removeWhere((entry) => entry['id'] == task.id);
    store.tasks.add(_taskToJson(task, task.id));
    store.save();
    return right(null);
  }
}

class _WebProjectRepository implements ProjectRepository {
  const _WebProjectRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, void>> clearAll() async {
    final store = await _store;
    store.projects.clear();
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, void>> completeProject(String projectId) async {
    final store = await _store;
    final row = store.projects
        .where((project) => project['id'] == projectId)
        .firstOrNull;
    if (row == null) {
      return left(const NotFoundFailure('Project was not found.'));
    }

    row['isCompleted'] = true;
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    final store = await _store;
    final row = _projectToJson(
      project,
      project.id.isEmpty ? store.takeId() : project.id,
    );
    store.projects.add(row);
    store.save();
    return right(_projectFromJson(row));
  }

  @override
  Future<Either<Failure, List<Project>>> getActiveProjects() async {
    final result = await getAllProjects();
    return result.map(
      (projects) => projects
          .where((project) => !project.isCompleted)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    final store = await _store;
    final projects = store.projects.map(_projectFromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return right(projects);
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    final store = await _store;
    final row =
        store.projects.where((project) => project['id'] == id).firstOrNull;
    if (row == null) {
      return left(const NotFoundFailure('Project was not found.'));
    }

    return right(_projectFromJson(row));
  }

  @override
  Future<Either<Failure, void>> moveProjectToSomeday(String projectId) {
    return completeProject(projectId);
  }

  @override
  Future<Either<Failure, void>> updateProject(Project project) async {
    final store = await _store;
    store.projects.removeWhere((entry) => entry['id'] == project.id);
    store.projects.add(_projectToJson(project, project.id));
    store.save();
    return right(null);
  }
}

class _WebReferenceRepository implements ReferenceRepository {
  const _WebReferenceRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, ReferenceItem>> addItem(ReferenceItem item) async {
    final store = await _store;
    final row = _referenceToJson(
      item,
      item.id.isEmpty ? store.takeId() : item.id,
    );
    store.reference.add(row);
    store.save();
    return right(_referenceFromJson(row));
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    final store = await _store;
    store.reference.clear();
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    final store = await _store;
    store.reference.removeWhere((item) => item['id'] == id);
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, List<ReferenceItem>>> getAllItems() async {
    final store = await _store;
    final items = store.reference.map(_referenceFromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return right(items);
  }
}

class _WebSomedayMaybeRepository implements SomedayMaybeRepository {
  const _WebSomedayMaybeRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, void>> clearAll() async {
    final store = await _store;
    store.someday.clear();
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, SomedayMaybeItem>> addItem(
    SomedayMaybeItem item,
  ) async {
    final store = await _store;
    final row = _somedayToJson(
      item,
      item.id.isEmpty ? store.takeId() : item.id,
    );
    store.someday.add(row);
    store.save();
    return right(_somedayFromJson(row));
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    final store = await _store;
    store.someday.removeWhere((item) => item['id'] == id);
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, List<SomedayMaybeItem>>> getAllItems() async {
    final store = await _store;
    final items = store.someday.map(_somedayFromJson).toList()
      ..sort((a, b) => a.reconsiderDate.compareTo(b.reconsiderDate));
    return right(items);
  }

  @override
  Future<Either<Failure, void>> snoozeItem(
    String id,
    DateTime reconsiderDate,
  ) async {
    final store = await _store;
    final row = store.someday.where((item) => item['id'] == id).firstOrNull;
    if (row == null) {
      return left(const NotFoundFailure('Someday/Maybe item was not found.'));
    }

    row['reconsiderDate'] = reconsiderDate.toIso8601String();
    store.save();
    return right(null);
  }
}

class _WebWaitingForRepository implements WaitingForRepository {
  const _WebWaitingForRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, void>> clearAll() async {
    final store = await _store;
    store.waitingFor.clear();
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, WaitingForItem>> addItem(
    WaitingForItem item,
  ) async {
    final store = await _store;
    final row = _waitingForToJson(
      item,
      item.id.isEmpty ? store.takeId() : item.id,
    );
    store.waitingFor.add(row);
    store.save();
    return right(_waitingForFromJson(row));
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    final store = await _store;
    store.waitingFor.removeWhere((item) => item['id'] == id);
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, List<WaitingForItem>>> getOpenItems() async {
    final store = await _store;
    final items = store.waitingFor
        .map(_waitingForFromJson)
        .where((item) => !item.isResolved)
        .toList()
      ..sort(_compareWaitingFor);
    return right(items);
  }

  @override
  Future<Either<Failure, List<WaitingForItem>>> getAllItems() async {
    final store = await _store;
    final items = store.waitingFor.map(_waitingForFromJson).toList()
      ..sort(_compareWaitingFor);
    return right(items);
  }

  @override
  Future<Either<Failure, void>> markResolved(String id) async {
    final store = await _store;
    final row = store.waitingFor.where((item) => item['id'] == id).firstOrNull;
    if (row == null) {
      return left(const NotFoundFailure('Waiting For item was not found.'));
    }

    row['isResolved'] = true;
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, void>> updateItem(WaitingForItem item) async {
    final store = await _store;
    final index =
        store.waitingFor.indexWhere((entry) => entry['id'] == item.id);
    if (index == -1) {
      return left(const NotFoundFailure('Waiting For item was not found.'));
    }

    store.waitingFor[index] = _waitingForToJson(item, item.id);
    store.save();
    return right(null);
  }
}

class _WebHistoryRepository implements HistoryRepository {
  const _WebHistoryRepository(this._store);

  final Future<WebPersistenceStore> _store;

  @override
  Future<Either<Failure, void>> clearAll() async {
    final store = await _store;
    store.history.clear();
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, List<HistoryEntry>>> getRecent({
    required DateTime since,
  }) async {
    final store = await _store;
    final entries = store.history
        .map(_historyFromJson)
        .where((entry) => !entry.timestamp.isBefore(since))
        .toList()
      ..sort((left, right) => right.timestamp.compareTo(left.timestamp));
    return right(entries);
  }

  @override
  Future<Either<Failure, void>> log(HistoryEntry entry) async {
    final store = await _store;
    store.history.add({
      'id': entry.id.isEmpty ? store.takeId() : entry.id,
      'timestamp': entry.timestamp.toIso8601String(),
      'action': entry.action.name,
      'entityType': entry.entityType,
      'entityId': entry.entityId,
      'description': entry.description,
      'details': entry.details,
    });
    store.save();
    return right(null);
  }

  @override
  Future<Either<Failure, void>> pruneBefore(DateTime cutoff) async {
    final store = await _store;
    store.history.removeWhere((row) {
      final rawTimestamp = row['timestamp'] ?? row['createdAt'];
      if (rawTimestamp is! String) {
        return false;
      }
      return DateTime.parse(rawTimestamp).isBefore(cutoff);
    });
    store.save();
    return right(null);
  }
}

HistoryEntry _historyFromJson(Map<String, Object?> json) {
  final rawTimestamp = json['timestamp'] ?? json['createdAt'];
  final rawAction = json['action'] as String? ?? '';
  return HistoryEntry(
    id: json['id'] as String,
    timestamp: DateTime.parse(rawTimestamp as String),
    action: HistoryAction.values.firstWhere(
      (action) => action.name == rawAction,
      orElse: () => rawAction == 'clear_all_data'
          ? HistoryAction.dataCleared
          : HistoryAction.inboxProcessed,
    ),
    entityType: json['entityType'] as String? ?? 'System',
    entityId: json['entityId'] as String?,
    description: json['description'] as String? ??
        (json['details'] as String? ?? 'History event recorded.'),
    details: json['details'] as String?,
  );
}

ZoroContext _contextFromJson(Map<String, Object?> json) {
  return ZoroContext(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    isDefault: json['isDefault'] as bool? ?? false,
  );
}

Map<String, Object?> _contextToJson(ZoroContext context, String id) {
  return {
    'id': id,
    'name': context.name,
    'description': context.description,
    'isDefault': context.isDefault,
  };
}

InboxItem _inboxFromJson(Map<String, Object?> json) {
  return InboxItem(
    id: json['id'] as String,
    title: json['title'] as String,
    notes: json['notes'] as String?,
    capturedAt: DateTime.parse(json['capturedAt'] as String),
    source: CaptureSource.values.firstWhere(
      (source) => source.name == json['source'],
      orElse: () => CaptureSource.manual,
    ),
  );
}

Task _taskFromJson(Map<String, Object?> json) {
  final contextName = json['contextName'] as String;
  return Task(
    id: json['id'] as String,
    title: json['title'] as String,
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
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedAt: _dateOrNull(json['completedAt']),
    projectId: json['projectId'] as String?,
    tags: _strings(json['tags']),
    energyLevel: EnergyLevel.values.firstWhere(
      (level) => level.name == json['energyLevel'],
      orElse: () => EnergyLevel.medium,
    ),
    estimatedMinutes: json['estimatedMinutes'] as int?,
    recurrence: Recurrence.fromRRule(json['recurrenceRule'] as String?),
  );
}

Map<String, Object?> _taskToJson(Task task, String id) {
  return {
    'id': id,
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

Project _projectFromJson(Map<String, Object?> json) {
  return Project(
    id: json['id'] as String,
    title: json['title'] as String,
    desiredOutcome: json['desiredOutcome'] as String,
    stepIds: _strings(json['stepIds']),
    projectSteps: _projectStepsFromJson(json['projectSteps']),
    currentNextActionId: json['currentNextActionId'] as String?,
    targetCompletionDate: _dateOrNull(json['targetCompletionDate']),
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    tags: _strings(json['tags']),
    areaOfFocus: json['areaOfFocus'] as String?,
    completedStepCount: json['completedStepCount'] as int? ?? 0,
  );
}

Map<String, Object?> _projectToJson(Project project, String id) {
  return {
    'id': id,
    'title': project.title,
    'desiredOutcome': project.desiredOutcome,
    'stepIds': project.stepIds,
    'projectSteps': project.projectSteps
        .map((step) => step.toJson())
        .toList(growable: false),
    'currentNextActionId': project.currentNextActionId,
    'targetCompletionDate': project.targetCompletionDate?.toIso8601String(),
    'isCompleted': project.isCompleted,
    'createdAt': project.createdAt.toIso8601String(),
    'tags': project.tags,
    'areaOfFocus': project.areaOfFocus,
    'completedStepCount': project.completedStepCount,
  };
}

List<ProjectStep> _projectStepsFromJson(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((entry) {
        if (entry is Map<String, Object?>) {
          return ProjectStep.fromJson(entry);
        }
        if (entry is Map) {
          return ProjectStep.fromJson(Map<String, Object?>.from(entry));
        }
        return null;
      })
      .nonNulls
      .toList(growable: false);
}

ReferenceItem _referenceFromJson(Map<String, Object?> json) {
  return ReferenceItem(
    id: json['id'] as String,
    title: json['title'] as String,
    notes: json['notes'] as String?,
    tags: _strings(json['tags']),
    folder: json['folder'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

Map<String, Object?> _referenceToJson(ReferenceItem item, String id) {
  return {
    'id': id,
    'title': item.title,
    'notes': item.notes,
    'tags': item.tags,
    'folder': item.folder,
    'createdAt': item.createdAt.toIso8601String(),
  };
}

SomedayMaybeItem _somedayFromJson(Map<String, Object?> json) {
  return SomedayMaybeItem(
    id: json['id'] as String,
    title: json['title'] as String,
    reconsiderDate: DateTime.parse(json['reconsiderDate'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    notes: json['notes'] as String?,
    tags: _strings(json['tags']),
  );
}

Map<String, Object?> _somedayToJson(SomedayMaybeItem item, String id) {
  return {
    'id': id,
    'title': item.title,
    'reconsiderDate': item.reconsiderDate.toIso8601String(),
    'createdAt': item.createdAt.toIso8601String(),
    'notes': item.notes,
    'tags': item.tags,
  };
}

WaitingForItem _waitingForFromJson(Map<String, Object?> json) {
  return WaitingForItem(
    id: json['id'] as String,
    title: json['title'] as String,
    person: json['person'] as String,
    projectId: json['projectId'] as String?,
    followUpDate: _dateOrNull(json['followUpDate']),
    createdAt: DateTime.parse(json['createdAt'] as String),
    notes: json['notes'] as String?,
    tags: _strings(json['tags']),
    isResolved: json['isResolved'] as bool? ?? false,
  );
}

Map<String, Object?> _waitingForToJson(WaitingForItem item, String id) {
  return {
    'id': id,
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

int _compareWaitingFor(WaitingForItem a, WaitingForItem b) {
  final aDate = a.followUpDate;
  final bDate = b.followUpDate;
  if (aDate != null && bDate != null) {
    return aDate.compareTo(bDate);
  }
  if (aDate != null) {
    return -1;
  }
  if (bDate != null) {
    return 1;
  }
  return b.createdAt.compareTo(a.createdAt);
}

DateTime? _dateOrNull(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}

List<String> _strings(Object? value) {
  return (value as List? ?? const []).cast<String>();
}
