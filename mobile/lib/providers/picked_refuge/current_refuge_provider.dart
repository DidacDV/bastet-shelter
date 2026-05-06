import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_refuge_provider.g.dart';

@riverpod
class CurrentRefuge extends _$CurrentRefuge {
  @override
  int? build() {
    return null; //null --> default to the first one available
  }

  void setRefuge(int id) {
    state = id;
  }
}
