import 'package:flutter/material.dart';
import '../models/job_model.dart';

const Color kPrimary = Color(0xFF43E8D8);
const Color kPrimaryDark = Color(0xFF00B0A0);
const Color kNavy = Color(0xFF0D1B4B);

/// Card hiển thị thông tin job.
class JobCardItem extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;

  const JobCardItem({
    super.key,
    required this.job,
    this.onTap,
  });

  Color get _avatarColor {
    final colors = [
      const Color(0xFF5B6EF5),
      const Color(0xFFFF6B6B),
      const Color(0xFF00B0A0),
      const Color(0xFFFFB347),
      const Color(0xFF9B59B6),
    ];
    final idx = job.company.isEmpty ? 0 : job.company.codeUnitAt(0) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final companyInitial = job.company.isNotEmpty ? job.company[0].toUpperCase() : '?';
    final avatarColor = _avatarColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Left accent bar
            Positioned(
              left: 0,
              top: 16,
              bottom: 16,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company avatar
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: avatarColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        companyInitial,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: avatarColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Type badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: kNavy,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (job.type.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: kPrimary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  job.type,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: kPrimaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Company name
                        Text(
                          job.company,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Salary + Location pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _InfoPill(
                              icon: Icons.attach_money_rounded,
                              text: job.salary,
                              color: const Color(0xFF2ECC71),
                            ),
                            _InfoPill(
                              icon: Icons.location_on_outlined,
                              text: job.location,
                              color: const Color(0xFF3498DB),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Posted date + action icons
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              job.postedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            _SmallIconBtn(icon: Icons.bookmark_border_rounded, onTap: () {}),
                          ],
                        ),
                      ],
                    ),
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoPill({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SmallIconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.grey.shade500),
      ),
    );
  }
}

/// Card "Top Employers" cuộn ngang.
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

  Color get _avatarColor {
    final colors = [
      const Color(0xFF5B6EF5),
      const Color(0xFFFF6B6B),
      const Color(0xFF00B0A0),
      const Color(0xFFFFB347),
      const Color(0xFF9B59B6),
    ];
    final idx = companyName.isEmpty ? 0 : companyName.codeUnitAt(0) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : '?';
    final avatarColor = _avatarColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: avatarColor,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$jobCount việc',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              companyName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: kNavy,
              ),
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ],
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: tags.take(3).map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF5B6EF5))),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}