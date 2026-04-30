import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_process/adoption_process_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_process/adoption_process_summary.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_requests/adoption_requests.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/contract_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/form_step_details.dart';

class AdoptionRepository {
  final ApiClient _apiClient;

  AdoptionRepository(this._apiClient);

  // ADOPTANT REGION
  Future<AdoptionProcessSummary> startAdoption(
    int animalId,
    AdoptionFormSubmit formData,
  ) async {
    final response = await _apiClient.post(
      '/adoption/start/$animalId',
      body: formData.toJson(),
    );
    return AdoptionProcessSummary.fromJson(response);
  }

  Future<void> cancelAdoption(int processId) async {
    await _apiClient.post('/adoption/$processId/cancel');
  }

  Future<List<AdoptionProcessSummary>> getProcessesForAdoptant() async {
    final response = await _apiClient.get('/adoption/adoptant');
    return AdoptionProcessSummary.listFromJson(response as List<dynamic>);
  }

  Future<AdoptionProcessSummary> getAdoptionProcessAdoptant(
    int processId,
  ) async {
    final response = await _apiClient.get('/adoption/$processId/adoptant');
    return AdoptionProcessSummary.fromJson(response);
  }

  // MANAGER REGION
  Future<void> rejectAdoptionProcess(
    int processId,
    RejectionRequest request,
  ) async {
    await _apiClient.post(
      '/adoption/$processId/reject',
      body: request.toJson(),
    );
  }

  Future<List<AdoptionProcessSummary>> getProcessesForShelter() async {
    final response = await _apiClient.get('/adoption/shelter');
    return AdoptionProcessSummary.listFromJson(
      response["processes"] as List<dynamic>,
    );
  }

  Future<AdoptionProcessDetails> getAdoptionProcessManager(
    int processId,
  ) async {
    final response = await _apiClient.get('/adoption/$processId/manager');
    return AdoptionProcessDetails.fromJson(response);
  }

  Future<AdoptionProcessDetails> getAdoptionProcessDetails(
    int processId,
  ) async {
    final response = await _apiClient.get('/adoption/$processId/details');
    return AdoptionProcessDetails.fromJson(response);
  }

  // ADOPTION PROCESS ACTIONS REGION
  Future<AdoptionProcessDetails> advanceCurrentStep(
    int processId,
    AdvanceStepRequest request,
  ) async {
    final response = await _apiClient.post(
      '/adoption/$processId/advance',
      body: request.toJson(),
    );
    return AdoptionProcessDetails.fromJson(response);
  }

  Future<AdoptionProcessDetails> skipStep(int processId) async {
    final response = await _apiClient.post('/adoption/$processId/skip');
    return AdoptionProcessDetails.fromJson(response);
  }

  // ADOPTION STEPS REGION
  Future<AdoptionStepDetails> setInterviewDate(
    int processId,
    ScheduledDateUpdate data,
  ) async {
    final response = await _apiClient.patch(
      '/adoption/$processId/steps/interview',
      body: data.toJson(),
    );
    return AdoptionStepDetails.fromJson(response);
  }

  Future<AdoptionStepDetails> setShelterVisitDate(
    int processId,
    ScheduledDateUpdate data,
  ) async {
    final response = await _apiClient.patch(
      '/adoption/$processId/steps/shelter-visit',
      body: data.toJson(),
    );
    return AdoptionStepDetails.fromJson(response);
  }

  Future<AdoptionStepDetails> setAnimalScheduledPickupDate(
    int processId,
    ScheduledDateUpdate data,
  ) async {
    final response = await _apiClient.patch(
      '/adoption/$processId/steps/pickup',
      body: data.toJson(),
    );
    return AdoptionStepDetails.fromJson(response);
  }

  Future<AdoptionStepDetails> setAnimalActualPickupDate(
    int processId,
    int stepId,
    ScheduledDateUpdate data,
  ) async {
    final response = await _apiClient.patch(
      '/adoption/$processId/steps/$stepId/actual-pickup',
      body: data.toJson(),
    );
    return AdoptionStepDetails.fromJson(response);
  }

  Future<AdoptionStepDetails> updateNotes(
    int processId,
    int stepId,
    NotesUpdate data,
  ) async {
    final response = await _apiClient.patch(
      '/adoption/$processId/steps/$stepId/notes',
      body: data.toJson(),
    );
    return AdoptionStepDetails.fromJson(response);
  }

  Future<AdoptionFormContent> getFormDetails(int processId) async {
    final response = await _apiClient.get('/adoption/$processId/steps/form');
    return AdoptionFormContent.fromJson(response);
  }

  Future<ContractStepDetails> updateShelterContractSignature(
    int processId,
  ) async {
    final response = await _apiClient.patch(
      '/adoption/$processId/steps/contract/shelter-signature',
    );
    return ContractStepDetails.fromJson(response);
  }

  Future<ContractStepDetails> updateAdoptantContractSignature(
    int processId,
  ) async {
    final response = await _apiClient.patch(
      '/adoption/$processId/steps/contract/adoptant-signature',
    );
    return ContractStepDetails.fromJson(response);
  }
}
