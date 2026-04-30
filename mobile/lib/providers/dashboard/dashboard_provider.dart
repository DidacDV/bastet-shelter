import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/home/data/dashboard_repository.dart';
import 'package:bastetshelter/features/home/data/dashboard_model.dart';

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((
  ref,
) async {
  return getIt<DashboardRepository>().getDashboard();
});
