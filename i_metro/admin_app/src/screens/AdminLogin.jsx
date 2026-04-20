import { useEffect, useRef, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";

import HtmlScreen from "./HtmlScreen";
import adminLoginHtml from "./html/admin_login.html?raw";
import { loginAdmin } from "../lib/api";
import { authStore } from "../lib/auth";

const wrapperClassName =
  "flex items-center justify-center min-h-screen text-on-surface bg-surface p-6 overflow-hidden";

function AdminLogin() {
  const navigate = useNavigate();
  const location = useLocation();
  const containerRef = useRef(null);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;
    const form = container.querySelector("form");
    if (!form) return;

    const handler = async (event) => {
      event.preventDefault();
      setError("");

      const emailOrPhone = container.querySelector("#email")?.value?.trim();
      const password = container.querySelector("#password")?.value ?? "";

      if (!emailOrPhone || !password) {
        setError("Please enter your email/phone and password.");
        return;
      }

      setBusy(true);
      try {
        const result = await loginAdmin({ emailOrPhone, password });
        if (result?.ok && result?.accessToken) {
          authStore.setSession({
            tokenValue: result.accessToken,
            userIdValue: result.userId,
            roleValue: result.role,
            emailValue: emailOrPhone.includes("@") ? emailOrPhone : undefined,
            phoneValue: emailOrPhone.includes("@") ? undefined : emailOrPhone,
          });
          await authStore.bootstrap();

          const from = location.state?.from;
          const target =
            typeof from === "string"
              ? from
              : from?.pathname
                ? `${from.pathname}${from.search ?? ""}${from.hash ?? ""}`
                : "/admin/dashboard";

          navigate(target, { replace: true });
          return;
        }
        setError("Invalid credentials. Please try again.");
      } catch {
        setError("Login failed. Please try again.");
      } finally {
        setBusy(false);
      }
    };

    form.addEventListener("submit", handler);
    return () => form.removeEventListener("submit", handler);
  }, [location, navigate]);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;
    const button = container.querySelector("button[type='submit']");
    if (!button) return;
    button.disabled = busy;
    if (busy) {
      button.classList.add("opacity-70", "cursor-not-allowed");
    } else {
      button.classList.remove("opacity-70", "cursor-not-allowed");
    }
  }, [busy]);

  return (
    <>
      {error && (
        <div className="fixed top-6 left-1/2 -translate-x-1/2 z-50 bg-error-container text-on-error-container px-4 py-2 rounded-lg shadow-md text-sm">
          {error}
        </div>
      )}
      <HtmlScreen
        html={adminLoginHtml}
        title="Admin Login"
        layout="auth"
        wrapperClassName={wrapperClassName}
        containerRef={containerRef}
      />
    </>
  );
}

export default AdminLogin;
