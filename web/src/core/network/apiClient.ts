import axios from 'axios'
import { AppConfig } from '../config'

const apiClient = axios.create({
  baseURL: AppConfig.baseUrl,
})

export default apiClient