import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/category.dart';
import '../../core/models/log_entry.dart';
import '../../core/providers/isar_provider.dart';
import 'providers/dsa_provider.dart';

class DsaTrackerScreen extends ConsumerWidget {
  const DsaTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(dsaTrackerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Blind 75'),
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
          ),
          statusesAsync.when(
            data: (statuses) {
              final solved = statuses.where((s) => s.isSolved).length;
              final total = statuses.length;
              return SliverList(
                delegate: SliverChildListDelegate([
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$solved / $total',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('solved', style: theme.textTheme.bodyMedium),
                            const Spacer(),
                            Text(
                              '${(solved / total * 100).round()}%',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? solved / total : 0,
                            minHeight: 8,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Group by topic
                  ..._buildTopicGroups(statuses, context),
                  const SizedBox(height: 80),
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTopicGroups(
    List<DsaProblemStatus> statuses,
    BuildContext context,
  ) {
    final Map<String, List<DsaProblemStatus>> byTopic = {};
    for (final s in statuses) {
      (byTopic[s.problem.group] ??= []).add(s);
    }

    final topics = <String>[];
    for (final status in statuses) {
      final topic = status.problem.group;
      if (!topics.contains(topic)) {
        topics.add(topic);
      }
    }

    return [
      for (final topic in topics) ...[
        _TopicHeader(
          topic: topic,
          solved: byTopic[topic]!.where((s) => s.isSolved).length,
          total: byTopic[topic]!.length,
        ),
        ...byTopic[topic]!.map((s) => _ProblemRow(status: s)),
      ],
    ];
  }
}

class _TopicHeader extends StatelessWidget {
  final String topic;
  final int solved;
  final int total;

  const _TopicHeader({
    required this.topic,
    required this.solved,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(
            topic,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text('$solved/$total', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ProblemRow extends ConsumerWidget {
  final DsaProblemStatus status;

  const _ProblemRow({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prob = status.problem;
    final solved = status.isSolved;

    return InkWell(
      onTap: () => _showDetails(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            // Solved indicator
            InkWell(
              onTap: () => _toggleProgress(context, ref),
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: solved
                      ? const Color(0xFF22C55E)
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: solved
                      ? null
                      : Border.all(
                          color: theme.colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                ),
                child: solved
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Problem number
            SizedBox(
              width: 36,
              child: Text('#${prob.id}', style: theme.textTheme.labelSmall),
            ),
            // Name
            Expanded(
              child: Text(
                prob.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: solved ? TextDecoration.none : null,
                  color: solved
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withAlpha(180),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Difficulty badge
            _DifficultyBadge(difficulty: prob.difficulty),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    if (status.attempts.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProblemDetailsSheet(status: status),
    );
  }

  Future<void> _toggleProgress(BuildContext context, WidgetRef ref) async {
    final isar = ref.read(isarProvider);

    if (status.isSolved && status.hasTrackerProgress) {
      final trackerAttemptIds = status.attempts
          .where((log) => log.payload['kind'] == 'tracker_progress')
          .map((log) => log.id)
          .toList();

      await isar.writeTxn(() async {
        for (final id in trackerAttemptIds) {
          await isar.logEntrys.delete(id);
        }
      });
    } else if (!status.isSolved) {
      final entry = LogEntry()
        ..category = Category.dsa
        ..createdAt = DateTime.now().toUtc()
        ..payload = {
          'problemNumber': status.problem.id,
          'problemName': status.problem.name,
          'topic': status.problem.topic,
          'approach': 'Tracker Marked',
          'status': 'Solved',
          'kind': 'tracker_progress',
        };

      await isar.writeTxn(() => isar.logEntrys.put(entry));
    }

    ref.invalidate(dsaTrackerProvider);

    if (context.mounted) {
      final removed = status.isSolved && status.hasTrackerProgress;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            removed
                ? 'Removed progress for ${status.problem.name}'
                : 'Marked ${status.problem.name} as solved',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  Color get _color => switch (difficulty) {
    'Easy' => const Color(0xFF22C55E),
    'Medium' => const Color(0xFFF59E0B),
    _ => const Color(0xFFF87171),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProblemDetailsSheet extends StatelessWidget {
  final DsaProblemStatus status;

  const _ProblemDetailsSheet({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prob = status.problem;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('#${prob.id} ${prob.name}', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(prob.topic, style: theme.textTheme.bodySmall),
              const SizedBox(width: 8),
              _DifficultyBadge(difficulty: prob.difficulty),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Attempts (${status.attempts.length})',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ...status.attempts.map((log) {
            final p = log.payload;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    p['status'] == 'Solved'
                        ? Icons.check_circle
                        : Icons.refresh,
                    color: p['status'] == 'Solved'
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFF59E0B),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    p['approach'] as String? ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('d MMM').format(log.createdAt.toLocal()),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
