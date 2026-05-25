import { BrowserRouter, Routes, Route } from "react-router-dom";
import Layout from "../components/Layout";
import AnimalsPage from "../features/animals/AnimalsPage";
import LoginPage from "../features/adoptantAuth/LoginPage";
import AdoptionPage from "../features/adoptions/AdoptionPage";
import LocationPage from "../features/locations/LocationPage";
import AuthCallbackPage from "../features/adoptantAuth/AuthCallbackPage";
import AnimalDetailPage from "../features/animals/AnimalDetailsPage";
import AdoptionDetailPage from "../features/adoptions/AdoptionDetailsPage";

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
