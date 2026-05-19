import 'package:isar/isar.dart';

import '../../domain/repositories/inbox_repository.dart';
import '../../domain/repositories/context_repository.dart';
import '../../domain/repositories/horizons_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/reference_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/someday_maybe_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/waiting_for_repository.dart';
import '../../domain/repositories/weekly_review_repository.dart';
import '../isar/history_isar_repository.dart';
import '../isar/isar_database.dart';
import '../repositories/context_isar_repository.dart';
import '../repositories/horizons_isar_repository.dart';
import '../repositories/inbox_isar_repository.dart';
import '../repositories/project_isar_repository.dart';
import '../repositories/reference_isar_repository.dart';
import '../repositories/settings_isar_repository.dart';
import '../repositories/someday_maybe_isar_repository.dart';
import '../repositories/task_isar_repository.dart';
import '../repositories/waiting_for_isar_repository.dart';
import '../repositories/weekly_review_isar_repository.dart';

Future<Object> openPersistenceStore() {
  return IsarDatabase.open();
}

InboxRepository createInboxRepository(Future<Object> store) {
  return InboxIsarRepository(store.then((value) => value as Isar));
}

ContextRepository createContextRepository(Future<Object> store) {
  return ContextIsarRepository(store.then((value) => value as Isar));
}

TaskRepository createTaskRepository(Future<Object> store) {
  return TaskIsarRepository(store.then((value) => value as Isar));
}

ProjectRepository createProjectRepository(Future<Object> store) {
  return ProjectIsarRepository(store.then((value) => value as Isar));
}

ReferenceRepository createReferenceRepository(Future<Object> store) {
  return ReferenceIsarRepository(store.then((value) => value as Isar));
}

SomedayMaybeRepository createSomedayMaybeRepository(Future<Object> store) {
  return SomedayMaybeIsarRepository(store.then((value) => value as Isar));
}

WaitingForRepository createWaitingForRepository(Future<Object> store) {
  return WaitingForIsarRepository(store.then((value) => value as Isar));
}

HistoryRepository createHistoryRepository(Future<Object> store) {
  return HistoryIsarRepository(store.then((value) => value as Isar));
}

SettingsRepository createSettingsRepository(Future<Object> store) {
  return SettingsIsarRepository(store.then((value) => value as Isar));
}

HorizonsRepository createHorizonsRepository(Future<Object> store) {
  return HorizonsIsarRepository(store.then((value) => value as Isar));
}

WeeklyReviewRepository createWeeklyReviewRepository(Future<Object> store) {
  return WeeklyReviewIsarRepository(store.then((value) => value as Isar));
}
