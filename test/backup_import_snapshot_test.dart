import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/domain/entities/project_step.dart';
import 'package:grok_zoro/domain/usecases/import_backup_use_case.dart';

void main() {
  test('BackupImportSnapshot parses Zoro backup JSON schema', () {
    final snapshot = BackupImportSnapshot.fromJson(
      jsonDecode(_backupJson) as Map<String, Object?>,
    );

    expect(snapshot.settings.defaultContextName, '@Computer');
    expect(snapshot.contexts.single.name, '@Computer');
    expect(snapshot.inbox.single.id, 'inbox-1');
    expect(snapshot.tasks.single.projectId, 'project-1');
    expect(snapshot.projects.single.currentNextActionId, 'task-1');
    expect(snapshot.projects.single.projectSteps.single,
        isA<NextActionProjectStep>());
    expect(snapshot.reference.single.folder, 'Docs');
    expect(snapshot.someday.single.tags, ['later']);
    expect(snapshot.waitingFor.single.isResolved, isFalse);
    expect(snapshot.horizons.horizons.single.title, 'Vision');
    expect(snapshot.weeklyReview.reviewedStepIds, {'calendar'});
  });

  test('BackupImportSnapshot rejects unknown schema versions', () {
    expect(
      () => BackupImportSnapshot.fromJson({'schemaVersion': 99}),
      throwsFormatException,
    );
  });
}

const _backupJson = '''
{
  "schemaVersion": 1,
  "settings": {
    "voiceCaptureEnabled": true,
    "defaultContextName": "@Computer",
    "weeklyReviewWeekday": 7,
    "aiEnabled": true,
    "aiBaseUrl": "https://example.test",
    "aiModel": "gpt-5.2",
    "aiApiKey": null,
    "voiceLocaleId": null
  },
  "contexts": [
    {
      "id": "computer",
      "name": "@Computer",
      "description": "Laptop work",
      "isDefault": true
    }
  ],
  "inbox": [
    {
      "id": "inbox-1",
      "title": "Imported capture",
      "notes": null,
      "capturedAt": "2026-05-17T10:00:00.000",
      "source": "import"
    }
  ],
  "tasks": [
    {
      "id": "task-1",
      "title": "Imported task",
      "description": "Description",
      "contextName": "@Computer",
      "dueDate": null,
      "targetDate": "2026-05-18T10:00:00.000",
      "endDateTime": null,
      "isNextAction": true,
      "isCalendarEvent": false,
      "isCompleted": false,
      "createdAt": "2026-05-17T10:00:00.000",
      "completedAt": null,
      "projectId": "project-1",
      "tags": ["import"],
      "energyLevel": "medium",
      "estimatedMinutes": 15,
      "recurrenceRule": null
    }
  ],
  "projects": [
    {
      "id": "project-1",
      "title": "Imported project",
      "desiredOutcome": "Restored project",
      "stepIds": ["task-1"],
      "projectSteps": [
        {
          "id": "step-1",
          "kind": "nextAction",
          "title": "Imported task",
          "createdEntityId": "task-1",
          "notes": null,
          "contextName": "@Computer",
          "targetDate": null,
          "allDay": false,
          "tags": []
        }
      ],
      "currentNextActionId": "task-1",
      "targetCompletionDate": null,
      "isCompleted": false,
      "createdAt": "2026-05-17T10:00:00.000",
      "tags": [],
      "areaOfFocus": null,
      "completedStepCount": 0
    }
  ],
  "reference": [
    {
      "id": "reference-1",
      "title": "Imported reference",
      "notes": "Keep this",
      "tags": [],
      "folder": "Docs",
      "createdAt": "2026-05-17T10:00:00.000"
    }
  ],
  "someday": [
    {
      "id": "someday-1",
      "title": "Imported maybe",
      "reconsiderDate": "2026-06-01T10:00:00.000",
      "createdAt": "2026-05-17T10:00:00.000",
      "notes": null,
      "tags": ["later"]
    }
  ],
  "waitingFor": [
    {
      "id": "waiting-1",
      "title": "Imported waiting",
      "person": "Maya",
      "projectId": "project-1",
      "followUpDate": "2026-05-20T10:00:00.000",
      "createdAt": "2026-05-17T10:00:00.000",
      "notes": null,
      "tags": [],
      "isResolved": false
    }
  ],
  "horizons": [
    {
      "level": "vision",
      "title": "Vision",
      "description": "Long term",
      "alignmentScore": 0.9
    }
  ],
  "weeklyReview": {
    "reviewedStepIds": ["calendar"],
    "completedAt": null
  }
}
''';
