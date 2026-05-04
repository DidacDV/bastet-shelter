import apiClient from "../../core/network/apiClient";

export interface AnimalPublicShortInfo {
  id: number;
  name: string;
  age: number;
  refuge_name: string;
  shelter_name: string;
  image_url: string | null;
  animal_type: "CAT" | "DOG" | "OTHER";
}

export interface AnimalPublicSummaryList {
  animals: AnimalPublicShortInfo[];
}

export const animalRepository = {
  getAnimalsByProvince: (provinceId: string) =>
    apiClient.get<AnimalPublicSummaryList>(`/animals/short_info_portal?province_id=${provinceId}`),
};