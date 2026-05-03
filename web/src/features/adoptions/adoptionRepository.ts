import apiClient from "../../core/network/apiClient";

export interface AdoptionProcessShort {
  id: string | number;
  animal_name: string;
  animal_photo: string;
  status: "pending" | "interview" | "approved" | "rejected" | "completed";
  start_date: string;
}

export const adoptionsRepository = {
  getMyAdoptions: () =>
    apiClient.get<AdoptionProcessShort[]>("/adoptant/processes"),
};
