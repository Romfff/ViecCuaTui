import 'package:flutter/material.dart';
import '../models/job_model.dart';

const Color kPrimary = Color(0xFF43E8D8);

/// Card hiển thị thông tin job (UI tương tự mẫu bạn gửi).
class JobCardItem extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;

  const JobCardItem({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final companyInitial = job.company.isNotEmpty ? job.company[0].toUpperCase() : '?';
    final locationText = job.location;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPrimary.withOpacity(0.35), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo (placeholder)
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  companyInitial,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: kPrimary.withOpacity(0.95),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: kPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16, color: kPrimary),
                      const SizedBox(width: 6),
                      Text(
                        'Lương',
                        style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _Pill(text: job.salary, bg: kPrimary.withOpacity(0.12), fg: kPrimary),
                      _Pill(text: locationText, bg: kPrimary.withOpacity(0.12), fg: kPrimary),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    job.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.postedDate,
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _IconCircle(
                        icon: Icons.search,
                        onTap: () {
                          // Không ảnh hưởng logic điều hướng chính (InkWell đã xử lý).
                        },
                      ),
                      const SizedBox(width: 10),
                      _IconCircle(
                        icon: Icons.favorite_border,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card hiển thị "Top Employers" (thanh ngang).
class TopEmployerCard extends StatelessWidget {
  final String companyName;
  final int jobCount;
  final String location;
  final List<String> tags;
  final VoidCallback? onTap;

  const TopEmployerCard({
    super.key,
    required this.companyName,
    required this.jobCount,
    required this.location,
    required this.tags,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : '?';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimary.withOpacity(0.08),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('$jobCount Jobs'),
                  backgroundColor: kPrimary.withOpacity(0.12),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const SizedBox(height: 8),

            Text(
              companyName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: kPrimary.withOpacity(0.95),
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tags
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      backgroundColor: kPrimary.withOpacity(0.10),
                      side: BorderSide(color: kPrimary.withOpacity(0.18)),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: kPrimary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: kPrimary.withOpacity(0.95),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _SmallBadge({
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Pill({
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconCircle({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }
}