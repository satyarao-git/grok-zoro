import 'project_step.dart';

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.desiredOutcome,
    required this.createdAt,
    this.stepIds = const [],
    this.projectSteps = const [],
    this.currentNextActionId,
    this.targetCompletionDate,
    this.isCompleted = false,
    this.tags = const [],
    this.areaOfFocus,
    this.completedStepCount = 0,
  });

  final String id;
  final String title;
  final String desiredOutcome;
  final List<String> stepIds;
  final List<ProjectStep> projectSteps;
  final String? currentNextActionId;
  final DateTime? targetCompletionDate;
  final bool isCompleted;
  final DateTime createdAt;
  final List<String> tags;
  final String? areaOfFocus;
  final int completedStepCount;

  double get progress {
    final totalSteps =
        projectSteps.isNotEmpty ? projectSteps.length : stepIds.length;
    if (totalSteps == 0) {
      return isCompleted ? 1 : 0;
    }

    return (completedStepCount / totalSteps).clamp(0, 1).toDouble();
  }

  Project copyWith({
    String? id,
    String? title,
    String? desiredOutcome,
    List<String>? stepIds,
    List<ProjectStep>? projectSteps,
    String? currentNextActionId,
    DateTime? targetCompletionDate,
    bool? isCompleted,
    DateTime? createdAt,
    List<String>? tags,
    String? areaOfFocus,
    int? completedStepCount,
    bool clearCurrentNextActionId = false,
    bool clearTargetCompletionDate = false,
    bool clearAreaOfFocus = false,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      desiredOutcome: desiredOutcome ?? this.desiredOutcome,
      stepIds: stepIds ?? this.stepIds,
      projectSteps: projectSteps ?? this.projectSteps,
      currentNextActionId: clearCurrentNextActionId
          ? null
          : currentNextActionId ?? this.currentNextActionId,
      targetCompletionDate: clearTargetCompletionDate
          ? null
          : targetCompletionDate ?? this.targetCompletionDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      areaOfFocus: clearAreaOfFocus ? null : areaOfFocus ?? this.areaOfFocus,
      completedStepCount: completedStepCount ?? this.completedStepCount,
    );
  }
}
