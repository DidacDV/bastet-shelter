import apiClient from '../../core/network/apiClient'

export const animalsRepository = {
  async fetchStatus(): Promise<string> {
    const response = await apiClient.get<unknown>('/')
    return JSON.stringify(response) //with fetch api client, we obtain "data" directly (no need for resp.data)
  },
}