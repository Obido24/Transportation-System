import { useEffect, useMemo, useRef, useState } from "react";
import { Link } from "react-router-dom";
import jsQR from "jsqr";

const storageKeys = {
  apiKey: "i_metro_validator_api_key",
  baseUrl: "i_metro_validator_base_url",
  busLabel: "i_metro_validator_bus_label",
  panel: "i_metro_validator_panel",
};

const defaultBaseUrl = import.meta.env.VITE_API_BASE_URL ?? "/api";
const defaultBusLabel = "Bus 1";
const busOptions = Array.from({ length: 20 }, (_, index) => `Bus ${index + 1}`);

const readStorage = (key, fallback = "") => {
  if (typeof window === "undefined") return fallback;
  return window.localStorage.getItem(key) ?? fallback;
};

const writeStorage = (key, value) => {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(key, value);
};

function formatLabel(value) {
  return String(value ?? "")
    .replace(/_/g, " ")
    .replace(/\b\w/g, (char) => char.toUpperCase());
}

export default function ValidatorWeb() {
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const detectorRef = useRef(null);
  const fileInputRef = useRef(null);
  const streamRef = useRef(null);
  const scanLoopRef = useRef(null);
  const busCopyTimeoutRef = useRef(null);
  const startCameraRef = useRef(null);
  const lastScanRef = useRef({ value: "", at: 0 });
  const busyRef = useRef(false);

  const [baseUrl, setBaseUrl] = useState(() => readStorage(storageKeys.baseUrl, defaultBaseUrl));
  const [apiKey, setApiKey] = useState(() => readStorage(storageKeys.apiKey, ""));
  const [busLabel, setBusLabel] = useState(() => readStorage(storageKeys.busLabel, defaultBusLabel));
  const [scanInput, setScanInput] = useState("");
  const [isCameraReady, setIsCameraReady] = useState(false);
  const [isScanning, setIsScanning] = useState(false);
  const [cameraError, setCameraError] = useState("");
  const [status, setStatus] = useState("idle");
  const [message, setMessage] = useState("Use the phone camera to scan a ticket QR.");
  const [result, setResult] = useState(null);
  const [history, setHistory] = useState([]);
  const [scanCount, setScanCount] = useState(0);
  const [acceptedCount, setAcceptedCount] = useState(0);
  const [rejectedCount, setRejectedCount] = useState(0);
  const [lastScanAt, setLastScanAt] = useState(null);
  const [showConnectionSettings, setShowConnectionSettings] = useState(false);
  const [selectedFileName, setSelectedFileName] = useState("");
  const [fileScanState, setFileScanState] = useState("");
  const [scanHint, setScanHint] = useState("Center the QR in the frame and hold steady.");
  const [isCompact, setIsCompact] = useState(false);
  const [isUltraCompact, setIsUltraCompact] = useState(false);
  const [mobilePanel, setMobilePanel] = useState(() => readStorage(storageKeys.panel, "none"));
  const [busCopied, setBusCopied] = useState(false);
  const [busLoaded, setBusLoaded] = useState(false);
  const autoStartAttemptedRef = useRef(false);
  const [cameraBooting, setCameraBooting] = useState(false);
  const busLogsPath = `/admin/validator-logs?bus=${encodeURIComponent(busLabel)}`;
  const mobileBusBadgeText = busLoaded ? busLabel : "Loading bus...";
  const desktopBusBadgeText = busLoaded ? `Assigned bus: ${busLabel}` : "Loading bus...";

  useEffect(() => {
    const updateCompact = () => {
      setIsCompact(window.innerWidth < 768);
      setIsUltraCompact(window.innerWidth < 380);
    };
    updateCompact();
    window.addEventListener("resize", updateCompact);
    return () => window.removeEventListener("resize", updateCompact);
  }, []);

  const canValidate = useMemo(
    () => Boolean(baseUrl.trim()) && Boolean(apiKey.trim()),
    [apiKey, baseUrl],
  );

  const getBarcodeDetector = () => {
    if (typeof window === "undefined" || !window.BarcodeDetector) {
      return null;
    }
    if (!detectorRef.current) {
      detectorRef.current = new window.BarcodeDetector({
        formats: ["qr_code", "code_128", "code_39", "ean_13"],
      });
    }
    return detectorRef.current;
  };

  const createCropCanvas = (source, crop) => {
    const canvas = document.createElement("canvas");
    const width = source.naturalWidth || source.videoWidth || source.width || 0;
    const height = source.naturalHeight || source.videoHeight || source.height || 0;

    if (!width || !height) {
      return null;
    }

    const x = Math.max(0, Math.min(width, Math.floor(crop.x)));
    const y = Math.max(0, Math.min(height, Math.floor(crop.y)));
    const w = Math.max(1, Math.min(width - x, Math.floor(crop.width)));
    const h = Math.max(1, Math.min(height - y, Math.floor(crop.height)));

    canvas.width = Math.max(1, Math.floor(w * (crop.scale ?? 1)));
    canvas.height = Math.max(1, Math.floor(h * (crop.scale ?? 1)));

    const ctx = canvas.getContext("2d");
    if (!ctx) {
      return null;
    }

    ctx.drawImage(source, x, y, w, h, 0, 0, canvas.width, canvas.height);
    return canvas;
  };

  const captureVideoFrame = (video) => {
    const width = video.videoWidth || 0;
    const height = video.videoHeight || 0;
    if (!width || !height) {
      return null;
    }

    const canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext("2d");
    if (!ctx) {
      return null;
    }

    ctx.drawImage(video, 0, 0, width, height);
    return canvas;
  };

  const getScanCandidates = (source) => {
    const width = source.naturalWidth || source.videoWidth || source.width || 0;
    const height = source.naturalHeight || source.videoHeight || source.height || 0;
    if (!width || !height) {
      return [source];
    }

    const shortest = Math.min(width, height);
    const squareSize = Math.floor(shortest * 0.92);
    const squareX = Math.floor((width - squareSize) / 2);
    const squareY = Math.floor((height - squareSize) / 2);
    const tightSize = Math.floor(shortest * 0.72);
    const tightX = Math.floor((width - tightSize) / 2);
    const tightY = Math.floor((height - tightSize) / 2);

    const candidates = [source];
    const crops = [
      { x: squareX, y: squareY, width: squareSize, height: squareSize, scale: 1.5 },
      { x: tightX, y: tightY, width: tightSize, height: tightSize, scale: 2 },
      { x: 0, y: 0, width: Math.floor(width * 0.75), height: Math.floor(height * 0.75), scale: 1.5 },
      {
        x: Math.floor(width * 0.25),
        y: Math.floor(height * 0.25),
        width: Math.floor(width * 0.75),
        height: Math.floor(height * 0.75),
        scale: 1.5,
      },
    ];

    crops.forEach((crop) => {
      const canvas = createCropCanvas(source, crop);
      if (canvas) {
        candidates.push(canvas);
      }
    });

    return candidates;
  };

  const detectQrValue = async (source) => {
    const detector = getBarcodeDetector();

    const candidates = getScanCandidates(source);
    for (const candidate of candidates) {
      if (detector) {
        const codes = await detector.detect(candidate);
        if (codes.length > 0 && codes[0]?.rawValue) {
          return codes[0].rawValue;
        }
      }

      const ctx = candidate.getContext?.("2d");
      const width = candidate.width || candidate.videoWidth || candidate.naturalWidth || 0;
      const height = candidate.height || candidate.videoHeight || candidate.naturalHeight || 0;
      if (!ctx || !width || !height) {
        continue;
      }

      const imageData = ctx.getImageData(0, 0, width, height);
      const decoded = jsQR(imageData.data, width, height, {
        inversionAttempts: "attemptBoth",
      });
      if (decoded?.data) {
        return decoded.data;
      }
    }

    return null;
  };

  useEffect(() => {
    writeStorage(storageKeys.baseUrl, baseUrl);
  }, [baseUrl]);

  useEffect(() => {
    writeStorage(storageKeys.apiKey, apiKey);
  }, [apiKey]);

  useEffect(() => {
    writeStorage(storageKeys.busLabel, busLabel);
  }, [busLabel]);

  useEffect(() => {
    writeStorage(storageKeys.panel, mobilePanel);
    setShowConnectionSettings(mobilePanel === "setup");
  }, [mobilePanel]);

  useEffect(() => {
    setBusLoaded(true);
  }, []);

  useEffect(() => {
    const savedBus = readStorage(storageKeys.busLabel, "");
    if (!savedBus) {
      writeStorage(storageKeys.busLabel, defaultBusLabel);
      setBusLabel(defaultBusLabel);
    }
    const savedPanel = readStorage(storageKeys.panel, "none");
    setMobilePanel(savedPanel || "none");
    setShowConnectionSettings(savedPanel === "setup");
  }, []);

  useEffect(() => {
    if (!isCompact) return;
    setMobilePanel("none");
    setShowConnectionSettings(false);
  }, [isCompact]);

  useEffect(() => {
    if (!isCompact || !busLoaded || isCameraReady || isScanning || autoStartAttemptedRef.current) {
      return;
    }

    autoStartAttemptedRef.current = true;
    setCameraBooting(true);
    const timer = window.setTimeout(() => {
      startCameraRef.current?.();
    }, 250);

    return () => window.clearTimeout(timer);
  }, [busLoaded, isCameraReady, isCompact, isScanning]);

  useEffect(() => {
    return () => {
      stopCamera();
      if (busCopyTimeoutRef.current) {
        window.clearTimeout(busCopyTimeoutRef.current);
      }
    };
  }, []);

  const pushHistory = (entry) => {
    setHistory((current) => [entry, ...current].slice(0, 10));
  };

  const stopCamera = () => {
    if (scanLoopRef.current) {
      cancelAnimationFrame(scanLoopRef.current);
      scanLoopRef.current = null;
    }
    const stream = streamRef.current;
    if (stream) {
      stream.getTracks().forEach((track) => track.stop());
      streamRef.current = null;
    }
    setIsCameraReady(false);
    setIsScanning(false);
    setCameraBooting(false);
    setScanHint("Center the QR in the frame and hold steady.");
  };

  const validateQr = async (qrValue, source = "camera") => {
    const value = String(qrValue ?? "").trim();
    if (!value) {
      return;
    }

    const now = Date.now();
    if (lastScanRef.current.value === value && now - lastScanRef.current.at < 1500) {
      setStatus("invalid");
      setResult({
        valid: false,
        reason: "duplicate_scan",
        raw: { duplicate: true },
      });
      setMessage("Same QR is still in frame. Move to a new ticket.");
      setScanHint("Move the QR away or present a different ticket.");
      return false;
    }
    lastScanRef.current = { value, at: now };

    if (busyRef.current) return;
    busyRef.current = true;

    setStatus("checking");
    setMessage(`Checking ${source} scan...`);
    setScanHint("Processing scan...");
    setResult(null);
    setLastScanAt(new Date().toISOString());
    setScanCount((current) => current + 1);

    try {
      const response = await fetch(`${baseUrl.replace(/\/$/, "")}/validators/validate-qr`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey.trim(),
        },
        body: JSON.stringify({ code: value, busLabel }),
      });
      const data = await response.json();
      const isValid = Boolean(data?.valid);

      const nextResult = {
        valid: isValid,
        reason: data?.reason ?? null,
        ticketId: data?.ticketId ?? null,
        routeId: data?.routeId ?? null,
        userId: data?.userId ?? null,
        validDate: data?.validDate ?? null,
        busLabel: data?.busLabel ?? busLabel,
        raw: data,
      };

      setResult(nextResult);
      setStatus(isValid ? "valid" : "invalid");
      setAcceptedCount((current) => current + (isValid ? 1 : 0));
      setRejectedCount((current) => current + (isValid ? 0 : 1));
      setMessage(
        isValid
          ? `Gate opened${data?.busLabel ? ` on ${data.busLabel}` : busLabel ? ` on ${busLabel}` : ""} for ticket${data?.ticketId ? ` #${String(data.ticketId).slice(0, 8).toUpperCase()}` : ""}.`
          : `Access denied${data?.reason ? `: ${formatLabel(data.reason)}` : ""}.`,
      );
      pushHistory({
        at: new Date().toISOString(),
        payload: value,
        valid: isValid,
        reason: data?.reason ?? null,
        busLabel: data?.busLabel ?? busLabel,
      });

      if (isValid) {
        stopCamera();
      } else {
        setScanHint("Try moving the QR closer and keep it flat to the camera.");
      }
      return isValid;
    } catch (error) {
      setStatus("error");
      setMessage("Network error while validating the QR.");
      setScanHint("Check the network and try scanning again.");
      setResult({
        valid: false,
        reason: "network_error",
        raw: { error: error?.message ?? "unknown_error" },
      });
      pushHistory({
        at: new Date().toISOString(),
        payload: value,
        valid: false,
        reason: "network_error",
      });
      return false;
    } finally {
      busyRef.current = false;
    }
  };

  const scanFrame = async () => {
    if (!isScanning || !videoRef.current) return;
    const video = videoRef.current;

    try {
      const frame = captureVideoFrame(video);
      if (!frame) {
        return;
      }

      if (getBarcodeDetector()) {
        const qrValue = await detectQrValue(frame);
        if (qrValue) {
          await validateQr(qrValue, "camera");
        }
      } else if (canvasRef.current && video.readyState >= 2) {
        const canvas = canvasRef.current;
        const ctx = canvas.getContext("2d");
        if (ctx) {
          canvas.width = video.videoWidth;
          canvas.height = video.videoHeight;
          ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
        }
      }
    } catch (error) {
      setCameraError(error?.message ?? "Unable to scan with this browser.");
    } finally {
      if (isScanning) {
        scanLoopRef.current = requestAnimationFrame(scanFrame);
      }
    }
  };

  const startCamera = async () => {
    setCameraError("");
    setMessage("Starting camera...");
    setScanHint("Hold the QR inside the frame. Good lighting helps a lot.");

    if (!navigator.mediaDevices?.getUserMedia) {
      setStatus("error");
      setCameraError("This browser does not support camera access.");
      return;
    }

    try {
      stopCamera();
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: { ideal: "environment" },
        },
        audio: false,
      });
      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
      }
      setIsScanning(true);
      setIsCameraReady(true);
      setCameraBooting(false);
      setStatus("idle");
      if (baseUrl.trim() && apiKey.trim()) {
        setMessage("Camera ready. Point it at the QR code.");
        setScanHint(`Keep the QR centered on ${busLabel}. If it does not read, move closer.`);
      } else {
        setMessage("Camera ready. Finish the backend URL and validator key setup to enable scans.");
        setScanHint("Camera is open, but validation still needs the integration details from Settings.");
      }
      scanLoopRef.current = requestAnimationFrame(scanFrame);
    } catch (error) {
      setStatus("error");
      setCameraBooting(false);
      setCameraError(error?.message ?? "Unable to open the camera.");
      setMessage("Camera failed to start.");
      setScanHint("Try another camera or use manual verify.");
    }
  };
  startCameraRef.current = startCamera;

  const handleManualValidate = async (event) => {
    event.preventDefault();
    await validateQr(scanInput, "manual");
  };

  const handleChangeBus = () => {
    setShowConnectionSettings(true);
    setMobilePanel("setup");
    setMessage("Open setup to change the active bus.");
    setScanHint("Pick the new bus and keep scanning.");
  };

  const handleCopyBusLabel = async () => {
    const text = busLabel.trim();
    if (!text) return;

    try {
      await navigator.clipboard.writeText(text);
      setBusCopied(true);
      if (busCopyTimeoutRef.current) {
        window.clearTimeout(busCopyTimeoutRef.current);
      }
      busCopyTimeoutRef.current = window.setTimeout(() => {
        setBusCopied(false);
      }, 1500);
    } catch {
      setMessage("Unable to copy bus label.");
    }
  };

  const detectFromSource = async (source, label = "image") => {
    try {
      setMessage(`Scanning ${label} on ${busLabel}...`);
      const qrValue = await detectQrValue(source);
      if (!qrValue) {
        setStatus("invalid");
        setMessage(`No QR detected in ${label}. Try a clearer image.`);
        return;
      }
      await validateQr(qrValue, label);
    } catch (error) {
      setStatus("error");
      setMessage(`Unable to decode ${label}.`);
      setCameraError(error?.message ?? "Unable to decode image.");
    }
  };

  const handleFileScan = async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    setSelectedFileName(file.name);
    setFileScanState("loading");

    try {
      const url = URL.createObjectURL(file);
      const image = new Image();
      image.onload = async () => {
        try {
          await detectFromSource(image, "image");
          setFileScanState("done");
        } finally {
          URL.revokeObjectURL(url);
        }
      };
      image.onerror = () => {
        URL.revokeObjectURL(url);
        setFileScanState("error");
        setStatus("error");
        setMessage("Unable to load image.");
      };
      image.src = url;
    } finally {
      event.target.value = "";
    }
  };

  const statusTone =
    status === "valid"
      ? "bg-[#00513f] text-white shadow-[0_25px_70px_rgba(0,81,63,0.45)]"
      : status === "invalid"
        ? "bg-rose-500 text-white shadow-[0_25px_70px_rgba(244,63,94,0.45)]"
        : status === "checking"
          ? "bg-[#0b6b54] text-white shadow-[0_25px_70px_rgba(11,107,84,0.42)]"
          : "bg-white/95 text-slate-900 border border-emerald-100";

  const statusLabel =
    status === "valid" ? "VALID" : status === "invalid" ? "INVALID" : status === "checking" ? "SCANNING" : "READY";

  const statusHeadline =
    status === "valid"
      ? "ACCESS GRANTED"
      : status === "invalid"
        ? "ACCESS DENIED"
        : status === "checking"
          ? "VERIFYING QR"
          : "READY TO SCAN";

  if (isCompact) {
    return (
      <div className="min-h-screen overflow-x-hidden bg-[radial-gradient(circle_at_top,#fff7ed_0%,#eff6ff_35%,#dbeafe_100%)] text-slate-900">
        <div className="mx-auto flex min-h-screen w-full max-w-[430px] flex-col gap-4 px-3 py-3">
          <header className="flex items-center justify-between gap-3 rounded-[1.75rem] border border-slate-200 bg-[#0b1220] px-3 py-3 text-white shadow-[0_18px_50px_rgba(15,23,42,0.18)] backdrop-blur">
            <div className="flex items-center gap-2">
              <div className="h-11 w-11 overflow-hidden rounded-xl bg-white p-1 shadow-sm">
                <img
                  alt="I-Metro logo"
                  className="h-full w-full object-contain"
                  src="/brand/imetro_logo.png"
                  onError={(event) => {
                    event.currentTarget.style.display = "none";
                  }}
                />
              </div>
              <div>
                <p className="text-[10px] uppercase tracking-[0.3em] text-sky-100/75">
                  Gate Validator
                </p>
                <h1 className="text-base font-black tracking-tight text-white">I-Metro QR Validator</h1>
                <div className="mt-2 flex flex-wrap items-center gap-2">
                  <Link
                    className={`inline-flex items-center rounded-full border border-amber-300/30 bg-amber-300/15 transition hover:bg-amber-300/25 ${
                      isUltraCompact ? "p-2" : "max-w-[180px] gap-1.5 px-2.5 py-1 text-[10px] font-semibold"
                    } text-amber-50`}
                    title="Open bus scan logs"
                    to={busLogsPath}
                  >
                    <span className={`material-symbols-outlined ${isUltraCompact ? "text-[14px]" : "text-[12px]"}`}>
                      directions_bus
                    </span>
                    {!isUltraCompact ? <span className="truncate">{mobileBusBadgeText}</span> : null}
                  </Link>
                  <button
                    className="inline-flex items-center gap-1.5 rounded-full border border-amber-300/25 bg-amber-300/15 px-2.5 py-1 text-[10px] font-semibold text-amber-50 transition hover:bg-amber-300/25"
                    onClick={handleCopyBusLabel}
                    type="button"
                  >
                    <span className="material-symbols-outlined text-[12px]">content_copy</span>
                    <span>{busCopied ? "Copied" : "Copy bus"}</span>
                  </button>
                </div>
                <button
                  className="inline-flex items-center gap-1.5 rounded-full border border-amber-300/25 bg-amber-300/15 px-2.5 py-1 text-[10px] font-semibold text-amber-50 transition hover:bg-amber-300/25"
                  onClick={handleChangeBus}
                  type="button"
                >
                  <span className="material-symbols-outlined text-[12px]">swap_horiz</span>
                  <span>Change bus</span>
                </button>
                <p className="text-[10px] text-slate-300">
                  Camera first. Bus assignment stays saved on this phone.
                </p>
              </div>
            </div>
            <Link
              className="rounded-full border border-amber-300/25 bg-amber-300 px-3 py-2 text-[11px] font-semibold text-slate-950 shadow-sm transition hover:bg-amber-200"
              to="/admin/login"
            >
              Admin Login
            </Link>
          </header>

          <section className="rounded-[1.6rem] border border-white/80 bg-white/92 px-4 py-4 text-slate-900 shadow-[0_18px_55px_rgba(15,23,42,0.08)]">
            <p className="text-[10px] font-bold uppercase tracking-[0.35em] text-[#00513f]">
              Live scan
            </p>
            <h2 className="mt-2 text-2xl font-black tracking-tight text-slate-950">Scan a passenger QR</h2>
            <p className="mt-2 text-sm leading-6 text-slate-600">
              Open this page on the gate phone, allow camera access, and point it at the ticket QR.
            </p>
            <div className={`mt-4 rounded-2xl px-4 py-3 text-sm font-semibold ${statusTone}`}>
              {statusLabel} • {statusHeadline}
            </div>
          </section>

          <section className={`rounded-[1.6rem] border px-4 py-4 ${statusTone}`}>
            <p className="text-xs font-semibold uppercase tracking-[0.35em] opacity-80">
              {statusLabel}
            </p>
            <h3 className="mt-2 text-2xl font-black">{statusHeadline}</h3>
            <p className="mt-2 text-sm leading-6 opacity-90">{message}</p>
            {lastScanAt ? (
              <p className="mt-3 text-[11px] uppercase tracking-[0.28em] opacity-80">
                Last scan: {new Date(lastScanAt).toLocaleString("en-NG")}
              </p>
            ) : null}
          </section>

          <section className="rounded-[1.6rem] border border-slate-200 bg-white/92 p-3 text-slate-900 shadow-[0_18px_55px_rgba(15,23,42,0.08)]">
            <div className="mb-3 flex items-center justify-between gap-3">
              <div>
                <p className="text-[10px] uppercase tracking-[0.28em] text-slate-500">Camera</p>
                <p className="mt-1 text-sm text-slate-500">
                  {isCameraReady ? "Camera is live" : "Camera is off"}
                </p>
              </div>
              <div className="flex gap-2">
                <button
                  className="rounded-full border border-[#1d4ed8] bg-[#1d4ed8] px-3 py-2 text-xs font-semibold text-white shadow-sm transition hover:bg-[#1e40af]"
                  onClick={startCamera}
                  type="button"
                >
                  Start
                </button>
                <button
                  className="rounded-full border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700 transition hover:bg-slate-50"
                  onClick={stopCamera}
                  type="button"
                >
                  Stop
                </button>
              </div>
            </div>

                <div className="relative overflow-hidden rounded-[1.25rem] border border-white/10 bg-black">
                  <video
                    ref={videoRef}
                    className={`${isUltraCompact ? "h-[320px]" : "h-[260px]"} w-full object-cover`}
                    muted
                    playsInline
                  />
                  {cameraBooting && !isCameraReady ? (
                    <div className="absolute inset-0 flex items-center justify-center bg-[#061512]/80 backdrop-blur-sm">
                      <div className="rounded-2xl border border-emerald-300/20 bg-white/5 px-4 py-3 text-center">
                        <p className="text-[10px] font-bold uppercase tracking-[0.32em] text-emerald-200/70">
                          Starting camera
                        </p>
                        <p className="mt-1 text-sm font-semibold text-white/90">
                          Hold on while we open the scan view...
                        </p>
                      </div>
                    </div>
                  ) : null}
                  <div className="pointer-events-none absolute inset-0">
                    <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(59,130,246,0.10),rgba(0,0,0,0.02)_35%,rgba(0,0,0,0.34)_78%,rgba(0,0,0,0.52))]" />
                    <div className="absolute inset-0 flex items-center justify-center">
                  <div
                    className={`relative rounded-3xl border border-emerald-300/55 shadow-[0_0_0_9999px_rgba(0,0,0,0.16)] ${
                      isUltraCompact ? "h-48 w-48" : "h-40 w-40"
                    }`}
                  >
                    <div className={`absolute left-3 right-3 top-3 ${isUltraCompact ? "h-7" : "h-6"} rounded-t-2xl border-t border-l border-r border-emerald-300/70`} />
                    <div className={`absolute bottom-3 left-3 right-3 ${isUltraCompact ? "h-7" : "h-6"} rounded-b-2xl border-b border-l border-r border-emerald-300/70`} />
                    <div className={`absolute left-3 top-3 bottom-3 ${isUltraCompact ? "w-7" : "w-6"} rounded-l-2xl border-l border-t border-b border-emerald-300/70`} />
                    <div className={`absolute right-3 top-3 bottom-3 ${isUltraCompact ? "w-7" : "w-6"} rounded-r-2xl border-r border-t border-b border-emerald-300/70`} />
                    <div className="absolute inset-x-6 top-1/2 h-1 -translate-y-1/2 rounded-full bg-emerald-300/60 shadow-[0_0_24px_rgba(110,231,183,0.8)] animate-pulse" />
                  </div>
                </div>
              </div>
            </div>

            <div className="mt-3 rounded-2xl border border-slate-200 bg-[#f8fafc] px-3 py-3 text-sm text-slate-700">
              {message}
            </div>
            {cameraError ? (
              <div className="mt-2 rounded-2xl border border-rose-400/20 bg-rose-500/10 px-3 py-3 text-sm text-rose-700">
                {cameraError}
              </div>
            ) : null}

            <div className="mt-3 rounded-2xl border border-indigo-100 bg-indigo-50 px-3 py-3 text-sm text-slate-700">
              <p className="text-[10px] font-semibold uppercase tracking-[0.25em] text-indigo-700">
                Scan tip
              </p>
              <p className="mt-1">{scanHint}</p>
            </div>
          </section>

          <section className="rounded-[1.6rem] bg-white/80 p-3 text-slate-900 shadow-[0_18px_45px_rgba(15,23,42,0.06)]">
            <div className="grid grid-cols-2 gap-2">
              <button
                className="rounded-2xl border border-slate-200 bg-white px-3 py-3 text-xs font-bold uppercase tracking-[0.2em] text-slate-900"
                onClick={() => setMobilePanel((current) => (current === "setup" ? "none" : "setup"))}
                type="button"
              >
                Setup
              </button>
              <button
                className="rounded-2xl border border-slate-200 bg-white px-3 py-3 text-xs font-bold uppercase tracking-[0.2em] text-slate-900"
                onClick={() => setMobilePanel((current) => (current === "tools" ? "none" : "tools"))}
                type="button"
              >
                Tools
              </button>
            </div>

            {mobilePanel === "tools" ? (
              <div className="mt-3 rounded-2xl border border-slate-200 bg-white p-3 shadow-sm">
                <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                  Backup tools
                </p>
                <p className="mt-2 text-sm text-slate-600">
                  Camera is the main way to validate. Use these only if needed.
                </p>
                <div className="mt-3 grid grid-cols-3 gap-2">
                  <button
                    className="rounded-2xl border border-slate-200 bg-slate-50 px-3 py-3 text-xs font-bold uppercase tracking-[0.18em] text-slate-800"
                    onClick={() => setMobilePanel("manual")}
                    type="button"
                  >
                    Manual
                  </button>
                  <button
                    className="rounded-2xl border border-slate-200 bg-slate-50 px-3 py-3 text-xs font-bold uppercase tracking-[0.18em] text-slate-800"
                    onClick={() => setMobilePanel("image")}
                    type="button"
                  >
                    Upload
                  </button>
                  <button
                    className="rounded-2xl border border-slate-200 bg-slate-50 px-3 py-3 text-xs font-bold uppercase tracking-[0.18em] text-slate-800"
                    onClick={() => setMobilePanel("history")}
                    type="button"
                  >
                    History
                  </button>
                </div>
              </div>
            ) : null}

            {mobilePanel === "setup" ? (
              <div className="mt-3 space-y-3 rounded-2xl border border-slate-200 bg-white p-3">
                <label className="block">
                  <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.22em] text-slate-500">
                    Backend URL
                  </span>
                  <input
                    className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-[#1d4ed8]"
                    value={baseUrl}
                    onChange={(event) => setBaseUrl(event.target.value)}
                    placeholder="/api"
                  />
                </label>
                <label className="block">
                  <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.22em] text-slate-500">
                    Validator API Key
                  </span>
                  <input
                    className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-[#1d4ed8]"
                    value={apiKey}
                    onChange={(event) => setApiKey(event.target.value)}
                    placeholder="vk_..."
                  />
                </label>
                <label className="block">
                  <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.22em] text-slate-500">
                    Bus assignment
                  </span>
                  <select
                    className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-[#1d4ed8]"
                    value={busLabel}
                    onChange={(event) => setBusLabel(event.target.value)}
                  >
                    {busOptions.map((option) => (
                      <option key={option} value={option}>
                        {option}
                      </option>
                    ))}
                  </select>
                </label>
              </div>
            ) : null}

            {mobilePanel === "manual" ? (
              <div className="mt-3 rounded-2xl border border-slate-200 bg-white p-3 shadow-sm">
                <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                  Manual verify
                </p>
                <form className="mt-3 space-y-3" onSubmit={handleManualValidate}>
                  <textarea
                    className="min-h-[120px] w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
                    value={scanInput}
                    onChange={(event) => setScanInput(event.target.value)}
                    placeholder="Paste the QR payload, ticket ID, or payment reference here."
                  />
                  <button
                    className="w-full rounded-2xl bg-[#1d4ed8] px-4 py-3 text-sm font-bold text-white transition hover:bg-[#1e40af] disabled:cursor-not-allowed disabled:opacity-60"
                    disabled={!canValidate || !scanInput.trim() || status === "checking"}
                    type="submit"
                  >
                    {status === "checking" ? "Checking..." : "Validate QR"}
                  </button>
                </form>
              </div>
            ) : null}

            {mobilePanel === "image" ? (
              <div className="mt-3 rounded-2xl border border-slate-200 bg-white p-3 shadow-sm">
                <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                  Image fallback
                </p>
                <p className="mt-2 text-sm text-slate-600">
                  Upload a clear QR image or screenshot if the camera struggles.
                </p>
                <input
                  ref={fileInputRef}
                  accept="image/*,.png,.jpg,.jpeg,.webp"
                  capture="environment"
                  className="mt-3 block w-full rounded-2xl border border-dashed border-slate-300 bg-white px-4 py-3 text-sm text-slate-700 file:mr-4 file:rounded-full file:border-0 file:bg-[#7c3aed] file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white hover:file:bg-[#6d28d9]"
                  onChange={handleFileScan}
                  type="file"
                />
                <p className="mt-2 text-xs text-slate-500">
                  {selectedFileName
                    ? `Selected: ${selectedFileName}${fileScanState === "loading" ? " (processing...)" : ""}`
                    : "Choose a QR image or screenshot from your device."}
                </p>
                {fileScanState === "error" ? (
                  <p className="mt-1 text-xs font-semibold text-rose-600">
                    The image could not be read. Try a tighter crop of just the QR code.
                  </p>
                ) : null}
              </div>
            ) : null}

            {mobilePanel === "history" ? (
              <div className="mt-3 rounded-2xl border border-slate-200 bg-white p-3 shadow-sm">
                <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                  Recent scans
                </p>
                <div className="mt-3 max-h-52 space-y-2 overflow-y-auto pr-1">
                  {history.length === 0 ? (
                    <p className="text-sm text-slate-500">No scans yet.</p>
                  ) : (
                    history.map((entry) => (
                      <div
                        key={`${entry.at}-${entry.payload.slice(0, 12)}`}
                        className="rounded-2xl border border-slate-200 bg-white px-3 py-3"
                      >
                        <div className="flex items-center justify-between gap-3">
                          <p className="truncate text-sm font-semibold text-slate-900">
                            {entry.payload}
                          </p>
                          <span
                            className={`rounded-full px-2.5 py-1 text-[11px] font-bold ${
                              entry.valid
                                ? "bg-emerald-100 text-emerald-900"
                                : "bg-rose-100 text-rose-900"
                            }`}
                          >
                            {entry.valid ? "Valid" : "Invalid"}
                          </span>
                        </div>
                        <p className="mt-1 text-xs text-slate-500">
                          {new Date(entry.at).toLocaleTimeString("en-NG", {
                            hour: "2-digit",
                            minute: "2-digit",
                          })}
                          {entry.reason ? ` • ${formatLabel(entry.reason)}` : ""}
                        </p>
                      </div>
                    ))
                  )}
                </div>
              </div>
            ) : null}
          </section>

          <section className="rounded-[1.6rem] bg-white/80 p-3 text-slate-900 shadow-[0_18px_45px_rgba(15,23,42,0.06)]">
            <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
              Validation result
            </p>
            <div className="mt-3 rounded-2xl border border-slate-200 bg-white p-3 shadow-sm">
              {!result ? (
                <p className="text-sm text-slate-500">No scan has been checked yet.</p>
              ) : (
                <div className="space-y-2 text-sm">
                  <p className="font-bold text-slate-900">
                    {result.valid ? "Ticket accepted" : "Ticket rejected"}
                  </p>
                  <p className="text-slate-600">
                    {result.reason ? formatLabel(result.reason) : "Verified against backend"}
                  </p>
                  {result.busLabel ? (
                    <p className="text-slate-500">Bus: {result.busLabel}</p>
                  ) : null}
                </div>
              )}
            </div>
          </section>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#061512] text-white">
      <div className="mx-auto flex min-h-screen w-full max-w-7xl flex-col px-4 py-5 md:px-6">
        <header className="mb-5 flex items-center justify-between gap-4 rounded-3xl border border-white/10 bg-white/5 px-4 py-4 backdrop-blur md:px-6">
              <div className="flex items-center gap-3">
            <div className="h-14 w-14 overflow-hidden rounded-2xl bg-white p-1.5">
              <img
                alt="I-Metro logo"
                className="h-full w-full object-contain"
                src="/brand/imetro_logo.png"
                onError={(event) => {
                  event.currentTarget.style.display = "none";
                }}
              />
            </div>
            <div>
              <p className="text-xs uppercase tracking-[0.35em] text-emerald-200/70">
                Gate Validator
              </p>
              <h1 className="text-lg font-semibold md:text-2xl">I-Metro QR Validator</h1>
              <div className="mt-2 flex flex-wrap items-center gap-2">
                <Link
                  className="inline-flex items-center gap-2 rounded-full border border-emerald-400/25 bg-emerald-400/10 px-3 py-1 text-xs font-semibold text-emerald-100 transition hover:bg-emerald-400/20"
                  title="Open bus scan logs"
                  to={busLogsPath}
                >
                  <span className="material-symbols-outlined text-[14px]">directions_bus</span>
                  <span>
                    {desktopBusBadgeText}
                  </span>
                </Link>
                {busLoaded ? (
                  <span className="inline-flex items-center rounded-full border border-white/10 bg-white/5 px-3 py-1 text-[11px] font-semibold text-emerald-100/75">
                    Saved locally
                  </span>
                ) : null}
                <button
                  className="inline-flex items-center gap-2 rounded-full border border-emerald-400/20 bg-white/5 px-3 py-1 text-xs font-semibold text-emerald-100/80 transition hover:bg-white/10"
                  onClick={handleCopyBusLabel}
                  type="button"
                >
                  <span className="material-symbols-outlined text-[14px]">content_copy</span>
                  <span>{busCopied ? "Copied" : "Copy bus"}</span>
                </button>
                <button
                  className="inline-flex items-center gap-2 rounded-full border border-emerald-400/20 bg-white/5 px-3 py-1 text-xs font-semibold text-emerald-100/80 transition hover:bg-white/10"
                  onClick={handleChangeBus}
                  type="button"
                >
                  <span className="material-symbols-outlined text-[14px]">swap_horiz</span>
                  <span>Change bus</span>
                </button>
              </div>
            </div>
          </div>
          <Link
            className="rounded-full border border-emerald-400/30 bg-emerald-400/10 px-4 py-2 text-sm font-semibold text-emerald-100 transition hover:bg-emerald-400/20"
            to="/admin/login"
          >
            Admin Login
          </Link>
        </header>

        <main className="grid flex-1 gap-5 lg:grid-cols-[1.25fr_0.75fr]">
          <section className="rounded-[2rem] border border-white/10 bg-white p-4 text-slate-900 shadow-[0_30px_90px_rgba(0,0,0,0.24)] md:p-6">
            <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
              <div>
                <p className="text-xs font-bold uppercase tracking-[0.28em] text-emerald-700">
                  Live scan
                </p>
                <h2 className="mt-2 text-2xl font-black md:text-3xl">Scan a passenger QR</h2>
                <p className="mt-2 max-w-2xl text-sm leading-6 text-slate-600">
                  Open this page on the gate phone, allow camera access, and point it at the
                  ticket QR. The result comes straight from the backend validator.
                </p>
              </div>
              <div
                className={`rounded-2xl px-4 py-3 text-sm font-semibold ${
                  status === "valid"
                    ? "bg-emerald-100 text-emerald-900"
                    : status === "invalid"
                      ? "bg-rose-100 text-rose-900"
                      : status === "checking"
                        ? "bg-amber-100 text-amber-900"
                        : "bg-slate-100 text-slate-700"
                }`}
              >
                {statusLabel}
              </div>
            </div>

            <div className={`mb-4 rounded-[2rem] border px-5 py-5 ${statusTone}`}>
              <div className="flex flex-wrap items-center justify-between gap-4">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-[0.35em] opacity-80">
                    {statusLabel}
                  </p>
                  <h3 className="mt-2 text-3xl font-black md:text-5xl">{statusHeadline}</h3>
                  <p className="mt-2 max-w-2xl text-sm leading-6 opacity-90 md:text-base">
                    {message}
                  </p>
                </div>
                <div className="grid grid-cols-2 gap-3 text-center sm:grid-cols-4">
                  <div className="rounded-2xl bg-white/10 px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.25em] opacity-85">
                      Scans
                    </p>
                    <p className="mt-1 text-2xl font-black">{scanCount}</p>
                  </div>
                  <div className="rounded-2xl bg-white/10 px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.25em] opacity-85">
                      Valid
                    </p>
                    <p className="mt-1 text-2xl font-black">{acceptedCount}</p>
                  </div>
                  <div className="rounded-2xl bg-white/10 px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.25em] opacity-85">
                      Invalid
                    </p>
                    <p className="mt-1 text-2xl font-black">{rejectedCount}</p>
                  </div>
                  <div className="rounded-2xl bg-white/10 px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.25em] opacity-85">
                      Camera
                    </p>
                    <p className="mt-1 text-sm font-black">{isCameraReady ? "LIVE" : "OFF"}</p>
                  </div>
                </div>
              </div>
              {lastScanAt ? (
                <p className="mt-4 text-xs uppercase tracking-[0.28em] opacity-80">
                  Last scan: {new Date(lastScanAt).toLocaleString("en-NG")}
                </p>
              ) : null}
            </div>

            <div className="grid gap-4 xl:grid-cols-[1.1fr_0.9fr]">
              <div className="rounded-[1.75rem] border border-emerald-900/10 bg-[#061512] p-4 text-white">
                <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <p className="text-xs uppercase tracking-[0.28em] text-emerald-200/70">
                      Camera
                    </p>
                    <p className="mt-1 text-sm text-slate-500">
                      {isCameraReady ? "Camera is live" : "Camera is off"}
                    </p>
                  </div>
                  <div className="flex gap-2">
                    <button
                      className="rounded-full border border-white/10 bg-white/10 px-4 py-2 text-sm font-semibold text-white transition hover:bg-white/15"
                      onClick={startCamera}
                      type="button"
                    >
                      Start camera
                    </button>
                    <button
                      className="rounded-full border border-white/10 bg-transparent px-4 py-2 text-sm font-semibold text-white/80 transition hover:bg-white/10"
                      onClick={stopCamera}
                      type="button"
                    >
                      Stop
                    </button>
                  </div>
                </div>

                <div className="overflow-hidden rounded-[1.5rem] border border-white/10 bg-black">
                  <div className="relative h-[380px] w-full overflow-hidden md:h-[540px]">
                    <video
                      ref={videoRef}
                      className="h-full w-full object-cover"
                      muted
                      playsInline
                    />
                    <div className="pointer-events-none absolute inset-0">
                      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(59,130,246,0.10),rgba(0,0,0,0.02)_35%,rgba(0,0,0,0.34)_78%,rgba(0,0,0,0.52))]" />
                      <div className="absolute inset-0 flex items-center justify-center">
                        <div className="relative h-72 w-72 rounded-[2rem] border border-emerald-300/55 shadow-[0_0_0_9999px_rgba(0,0,0,0.16)] md:h-96 md:w-96">
                          <div className="absolute left-4 right-4 top-4 h-8 rounded-t-[1.5rem] border-t border-l border-r border-emerald-300/70" />
                          <div className="absolute bottom-4 left-4 right-4 h-8 rounded-b-[1.5rem] border-b border-l border-r border-emerald-300/70" />
                          <div className="absolute left-4 top-4 bottom-4 w-8 rounded-l-[1.5rem] border-l border-t border-b border-emerald-300/70" />
                          <div className="absolute right-4 top-4 bottom-4 w-8 rounded-r-[1.5rem] border-r border-t border-b border-emerald-300/70" />
                          <div className="absolute inset-x-10 top-1/2 h-1 -translate-y-1/2 rounded-full bg-emerald-300/60 shadow-[0_0_24px_rgba(110,231,183,0.8)] animate-pulse" />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="mt-4 rounded-2xl border border-emerald-400/15 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-50">
                  <p className="font-semibold uppercase tracking-[0.25em] text-emerald-200/80">
                    Scan tip
                  </p>
                  <p className="mt-1">{scanHint}</p>
                </div>

                <canvas ref={canvasRef} className="hidden" />

                <div className="mt-4 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-emerald-50/90">
                  {message}
                </div>
                {cameraError ? (
                  <div className="mt-3 rounded-2xl border border-rose-400/20 bg-rose-500/10 px-4 py-3 text-sm text-rose-100">
                    {cameraError}
                  </div>
                ) : null}
              </div>

              <div className="space-y-4">
                <div className="rounded-[1.75rem] bg-slate-50 p-4 md:p-5">
                  <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                    Status board
                  </p>
                  <div
                    className={`mt-4 flex min-h-[220px] items-center justify-center rounded-[2rem] border px-4 py-6 text-center ${
                      status === "valid"
                        ? "border-emerald-200 bg-emerald-50 text-emerald-950"
                        : status === "invalid"
                          ? "border-rose-200 bg-rose-50 text-rose-950"
                          : status === "checking"
                            ? "border-amber-200 bg-amber-50 text-amber-950"
                            : "border-slate-200 bg-white text-slate-900"
                    }`}
                  >
                    <div>
                      <p className="text-xs font-black uppercase tracking-[0.4em] text-slate-500">
                        {status === "valid"
                          ? "VALID"
                          : status === "invalid"
                            ? "INVALID"
                            : status === "checking"
                              ? "SCANNING"
                              : "READY"}
                      </p>
                      <p className="mt-3 text-4xl font-black md:text-6xl">
                        {status === "valid"
                          ? "Access Granted"
                          : status === "invalid"
                            ? "Access Denied"
                            : status === "checking"
                              ? "Please Wait"
                              : "Hold Up QR"}
                      </p>
                      <p className="mt-3 text-sm text-slate-500">
                        {result?.reason ? formatLabel(result.reason) : "Waiting for the next scan."}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="rounded-[1.75rem] bg-slate-50 p-4 md:p-5">
                  <div className="flex items-center justify-between gap-3">
                    <div>
                      <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                        Connection
                      </p>
                      <p className="mt-2 text-sm text-slate-600">
                        {canValidate
                          ? "Validator is configured."
                          : "Open Admin > Settings > Validator + User App Integration to create or copy a key."}
                      </p>
                    </div>
                    <button
                      className="rounded-full border border-emerald-100 bg-white px-4 py-2 text-xs font-bold uppercase tracking-[0.2em] text-[#00513f] transition hover:bg-[#00513f] hover:text-white"
                      onClick={() => setShowConnectionSettings((current) => !current)}
                      type="button"
                    >
                      {showConnectionSettings ? "Hide setup" : "Setup"}
                    </button>
                  </div>
                  {showConnectionSettings ? (
                    <div className="mt-4 space-y-3">
                      <label className="block">
                        <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.22em] text-slate-500">
                          Backend URL
                        </span>
                        <input
                          className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-[#1d4ed8]"
                          value={baseUrl}
                          onChange={(event) => setBaseUrl(event.target.value)}
                          placeholder="http://localhost:3000/api"
                        />
                      </label>
                      <label className="block">
                        <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.22em] text-slate-500">
                          Validator API Key
                        </span>
                        <input
                          className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-[#1d4ed8]"
                          value={apiKey}
                          onChange={(event) => setApiKey(event.target.value)}
                          placeholder="vk_..."
                        />
                      </label>
                    </div>
                  ) : (
                    <div className="mt-4 rounded-2xl border border-dashed border-slate-200 bg-white px-4 py-3 text-sm text-slate-500">
                      Connection details are hidden for gate use. Open setup only when you need to
                      change the backend or API key, or use Admin &gt; Settings &gt; Validator + User App Integration
                      to generate a fresh device key.
                    </div>
                  )}
                  <div className="mt-4">
                    <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                      Image fallback
                    </p>
                    <p className="mt-2 text-sm text-slate-600">
                      If the live camera struggles, upload a clear QR image or use the manual input below.
                    </p>
                    <input
                      ref={fileInputRef}
                      accept="image/*,.png,.jpg,.jpeg,.webp"
                      className="mt-3 block w-full rounded-2xl border border-dashed border-slate-300 bg-white px-4 py-3 text-sm text-slate-700 file:mr-4 file:rounded-full file:border-0 file:bg-[#7c3aed] file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white hover:file:bg-[#6d28d9]"
                      capture="environment"
                      onChange={handleFileScan}
                      type="file"
                    />
                    <p className="mt-2 text-xs text-slate-500">
                      {selectedFileName
                        ? `Selected: ${selectedFileName}${fileScanState === "loading" ? " (processing...)" : ""}`
                        : "Choose a QR image or screenshot from your device."}
                    </p>
                    {fileScanState === "error" ? (
                      <p className="mt-1 text-xs font-semibold text-rose-600">
                        The image could not be read. Try a tighter crop of just the QR code.
                      </p>
                    ) : null}
                  </div>
                </div>

                <div className="rounded-[1.75rem] bg-slate-50 p-4 md:p-5">
                  <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                    Manual verify
                  </p>
                  <form className="mt-4 space-y-3" onSubmit={handleManualValidate}>
                    <textarea
                      className="min-h-[120px] w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
                      value={scanInput}
                      onChange={(event) => setScanInput(event.target.value)}
                      placeholder="Paste the QR payload, ticket ID, or payment reference here."
                    />
                    <button
                      className="w-full rounded-2xl bg-[#1d4ed8] px-4 py-3 text-sm font-bold text-white transition hover:bg-[#1e40af] disabled:cursor-not-allowed disabled:opacity-60"
                      disabled={!canValidate || !scanInput.trim() || status === "checking"}
                      type="submit"
                    >
                      {status === "checking" ? "Checking..." : "Validate QR"}
                    </button>
                  </form>
                </div>

                <div className="rounded-[1.75rem] bg-slate-50 p-4 md:p-5">
                  <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                    Validation result
                  </p>
                  <div className="mt-3 rounded-2xl border border-slate-200 bg-white p-4">
                    {!result ? (
                      <p className="text-sm text-slate-500">No scan has been checked yet.</p>
                    ) : (
                      <div className="space-y-2 text-sm">
                        <p className="font-bold text-slate-900">
                          {result.valid ? "Ticket accepted" : "Ticket rejected"}
                        </p>
                        <p className="text-slate-600">
                          {result.reason ? formatLabel(result.reason) : "Verified against backend"}
                        </p>
                        {result.ticketId ? (
                          <p className="text-slate-500">Ticket ID: {result.ticketId}</p>
                        ) : null}
                        {result.routeId ? (
                          <p className="text-slate-500">Route ID: {result.routeId}</p>
                        ) : null}
                        {result.validDate ? (
                          <p className="text-slate-500">Valid date: {result.validDate}</p>
                        ) : null}
                      </div>
                    )}
                  </div>
                </div>

                <div className="rounded-[1.75rem] bg-slate-50 p-4 md:p-5">
                  <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-600">
                    Recent scans
                  </p>
                  <div className="mt-3 max-h-56 space-y-2 overflow-y-auto pr-1 md:max-h-72">
                    {history.length === 0 ? (
                      <p className="text-sm text-slate-500">No scans yet.</p>
                    ) : (
                      history.map((entry) => (
                        <div
                          key={`${entry.at}-${entry.payload.slice(0, 12)}`}
                          className="rounded-2xl border border-slate-200 bg-white px-4 py-3"
                        >
                          <div className="flex items-center justify-between gap-3">
                            <p className="truncate text-sm font-semibold text-slate-900">
                              {entry.payload}
                            </p>
                            <span
                              className={`rounded-full px-2.5 py-1 text-[11px] font-bold ${
                                entry.valid
                                  ? "bg-emerald-100 text-emerald-900"
                                  : "bg-rose-100 text-rose-900"
                              }`}
                            >
                              {entry.valid ? "Valid" : "Invalid"}
                            </span>
                          </div>
                          <p className="mt-1 text-xs text-slate-500">
                            {new Date(entry.at).toLocaleTimeString("en-NG", {
                              hour: "2-digit",
                              minute: "2-digit",
                            })}
                            {entry.reason ? ` • ${formatLabel(entry.reason)}` : ""}
                          </p>
                        </div>
                      ))
                    )}
                  </div>
                </div>
              </div>
            </div>
          </section>
        </main>
      </div>
    </div>
  );
}
