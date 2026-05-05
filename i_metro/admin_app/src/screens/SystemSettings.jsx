import { useEffect, useRef, useState } from "react";

import HtmlScreen from "./HtmlScreen";
import { API_BASE_URL, fetchWithAuth } from "../lib/api";
import systemSettingsHtml from "./html/system_settings.html?raw";

const wrapperClassName = "min-h-screen";
const defaultSettings = {
  platformName: "Inter-Metro Transport Solution Limited",
  timezone: "UTC",
  maintenanceMode: false,
  baseFareMultiplier: 1.2,
  peakStrategy: "Dynamic",
  apiKey: "",
  webhookUrl: "",
  notifications: {
    emailAdminAlerts: true,
    slackIntegration: false,
    smsCriticalDelays: true,
    pushNotifications: true,
  },
  branding: {
    primaryColor: "#00513F",
    logoHint: "Upload the I-Metro logo (PNG or SVG)",
    logoFileName: "",
    logoDataUrl: "",
  },
  lastModified: "Last modified by I-Metro Admin",
  lastModifiedBy: "I-Metro Admin",
  lastModifiedAt: "",
  apiKeysRevokedAt: null,
};

const TIMEZONE_LABELS = {
  UTC: "UTC (Coordinated Universal Time)",
  WAT: "WAT (West Africa Time)",
  GMT: "GMT (Greenwich Mean Time)",
};

