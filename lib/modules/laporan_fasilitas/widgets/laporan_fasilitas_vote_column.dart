import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class LaporanFasilitasVoteColumn extends StatelessWidget {
  final int voteScore;
  final bool isUpvoted;
  final bool isDownvoted;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const LaporanFasilitasVoteColumn({
    super.key,
    required this.voteScore,
    required this.isUpvoted,
    required this.isDownvoted,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          GestureDetector(
            onTap: onUpvote,
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: isUpvoted ? Colors.orange : Colors.grey,
              size: 22,
            ),
          ),
          Text(
            '$voteScore',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.title,
            ),
          ),
          GestureDetector(
            onTap: onDownvote,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDownvoted ? Colors.blue : Colors.grey,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
