import 'package:flutter/material.dart';
import 'package:bastetshelter/features/exampleFeature/data/example_repository.dart';
import 'package:bastetshelter/core/network/api_client.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleFeatureState();
}

class _ExampleFeatureState extends State<ExampleScreen> {
  final ExampleRepository _repository = ExampleRepository(ApiClient());
  String _response = 'No response yet';
  bool _loading = false;

  Future<void> _testBackend() async {
    setState(() => _loading = true);
    try {
      final result = await _repository.fetchStatus();
      setState(() => _response = result);
    } catch (e) {
      setState(() => _response = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bastet Shelter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_response),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _testBackend,
              child: const Text('Test Backend'),
            ),
          ],
        ),
      ),
    );
  }
}