const normalizeHex = (value, fallback) => {
  const trimmed = `${value ?? ""}`.trim();
  if (/^#[0-9a-fA-F]{6}$/.test(trimmed)) return trimmed.toUpperCase();
  return fallback;
};

const normalizeStrategy = (value) => {
  const label = `${value ?? ""}`.trim();
  if (label === "Fixed" || label === "Disabled") {
    return label;
  }
  return "Dynamic";
};

const normalizeTimezone = (value) => {
  const text = `${value ?? ""}`.trim().toUpperCase();
  if (text.startsWith("WAT")) return "WAT";
  if (text.startsWith("GMT")) return "GMT";
  return "UTC";
};

const normalizeSettings = (settings = {}) => {
  const notifications = settings.notifications ?? {};
  const branding = settings.branding ?? {};
  const timezone = normalizeTimezone(settings.timezone);

  return {
    ...defaultSettings,
    ...settings,
    timezone,
    baseFareMultiplier:
      Number.isFinite(Number(settings.baseFareMultiplier)) && Number(settings.baseFareMultiplier) > 0
        ? Number(settings.baseFareMultiplier)
        : defaultSettings.baseFareMultiplier,
    peakStrategy: normalizeStrategy(settings.peakStrategy),
    maintenanceMode: Boolean(settings.maintenanceMode),
    webhookUrl: `${settings.webhookUrl ?? ""}`.trim(),
    apiKey: `${settings.apiKey ?? settings.apiKeyMasked ?? ""}`.trim(),
    notifications: {
      emailAdminAlerts:
        notifications.emailAdminAlerts ?? defaultSettings.notifications.emailAdminAlerts,
      slackIntegration: notifications.slackIntegration ?? defaultSettings.notifications.slackIntegration,
      smsCriticalDelays: notifications.smsCriticalDelays ?? defaultSettings.notifications.smsCriticalDelays,
      pushNotifications: notifications.pushNotifications ?? defaultSettings.notifications.pushNotifications,
    },
    branding: {
      primaryColor: normalizeHex(branding.primaryColor ?? settings.primaryColor, defaultSettings.branding.primaryColor),
      logoHint: branding.logoHint ?? defaultSettings.branding.logoHint,
      logoFileName: branding.logoFileName ?? defaultSettings.branding.logoFileName,
      logoDataUrl: branding.logoDataUrl ?? defaultSettings.branding.logoDataUrl,
    },
    lastModified: settings.lastModified ?? defaultSettings.lastModified,
    lastModifiedBy: settings.lastModifiedBy ?? defaultSettings.lastModifiedBy,
    lastModifiedAt: settings.lastModifiedAt ?? defaultSettings.lastModifiedAt,
    apiKeysRevokedAt: settings.apiKeysRevokedAt ?? defaultSettings.apiKeysRevokedAt,
  };
};

const settingsSummary = (settings) => ({
  ...settings,
  apiKeyMasked:
    settings.apiKey.length > 8
      ? `${settings.apiKey.slice(0, 4)}${"*".repeat(Math.max(4, settings.apiKey.length - 8))}${settings.apiKey.slice(-4)}`
      : settings.apiKey,
});

const getValidatorLaunchUrl = () => {
  if (typeof window === "undefined") {
    return "/validator";
  }
  const apiBase = API_BASE_URL.replace(/\/$/, "");
  const url = new URL(`${window.location.origin.replace(/\/$/, "")}/validator`);
  if (!/localhost|127\.0\.0\.1/i.test(apiBase)) {
    url.searchParams.set("apiBase", apiBase);
  }
  return url.toString();
};

function SystemSettings() {
  const containerRef = useRef(null);
  const baselineRef = useRef(normalizeSettings());
  const draftRef = useRef(normalizeSettings());
  const [statusMessage, setStatusMessage] = useState("Loading system settings...");
  const [statusTone, setStatusTone] = useState("info");
  const [isSaving, setIsSaving] = useState(false);
  const [validatorDevices, setValidatorDevices] = useState([]);
  const [validatorDeviceKey, setValidatorDeviceKey] = useState("");
  const [validatorDeviceName, setValidatorDeviceName] = useState("Gate Validator");
  const [validatorStatusMessage, setValidatorStatusMessage] = useState("No validator device key generated yet.");
  const validatorDeviceKeyRef = useRef("");
  const validatorDeviceNameRef = useRef("Gate Validator");
  const validatorStatusMessageRef = useRef("No validator device key generated yet.");

  const showStatus = (message, tone = "info") => {
    setStatusMessage(message);
    setStatusTone(tone);
  };

  const getNode = (selector) => containerRef.current?.querySelector(selector);
  const getNodes = (selector) => Array.from(containerRef.current?.querySelectorAll(selector) ?? []);

  const copyText = async (value) => {
    const text = `${value ?? ""}`.trim();
    if (!text) {
      throw new Error("No text available to copy");
    }
    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(text);
        return;
      }
    } catch {
      // Fall back to the legacy copy flow below.
    }

    const textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.setAttribute("readonly", "true");
    textarea.style.position = "fixed";
    textarea.style.left = "-9999px";
    textarea.style.top = "-9999px";
    document.body.appendChild(textarea);
    textarea.focus();
    textarea.select();
    const copied = document.execCommand("copy");
    document.body.removeChild(textarea);
    if (!copied) {
      throw new Error("Unable to copy text");
    }
  };

  const applyStrategyButtons = (strategy) => {
    const active = normalizeStrategy(strategy);
    getNodes('button[data-setting="peak-strategy"]').forEach((button) => {
      const value = normalizeStrategy(button.dataset.value);
      const isActive = value === active;
      button.classList.toggle("border-primary", isActive);
      button.classList.toggle("text-primary", isActive);
      button.classList.toggle("bg-primary/5", isActive);
      button.classList.toggle("border-transparent", !isActive);
      button.classList.toggle("text-on-surface-variant", !isActive);
      button.classList.toggle("bg-surface-container-high", !isActive);
    });
  };

  const updateDerivedFields = (settings) => {
    const multiplierLabel = getNode('[data-setting="peak-multiplier-label"]');
    const basePreview = getNode('[data-setting="preview-base-fare"]');
    const peakPreview = getNode('[data-setting="preview-peak-surcharge"]');
    const lastModified = getNode('[data-setting="last-modified"]');

    const multiplier = Number(settings.baseFareMultiplier) || defaultSettings.baseFareMultiplier;
    const standardFare = Math.round(600 * multiplier);
    const peakSurcharge = Math.round(150 * multiplier);

    if (multiplierLabel) {
      multiplierLabel.textContent = `${multiplier.toFixed(1)}x`;
    }
    if (basePreview) {
      basePreview.textContent = `NGN ${standardFare.toLocaleString("en-NG")}`;
    }
    if (peakPreview) {
      peakPreview.textContent = `+NGN ${peakSurcharge.toLocaleString("en-NG")}`;
    }
    if (lastModified) {
      const modifiedBy = settings.lastModifiedBy || "I-Metro Admin";
      const modifiedAt = settings.lastModifiedAt
        ? new Date(settings.lastModifiedAt).toLocaleString("en-GB", {
            day: "2-digit",
            month: "short",
            hour: "2-digit",
            minute: "2-digit",
          })
        : "";
      lastModified.textContent = modifiedAt
        ? `Last modified by ${modifiedBy} at ${modifiedAt}`
        : `Last modified by ${modifiedBy}`;
    }
  };

  const updateValidatorIntegrationDom = (devices, latestKey, message) => {
    const apiBase = API_BASE_URL.replace(/\/$/, "");
    const validatorUrl = getValidatorLaunchUrl();
    const validatorEndpoint = `${apiBase}/validators/validate-qr`;

    const setText = (selector, value) => {
      const node = getNode(selector);
      if (node) {
        node.textContent = value;
      }
    };

    setText("[data-setting='validator-api-base']", apiBase);
    setText("[data-setting='validator-launch-url']", validatorUrl);
    setText("[data-setting='validator-scan-endpoint']", validatorEndpoint);
    setText("[data-setting='validator-status']", message ?? validatorStatusMessage);

    const keyInput = getNode("[data-setting='validator-device-key']");
    if (keyInput) {
      keyInput.value = latestKey ?? validatorDeviceKey;
    }

    const nameInput = getNode("[data-setting='validator-device-name']");
    if (nameInput && !nameInput.value) {
      nameInput.value = validatorDeviceName;
    }

    const list = getNode("[data-setting='validator-device-list']");
    if (list) {
      if (!devices.length) {
        list.innerHTML = `
          <div class="rounded-xl bg-surface-container-low p-4 text-sm text-on-surface-variant">
            No validator devices yet. Generate a key for the first gate phone.
          </div>
        `;
      } else {
        list.innerHTML = devices
          .map((device) => {
            const lastSeen = device.lastSeenAt
              ? new Date(device.lastSeenAt).toLocaleString("en-NG", {
                  day: "2-digit",
                  month: "short",
                  year: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                })
              : "Never";
            return `
              <div class="rounded-xl bg-surface-container-low border border-outline-variant/10 p-4 flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                <div class="min-w-0">
                  <p class="text-sm font-bold text-on-surface">${device.name}</p>
                  <p class="text-xs text-on-surface-variant mt-1">Device ID: ${device.id}</p>
                  <p class="text-xs text-on-surface-variant">Last seen: ${lastSeen}</p>
                </div>
                <div class="flex flex-wrap gap-2 sm:justify-end">
                  <button data-action="rotate-validator-device" data-device-id="${device.id}" class="px-3 py-2 rounded-lg bg-primary text-on-primary text-xs font-bold hover:opacity-90 transition-opacity" type="button">
                    Rotate key
                  </button>
                  <button data-action="copy-validator-device-id" data-device-id="${device.id}" class="px-3 py-2 rounded-lg bg-surface-container-high text-on-surface text-xs font-bold hover:bg-surface-container-highest transition-colors" type="button">
                    Copy ID
                  </button>
                </div>
              </div>
            `;
          })
          .join("");
      }
    }
  };

  const loadValidatorDevices = async () => {
    try {
      const response = await fetchWithAuth("/validators/devices");
      const payload = await response.json();
      if (!response.ok) {
        throw new Error(payload?.message ?? "Unable to load validator devices");
      }
      const devices = Array.isArray(payload) ? payload : [];
      setValidatorDevices(devices);
      updateValidatorIntegrationDom(
        devices,
        validatorDeviceKeyRef.current,
        `${devices.length} validator device${devices.length === 1 ? "" : "s"} loaded.`,
      );
    } catch {
      setValidatorDevices([]);
      updateValidatorIntegrationDom(
        [],
        validatorDeviceKeyRef.current,
        validatorStatusMessageRef.current || "Unable to load validator devices right now.",
      );
    }
  };

  useEffect(() => {
    updateValidatorIntegrationDom(validatorDevices, validatorDeviceKey, validatorStatusMessage);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [validatorDevices, validatorDeviceKey, validatorStatusMessage]);

  useEffect(() => {
    validatorDeviceKeyRef.current = validatorDeviceKey;
    validatorDeviceNameRef.current = validatorDeviceName;
    validatorStatusMessageRef.current = validatorStatusMessage;
  }, [validatorDeviceKey, validatorDeviceName, validatorStatusMessage]);

  const applyBrandColor = (value) => {
    const color = normalizeHex(value, defaultSettings.branding.primaryColor);
    const swatch = getNode('[data-setting="brand-swatch"]');
    const code = getNode('[data-setting="brand-color-code"]');
    if (swatch) {
      swatch.style.backgroundColor = color;
    }
    if (code) {
      code.textContent = color;
    }
    draftRef.current.branding.primaryColor = color;
    return color;
  };

  const syncDraftToDom = (settings) => {
    const platformInput = getNode('[data-setting="platform-name"]');
    const timezoneSelect = getNode('[data-setting="timezone"]');
    const maintenanceToggle = getNode('[data-setting="maintenance-mode"]');
    const multiplierInput = getNode('[data-setting="base-fare-multiplier"]');
    const apiKeyInput = getNode('[data-setting="api-key"]');
    const webhookInput = getNode('[data-setting="webhook-endpoint"]');
    const emailAlerts = getNode('[data-setting="email-admin-alerts"]');
    const slackIntegration = getNode('[data-setting="slack-integration"]');
    const smsCriticalDelays = getNode('[data-setting="sms-critical-delays"]');
    const pushNotifications = getNode('[data-setting="mobile-push-notifications"]');
    const logoStatus = getNode('[data-setting="logo-status"]');
    const logoDropzone = getNode('[data-setting="logo-dropzone"]');
    const logoInput = getNode('[data-setting="logo-input"]');
    const colorCode = getNode('[data-setting="brand-color-code"]');

    if (platformInput) platformInput.value = settings.platformName;
    if (timezoneSelect) timezoneSelect.value = settings.timezone;
    if (maintenanceToggle) maintenanceToggle.checked = settings.maintenanceMode;
    if (multiplierInput) multiplierInput.value = String(settings.baseFareMultiplier);
    if (apiKeyInput) apiKeyInput.value = settings.apiKey;
    if (webhookInput) webhookInput.value = settings.webhookUrl;
    if (emailAlerts) emailAlerts.checked = settings.notifications.emailAdminAlerts;
    if (slackIntegration) slackIntegration.checked = settings.notifications.slackIntegration;
    if (smsCriticalDelays) smsCriticalDelays.checked = settings.notifications.smsCriticalDelays;
    if (pushNotifications) pushNotifications.checked = settings.notifications.pushNotifications;
    if (logoStatus) {
      logoStatus.innerHTML = settings.branding.logoFileName
        ? `${settings.branding.logoFileName}<br/><span class="text-[10px] opacity-60">Selected for save</span>`
        : 'Drop SVG or PNG here<br/><span class="text-[10px] opacity-60">Max size 2MB</span>';
    }
    if (logoDropzone) {
      logoDropzone.style.backgroundImage = settings.branding.logoDataUrl ? `url(${settings.branding.logoDataUrl})` : "";
      logoDropzone.style.backgroundRepeat = "no-repeat";
      logoDropzone.style.backgroundPosition = "center";
      logoDropzone.style.backgroundSize = "contain";
      logoDropzone.style.backgroundColor = settings.branding.logoDataUrl ? "rgba(255,255,255,0.92)" : "";
    }
    if (logoInput) {
      logoInput.value = "";
    }
    if (colorCode) {
      colorCode.textContent = settings.branding.primaryColor;
    }

    applyStrategyButtons(settings.peakStrategy);
    applyBrandColor(settings.branding.primaryColor);
    updateDerivedFields(settings);
  };

  const loadSettings = async () => {
    try {
      const response = await fetchWithAuth("/admin/system-settings");
      const payload = await response.json();
      if (!response.ok) {
        throw new Error(payload?.message ?? "Unable to load settings");
      }
      const next = normalizeSettings(payload);
      baselineRef.current = next;
      draftRef.current = { ...next, branding: { ...next.branding }, notifications: { ...next.notifications } };
      syncDraftToDom(draftRef.current);
      updateValidatorIntegrationDom(validatorDevices, validatorDeviceKey, validatorStatusMessage);
      void loadValidatorDevices();
      showStatus("System settings loaded.", "success");
    } catch {
      const fallback = settingsSummary(draftRef.current);
      baselineRef.current = normalizeSettings(fallback);
      draftRef.current = normalizeSettings(fallback);
      syncDraftToDom(draftRef.current);
      updateValidatorIntegrationDom(validatorDevices, validatorDeviceKey, validatorStatusMessage);
      void loadValidatorDevices();
      showStatus("Using local settings defaults.", "info");
    }
  };

  const saveSettings = async () => {
    if (isSaving) {
      return;
    }

    setIsSaving(true);
    try {
      const response = await fetchWithAuth("/admin/system-settings", {
        method: "PATCH",
        body: JSON.stringify(draftRef.current),
      });
      const payload = await response.json();
      if (!response.ok) {
        throw new Error(payload?.message ?? "Unable to save settings");
      }
      const next = normalizeSettings(payload);
      baselineRef.current = next;
      draftRef.current = { ...next, branding: { ...next.branding }, notifications: { ...next.notifications } };
      draftRef.current.revokeAllKeys = false;
      syncDraftToDom(draftRef.current);
      showStatus("System settings saved.", "success");
    } catch {
      showStatus("Unable to save settings right now.", "error");
    } finally {
      setIsSaving(false);
    }
  };

  const discardChanges = () => {
    draftRef.current = {
      ...baselineRef.current,
      branding: { ...baselineRef.current.branding },
      notifications: { ...baselineRef.current.notifications },
    };
    draftRef.current.revokeAllKeys = false;
    syncDraftToDom(draftRef.current);
    showStatus("Unsaved changes discarded.", "info");
  };

  useEffect(() => {
    const container = containerRef.current;
    if (!container) {
      return undefined;
    }

    const bindings = [];
    const bind = (selector, eventName, handler) => {
      const node = container.querySelector(selector);
      if (!node || node.dataset.bound === "true") {
        return;
      }
      node.dataset.bound = "true";
      node.addEventListener(eventName, handler);
      bindings.push(() => node.removeEventListener(eventName, handler));
    };

    bind('[data-setting="platform-name"]', "input", (event) => {
      draftRef.current.platformName = event.target.value;
    });

    bind('[data-setting="timezone"]', "change", (event) => {
      draftRef.current.timezone = normalizeTimezone(event.target.value);
      event.target.value = draftRef.current.timezone;
    });

    bind('[data-setting="maintenance-mode"]', "change", (event) => {
      draftRef.current.maintenanceMode = event.target.checked;
    });

    bind('[data-setting="base-fare-multiplier"]', "input", (event) => {
      const value = Number(event.target.value);
      draftRef.current.baseFareMultiplier = Number.isFinite(value) ? value : defaultSettings.baseFareMultiplier;
      updateDerivedFields(draftRef.current);
    });

    bind('[data-setting="webhook-endpoint"]', "input", (event) => {
      draftRef.current.webhookUrl = event.target.value;
    });

    bind('[data-setting="validator-device-name"]', "input", (event) => {
      setValidatorDeviceName(event.target.value || "Gate Validator");
    });

    bind('[data-setting="email-admin-alerts"]', "change", (event) => {
      draftRef.current.notifications.emailAdminAlerts = event.target.checked;
    });

    bind('[data-setting="slack-integration"]', "change", (event) => {
      draftRef.current.notifications.slackIntegration = event.target.checked;
    });

    bind('[data-setting="sms-critical-delays"]', "change", (event) => {
      draftRef.current.notifications.smsCriticalDelays = event.target.checked;
    });

    bind('[data-setting="mobile-push-notifications"]', "change", (event) => {
      draftRef.current.notifications.pushNotifications = event.target.checked;
    });

    bind('[data-setting="logo-input"]', "change", async (event) => {
      const file = event.target.files?.[0];
      if (!file) {
        return;
      }
      if (!["image/png", "image/svg+xml"].includes(file.type)) {
        showStatus("Please upload a PNG or SVG logo.", "error");
        event.target.value = "";
        return;
      }
      if (file.size > 2 * 1024 * 1024) {
        showStatus("Logo file is too large. Keep it under 2MB.", "error");
        event.target.value = "";
        return;
      }
      const dataUrl = await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = () => reject(new Error("Unable to read logo file"));
        reader.readAsDataURL(file);
      });
      draftRef.current.branding.logoDataUrl = `${dataUrl}`;
      draftRef.current.branding.logoFileName = file.name;
      const logoStatus = getNode('[data-setting="logo-status"]');
      const logoDropzone = getNode('[data-setting="logo-dropzone"]');
      if (logoStatus) {
        logoStatus.innerHTML = `${file.name}<br/><span class="text-[10px] opacity-60">Ready to save</span>`;
      }
      if (logoDropzone) {
        logoDropzone.style.backgroundImage = `url(${dataUrl})`;
        logoDropzone.style.backgroundRepeat = "no-repeat";
        logoDropzone.style.backgroundPosition = "center";
        logoDropzone.style.backgroundSize = "contain";
        logoDropzone.style.backgroundColor = "rgba(255,255,255,0.92)";
      }
      showStatus(`Logo "${file.name}" ready to save.`, "success");
    });

    const handleClick = async (event) => {
      const target = event.target.closest("[data-setting], [data-action]");
      if (!target || !container.contains(target)) {
        return;
      }

      const setting = target.dataset.setting;
      const action = target.dataset.action;

      if (setting === "peak-strategy") {
        const strategy = normalizeStrategy(target.dataset.value);
        draftRef.current.peakStrategy = strategy;
        applyStrategyButtons(strategy);
        showStatus(`Peak hour strategy set to ${strategy}.`, "success");
        return;
      }

      if (setting === "copy-api-key") {
        const apiKeyInput = getNode('[data-setting="api-key"]');
        const value = apiKeyInput?.value?.trim() ?? "";
        if (!value) {
          showStatus("No API key is available to copy.", "error");
          return;
        }
        try {
          await copyText(value);
          showStatus("API key copied to clipboard.", "success");
        } catch {
          showStatus("Unable to copy the API key right now.", "error");
        }
        return;
      }

      if (setting === "copy-validator-api-base") {
        try {
          await copyText(API_BASE_URL.replace(/\/$/, ""));
          setValidatorStatusMessage("API base copied to clipboard.");
        } catch {
          setValidatorStatusMessage("Unable to copy the API base right now.");
        }
        return;
      }

      if (setting === "copy-validator-launch-url") {
        try {
          await copyText(getValidatorLaunchUrl());
          setValidatorStatusMessage("Validator URL copied to clipboard.");
        } catch {
          setValidatorStatusMessage("Unable to copy the validator URL right now.");
        }
        return;
      }

      if (setting === "copy-validator-scan-endpoint") {
        try {
          await copyText(`${API_BASE_URL.replace(/\/$/, "")}/validators/validate-qr`);
          setValidatorStatusMessage("Scan endpoint copied to clipboard.");
        } catch {
          setValidatorStatusMessage("Unable to copy the scan endpoint right now.");
        }
        return;
      }

      if (setting === "test-webhook") {
        const endpoint = draftRef.current.webhookUrl.trim();
        if (!endpoint) {
          showStatus("Add a webhook endpoint before testing it.", "error");
          return;
        }
        try {
          new URL(endpoint);
        } catch {
          showStatus("That webhook URL is not valid.", "error");
          return;
        }
        try {
          await fetch(endpoint, { method: "HEAD", mode: "no-cors" });
          showStatus("Webhook test request sent.", "success");
        } catch {
          showStatus("Unable to reach the webhook endpoint.", "error");
        }
        return;
      }

      if (setting === "change-brand-color") {
        const next = window.prompt("Enter a brand color hex value:", draftRef.current.branding.primaryColor);
        if (!next) {
          return;
        }
        draftRef.current.branding.primaryColor = applyBrandColor(next);
        updateDerivedFields(draftRef.current);
        showStatus(`Brand color updated to ${draftRef.current.branding.primaryColor}.`, "success");
        return;
      }

      if (setting === "logo-dropzone") {
        const input = getNode('[data-setting="logo-input"]');
        input?.click();
        return;
      }

      if (setting === "revoke-all-keys") {
        const confirmed = window.confirm("Rotate the production API key? Any existing integrations will need the new key.");
        if (!confirmed) {
          return;
        }
        draftRef.current.apiKey = draftRef.current.apiKey || baselineRef.current.apiKey;
        showStatus("API key will be rotated when you save changes.", "info");
        draftRef.current.revokeAllKeys = true;
        return;
      }

      if (setting === "refresh-validator-devices") {
        await loadValidatorDevices();
        return;
      }

      if (setting === "create-validator-device") {
        const input = getNode('[data-setting="validator-device-name"]');
        const name = input?.value?.trim() || validatorDeviceNameRef.current || "Gate Validator";
        if (input && !input.value.trim()) {
          input.value = name;
        }
        try {
          const response = await fetchWithAuth("/validators/devices", {
            method: "POST",
            body: JSON.stringify({ name }),
          });
          const payload = await response.json();
          if (!response.ok) {
            throw new Error(payload?.message ?? "Unable to create validator device");
          }
          const nextKey = payload.apiKey ?? "";
          const nextMessage = `Validator device "${payload.name ?? name}" created. Copy the key now.`;
          validatorDeviceKeyRef.current = nextKey;
          validatorStatusMessageRef.current = nextMessage;
          setValidatorDeviceKey(nextKey);
          setValidatorStatusMessage(nextMessage);
          await loadValidatorDevices();
        } catch {
          validatorStatusMessageRef.current = "Unable to create a validator device right now.";
          setValidatorStatusMessage("Unable to create a validator device right now.");
        }
        return;
      }

      if (setting === "copy-validator-device-key") {
        const value = validatorDeviceKeyRef.current.trim();
        if (!value) {
          setValidatorStatusMessage("Generate a validator key first.");
          return;
        }
        try {
          await copyText(value);
          setValidatorStatusMessage("Validator key copied to clipboard.");
        } catch {
          setValidatorStatusMessage("Unable to copy the validator key right now.");
        }
        return;
      }

      if (action === "rotate-validator-device") {
        const deviceId = target.dataset.deviceId;
        if (!deviceId) return;
        try {
          const response = await fetchWithAuth("/validators/devices/rotate-key", {
            method: "POST",
            body: JSON.stringify({ deviceId }),
          });
          const payload = await response.json();
          if (!response.ok) {
            throw new Error(payload?.message ?? "Unable to rotate validator key");
          }
          const nextKey = payload.apiKey ?? "";
          const nextMessage = "Validator key rotated. Copy the new key now.";
          validatorDeviceKeyRef.current = nextKey;
          validatorStatusMessageRef.current = nextMessage;
          setValidatorDeviceKey(nextKey);
          setValidatorStatusMessage(nextMessage);
          await loadValidatorDevices();
        } catch {
          validatorStatusMessageRef.current = "Unable to rotate the validator key right now.";
          setValidatorStatusMessage("Unable to rotate the validator key right now.");
        }
        return;
      }

      if (action === "copy-validator-device-id") {
        const deviceId = target.dataset.deviceId ?? "";
        if (!deviceId) return;
        try {
          await copyText(deviceId);
          setValidatorStatusMessage("Validator device ID copied.");
        } catch {
          setValidatorStatusMessage("Unable to copy the validator device ID right now.");
        }
        return;
      }

      if (setting === "discard-changes") {
        discardChanges();
        return;
      }

      if (setting === "save-configuration" || setting === "floating-save") {
        await saveSettings();
      }
    };

    container.addEventListener("click", handleClick);
    bindings.push(() => container.removeEventListener("click", handleClick));

    void loadSettings();

    return () => {
      bindings.forEach((unbind) => unbind());
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <>
      {statusMessage && (
        <div
          className={`mb-4 rounded-lg px-4 py-2 text-sm ${
            statusTone === "success"
              ? "bg-primary-fixed-dim/15 text-primary"
              : statusTone === "error"
                ? "bg-error-container text-on-error-container"
                : "bg-surface-container-low text-on-surface-variant"
          }`}
        >
          {isSaving ? "Saving system settings..." : statusMessage}
        </div>
      )}
      <HtmlScreen
        html={systemSettingsHtml}
        title="System Settings"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
    </>
  );
}

export default SystemSettings;
