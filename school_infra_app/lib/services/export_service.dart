import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/school.dart';
import '../models/demand_plan.dart';
import '../models/enrolment.dart';
import '../config/api_config.dart';

class ExportService {
  /// Descriptive status label showing AI vs Officer stage
  static String _demandStatusLabel(DemandPlan d) {
    final stage = d.pipelineStage;
    switch (stage) {
      case 'PENDING':
        return 'Pending (AI Review)';
      case 'AI_REVIEWED':
        final aiVerdict = AppConstants.validationLabel(d.validationStatus);
        return 'AI $aiVerdict (Officer Pending)';
      case 'FINAL_APPROVED':
        return 'Approved (Officer)';
      case 'FLAGGED':
        return d.isOfficerPending ? 'Flagged (AI)' : 'Flagged (Officer)';
      case 'REJECTED':
        return d.isOfficerPending ? 'Rejected (AI)' : 'Rejected (Officer)';
      default:
        return stage;
    }
  }

  /// Export school list with demands to Excel
  static Future<void> exportSchoolsExcel({
    required List<School> schools,
    required List<DemandPlan> demands,
    Rect? sharePositionOrigin,
  }) async {
    final excel = Excel.createExcel();

    // Sheet 1: Schools
    final schoolSheet = excel['Schools'];
    schoolSheet.appendRow([
      TextCellValue('UDISE Code'),
      TextCellValue('School Name'),
      TextCellValue('District'),
      TextCellValue('Mandal'),
      TextCellValue('Category'),
      TextCellValue('Management'),
      TextCellValue('Total Enrolment'),
      TextCellValue('Priority Level'),
      TextCellValue('Priority Score'),
    ]);
    for (final s in schools) {
      schoolSheet.appendRow([
        IntCellValue(s.udiseCode),
        TextCellValue(s.schoolName),
        TextCellValue(s.districtName ?? ''),
        TextCellValue(s.mandalName ?? ''),
        TextCellValue(s.categoryLabel),
        TextCellValue(s.managementLabel),
        IntCellValue(s.totalEnrolment ?? 0),
        TextCellValue(s.priorityLevel ?? 'N/A'),
        DoubleCellValue(s.priorityScore ?? 0),
      ]);
    }

    // Sheet 2: Demand Plans
    final demandSheet = excel['Demand Plans'];
    demandSheet.appendRow([
      TextCellValue('School Name'),
      TextCellValue('District'),
      TextCellValue('Mandal'),
      TextCellValue('Infra Type'),
      TextCellValue('Physical Count'),
      TextCellValue('Financial (Lakhs)'),
      TextCellValue('Validation Status'),
      TextCellValue('Validation Score'),
    ]);
    for (final d in demands) {
      demandSheet.appendRow([
        TextCellValue(d.schoolName ?? 'School #${d.schoolId}'),
        TextCellValue(d.districtName ?? ''),
        TextCellValue(d.mandalName ?? ''),
        TextCellValue(d.infraTypeLabel),
        IntCellValue(d.physicalCount),
        DoubleCellValue(d.financialAmount),
        TextCellValue(_demandStatusLabel(d)),
        DoubleCellValue(d.validationScore ?? 0),
      ]);
    }

    // Remove default sheet
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to generate Excel file');
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/school_infra_report_$timestamp.xlsx');
    await file.writeAsBytes(bytes);

    if (!await file.exists()) {
      throw Exception('File was not saved');
    }

    final result = await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
      subject: 'School Infrastructure Report',
      sharePositionOrigin: sharePositionOrigin,
    );

    // Clean up temp file after sharing (ignore errors)
    try {
      if (result.status != ShareResultStatus.dismissed) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Export single school report as PDF
  static Future<void> exportSchoolPdf({
    required School school,
    required List<EnrolmentRecord> enrolment,
    required List<DemandPlan> demands,
    Rect? sharePositionOrigin,
  }) async {
    final pdf = pw.Document();
    final trend = EnrolmentTrend.compute(school.id, enrolment);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('School Infrastructure Report',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Vidya Nirmaan — AI-Powered School Infrastructure System',
                    style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // School Info
          pw.Header(level: 1, text: 'School Information'),
          _pdfInfoRow('Name', school.schoolName),
          _pdfInfoRow('UDISE Code', '${school.udiseCode}'),
          _pdfInfoRow('District', school.districtName ?? 'N/A'),
          _pdfInfoRow('Mandal', school.mandalName ?? 'N/A'),
          _pdfInfoRow('Category', school.categoryLabel),
          _pdfInfoRow('Management', school.managementLabel),
          _pdfInfoRow(
              'Total Enrolment', '${school.totalEnrolment ?? "N/A"}'),
          _pdfInfoRow('Priority Level', school.priorityLevel ?? 'N/A'),
          _pdfInfoRow(
              'Priority Score',
              school.priorityScore?.toStringAsFixed(1) ?? 'N/A'),
          pw.SizedBox(height: 16),

          // Enrolment Trend
          pw.Header(level: 1, text: 'Enrolment Trend'),
          pw.Text(
              'Trend: ${trend.trend} (${trend.growthRate > 0 ? "+" : ""}${trend.growthRate.toStringAsFixed(1)}%)'),
          pw.SizedBox(height: 8),
          if (trend.yearWise.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: ['Year', 'Boys', 'Girls', 'Total'],
              data: trend.yearWise
                  .map((y) => [
                        y.academicYear,
                        '${y.totalBoys}',
                        '${y.totalGirls}',
                        '${y.totalStudents}',
                      ])
                  .toList(),
            ),
          pw.SizedBox(height: 16),

          // Demand Plans
          pw.Header(level: 1, text: 'Infrastructure Demand Plans'),
          if (demands.isEmpty)
            pw.Text('No demand plans for this school.')
          else
            pw.TableHelper.fromTextArray(
              headers: [
                'Infra Type',
                'Units',
                'Cost (₹L)',
                'Status',
                'Score'
              ],
              data: demands
                  .map((d) => [
                        d.infraTypeLabel,
                        '${d.physicalCount}',
                        d.financialAmount.toStringAsFixed(2),
                        _demandStatusLabel(d),
                        d.validationScore?.toStringAsFixed(0) ?? '-',
                      ])
                  .toList(),
            ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file =
        File('${dir.path}/${school.schoolName.replaceAll(' ', '_')}_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '${school.schoolName} - Infrastructure Report',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  static pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text('$label:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
