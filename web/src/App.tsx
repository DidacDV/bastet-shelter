import { AuthProvider } from "./context/authContext";
import Router from "./router";

export default function App() {
  return (
    <AuthProvider>
      <Router />
    </AuthProvider>
  );
}
