import { useEffect, useRef, useState } from "react";

import HtmlScreen from "./HtmlScreen";
import { fetchWithAuth } from "../lib/api";
import systemSettingsHtml from "./html/system_settings.html?raw";

const wrapperClassName = "min-h-screen";
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "/api";

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
  return `${window.location.origin.replace(/\/$/, "")}/validator`;
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

  const showStatus = (message, tone = "info") => {
    setStatusMessage(message);
    setStatusTone(tone);
  };

  const getNode = (selector) => containerRef.current?.querySelector(selector);
  const getNodes = (selector) => Array.from(containerRef.current?.querySelectorAll(selector) ?? []);

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
              <div class="rounded-xl bg-surface-container-low border border-outline-variant/10 p-4 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                <div>
                  <p class="text-sm font-bold text-on-surface">${device.name}</p>
                  <p class="text-xs text-on-surface-variant mt-1">Device ID: ${device.id}</p>
                  <p class="text-xs text-on-surface-variant">Last seen: ${lastSeen}</p>
                </div>
                <div class="flex flex-wrap gap-2">
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
      updateValidatorIntegrationDom(devices, validatorDeviceKey, `${devices.length} validator device${devices.length === 1 ? "" : "s"} loaded.`);
    } catch {
      setValidatorDevices([]);
      updateValidatorIntegrationDom([], validatorDeviceKey, "Unable to load validator devices right now.");
    }
  };

  useEffect(() => {
    updateValidatorIntegrationDom(validatorDevices, validatorDeviceKey, validatorStatusMessage);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [validatorDevices, validatorDeviceKey, validatorStatusMessage]);

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

    const bindMany = (selector, eventName, handlerFactory) => {
      getNodes(selector).forEach((node, index) => {
        if (node.dataset.bound === "true") {
          return;
        }
        node.dataset.bound = "true";
        const handler = handlerFactory(node, index);
        node.addEventListener(eventName, handler);
        bindings.push(() => node.removeEventListener(eventName, handler));
      });
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

    bindMany('button[data-setting="peak-strategy"]', "click", (node) => () => {
      const strategy = normalizeStrategy(node.dataset.value);
      draftRef.current.peakStrategy = strategy;
      applyStrategyButtons(strategy);
      showStatus(`Peak hour strategy set to ${strategy}.`, "success");
    });

    bind('[data-setting="copy-api-key"]', "click", async () => {
      const apiKeyInput = getNode('[data-setting="api-key"]');
      const value = apiKeyInput?.value?.trim() ?? "";
      if (!value) {
        showStatus("No API key is available to copy.", "error");
        return;
      }
      try {
        await navigator.clipboard.writeText(value);
        showStatus("API key copied to clipboard.", "success");
      } catch {
        showStatus("Unable to copy the API key right now.", "error");
      }
    });

    bind('[data-setting="copy-validator-api-base"]', "click", async () => {
      try {
        await navigator.clipboard.writeText(API_BASE_URL.replace(/\/$/, ""));
        setValidatorStatusMessage("API base copied to clipboard.");
      } catch {
        setValidatorStatusMessage("Unable to copy the API base right now.");
      }
    });

    bind('[data-setting="copy-validator-launch-url"]', "click", async () => {
      try {
        await navigator.clipboard.writeText(getValidatorLaunchUrl());
        setValidatorStatusMessage("Validator URL copied to clipboard.");
      } catch {
        setValidatorStatusMessage("Unable to copy the validator URL right now.");
      }
    });

    bind('[data-setting="copy-validator-scan-endpoint"]', "click", async () => {
      try {
        await navigator.clipboard.writeText(`${API_BASE_URL.replace(/\/$/, "")}/validators/validate-qr`);
        setValidatorStatusMessage("Scan endpoint copied to clipboard.");
      } catch {
        setValidatorStatusMessage("Unable to copy the scan endpoint right now.");
      }
    });

    bind('[data-setting="webhook-endpoint"]', "input", (event) => {
      draftRef.current.webhookUrl = event.target.value;
    });

    bind('[data-setting="test-webhook"]', "click", async () => {
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
    });

    bind('[data-setting="change-brand-color"]', "click", () => {
      const next = window.prompt("Enter a brand color hex value:", draftRef.current.branding.primaryColor);
      if (!next) {
        return;
      }
      draftRef.current.branding.primaryColor = applyBrandColor(next);
      updateDerivedFields(draftRef.current);
      showStatus(`Brand color updated to ${draftRef.current.branding.primaryColor}.`, "success");
    });

    bind('[data-setting="revoke-all-keys"]', "click", async () => {
      const confirmed = window.confirm("Rotate the production API key? Any existing integrations will need the new key.");
      if (!confirmed) {
        return;
      }
      draftRef.current.apiKey = draftRef.current.apiKey || baselineRef.current.apiKey;
      showStatus("API key will be rotated when you save changes.", "info");
      draftRef.current.revokeAllKeys = true;
    });

    bind('[data-setting="validator-device-name"]', "input", (event) => {
      setValidatorDeviceName(event.target.value || "Gate Validator");
    });

    bind('[data-setting="refresh-validator-devices"]', "click", async () => {
      await loadValidatorDevices();
    });

    bind('[data-setting="create-validator-device"]', "click", async () => {
      const input = getNode('[data-setting="validator-device-name"]');
      const name = input?.value?.trim() || validatorDeviceName || "Gate Validator";
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
        setValidatorDeviceKey(payload.apiKey ?? "");
        setValidatorStatusMessage(`Validator device "${payload.name ?? name}" created. Copy the key now.`);
        await loadValidatorDevices();
      } catch {
        setValidatorStatusMessage("Unable to create a validator device right now.");
      }
    });

    bind('[data-setting="copy-validator-device-key"]', "click", async () => {
      const value = validatorDeviceKey.trim();
      if (!value) {
        setValidatorStatusMessage("Generate a validator key first.");
        return;
      }
      try {
        await navigator.clipboard.writeText(value);
        setValidatorStatusMessage("Validator key copied to clipboard.");
      } catch {
        setValidatorStatusMessage("Unable to copy the validator key right now.");
      }
    });

    const deviceList = getNode('[data-setting="validator-device-list"]');
    const deviceHandler = async (event) => {
      const rotateButton = event.target.closest("button[data-action='rotate-validator-device']");
      if (rotateButton) {
        const deviceId = rotateButton.dataset.deviceId;
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
          setValidatorDeviceKey(payload.apiKey ?? "");
          setValidatorStatusMessage("Validator key rotated. Copy the new key now.");
          await loadValidatorDevices();
        } catch {
          setValidatorStatusMessage("Unable to rotate the validator key right now.");
        }
        return;
      }

      const copyIdButton = event.target.closest("button[data-action='copy-validator-device-id']");
      if (copyIdButton) {
        const deviceId = copyIdButton.dataset.deviceId ?? "";
        if (!deviceId) return;
        try {
          await navigator.clipboard.writeText(deviceId);
          setValidatorStatusMessage("Validator device ID copied.");
        } catch {
          setValidatorStatusMessage("Unable to copy the validator device ID right now.");
        }
      }
    };
    if (deviceList && !deviceList.dataset.bound) {
      deviceList.dataset.bound = "true";
      deviceList.addEventListener("click", deviceHandler);
      bindings.push(() => deviceList.removeEventListener("click", deviceHandler));
    }

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

    bind('[data-setting="logo-dropzone"]', "click", () => {
      const input = getNode('[data-setting="logo-input"]');
      input?.click();
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

    bind('[data-setting="discard-changes"]', "click", discardChanges);
    bind('[data-setting="save-configuration"]', "click", saveSettings);
    bind('[data-setting="floating-save"]', "click", saveSettings);

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
