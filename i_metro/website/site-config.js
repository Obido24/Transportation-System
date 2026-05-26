// Local preview uses the local API; production uses Contabo.
window.I_METRO_API_BASE_URL =
  window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'
    ? 'http://localhost:3000'
    : 'https://api.ridei-metro.com';
