import 'package:bastetshelter/core/navigation_service.dart';
import 'package:bastetshelter/core/network/api_client.dart';

Future<T?> genericApiCall<T>(Future<T> Function() externalCall) async {
  try {
    return await externalCall();
  } on ApiException catch (e) {
    print('Error: $e');
    NavigationService.instance.showSnackBar(e.message, isError: true);
    return null;
  } catch (e) {
    print('Error: $e');
    NavigationService.instance.showSnackBar(
      'Something went wrong',
      isError: true,
    );
    return null;
  }
}
