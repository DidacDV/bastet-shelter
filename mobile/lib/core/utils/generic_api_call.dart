import 'package:bastetshelter/core/navigation_service.dart';
import 'package:bastetshelter/core/network/api_client.dart';
import 'package:flutter/material.dart';

Future<T?> genericApiCall<T>(Future<T> Function() externalCall) async {
  try {
    return await externalCall();
  } on ApiException catch (e) {
    debugPrint(e.toString());
    NavigationService.instance.showSnackBar(e.message, isError: true);
    return null;
  } catch (e) {
    debugPrint(e.toString());
    NavigationService.instance.showSnackBarKey(
      'common.somethingWentWrong',
      isError: true,
    );
    return null;
  }
}
