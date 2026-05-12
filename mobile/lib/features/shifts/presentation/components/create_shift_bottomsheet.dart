import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CreateShiftBottomSheet extends ConsumerStatefulWidget {
  final int refugeId;
  final DateTime weekStart;
  final DateTime initialDate;

  const CreateShiftBottomSheet({
    super.key,
    required this.refugeId,
    required this.weekStart,
    required this.initialDate,
  });

  @override
  ConsumerState<CreateShiftBottomSheet> createState() =>
      _CreateShiftBottomSheetState();
}

class _CreateShiftBottomSheetState
    extends ConsumerState<CreateShiftBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _maxParticipantsController = TextEditingController();

  late DateTime _selectedDay;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    //default to today or to monday if past week
    _selectedDay = widget.initialDate;
  }

  @override
  void dispose() {
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final endOfWeek = widget.weekStart.add(const Duration(days: 6));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: widget.weekStart,
      lastDate: endOfWeek,
      helpText: 'Select a day this week',
    );

    if (picked != null) setState(() => _selectedDay = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      final startDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        _endTime.hour,
        _endTime.minute,
      );

      if (endDateTime.isBefore(startDateTime) ||
          endDateTime.isAtSameMomentAs(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        setState(() => _loading = false);
        return;
      }

      final maxP = int.tryParse(_maxParticipantsController.text.trim());

      await ref
          .read(shiftsProvider(widget.refugeId, widget.weekStart).notifier)
          .createShift(
            startTime: startDateTime,
            endTime: endDateTime,
            day: _selectedDay,
            maxParticipants: maxP,
          );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return FormBottomSheet(
      title: 'New Shift',
      actions: [
        PrimaryButton(
          label: 'Create Shift',
          isLoading: _loading,
          onPressed: _submit,
        ),
      ],
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: TextEditingController(
                  text: dateFormat.format(_selectedDay),
                ),
                label: 'Shift Date',
                readOnly: true,
                onTap: _pickDay,
                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: TextEditingController(
                        text: _startTime.format(context),
                      ),
                      label: 'Start Time',
                      readOnly: true,
                      onTap: () => _pickTime(true),
                      suffixIcon: const Icon(
                        Icons.access_time_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: TextEditingController(
                        text: _endTime.format(context),
                      ),
                      label: 'End Time',
                      readOnly: true,
                      onTap: () => _pickTime(false),
                      suffixIcon: const Icon(
                        Icons.access_time_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _maxParticipantsController,
                label: 'Max Participants (Optional)',
                hintText: 'Leave empty for unlimited',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showCreateShiftBottomSheet({
  required BuildContext context,
  required int refugeId,
  required DateTime weekStart,
  required DateTime initialDate,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => CreateShiftBottomSheet(
      refugeId: refugeId,
      weekStart: weekStart,
      initialDate: initialDate,
    ),
  );
}
