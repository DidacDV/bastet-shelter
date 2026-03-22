import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';

enum CodeScreenMode { volunteer, manager }

class CodeEntryScreen extends StatefulWidget {
  final CodeScreenMode mode;

  const CodeEntryScreen({super.key, required this.mode});

  @override
  State<CodeEntryScreen> createState() => _CodeEntryScreenState();
}

class _CodeEntryScreenState extends State<CodeEntryScreen> {
  final _codeController = TextEditingController();
  final _repository = getIt<ShelterRepository>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    await genericApiCall(() async {
      switch (widget.mode) {
        case CodeScreenMode.volunteer:
          await _repository.joinAsVolunteer(code);
          break;
        case CodeScreenMode.manager:
          await _repository.joinAsManager(code);
          break;
      }
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Code')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your shelter code',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Code',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}