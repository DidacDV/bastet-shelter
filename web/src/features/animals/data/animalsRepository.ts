import apiClient from "../../../core/network/apiClient";

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

export interface TraitResponse {
  id: number;
  name: string;
  shelter_id: number;
}

export interface AnimalImageResponse {
  id: number;
  url: string;
  cloudinary_public_id: string;
  order: number;
}

export interface AnimalPublicDetails extends AnimalPublicShortInfo {
  link_name: string;
  shelter_link_name: string;
  birth_date: string;
  arrival_date: string | null;
  description: string;
  breed: string;
  in_adoption: boolean;
  traits: TraitResponse[];
  images: AnimalImageResponse[];
}

export const animalRepository = {
  getAnimalsByProvince: (provinceId: string) =>
    apiClient.get<AnimalPublicSummaryList>(
      `/animals/short_info_portal?province_id=${provinceId}`,
    ),

  getAnimalDetails: (animalId: number) =>
    apiClient.get<AnimalPublicDetails>(`/animals/public/${animalId}`),

  getAnimalByLinkName: (shelterLinkName: string, animalLinkName: string) =>
    apiClient.get<AnimalPublicDetails>(
      `/animals/public/by-link/${shelterLinkName}/${animalLinkName}`,
    ),
};
