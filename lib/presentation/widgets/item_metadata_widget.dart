import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/inbox_item.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/someday_maybe_item.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/waiting_for_item.dart';

class ItemMetadataWidget extends StatelessWidget {
  const ItemMetadataWidget({
    required this.entity,
    super.key,
  });

  final Object entity;

  @override
  Widget build(BuildContext context) {
    final createdAt = _createdAtFor(entity);
    final id = _idFor(entity);
    if (createdAt == null) {
      return const SizedBox.shrink();
    }

    // Master Spec debugging enhancement: IDs stay available but tucked away.
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Item Metadata'),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _MetadataProperties(id: id, createdAt: createdAt),
          ),
        ],
      ),
    );
  }
}

Future<void> showItemMetadataBottomSheet(
  BuildContext context, {
  required Object entity,
  String? title,
}) async {
  final createdAt = _createdAtFor(entity);
  final id = _idFor(entity);
  if (createdAt == null) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'Quick Properties',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              _MetadataProperties(id: id, createdAt: createdAt),
            ],
          ),
        ),
      );
    },
  );
}

class _MetadataProperties extends StatelessWidget {
  const _MetadataProperties({
    required this.id,
    required this.createdAt,
  });

  final String? id;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CopyableMetadataRow(label: 'ID', value: id ?? '-'),
        const SizedBox(height: 8),
        _MetadataText(
          label: 'Created',
          value: '${DateFormat('MMMM d, y').format(createdAt)} • '
              '${DateFormat.jm().format(createdAt)}',
        ),
      ],
    );
  }
}

class _CopyableMetadataRow extends StatelessWidget {
  const _CopyableMetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: $value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        if (value != '-')
          IconButton(
            tooltip: 'Copy ID',
            visualDensity: VisualDensity.compact,
            onPressed: () => _copyValue(context, value),
            icon: const Icon(Icons.copy_outlined, size: 18),
          ),
      ],
    );
  }
}

class _MetadataText extends StatelessWidget {
  const _MetadataText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

Future<void> _copyValue(BuildContext context, String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('ID copied.')),
  );
}

String? _idFor(Object entity) {
  return switch (entity) {
    InboxItem(:final id) => id,
    Task(:final id) => id,
    Project(:final id) => id,
    SomedayMaybeItem(:final id) => id,
    WaitingForItem(:final id) => id,
    _ => null,
  };
}

DateTime? _createdAtFor(Object entity) {
  return switch (entity) {
    InboxItem(:final capturedAt) => capturedAt,
    Task(:final createdAt) => createdAt,
    Project(:final createdAt) => createdAt,
    SomedayMaybeItem(:final createdAt) => createdAt,
    WaitingForItem(:final createdAt) => createdAt,
    _ => null,
  };
}
