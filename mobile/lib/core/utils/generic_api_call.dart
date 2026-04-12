import 'package:bastetshelter/core/navigation_service.dart';
import 'package:bastetshelter/core/network/api_client.dart';

Future<void> genericApiCall(Future<void> Function() externalCall) async {
  try {
    await externalCall();
  } on ApiException catch (e) {
    NavigationService.instance.showSnackBar(e.message, isError: true);
  } catch (_) {
    NavigationService.instance.showSnackBar(
      'Something went wrong',
      isError: true,
    );
  }
}
