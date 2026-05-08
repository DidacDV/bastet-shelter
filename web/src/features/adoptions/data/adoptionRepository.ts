import apiClient from "../../../core/network/apiClient";
import type {
  AdoptionFormSubmit,
  AdoptionProcessAdoptantResponse,
  AdoptionProcessShort,
  ContractStep,
} from "./adoptionTypes";

export const adoptionsRepository = {
  getMyAdoptions: () =>
    apiClient.get<{ processes: AdoptionProcessShort[] }>("/adoptant/processes"),

  getAdoptionDetail: (processId: number) =>
    apiClient.get<AdoptionProcessAdoptantResponse>(
      `/adoptant/processes/${processId}`,
    ),

  startAdoption: (animalId: number, formData: AdoptionFormSubmit) =>
    apiClient.post<AdoptionProcessAdoptantResponse>(
      `/adoption/start/${animalId}`,
      formData,
    ),

  signContract: (processId: number) =>
    apiClient.patch<ContractStep>(
      `/adoption/${processId}/steps/contract/adoptant-signature`,
    ),
};
