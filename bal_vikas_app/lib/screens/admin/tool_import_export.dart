import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/admin_supabase_service.dart';

/// Export a tool as JSON and show it in a dialog for copying.
Future<void> showExportDialog(BuildContext context, int toolId, String toolName, Color toolColor) async {
  Map<String, dynamic>? json;
  String? error;

  try {
    json = await AdminSupabaseService.exportToolAsJson(toolId);
  } catch (e) {
    error = '$e';
  }

  if (!context.mounted) return;

  final jsonStr = json != null ? const JsonEncoder.withIndent('  ').convert(json) : '';

  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: toolColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.file_download_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Export — $toolName',
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),

            if (error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Export failed: $error', style: const TextStyle(color: Colors.red)),
              )
            else ...[
              // Stats bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    _statChip('Questions', '${(json!['questions'] as List).length}'),
                    const SizedBox(width: 12),
                    _statChip('Options', '${(json['tool_response_options'] as List).length}'),
                    const SizedBox(width: 12),
                    _statChip('Rules', '${(json['scoring_rules'] as List).length}'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: jsonStr));
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard'), backgroundColor: Color(0xFF4CAF50)),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),

              // JSON content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace', height: 1.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _statChip(String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Text('$label: $value', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
  );
}

/// Show an import dialog where the user pastes JSON.
/// Returns the new tool config ID on success, or null on cancel/failure.
Future<int?> showImportDialog(BuildContext context, Color themeColor) async {
  final ctrl = TextEditingController();
  String? importError;

  final result = await showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.file_upload_outlined, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Import Tool from JSON',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Body
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paste the exported tool JSON below:',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            hintText: '{"tool": {...}, "questions": [...], ...}',
                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                      if (importError != null) ...[
                        const SizedBox(height: 8),
                        Text(importError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final parsed = jsonDecode(ctrl.text) as Map<String, dynamic>;
                            if (!parsed.containsKey('tool') || !parsed.containsKey('questions')) {
                              setDialogState(() => importError = 'JSON must contain "tool" and "questions" keys');
                              return;
                            }
                            final id = await AdminSupabaseService.importToolFromJson(parsed);
                            if (ctx.mounted) Navigator.pop(ctx, id);
                          } on FormatException {
                            setDialogState(() => importError = 'Invalid JSON format');
                          } catch (e) {
                            setDialogState(() => importError = 'Import failed: $e');
                          }
                        },
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text('Import'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  ctrl.dispose();
  return result;
}
