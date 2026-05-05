export const ROUTES_UPDATED_KEY = "i_metro_routes_updated_at";

export const signalRoutesUpdated = () => {
  const marker = new Date().toISOString();
  try {
    localStorage.setItem(ROUTES_UPDATED_KEY, marker);
  } catch {
    // Ignore storage failures; the backend refresh still keeps the UI correct.
  }
  window.dispatchEvent(new Event("i-metro:routes-updated"));
};
