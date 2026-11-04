import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../format.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Goals tab: savings targets with progress. Entered by hand.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: StreamBuilder<List<Goal>>(
        stream: db.watchGoals(),
        builder: (context, snapshot) {
          final goals = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Goals',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                  InkWell(
                    onTap: () => _openEditor(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          const Icon(Icons.add, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (goals.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'No goals yet.\nTap + to set a savings target.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.faint),
                  ),
                )
              else
                for (var i = 0; i < goals.length; i++) ...[
                  _GoalCard(goal: goals[i], color: AppColors.paletteAt(i)),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.color});

  final Goal goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = goal.targetAmount <= 0
        ? 0.0
        : (goal.savedAmount / goal.targetAmount * 100).clamp(0, 100).toDouble();

    return AppCard(
      onTap: () => _openEditor(context, goal),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Dot(color),
                  const SizedBox(width: 10),
                  Text(goal.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                ],
              ),
              Text('${pct.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(fraction: pct / 100, color: AppColors.green),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${amountText(goal.savedAmount)} of '
                '${money(goal.targetAmount)}',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              if (goal.targetDate != null)
                Text('by ${monthYear(goal.targetDate!)}',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.faint)),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _openEditor(BuildContext context, [Goal? existing]) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.screen,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _GoalEditor(existing: existing),
    ),
  );
}

class _GoalEditor extends StatefulWidget {
  const _GoalEditor({this.existing});

  final Goal? existing;

  @override
  State<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends State<_GoalEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _saved;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _name = TextEditingController(text: g?.name ?? '');
    _target = TextEditingController(
        text: g == null ? '' : g.targetAmount.toStringAsFixed(3));
    _saved = TextEditingController(
        text: g == null ? '' : g.savedAmount.toStringAsFixed(3));
    _targetDate = g?.targetDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _saved.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final target = double.parse(_target.text);
    final saved = double.tryParse(_saved.text) ?? 0;
    final g = widget.existing;
    if (g == null) {
      await db.addGoal(GoalsCompanion.insert(
        name: _name.text.trim(),
        targetAmount: target,
        savedAmount: Value(saved),
        targetDate: Value(_targetDate),
      ));
    } else {
      await db.updateGoal(g.copyWith(
        name: _name.text.trim(),
        targetAmount: target,
        savedAmount: saved,
        targetDate: Value(_targetDate),
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.existing == null ? 'Add goal' : 'Edit goal',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink)),
                if (widget.existing != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.terracotta),
                    onPressed: () async {
                      await db.deleteGoal(widget.existing!.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _tf(_name, 'Goal name', capitalize: true, required: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _tf(_target, 'Target (OMR)',
                        number: true, required: true)),
                const SizedBox(width: 12),
                Expanded(child: _tf(_saved, 'Saved (OMR)', number: true)),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(_targetDate == null
                  ? 'Target date (optional)'
                  : 'Target: ${shortDate(_targetDate!)}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: Color(0x261E2E2A)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(
    TextEditingController c,
    String label, {
    bool number = false,
    bool capitalize = false,
    bool required = false,
  }) {
    return TextFormField(
      controller: c,
      keyboardType:
          number ? const TextInputType.numberWithOptions(decimal: true) : null,
      textCapitalization:
          capitalize ? TextCapitalization.sentences : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x261E2E2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x261E2E2A)),
        ),
      ),
      validator: required
          ? (v) {
              if (number) {
                final n = double.tryParse(v ?? '');
                return (n == null || n <= 0) ? 'Invalid' : null;
              }
              return (v == null || v.trim().isEmpty) ? 'Required' : null;
            }
          : null,
    );
  }
}
