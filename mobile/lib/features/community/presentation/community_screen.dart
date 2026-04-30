import 'package:flutter/material.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: BastetAppBar(),
    body: Center(child: Text('Community')),
  );
}
