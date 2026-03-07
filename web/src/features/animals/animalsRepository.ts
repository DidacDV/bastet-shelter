import apiClient from '../../core/network/apiClient'

export const animalsRepository = {
  async fetchStatus(): Promise<string> {
    const response = await apiClient.get('/')
    return JSON.stringify(response.data)
  },
}