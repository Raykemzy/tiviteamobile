import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The five-star selector from the Reviews design.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var star = 1; star <= 5; star++)
          IconButton(
            onPressed: () => onChanged(star),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.star_rounded,
              size: size ?? 34.sp,
              color: star <= rating
                  ? const Color(0xFFF5A623)
                  : const Color(0xFFD8D8DD),
            ),
          ),
      ],
    );
  }
}

/// Read-only star row for an existing rating.
class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({super.key, required this.rating, this.size});

  final int rating;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            Icons.star_rounded,
            size: size ?? 16.sp,
            color: star <= rating
                ? const Color(0xFFF5A623)
                : const Color(0xFFD8D8DD),
          ),
      ],
    );
  }
}
