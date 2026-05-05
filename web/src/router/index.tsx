import { BrowserRouter, Routes, Route } from "react-router-dom";
import Layout from "../components/Layout";
import AnimalsPage from "../pages/AnimalsPage";
import LoginPage from "../pages/LoginPage";
import AdoptionPage from "../pages/AdoptionPage";
import LocationPage from "../pages/LocationPage";
import AuthCallbackPage from "../pages/AuthCallbackPage";
import AnimalDetailPage from "../pages/AnimalDetailsPage";
import AdoptionDetailPage from "../pages/AdoptionDetailsPage";

export default function Router() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<LocationPage />} />
          <Route path="/animals" element={<AnimalsPage />} />
          <Route path="/animals/:id" element={<AnimalDetailPage />} />
          <Route path="/adoptions/:id" element={<AdoptionDetailPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/adoptions" element={<AdoptionPage />} />
          <Route path="/verify" element={<AuthCallbackPage />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  );
}
