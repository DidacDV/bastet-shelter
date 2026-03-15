import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _repository = getIt<ShelterRepository>();
  final _client = getIt<ApiClient>();
  Map<String, dynamic>? _shelterInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShelterInfo();
  }

  Future<void> _loadShelterInfo() async {
    try {
      final data = await _repository.getShelterInfo();
      setState(() {
        _shelterInfo = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    final info = _shelterInfo!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shelter Info', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _InfoRow(label: 'Name', value: info['name']),
        const SizedBox(height: 12),
        _InfoRow(label: 'Location', value: info['location']),
        const SizedBox(height: 12),
        _InfoRow(label: 'Volunteer Code', value: info['volunteer_code']),
        const SizedBox(height: 12),
        _InfoRow(label: 'Manager Code', value: info['manager_code']),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}