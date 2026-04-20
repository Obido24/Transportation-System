import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import "./index.css";
import App from "./App.jsx";
import AuthBootstrap from "./components/AuthBootstrap.jsx";

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <AuthBootstrap>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </AuthBootstrap>
  </StrictMode>,
)
