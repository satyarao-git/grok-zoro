enum RecurrenceFrequency { none, daily, weekly, biweekly, monthly, yearly }

class Recurrence {
  const Recurrence({
    this.frequency = RecurrenceFrequency.none,
    this.interval = 1,
    this.weekdays = const [],
    this.count,
    this.until,
  });

  final RecurrenceFrequency frequency;
  final int interval;
  final List<int> weekdays;
  final int? count;
  final DateTime? until;

  bool get isRecurring => frequency != RecurrenceFrequency.none;

  Recurrence copyWith({
    RecurrenceFrequency? frequency,
    int? interval,
    List<int>? weekdays,
    int? count,
    DateTime? until,
    bool clearCount = false,
    bool clearUntil = false,
  }) {
    return Recurrence(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      weekdays: weekdays ?? this.weekdays,
      count: clearCount ? null : count ?? this.count,
      until: clearUntil ? null : until ?? this.until,
    );
  }

  String toRRule() {
    if (frequency == RecurrenceFrequency.none) {
      return '';
    }

    final parts = <String>[
      'FREQ=${_rruleFrequency(frequency)}',
      'INTERVAL=${frequency == RecurrenceFrequency.biweekly ? 2 : interval}',
      if ((frequency == RecurrenceFrequency.weekly ||
              frequency == RecurrenceFrequency.biweekly) &&
          weekdays.isNotEmpty)
        'BYDAY=${weekdays.map(_weekdayCode).join(',')}',
      if (count != null) 'COUNT=$count',
      if (until != null) 'UNTIL=${_formatUntil(until!)}',
    ];
    return parts.join(';');
  }

  static Recurrence? fromRRule(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    final parts = <String, String>{};
    for (final segment in text.split(';')) {
      final pair = segment.split('=');
      if (pair.length == 2) {
        parts[pair.first.toUpperCase()] = pair.last;
      }
    }

    final rawFrequency = parts['FREQ']?.toUpperCase();
    final rawInterval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;
    final frequency = switch (rawFrequency) {
      'DAILY' => RecurrenceFrequency.daily,
      'WEEKLY' when rawInterval == 2 => RecurrenceFrequency.biweekly,
      'WEEKLY' => RecurrenceFrequency.weekly,
      'MONTHLY' => RecurrenceFrequency.monthly,
      'YEARLY' => RecurrenceFrequency.yearly,
      _ => RecurrenceFrequency.none,
    };

    return Recurrence(
      frequency: frequency,
      interval: rawInterval < 1 ? 1 : rawInterval,
      weekdays: (parts['BYDAY'] ?? '')
          .split(',')
          .map(_weekdayFromCode)
          .whereType<int>()
          .toList(growable: false),
      count: int.tryParse(parts['COUNT'] ?? ''),
      until: _parseUntil(parts['UNTIL']),
    );
  }

  static String _rruleFrequency(RecurrenceFrequency frequency) {
    return switch (frequency) {
      RecurrenceFrequency.none => 'DAILY',
      RecurrenceFrequency.daily => 'DAILY',
      RecurrenceFrequency.weekly => 'WEEKLY',
      RecurrenceFrequency.biweekly => 'WEEKLY',
      RecurrenceFrequency.monthly => 'MONTHLY',
      RecurrenceFrequency.yearly => 'YEARLY',
    };
  }

  static String _weekdayCode(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'MO',
      DateTime.tuesday => 'TU',
      DateTime.wednesday => 'WE',
      DateTime.thursday => 'TH',
      DateTime.friday => 'FR',
      DateTime.saturday => 'SA',
      DateTime.sunday => 'SU',
      _ => 'MO',
    };
  }

  static int? _weekdayFromCode(String value) {
    return switch (value.toUpperCase()) {
      'MO' => DateTime.monday,
      'TU' => DateTime.tuesday,
      'WE' => DateTime.wednesday,
      'TH' => DateTime.thursday,
      'FR' => DateTime.friday,
      'SA' => DateTime.saturday,
      'SU' => DateTime.sunday,
      _ => null,
    };
  }

  static String _formatUntil(DateTime value) {
    final utc = value.toUtc();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${utc.year}${two(utc.month)}${two(utc.day)}T'
        '${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
  }

  static DateTime? _parseUntil(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length == 8) {
      return DateTime.tryParse(value);
    }
    final match = RegExp(r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z$')
        .firstMatch(value);
    if (match == null) {
      return DateTime.tryParse(value);
    }
    final parts = [
      for (var index = 1; index <= 6; index++) int.parse(match.group(index)!),
    ];
    return DateTime.utc(
      parts[0],
      parts[1],
      parts[2],
      parts[3],
      parts[4],
      parts[5],
    ).toLocal();
  }

  @override
  bool operator ==(Object other) {
    return other is Recurrence &&
        other.frequency == frequency &&
        other.interval == interval &&
        _listEquals(other.weekdays, weekdays) &&
        other.count == count &&
        other.until == until;
  }

  @override
  int get hashCode => Object.hash(
        frequency,
        interval,
        Object.hashAll(weekdays),
        count,
        until,
      );
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}
