import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/intervention_provider.dart';

/// Service to generate printable/sharable PDF activity sheets for parents.
class ActivityPdfService {
  ActivityPdfService._();

  static pw.Font? _notoSans;
  static pw.Font? _notoSansTelugu;
  static pw.Font? _notoSansBold;

  /// Load fonts once and cache them.
  static Future<void> _loadFonts() async {
    if (_notoSans != null) return;
    final sansData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    _notoSans = pw.Font.ttf(sansData);
    final teluguData = await rootBundle.load('assets/fonts/NotoSansTelugu-Regular.ttf');
    _notoSansTelugu = pw.Font.ttf(teluguData);
    // Use the same font for bold (variable font supports weight)
    _notoSansBold = _notoSans;
  }

  /// Base text style with Telugu fallback font support.
  static pw.TextStyle _baseStyle({double fontSize = 12, PdfColor? color, pw.FontWeight? fontWeight}) {
    return pw.TextStyle(
      font: _notoSans,
      fontBold: _notoSansBold,
      fontFallback: _notoSansTelugu != null ? [_notoSansTelugu!] : [],
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  /// Generate a child-specific activity sheet PDF.
  static Future<Uint8List> generateActivitySheet({
    required Map<String, dynamic> activity,
    Map<String, dynamic>? child,
  }) async {
    await _loadFonts();

    final doc = pw.Document();

    final titleEn = activity['activity_title'] as String? ?? '';
    final titleTe = activity['activity_title_te'] as String? ?? '';
    final descEn = activity['activity_description'] as String? ?? '';
    final descTe = activity['activity_description_te'] as String? ?? '';
    final materialsEn = activity['materials_needed'] as String? ?? '';
    final materialsTe = activity['materials_needed_te'] as String? ?? '';
    final domain = activity['domain'] as String? ?? '';
    final duration = activity['duration_minutes'] as int? ?? 15;
    final activityCode = activity['activity_code'] as String? ?? '';

    final guidance = getActivityGuidance(activityCode);
    final stepsEn = guidance?['steps'] ?? '';
    final stepsTe = guidance?['steps_te'] ?? '';
    final tipsEn = guidance?['tips'] ?? '';
    final tipsTe = guidance?['tips_te'] ?? '';

    final childName = child?['child_name'] as String? ?? 'General';
    final ageMonths = child?['age_months'] as int?;
    final ageText = ageMonths != null ? '$ageMonths months' : '';

    final domainEn = domainNames[domain]?['en'] ?? domain;
    final domainTe = domainNames[domain]?['te'] ?? '';

    final dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Try to load activity image
    pw.MemoryImage? activityImage;
    if (activityCode.isNotEmpty) {
      try {
        final imgData = await rootBundle.load('assets/images/activities/$activityCode.png');
        activityImage = pw.MemoryImage(imgData.buffer.asUint8List());
      } catch (_) {
        // Image not available — skip
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(childName, ageText, dateStr, domainEn, domainTe),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Activity image (if available)
          if (activityImage != null) ...[
            pw.Center(
              child: pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(activityImage, height: 150, fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(height: 12),
          ],

          // Activity title
          _sectionBox(
            color: PdfColors.blue50,
            borderColor: PdfColors.blue200,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(titleEn, style: _baseStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                if (titleTe.isNotEmpty)
                  pw.Text(titleTe, style: _baseStyle(fontSize: 16)),
                pw.SizedBox(height: 4),
                pw.Text('Duration / \u0C35\u0C4D\u0C2F\u0C35\u0C27\u0C3F: $duration minutes / \u0C28\u0C3F\u0C2E\u0C3F\u0C37\u0C3E\u0C32\u0C41',
                    style: _baseStyle(fontSize: 11, color: PdfColors.grey700)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Description
          _sectionTitle('Description / \u0C35\u0C3F\u0C35\u0C30\u0C23'),
          _sectionBox(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(descEn, style: _baseStyle(fontSize: 12)),
                if (descTe.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(descTe, style: _baseStyle(fontSize: 12)),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Steps
          if (stepsEn.isNotEmpty) ...[
            _sectionTitle('Step-by-Step Instructions / \u0C26\u0C36\u0C32 \u0C35\u0C3E\u0C30\u0C40 \u0C38\u0C42\u0C1A\u0C28\u0C32\u0C41'),
            _sectionBox(
              color: PdfColors.green50,
              borderColor: PdfColors.green200,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(stepsEn, style: _baseStyle(fontSize: 12)),
                  if (stepsTe.isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    pw.Divider(color: PdfColors.green200),
                    pw.SizedBox(height: 8),
                    pw.Text(stepsTe, style: _baseStyle(fontSize: 12)),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 12),
          ],

          // Materials
          if (materialsEn.isNotEmpty) ...[
            _sectionTitle('Materials Needed / \u0C05\u0C35\u0C38\u0C30\u0C2E\u0C48\u0C28 \u0C38\u0C3E\u0C2E\u0C3E\u0C17\u0C4D\u0C30\u0C3F'),
            _sectionBox(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(materialsEn, style: _baseStyle(fontSize: 12)),
                  if (materialsTe.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(materialsTe, style: _baseStyle(fontSize: 12)),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 12),
          ],

          // Tips
          if (tipsEn.isNotEmpty) ...[
            _sectionTitle('Tips / \u0C1A\u0C3F\u0C1F\u0C4D\u0C15\u0C3E\u0C32\u0C41'),
            _sectionBox(
              color: PdfColors.amber50,
              borderColor: PdfColors.amber200,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(tipsEn, style: _baseStyle(fontSize: 12)),
                  if (tipsTe.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text(tipsTe, style: _baseStyle(fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  /// Print the activity sheet directly.
  static Future<void> printActivitySheet({
    required Map<String, dynamic> activity,
    Map<String, dynamic>? child,
  }) async {
    try {
      final pdfBytes = await generateActivitySheet(activity: activity, child: child);
      await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
    } catch (e) {
      // ignore — prevents crash if PDF generation fails
    }
  }

  /// Share the activity sheet as a PDF file.
  static Future<void> shareActivitySheet({
    required Map<String, dynamic> activity,
    Map<String, dynamic>? child,
  }) async {
    try {
      final pdfBytes = await generateActivitySheet(activity: activity, child: child);
      final title = activity['activity_title'] as String? ?? 'Activity';
      await Printing.sharePdf(bytes: pdfBytes, filename: '${title.replaceAll(' ', '_')}_activity_sheet.pdf');
    } catch (e) {
      // ignore — prevents crash if PDF generation fails
    }
  }

  // ---- Internal helpers ----

  static pw.Widget _buildHeader(String childName, String ageText, String date, String domainEn, String domainTe) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue800, width: 2)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('BAL VIKAS - Activity Sheet',
                  style: _baseStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Text(date, style: _baseStyle(fontSize: 11, color: PdfColors.grey700)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Child / \u0C2A\u0C3F\u0C32\u0C4D\u0C32\u0C32 \u0C2A\u0C47\u0C30\u0C41: $childName${ageText.isNotEmpty ? '  |  Age: $ageText' : ''}',
                  style: _baseStyle(fontSize: 12)),
              pw.Text('Domain: $domainEn${domainTe.isNotEmpty ? ' / $domainTe' : ''}',
                  style: _baseStyle(fontSize: 11, color: PdfColors.grey700)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Bal Vikas ECD Platform',
              style: _baseStyle(fontSize: 9, color: PdfColors.grey600)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
              style: _baseStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(text, style: _baseStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _sectionBox({
    required pw.Widget child,
    PdfColor color = PdfColors.grey50,
    PdfColor borderColor = PdfColors.grey200,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color,
        border: pw.Border.all(color: borderColor),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: child,
    );
  }
}
