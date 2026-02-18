import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_config_provider.dart';
import '../../services/admin_supabase_service.dart';

/// A widget (not a full screen) that displays and edits response options for a
/// screening tool in a Material 3 `DataTable`.
///
/// Columns: Order, Label (En), Label (Te), Value, Color, Actions
///
/// Each row supports inline editing via an edit-button that opens a small dialog.
/// An "Add Option" button is displayed at the bottom.
class ResponseOptionEditor extends StatelessWidget {
  final int toolId;
  final List<Map<String, dynamic>> options;
  final WidgetRef ref;

  const ResponseOptionEditor({
    super.key,
    required this.toolId,
    required this.options,
    required this.ref,
  });

  static const _primary = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Data table ──────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStatePropertyAll(Colors.grey.shade50),
                headingTextStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
                dataTextStyle: const TextStyle(fontSize: 13),
                columnSpacing: 20,
                horizontalMargin: 16,
                columns: const [
                  DataColumn(label: Text('Order')),
                  DataColumn(label: Text('Label (En)')),
                  DataColumn(label: Text('Label (Te)')),
                  DataColumn(label: Text('Value'), numeric: true),
                  DataColumn(label: Text('Color')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: List.generate(options.length, (i) {
                  final opt = options[i];
                  final sortOrder = opt['sort_order'] as int? ?? i;
                  final labelEn = opt['label_en'] as String? ?? '';
                  final labelTe = opt['label_te'] as String? ?? '';
                  final value = opt['value_json'] ?? opt['value'] ?? '';
                  final colorHex = opt['color_hex'] as String? ?? '';
                  final optionId = opt['id'] as int?;

                  Color? parsedColor;
                  if (colorHex.isNotEmpty) {
                    try {
                      final cleaned = colorHex.replaceFirst('#', '');
                      parsedColor =
                          Color(int.parse('FF$cleaned', radix: 16));
                    } catch (_) {}
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(
                        '$sortOrder',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      )),
                      DataCell(Text(labelEn)),
                      DataCell(Text(labelTe)),
                      DataCell(Text(
                        '$value',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: parsedColor ?? Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: Colors.grey.shade400),
                              ),
                            ),
                            if (colorHex.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                colorHex,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionButton(
                              icon: Icons.edit_outlined,
                              color: _primary,
                              tooltip: 'Edit option',
                              onPressed: () => _showOptionDialog(
                                context,
                                existingOption: opt,
                              ),
                            ),
                            _ActionButton(
                              icon: Icons.delete_outline,
                              color: Colors.red.shade400,
                              tooltip: 'Delete option',
                              onPressed: optionId != null
                                  ? () => _deleteOption(context, optionId)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),

        // ── Add button ──────────────────────────────────────────────────
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _showOptionDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Option'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: BorderSide(color: _primary.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  // ── Delete option ────────────────────────────────────────────────────

  Future<void> _deleteOption(BuildContext context, int optionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Response Option'),
        content: const Text(
          'Are you sure you want to remove this response option?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminSupabaseService.deleteResponseOption(optionId);
        ref.invalidate(adminToolDetailProvider(toolId));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Delete failed: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ── Option edit dialog ───────────────────────────────────────────────

  Future<void> _showOptionDialog(
    BuildContext context, {
    Map<String, dynamic>? existingOption,
  }) async {
    final isEdit = existingOption != null;

    final labelEnCtrl = TextEditingController(
        text: existingOption?['label_en'] as String? ?? '');
    final labelTeCtrl = TextEditingController(
        text: existingOption?['label_te'] as String? ?? '');
    final valueCtrl = TextEditingController(
        text: '${existingOption?['value_json'] ?? existingOption?['value'] ?? ''}');
    final colorCtrl = TextEditingController(
        text: existingOption?['color_hex'] as String? ?? '');
    final orderCtrl = TextEditingController(
        text: '${existingOption?['sort_order'] ?? options.length}');

    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                Icon(
                  isEdit ? Icons.edit : Icons.add_circle_outline,
                  color: _primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  isEdit ? 'Edit Response Option' : 'Add Response Option',
                  style: const TextStyle(fontSize: 17),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: orderCtrl,
                          decoration: _inputDecor('Order'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: valueCtrl,
                          decoration: _inputDecor('Value'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: labelEnCtrl,
                    decoration: _inputDecor('Label (English)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: labelTeCtrl,
                    decoration: _inputDecor('Label (Telugu)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: colorCtrl,
                          decoration: _inputDecor('Color Hex',
                              hint: '#4CAF50'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Builder(builder: (_) {
                        Color? preview;
                        if (colorCtrl.text.isNotEmpty) {
                          try {
                            final c = colorCtrl.text.replaceFirst('#', '');
                            preview = Color(int.parse('FF$c', radix: 16));
                          } catch (_) {}
                        }
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: preview ?? Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: saving
                    ? null
                    : () async {
                        setDialogState(() => saving = true);
                        final data = {
                          'label_en': labelEnCtrl.text.trim(),
                          'label_te': labelTeCtrl.text.trim(),
                          'value_json': valueCtrl.text.trim(),
                          'color_hex': colorCtrl.text.trim(),
                          'sort_order':
                              int.tryParse(orderCtrl.text) ?? 0,
                        };
                        try {
                          if (isEdit) {
                            final optId =
                                existingOption['id'] as int;
                            await AdminSupabaseService
                                .updateResponseOption(optId, data);
                          } else {
                            await AdminSupabaseService
                                .addResponseOption({...data, 'tool_config_id': toolId});
                          }
                          ref.invalidate(
                              adminToolDetailProvider(toolId));
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text('Save failed: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (ctx.mounted) {
                            setDialogState(() => saving = false);
                          }
                        }
                      },
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(saving ? 'Saving...' : 'Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );

    labelEnCtrl.dispose();
    labelTeCtrl.dispose();
    valueCtrl.dispose();
    colorCtrl.dispose();
    orderCtrl.dispose();
  }

  InputDecoration _inputDecor(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Small icon-only action button
// ═══════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? color : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
