import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'context_schema.dart';
import 'app_settings_schema.dart';
import 'horizon_schema.dart';
import 'history_schema.dart';
import 'inbox_item_schema.dart';
import 'project_schema.dart';
import 'reference_schema.dart';
import 'someday_maybe_schema.dart';
import 'task_schema.dart';
import 'waiting_for_schema.dart';
import 'weekly_review_schema.dart';

class IsarDatabase {
  const IsarDatabase._();

  static Future<Isar> open() async {
    final existing = Isar.getInstance();
    if (existing != null) {
      return existing;
    }

    final directory = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        AppSettingsSchemaSchema,
        ContextSchemaSchema,
        HorizonSchemaSchema,
        HistorySchemaSchema,
        InboxItemSchemaSchema,
        ProjectSchemaSchema,
        ReferenceSchemaSchema,
        SomedayMaybeSchemaSchema,
        TaskSchemaSchema,
        WaitingForSchemaSchema,
        WeeklyReviewSchemaSchema,
      ],
      directory: directory.path,
    );

    await _seedStarterData(isar);
    return isar;
  }

  static Future<void> _seedStarterData(Isar isar) async {
    final hasInbox = await isar.inboxItemSchemas.count() > 0;
    final hasProjects = await isar.projectSchemas.count() > 0;
    final hasTasks = await isar.taskSchemas.count() > 0;
    final hasSomeday = await isar.somedayMaybeSchemas.count() > 0;
    final hasContexts = await isar.contextSchemas.count() > 0;
    final hasWaitingFor = await isar.waitingForSchemas.count() > 0;

    if (hasInbox &&
        hasProjects &&
        hasTasks &&
        hasSomeday &&
        hasContexts &&
        hasWaitingFor) {
      return;
    }

    await isar.writeTxn(() async {
      if (!hasContexts) {
        await isar.contextSchemas.putAll([
          _context('@Anywhere', isDefault: true),
          _context('@Computer', isDefault: true),
          _context('@Home', isDefault: true),
          _context('@Errands', isDefault: true),
          _context('@Calls', isDefault: true),
        ]);
      }

      if (!hasInbox) {
        await isar.inboxItemSchemas.putAll([
          _inboxItem(
            'Launch company website v2',
            DateTime(2026, 5, 8, 9),
          ),
          _inboxItem(
            'Prepare Q2 financial report',
            DateTime(2026, 5, 8, 10, 30),
            source: 'voice',
          ),
        ]);
      }

      if (!hasProjects && !hasTasks) {
        final project = ProjectSchema()
          ..title = 'Launch Company Website v2'
          ..desiredOutcome =
              'A polished, fast website is live and ready for customers.'
          ..targetCompletionDate = DateTime(2026, 6, 12)
          ..createdAt = DateTime(2026, 5, 1)
          ..tags = ['marketing', 'web']
          ..areaOfFocus = 'Business Development';

        final projectId = await isar.projectSchemas.put(project);
        final task = TaskSchema()
          ..title = 'Review homepage copy in staging'
          ..contextName = '@Computer'
          ..isNextAction = true
          ..targetDate = DateTime(2026, 5, 11)
          ..createdAt = DateTime(2026, 5, 8)
          ..projectId = projectId.toString()
          ..tags = ['website']
          ..estimatedMinutes = 30;

        final taskId = await isar.taskSchemas.put(task);
        project
          ..id = projectId
          ..stepIds = [taskId.toString()]
          ..currentNextActionId = taskId.toString();
        await isar.projectSchemas.put(project);
      }

      if (!hasTasks) {
        await isar.taskSchemas.put(
          TaskSchema()
            ..title = 'Call printer about event cards'
            ..contextName = '@Calls'
            ..isNextAction = true
            ..createdAt = DateTime(2026, 5, 8)
            ..tags = ['event']
            ..energyLevel = 'low'
            ..estimatedMinutes = 10,
        );
      }

      if (!hasSomeday) {
        await isar.somedayMaybeSchemas.putAll([
          _someday(
            'Record a short Zoro onboarding video',
            DateTime(2026, 5, 1),
            DateTime(2026, 4, 12),
            tags: ['product'],
          ),
          _someday(
            'Explore handwritten notes import',
            DateTime(2027, 1, 1),
            DateTime(2026, 4, 18),
            tags: ['research'],
          ),
        ]);
      }

      if (!hasWaitingFor) {
        await isar.waitingForSchemas.putAll([
          _waitingFor(
            'Draft website launch quote',
            'Maya',
            DateTime(2026, 5, 12),
            DateTime(2026, 5, 6),
            notes: 'Need final pricing before publishing vendor page.',
          ),
          _waitingFor(
            'Q2 report source numbers',
            'Finance Team',
            DateTime(2026, 5, 15),
            DateTime(2026, 5, 7),
            notes: 'Ask for revenue export and expense adjustments.',
          ),
        ]);
      }
    });
  }

  static ContextSchema _context(String name, {required bool isDefault}) {
    return ContextSchema()
      ..name = name
      ..isDefault = isDefault;
  }

  static InboxItemSchema _inboxItem(
    String title,
    DateTime capturedAt, {
    String source = 'manual',
  }) {
    return InboxItemSchema()
      ..title = title
      ..capturedAt = capturedAt
      ..source = source;
  }

  static SomedayMaybeSchema _someday(
    String title,
    DateTime reconsiderDate,
    DateTime createdAt, {
    List<String> tags = const [],
  }) {
    return SomedayMaybeSchema()
      ..title = title
      ..reconsiderDate = reconsiderDate
      ..createdAt = createdAt
      ..tags = tags;
  }

  static WaitingForSchema _waitingFor(
    String title,
    String person,
    DateTime followUpDate,
    DateTime createdAt, {
    String? notes,
  }) {
    return WaitingForSchema()
      ..title = title
      ..person = person
      ..followUpDate = followUpDate
      ..createdAt = createdAt
      ..notes = notes;
  }
}
