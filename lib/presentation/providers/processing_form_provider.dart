import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/processing_choice.dart';

final currentProcessingChoiceProvider = StateProvider<ProcessingChoice>(
  (ref) => ProcessingChoice.nextAction,
);
