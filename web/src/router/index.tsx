import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Layout from '../components/Layout'
import AnimalsPage from '../pages/AnimalsPage'
import LoginPage from '../pages/LoginPage'
import AdoptionPage from '../pages/AdoptionPage'

export default function Router() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<AnimalsPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/adoption" element={<AdoptionPage />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  )
} 