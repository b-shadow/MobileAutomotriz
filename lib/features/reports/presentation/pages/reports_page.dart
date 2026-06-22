import 'package:flutter/material.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'ia_reports_page.dart';
import 'explorer_reports_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _mainMode = 'clasico'; // 'clasico' or 'ia'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Reportes y Estadísticas'),
      ),
      body: Column(
        children: [
          // ── Mode Toggle ──────────────────────────────
          _buildModeToggle(),

          // ── Content based on mode ───────────────────
          if (_mainMode == 'ia')
            const Expanded(child: IaReportsPage())
          else
            const Expanded(child: ExplorerReportsPage()),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mainMode = 'clasico'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _mainMode == 'clasico'
                      ? AppColors.darkCard
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _mainMode == 'clasico'
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 18,
                      color: _mainMode == 'clasico'
                          ? const Color(0xFF10B981)
                          : AppColors.darkTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Clásicos',
                      style: TextStyle(
                        color: _mainMode == 'clasico'
                            ? Colors.white
                            : AppColors.darkTextSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mainMode = 'ia'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: _mainMode == 'ia'
                      ? const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF6366F1)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _mainMode == 'ia'
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.smart_toy_rounded,
                      size: 18,
                      color: _mainMode == 'ia'
                          ? Colors.white
                          : AppColors.darkTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Reportes con IA',
                      style: TextStyle(
                        color: _mainMode == 'ia'
                            ? Colors.white
                            : AppColors.darkTextSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
