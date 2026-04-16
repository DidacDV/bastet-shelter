import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:flutter/material.dart';

class ShiftsScreen extends StatelessWidget {
  const ShiftsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: BastetAppBar(),
    body: Center(child: Text('Shiofts')),
  );
}
