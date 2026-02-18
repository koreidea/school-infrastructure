import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../services/supabase_service.dart';
import '../../utils/telugu_transliterator.dart';
import 'scoped_awc_dashboard_screen.dart';
import 'scoped_dashboard_screen.dart';

/// Reusable screen that lists hierarchy units (districts, projects, sectors, or AWCs)
/// with drill-down navigation. Works in two modes:
/// - Sub-unit mode: receives pre-loaded [subUnits] list (districts/projects/sectors from stats)
/// - AWC mode: fetches AWCs from Supabase based on [scopeLevel] and [scopeId]
class ScopedUnitListScreen extends StatefulWidget {
  final String unitType;   // 'district', 'project', 'sector', 'awc'
  final String scopeLevel; // 'state', 'district', 'project', 'sector'
  final int scopeId;
  final String title;
  final List<dynamic>? subUnits; // pre-loaded sub-units; null → fetch from Supabase

  const ScopedUnitListScreen({
    super.key,
    required this.unitType,
    required this.scopeLevel,
    required this.scopeId,
    required this.title,
    this.subUnits,
  });

  @override
  State<ScopedUnitListScreen> createState() => _ScopedUnitListScreenState();
}

class _ScopedUnitListScreenState extends State<ScopedUnitListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _units = [];

  @override
  void initState() {
    super.initState();
    if (widget.subUnits != null) {
      _units = widget.subUnits!.map((u) => Map<String, dynamic>.from(u as Map)).toList();
      _isLoading = false;
    } else {
      _fetchUnits();
    }
  }

  Future<void> _fetchUnits() async {
    try {
      List<Map<String, dynamic>> fetched;
      switch (widget.scopeLevel) {
        case 'state':
          fetched = await SupabaseService.getAwcsForState(widget.scopeId);
        case 'district':
          fetched = await SupabaseService.getAwcsForDistrict(widget.scopeId);
        case 'project':
          fetched = await SupabaseService.getAwcsForProject(widget.scopeId);
        case 'sector':
          fetched = await SupabaseService.getAwcsForSector(widget.scopeId);
        default:
          fetched = [];
      }
      if (mounted) setState(() { _units = fetched; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = Localizations.localeOf(context).languageCode == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primaryLight,
                child: Row(children: [
                  Text(
                    '${_units.length} ${widget.unitType == 'awc' ? (isTelugu ? 'AWC కేంద్రాలు' : 'AWC Centres') : _unitTypeLabel(isTelugu)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ]),
              ),
              Expanded(
                child: _units.isEmpty
                    ? Center(
                        child: Text(
                          isTelugu ? 'డేటా లేదు' : 'No data found',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _units.length,
                        itemBuilder: (context, index) {
                          if (widget.unitType == 'awc') {
                            return _buildAwcCard(_units[index], isTelugu);
                          }
                          return _buildSubUnitCard(_units[index], isTelugu);
                        },
                      ),
              ),
            ]),
    );
  }

  String _unitTypeLabel(bool isTelugu) {
    switch (widget.unitType) {
      case 'district':
        return isTelugu ? 'జిల్లాలు' : 'Districts';
      case 'project':
        return isTelugu ? 'ప్రాజెక్టులు' : 'Projects';
      case 'sector':
        return isTelugu ? 'సెక్టార్లు' : 'Sectors';
      default:
        return '';
    }
  }

  IconData get _unitIcon {
    switch (widget.unitType) {
      case 'district':
        return Icons.map;
      case 'project':
        return Icons.business;
      case 'sector':
        return Icons.location_city;
      case 'awc':
        return Icons.location_on;
      default:
        return Icons.dashboard;
    }
  }

  /// Card for sub-units (districts/projects/sectors) — has children_count, screened_count etc.
  Widget _buildSubUnitCard(Map<String, dynamic> u, bool isTelugu) {
    final unitName = u['name']?.toString() ?? '';
    final childrenCount = u['children_count'] ?? 0;
    final screenedCount = u['screened_count'] ?? 0;
    final highRiskCount = u['high_risk_count'] ?? 0;
    final subUnitCount = u['sub_unit_count'] ?? 0;
    final pct = childrenCount > 0 ? screenedCount / childrenCount : 0.0;
    final color = pct >= 0.75 ? AppColors.riskLow : pct >= 0.5 ? AppColors.riskMedium : AppColors.riskHigh;

    // Sub-unit label for the next level down
    final subLabel = widget.unitType == 'district'
        ? (isTelugu ? 'ప్రాజెక్టులు' : 'Projects')
        : widget.unitType == 'project'
            ? (isTelugu ? 'సెక్టార్లు' : 'Sectors')
            : (isTelugu ? 'AWCలు' : 'AWCs');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _onSubUnitTap(u, unitName),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(_unitIcon, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isTelugu ? toTelugu(unitName) : unitName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (subUnitCount > 0)
                  Text('$subUnitCount $subLabel',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ])),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(children: [
                Text('$childrenCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                Text(isTelugu ? 'పిల్లలు' : 'Children', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
              Column(children: [
                Text('$screenedCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.riskLow)),
                Text(isTelugu ? 'తనిఖీ' : 'Screened', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
              Column(children: [
                Text('$highRiskCount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                        color: highRiskCount > 0 ? AppColors.riskHigh : AppColors.text)),
                Text(isTelugu ? 'అధిక ప్రమాదం' : 'High Risk', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ]),
          ]),
        ),
      ),
    );
  }

  /// Card for AWCs — simpler layout with name and centre code
  Widget _buildAwcCard(Map<String, dynamic> awc, bool isTelugu) {
    final awcName = awc['name']?.toString() ?? awc['centre_code']?.toString() ?? '';
    final centreCode = awc['centre_code']?.toString() ?? '';
    final sectorName = (awc['sectors'] as Map?)?['name']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: const Icon(Icons.location_on, color: AppColors.primary),
        ),
        title: Text(
          isTelugu ? toTelugu(awcName) : awcName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          sectorName.isNotEmpty
              ? '$centreCode • ${isTelugu ? toTelugu(sectorName) : sectorName}'
              : centreCode,
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () {
          final awcId = awc['id'] as int?;
          if (awcId != null) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => ScopedAwcDashboardScreen(awcId: awcId, awcName: awcName)));
          }
        },
      ),
    );
  }

  void _onSubUnitTap(Map<String, dynamic> u, String unitName) {
    final id = u['id'] as int?;
    if (id == null) return;

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ScopedDashboardScreen(
        scopeLevel: widget.unitType, scopeId: id, scopeName: unitName)));
  }
}
