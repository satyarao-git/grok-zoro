import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/application/imports/bulk_capture_import.dart';

void main() {
  test('buildImportedCaptureTitle concatenates available row information', () {
    expect(
      buildImportedCaptureTitle(
        serialNumber: '12',
        task: 'Move tasks from old app',
        category: 'Migration',
      ),
      '12 - Move tasks from old app - Migration',
    );

    expect(
      buildImportedCaptureTitle(
        serialNumber: '13',
        task: 'Empty inbox',
      ),
      '13 - Empty inbox',
    );
  });

  test('parseBulkCaptureSpreadsheet imports task rows and skips blanks', () {
    final result = parseBulkCaptureSpreadsheet(
      _workbookBytes([
        ['Serial Number', 'Task', 'Category'],
        ['1', 'Gather receipts', 'Finance'],
        ['2', '', ''],
        ['3', 'Schedule planning call', 'Work'],
      ]),
    );

    expect(result.titles, [
      '1 - Gather receipts - Finance',
      '3 - Schedule planning call - Work',
    ]);
    expect(result.skippedRows, 1);
  });

  test('parseBulkCaptureSpreadsheet accepts optional category', () {
    final result = parseBulkCaptureSpreadsheet(
      _workbookBytes([
        ['#', 'task'],
        ['1', 'Capture loose notes'],
      ]),
    );

    expect(result.titles, ['1 - Capture loose notes']);
  });

  test('parseBulkCaptureSpreadsheet requires a task column', () {
    expect(
      () => parseBulkCaptureSpreadsheet(
        _workbookBytes([
          ['Serial Number', 'Category'],
          ['1', 'Work'],
        ]),
      ),
      throwsFormatException,
    );
  });
}

Uint8List _workbookBytes(List<List<String>> rows) {
  final workbook = xls.Excel.createExcel();
  final sheet = workbook['Sheet1'];
  for (final row in rows) {
    sheet.appendRow([
      for (final value in row) xls.TextCellValue(value),
    ]);
  }
  return Uint8List.fromList(workbook.encode()!);
}
