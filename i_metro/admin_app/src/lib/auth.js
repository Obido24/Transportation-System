import { useSyncExternalStore } from "react";

const TOKEN_KEY = "i_metro_admin_token";
const PROFILE_KEY = "i_metro_admin_profile";
const API_BASE = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:3000/api";
const BOOTSTRAP_TIMEOUT_MS = 3500;

const listeners = new Set();
let bootstrapPromise = null;
let sessionSnapshot = null;

const emptyProfile = {
  id: null,
  email: null,
  phone: null,
  firstName: null,
  lastName: null,
  role: null,
  avatarUrl: null,
  createdAt: null,
};

const state = {
  token: null,
  payload: null,
  profile: { ...emptyProfile },
};

const emit = () => {
  sessionSnapshot = {
    token: state.token,
    payload: state.payload,
    profile: { ...state.profile },
    isExpired: false,
  };
  sessionSnapshot.isExpired = authStore.isExpired();
  listeners.forEach((listener) => listener());
};

const safeJsonParse = (value) => {
  if (!value) return null;
  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
};

const decodeBase64Url = (value) => {
  if (!value) return "";
  const normalized = value.replace(/-/g, "+").replace(/_/g, "/");
  const padded = normalized + "=".repeat((4 - (normalized.length % 4)) % 4);
  try {
    return atob(padded);
  } catch {
    return "";
  }
};

const parseJwt = (token) => {
  if (!token) return null;
  const parts = token.split(".");
  if (parts.length !== 3) return null;
  try {
    return JSON.parse(decodeBase64Url(parts[1]));
  } catch {
    return null;
  }
};

const normalizeProfile = (profile = {}) => ({
  id: profile.id ?? null,
  email: profile.email ?? null,
  phone: profile.phone ?? null,
  firstName: profile.firstName ?? null,
  lastName: profile.lastName ?? null,
  role: profile.role ?? null,
  avatarUrl: profile.avatarUrl ?? null,
  createdAt: profile.createdAt ?? null,
});

const loadFromStorage = () => {
  if (typeof window === "undefined") return;
  const token = localStorage.getItem(TOKEN_KEY);
  const profile = safeJsonParse(localStorage.getItem(PROFILE_KEY));
  state.token = token;
  state.payload = parseJwt(token);
  state.profile = normalizeProfile(profile);
  sessionSnapshot = {
    token: state.token,
    payload: state.payload,
    profile: { ...state.profile },
    isExpired: false,
  };
  sessionSnapshot.isExpired = authStore.isExpired();
};

const persist = () => {
  if (typeof window === "undefined") return;
  if (state.token) {
    localStorage.setItem(TOKEN_KEY, state.token);
  } else {
    localStorage.removeItem(TOKEN_KEY);
  }

  if (state.profile && (state.profile.id || state.profile.email || state.profile.phone)) {
    localStorage.setItem(PROFILE_KEY, JSON.stringify(state.profile));
  } else {
    localStorage.removeItem(PROFILE_KEY);
  }
};

const hydrateFromServer = async () => {
  if (!state.token || authStore.isExpired()) {
    authStore.clear();
    return { ok: false, reason: "expired" };
  }

  const controller = new AbortController();
  const timeoutId = window.setTimeout(() => controller.abort(), BOOTSTRAP_TIMEOUT_MS);

  try {
    const response = await fetch(`${API_BASE}/auth/me`, {
      headers: {
        Authorization: `Bearer ${state.token}`,
      },
      signal: controller.signal,
    });

    if (response.status === 401) {
      authStore.clear();
      return { ok: false, reason: "unauthorized" };
    }

    if (!response.ok) {
      return { ok: false, reason: "network_error" };
    }

    const data = await response.json();
    if (data?.ok && data.user) {
      state.profile = normalizeProfile(data.user);
      persist();
      emit();
      return { ok: true, user: state.profile };
    }

    return { ok: false, reason: data?.reason ?? "unknown" };
  } catch {
    return { ok: false, reason: "network_error" };
  } finally {
    window.clearTimeout(timeoutId);
  }
};

export const authStore = {
  init() {
    loadFromStorage();
  },
  bootstrap() {
    if (!bootstrapPromise) {
      bootstrapPromise = hydrateFromServer().finally(() => {
        bootstrapPromise = null;
      });
    }
    return bootstrapPromise;
  },
  setSession({
    tokenValue,
    userIdValue,
    roleValue,
    firstNameValue,
    lastNameValue,
    emailValue,
    phoneValue,
    avatarUrlValue,
  }) {
    state.token = tokenValue;
    state.payload = parseJwt(tokenValue);
    state.profile = {
      ...state.profile,
      id: userIdValue ?? state.profile.id,
      role: roleValue ?? state.profile.role ?? state.payload?.role ?? null,
      firstName: firstNameValue ?? state.profile.firstName,
      lastName: lastNameValue ?? state.profile.lastName,
      email: emailValue ?? state.profile.email,
      phone: phoneValue ?? state.profile.phone,
      avatarUrl: avatarUrlValue ?? state.profile.avatarUrl ?? null,
    };
    persist();
    emit();
  },
  setProfile(profileValue = {}) {
    state.profile = {
      ...state.profile,
      ...normalizeProfile(profileValue),
    };
    persist();
    emit();
  },
  get() {
    return state.token ?? localStorage.getItem(TOKEN_KEY);
  },
  getSession() {
    if (!sessionSnapshot) {
      sessionSnapshot = {
        token: state.token,
        payload: state.payload,
        profile: { ...state.profile },
        isExpired: this.isExpired(),
      };
    }
    return sessionSnapshot;
  },
  clear() {
    state.token = null;
    state.payload = null;
    state.profile = { ...emptyProfile };
    if (typeof window !== "undefined") {
      localStorage.removeItem(TOKEN_KEY);
      localStorage.removeItem(PROFILE_KEY);
    }
    emit();
  },
  isExpired() {
    const payload = state.payload ?? parseJwt(state.token ?? localStorage.getItem(TOKEN_KEY));
    if (!payload || !payload.exp) {
      return false;
    }
    return payload.exp * 1000 <= Date.now();
  },
  subscribe(listener) {
    listeners.add(listener);
    return () => listeners.delete(listener);
  },
};

if (typeof window !== "undefined") {
  window.addEventListener("storage", (event) => {
    if (event.key !== TOKEN_KEY && event.key !== PROFILE_KEY) return;
    loadFromStorage();
    emit();
  });
}

export const useAuthSession = () =>
  useSyncExternalStore(
    authStore.subscribe,
    () => authStore.getSession(),
    () => authStore.getSession(),
  );
