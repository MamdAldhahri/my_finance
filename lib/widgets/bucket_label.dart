import 'package:flutter/material.dart';

import '../database/database.dart';
import '../services/income_plan.dart';
import 'ui.dart';

/// Small group heading naming a bucket, used above its categories in
/// pickers: a coloured dot and the bucket name in caps.
class BucketLabel extends StatelessWidget {
  const BucketLabel(this.bucket, {super.key, this.padding});

  final Bucket bucket;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding ?? const EdgeInsets.only(top: 14, bottom: 4),
        child: Row(
          children: [
            Dot(bucket.color, size: 7),
            const SizedBox(width: 7),
            MutedCaps(bucket.label, size: 11),
          ],
        ),
      );
}
