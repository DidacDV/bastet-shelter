import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/form_step_details.dart';
import 'package:bastetshelter/providers/adoption/adoption_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'form_step_content_provider.g.dart';

@riverpod
Future<AdoptionFormContent> formStepContent(Ref ref, int processId) async {
  return ref.read(adoptionRepositoryProvider).getFormDetails(processId);
}
