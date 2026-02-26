import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/school.dart';
import '../models/enrolment.dart';
import '../models/demand_plan.dart';
import '../models/priority_score.dart';

class ExcelExportService {
  /// Export school registry with enrolment, demands, and priority data
  static Future<String> exportSchoolData({
    required List<School> schools,
    List<EnrolmentRecord>? enrolment,
    List<DemandPlan>? demands,
    List<SchoolPriorityScore>? priorities,
  }) async {
    final excel = Excel.createExcel();

    // Sheet 1: School Registry
    final regSheet = excel['School Registry'];
    regSheet.appendRow([
      TextCellValue('S.No'),
      TextCellValue('UDISE Code'),
      TextCellValue('School Name'),
      TextCellValue('District'),
      TextCellValue('Mandal'),
      TextCellValue('Category'),
      TextCellValue('Management'),
      TextCellValue('Enrolment'),
      TextCellValue('Priority Level'),
      TextCellValue('Priority Score'),
      TextCellValue('Latitude'),
      TextCellValue('Longitude'),
    ]);

    for (var i = 0; i < schools.length; i++) {
      final s = schools[i];
      regSheet.appendRow([
        IntCellValue(i + 1),
        IntCellValue(s.udiseCode),
        TextCellValue(s.schoolName),
        TextCellValue(s.districtName ?? 'N/A'),
        TextCellValue(s.mandalName ?? 'N/A'),
        TextCellValue(s.categoryLabel),
        TextCellValue(s.managementLabel),
        IntCellValue(s.totalEnrolment ?? 0),
        TextCellValue(s.priorityLevel ?? 'N/A'),
        DoubleCellValue(s.priorityScore ?? 0),
        DoubleCellValue(s.latitude ?? 0),
        DoubleCellValue(s.longitude ?? 0),
      ]);
    }

    // Sheet 2: Demand Plans
    if (demands != null && demands.isNotEmpty) {
      final demandSheet = excel['Demand Plans'];
      demandSheet.appendRow([
        TextCellValue('School ID'),
        TextCellValue('Infrastructure Type'),
        TextCellValue('Physical Count'),
        TextCellValue('Financial Amount (Lakhs)'),
        TextCellValue('Validation Status'),
        TextCellValue('Validation Score'),
      ]);

      for (final d in demands) {
        demandSheet.appendRow([
          IntCellValue(d.schoolId),
          TextCellValue(d.infraTypeLabel),
          IntCellValue(d.physicalCount),
          DoubleCellValue(d.financialAmount),
          TextCellValue(d.validationStatus),
          DoubleCellValue(d.validationScore ?? 0),
        ]);
      }
    }

    // Sheet 3: Priority Scores
    if (priorities != null && priorities.isNotEmpty) {
      final prioSheet = excel['Priority Scores'];
      prioSheet.appendRow([
        TextCellValue('School ID'),
        TextCellValue('Composite Score'),
        TextCellValue('Priority Level'),
        TextCellValue('Enrolment Pressure'),
        TextCellValue('Infrastructure Gap'),
        TextCellValue('CWSN Need'),
        TextCellValue('Accessibility'),
      ]);

      for (final p in priorities) {
        prioSheet.appendRow([
          IntCellValue(p.schoolId),
          DoubleCellValue(p.compositeScore),
          TextCellValue(p.priorityLevel),
          DoubleCellValue(p.enrolmentPressureScore),
          DoubleCellValue(p.infraGapScore),
          DoubleCellValue(p.cwsnNeedScore),
          DoubleCellValue(p.accessibilityScore),
        ]);
      }
    }

    // Remove default Sheet1
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // Save to file
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${dir.path}/school_infra_report_$timestamp.xlsx';
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      File(filePath).writeAsBytesSync(fileBytes);
    }

    return filePath;
  }

  /// Share the exported file
  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)],
        text: 'School Infrastructure Report');
  }
}
