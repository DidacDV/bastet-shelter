import apiClient from "../../core/network/apiClient";
import type {
  AdoptionFormSubmit,
  AdoptionProcessDetail,
  AdoptionProcessShort,
  ContractStep,
} from "./adoptionTypes";

export const adoptionsRepository = {
  getMyAdoptions: () =>
    apiClient.get<{ processes: AdoptionProcessShort[] }>("/adoptant/processes"),

  getAdoptionDetail: (processId: number) =>
    apiClient.get<AdoptionProcessDetail>(`/adoptant/processes/${processId}`),

  startAdoption: (animalId: number, formData: AdoptionFormSubmit) =>
    apiClient.post<AdoptionProcessDetail>(
      `/adoption/start/${animalId}`,
      formData,
    ),

  signContract: (processId: number) =>
    apiClient.patch<ContractStep>(
      `/adoption/${processId}/steps/contract/adoptant-signature`,
    ),
};
