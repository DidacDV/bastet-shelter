import { AuthProvider } from "./context/authContext";
import { LocalizationProvider } from "./localization/localization";
import Router from "./router";

export default function App() {
  return (
    <LocalizationProvider>
      <AuthProvider>
        <Router />
      </AuthProvider>
    </LocalizationProvider>
  );
}
