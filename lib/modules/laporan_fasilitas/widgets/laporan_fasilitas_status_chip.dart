import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';

class LaporanFasilitasStatusChip extends StatelessWidget {
  final StatusLaporan status;
  final bool printed;

  const LaporanFasilitasStatusChip({
    super.key,
    required this.status,
    required this.printed,
  });

  @override
  Widget build(BuildContext context) {
    final color = printed ? Colors.teal : const Color(0xFF1E78E6);
    final bg = printed ? const Color(0xFFE0F2F1) : const Color(0xFFE3F2FD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            printed ? 'Selesai' : status.label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
