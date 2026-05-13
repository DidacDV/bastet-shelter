import apiClient from "../../../core/network/apiClient";

export interface Province {
  id: string;
  name: string;
}

export const geoRepository = {
  getProvinces: () =>
    apiClient.get<{ provinces: Province[] }>("/geo/provinces"),
};
