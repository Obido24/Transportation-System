import { authStore } from "./auth";

const API_BASE =
  import.meta.env.VITE_API_BASE_URL ?? "http://localhost:3000/api";

const withAuthHeaders = (headers = {}) => {
  const token = authStore.get();
  if (!token) return headers;
  return { ...headers, Authorization: `Bearer ${token}` };
};

const handleAuthFailure = (response) => {
  if (response.status === 401) {
    authStore.clear();
    if (typeof window !== "undefined") {
      window.location.assign("/admin/login");
    }
  }
};

export const loginAdmin = async ({ emailOrPhone, password }) => {
  const response = await fetch(`${API_BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ emailOrPhone, password }),
  });

  if (!response.ok) {
    return { ok: false, reason: "network_error" };
  }

  return response.json();
};

export const fetchWithAuth = async (path, options = {}) => {
  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: withAuthHeaders({
      "Content-Type": "application/json",
      ...(options.headers || {}),
    }),
  });

  handleAuthFailure(response);
  return response;
};

export const updateAdminProfile = async (payload) => {
  const response = await fetchWithAuth("/auth/me", {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
  return response.json();
};

export const changeAdminPassword = async (payload) => {
  const response = await fetchWithAuth("/auth/change-password", {
    method: "POST",
    body: JSON.stringify(payload),
  });
  return response.json();
};
