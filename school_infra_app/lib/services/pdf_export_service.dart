import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/school.dart';
import '../models/enrolment.dart';
import '../models/demand_plan.dart';

class PdfExportService {
  /// Generate a school report card PDF
  static Future<String> generateSchoolReport({
    required School school,
    List<EnrolmentRecord>? enrolment,
    List<DemandPlan>? demands,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('School Infrastructure Report',
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(school.schoolName,
                    style: const pw.TextStyle(fontSize: 16)),
                pw.Divider(),
              ],
            ),
          ),

          // School Info
          pw.Header(level: 1, text: 'School Information'),
          _infoTable([
            ['UDISE Code', school.udiseCode.toString()],
            ['District', school.districtName ?? 'N/A'],
            ['Mandal', school.mandalName ?? 'N/A'],
            ['Category', school.categoryLabel],
            ['Management', school.managementLabel],
            ['Total Enrolment', '${school.totalEnrolment ?? "N/A"} students'],
            ['Priority Level', school.priorityLevel ?? 'N/A'],
            [
              'Priority Score',
              school.priorityScore?.toStringAsFixed(1) ?? 'N/A'
            ],
            if (school.hasLocation)
              [
                'Coordinates',
                '${school.latitude!.toStringAsFixed(4)}, ${school.longitude!.toStringAsFixed(4)}'
              ],
          ]),

          pw.SizedBox(height: 20),

          // Enrolment Trend
          if (enrolment != null && enrolment.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Enrolment History'),
            _enrolmentTable(enrolment),
            pw.SizedBox(height: 20),
          ],

          // Demand Plans
          if (demands != null && demands.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Infrastructure Demand Plans'),
            _demandTable(demands),
            pw.SizedBox(height: 20),
          ],

          // Footer
          pw.SizedBox(height: 30),
          pw.Text(
            'Generated on: ${DateTime.now().toString().split('.')[0]}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.Text(
            'AI-powered School Infrastructure Planning System | Dept. of School Education, AP',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath =
        '${dir.path}/school_report_${school.udiseCode}_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  static pw.Widget _infoTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(2.5),
      },
      children: rows
          .map((r) => pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(r[0],
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(r[1]),
                ),
              ]))
          .toList(),
    );
  }

  static pw.Widget _enrolmentTable(List<EnrolmentRecord> records) {
    // Group by year
    final byYear = <String, Map<String, int>>{};
    for (final r in records) {
      byYear.putIfAbsent(
          r.academicYear, () => {'boys': 0, 'girls': 0, 'total': 0});
      byYear[r.academicYear]!['boys'] =
          byYear[r.academicYear]!['boys']! + r.boys;
      byYear[r.academicYear]!['girls'] =
          byYear[r.academicYear]!['girls']! + r.girls;
      byYear[r.academicYear]!['total'] =
          byYear[r.academicYear]!['total']! + r.total;
    }

    final years = byYear.keys.toList()..sort();
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: ['Year', 'Boys', 'Girls', 'Total']
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(h,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ))
              .toList(),
        ),
        ...years.map((yr) => pw.TableRow(children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(6), child: pw.Text(yr)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('${byYear[yr]!["boys"]}')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('${byYear[yr]!["girls"]}')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('${byYear[yr]!["total"]}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            ])),
      ],
    );
  }

  static pw.Widget _demandTable(List<DemandPlan> demands) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: ['Infra Type', 'Units', 'Amount (L)', 'Status']
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(h,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ))
              .toList(),
        ),
        ...demands.map((d) => pw.TableRow(children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(d.infraTypeLabel)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('${d.physicalCount}')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(d.financialAmount.toStringAsFixed(2))),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(d.validationStatus)),
            ])),
      ],
    );
  }

  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)],
        text: 'School Infrastructure Report');
  }
}
