import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;

class BulkCaptureImportResult {
  const BulkCaptureImportResult({
    required this.titles,
    required this.skippedRows,
  });

  final List<String> titles;
  final int skippedRows;
}

BulkCaptureImportResult parseBulkCaptureSpreadsheet(Uint8List bytes) {
  final workbook = xls.Excel.decodeBytes(bytes);
  final sheet = workbook.tables.values
      .where((sheet) => sheet.rows.isNotEmpty)
      .firstOrNull;
  if (sheet == null) {
    throw const FormatException('The spreadsheet does not contain any rows.');
  }

  final rows = sheet.rows;
  final headers = <String, int>{};
  for (var index = 0; index < rows.first.length; index++) {
    final normalized = _normalizeHeader(_cellText(rows.first[index]));
    if (normalized.isNotEmpty) {
      headers[normalized] = index;
    }
  }

  final serialIndex = _findHeader(headers, const [
    'serialnumber',
    'serialno',
    'serial',
    'number',
    'no',
    '#',
  ]);
  final taskIndex = _findHeader(headers, const [
    'task',
    'tasks',
    'title',
    'capture',
    'captureditem',
    'item',
  ]);
  final categoryIndex = _findHeader(headers, const [
    'category',
    'categories',
    'tag',
    'tags',
  ]);

  if (taskIndex == null) {
    throw const FormatException(
      'The spreadsheet must include a Task column.',
    );
  }

  final titles = <String>[];
  var skippedRows = 0;
  for (final row in rows.skip(1)) {
    final task = _cellTextAt(row, taskIndex);
    if (task.isEmpty) {
      skippedRows++;
      continue;
    }

    titles.add(
      buildImportedCaptureTitle(
        serialNumber:
            serialIndex == null ? null : _cellTextAt(row, serialIndex),
        task: task,
        category:
            categoryIndex == null ? null : _cellTextAt(row, categoryIndex),
      ),
    );
  }

  if (titles.isEmpty) {
    throw const FormatException(
      'The spreadsheet did not contain any task rows to import.',
    );
  }

  return BulkCaptureImportResult(titles: titles, skippedRows: skippedRows);
}

String buildImportedCaptureTitle({
  String? serialNumber,
  required String task,
  String? category,
}) {
  return [
    serialNumber,
    task,
    category,
  ].where((value) => value != null && value.trim().isNotEmpty).join(' - ');
}

int? _findHeader(Map<String, int> headers, List<String> candidates) {
  for (final candidate in candidates) {
    final index = headers[_normalizeHeader(candidate)];
    if (index != null) {
      return index;
    }
  }
  return null;
}

String _cellTextAt(List<xls.Data?> row, int index) {
  if (index >= row.length) {
    return '';
  }
  return _cellText(row[index]);
}

String _cellText(xls.Data? cell) {
  final value = cell?.value;
  if (value == null) {
    return '';
  }
  return value.toString().trim();
}

String _normalizeHeader(String value) {
  final trimmed = value.trim().toLowerCase();
  if (trimmed == '#') {
    return '#';
  }
  return trimmed.replaceAll(RegExp(r'[^a-z0-9]'), '');
}
