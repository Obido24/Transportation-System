import { useEffect, useMemo, useRef, useState } from "react";
import { Link } from "react-router-dom";

const storageKeys = {
  apiKey: "i_metro_validator_api_key",
  baseUrl: "i_metro_validator_base_url",
};

const defaultBaseUrl = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:3000/api";

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
  const lastScanRef = useRef({ value: "", at: 0 });
  const busyRef = useRef(false);

  const [baseUrl, setBaseUrl] = useState(() => readStorage(storageKeys.baseUrl, defaultBaseUrl));
  const [apiKey, setApiKey] = useState(() => readStorage(storageKeys.apiKey, ""));
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

  const canScan = useMemo(
    () => Boolean(baseUrl.trim()) && Boolean(apiKey.trim()),
    [apiKey, baseUrl],
  );

  useEffect(() => {
    writeStorage(storageKeys.baseUrl, baseUrl);
  }, [baseUrl]);

  useEffect(() => {
    writeStorage(storageKeys.apiKey, apiKey);
  }, [apiKey]);

  useEffect(() => {
    return () => {
      stopCamera();
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
  };

  const validateQr = async (qrValue, source = "camera") => {
    const value = String(qrValue ?? "").trim();
    if (!value) {
      return;
    }

    const now = Date.now();
    if (lastScanRef.current.value === value && now - lastScanRef.current.at < 5000) {
      return;
    }
    lastScanRef.current = { value, at: now };

    if (busyRef.current) return;
    busyRef.current = true;

    setStatus("checking");
    setMessage(`Checking ${source} scan...`);
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
        body: JSON.stringify({ code: value }),
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
        raw: data,
      };

      setResult(nextResult);
      setStatus(isValid ? "valid" : "invalid");
      setAcceptedCount((current) => current + (isValid ? 1 : 0));
      setRejectedCount((current) => current + (isValid ? 0 : 1));
      setMessage(
        isValid
          ? `Gate opened for ticket${data?.ticketId ? ` #${String(data.ticketId).slice(0, 8).toUpperCase()}` : ""}.`
          : `Access denied${data?.reason ? `: ${formatLabel(data.reason)}` : ""}.`,
      );
      pushHistory({
        at: new Date().toISOString(),
        payload: value,
        valid: isValid,
        reason: data?.reason ?? null,
      });

      if (isValid) {
        stopCamera();
      }
    } catch (error) {
      setStatus("error");
      setMessage("Network error while validating the QR.");
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
    } finally {
      busyRef.current = false;
    }
  };

  const scanFrame = async () => {
    if (!isScanning || !videoRef.current) return;
    const video = videoRef.current;

    try {
      if (window.BarcodeDetector) {
        if (!detectorRef.current) {
          detectorRef.current = new window.BarcodeDetector({
            formats: ["qr_code", "code_128", "code_39", "ean_13"],
          });
        }
        const codes = await detectorRef.current.detect(video);
        if (codes.length > 0) {
          await validateQr(codes[0].rawValue, "camera");
          return;
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
    }

    scanLoopRef.current = requestAnimationFrame(scanFrame);
  };

  const startCamera = async () => {
    setCameraError("");
    setMessage("Starting camera...");

    if (!canScan) {
      setStatus("error");
      setMessage("Add the backend URL and API key first.");
      return;
    }

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
      setStatus("idle");
      setMessage("Camera ready. Point it at the QR code.");
      scanLoopRef.current = requestAnimationFrame(scanFrame);
    } catch (error) {
      setStatus("error");
      setCameraError(error?.message ?? "Unable to open the camera.");
      setMessage("Camera failed to start.");
    }
  };

  const handleManualValidate = async (event) => {
    event.preventDefault();
    await validateQr(scanInput, "manual");
  };

  const detectFromSource = async (source, label = "image") => {
    if (!window.BarcodeDetector) {
      setStatus("error");
      setMessage("This browser does not support image QR decoding.");
      return;
    }

    if (!detectorRef.current) {
      detectorRef.current = new window.BarcodeDetector({
        formats: ["qr_code", "code_128", "code_39", "ean_13"],
      });
    }

    try {
      setMessage(`Scanning ${label}...`);
      const codes = await detectorRef.current.detect(source);
      if (!codes.length) {
        setStatus("invalid");
        setMessage(`No QR detected in ${label}. Try a clearer image.`);
        return;
      }
      await validateQr(codes[0].rawValue, label);
    } catch (error) {
      setStatus("error");
      setMessage(`Unable to decode ${label}.`);
      setCameraError(error?.message ?? "Unable to decode image.");
    }
  };

  const handleFileScan = async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;

    try {
      const url = URL.createObjectURL(file);
      const image = new Image();
      image.onload = async () => {
        await detectFromSource(image, "image");
        URL.revokeObjectURL(url);
      };
      image.onerror = () => {
        URL.revokeObjectURL(url);
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
      ? "bg-emerald-500 text-white shadow-[0_25px_70px_rgba(16,185,129,0.45)]"
      : status === "invalid"
        ? "bg-rose-500 text-white shadow-[0_25px_70px_rgba(244,63,94,0.45)]"
        : status === "checking"
          ? "bg-amber-400 text-slate-950 shadow-[0_25px_70px_rgba(251,191,36,0.45)]"
          : "bg-white/10 text-white border border-white/15";

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
                    <p className="mt-1 text-sm text-emerald-100/80">
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
                  <video
                    ref={videoRef}
                    className="h-[380px] w-full object-cover md:h-[540px]"
                    muted
                    playsInline
                  />
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
                  <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-500">
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
                  <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-500">
                    Connection
                  </p>
                  <div className="mt-4 space-y-3">
                    <label className="block">
                      <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.22em] text-slate-500">
                        Backend URL
                      </span>
                      <input
                        className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
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
                        className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
                        value={apiKey}
                        onChange={(event) => setApiKey(event.target.value)}
                        placeholder="vk_..."
                      />
                    </label>
                  </div>
                  <div className="mt-4">
                    <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-500">
                      Image fallback
                    </p>
                    <p className="mt-2 text-sm text-slate-600">
                      If the live camera struggles, upload a clear QR image or use the manual input below.
                    </p>
                    <input
                      ref={fileInputRef}
                      accept="image/*"
                      className="mt-3 block w-full rounded-2xl border border-dashed border-slate-300 bg-white px-4 py-3 text-sm text-slate-700 file:mr-4 file:rounded-full file:border-0 file:bg-emerald-600 file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white hover:file:bg-emerald-700"
                      onChange={handleFileScan}
                      type="file"
                    />
                  </div>
                </div>

                <div className="rounded-[1.75rem] bg-slate-50 p-4 md:p-5">
                  <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-500">
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
                      className="w-full rounded-2xl bg-emerald-600 px-4 py-3 text-sm font-bold text-white transition hover:bg-emerald-700 disabled:cursor-not-allowed disabled:opacity-60"
                      disabled={!canScan || !scanInput.trim() || status === "checking"}
                      type="submit"
                    >
                      {status === "checking" ? "Checking..." : "Validate QR"}
                    </button>
                  </form>
                </div>

                <div className="rounded-[1.75rem] bg-slate-50 p-4 md:p-5">
                  <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-500">
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
                  <p className="text-xs font-bold uppercase tracking-[0.28em] text-slate-500">
                    Recent scans
                  </p>
                  <div className="mt-3 space-y-2">
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
