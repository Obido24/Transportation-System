import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useSearchParams } from "react-router-dom";

import ExportToolbar from "../components/ExportToolbar";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const statusStyles = {
  VALID: "bg-secondary-container text-on-secondary-fixed-variant",
  INVALID: "bg-error-container text-on-error-container",
};

const formatDateTime = (value) => {
  if (!value) return "-";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "-";
  return new Intl.DateTimeFormat("en-NG", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
};

const normalizeText = (value, fallback = "-") => {
  const text = String(value ?? "").trim();
  return text || fallback;
};

const normalizeBusLabel = (value) => normalizeText(value, "Unassigned bus");

const normalizeReason = (entry) => {
  if (entry?.reason) return entry.reason;
  return entry?.isValid ? "Validated successfully" : "Unknown rejection reason";
};

function ValidatorLogs() {
  const logsRef = useRef([]);
  const [searchParams, setSearchParams] = useSearchParams();
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [filter, setFilter] = useState("ALL");
  const [busFilter, setBusFilter] = useState(() => {
    const initialBus = searchParams.get("bus")?.trim();
    return initialBus || "ALL";
  });
  const [lastUpdated, setLastUpdated] = useState("");

  const loadLogs = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const response = await fetchWithAuth("/admin/validator/logs");
      if (!response.ok) {
        setError("Unable to load validator logs.");
        return;
      }

      const payload = await response.json();
      const nextLogs = Array.isArray(payload) ? payload : [];
      logsRef.current = nextLogs;
      setLogs(nextLogs);
      setLastUpdated(new Date().toLocaleTimeString("en-NG", { hour: "2-digit", minute: "2-digit" }));
    } catch {
      setError("Unable to load validator logs.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadLogs();
    const timer = window.setInterval(() => {
      void loadLogs();
    }, 30000);

    return () => window.clearInterval(timer);
  }, [loadLogs]);

  const busOptions = useMemo(() => {
    const buses = Array.from(
      new Set(logs.map((entry) => normalizeBusLabel(entry.busLabel))),
    ).sort((a, b) => a.localeCompare(b));
    return ["ALL", ...buses];
  }, [logs]);

  const filteredLogs = useMemo(() => {
    const normalized = filter.toUpperCase();
    return logs.filter((entry) => {
      const statusMatch =
        normalized === "ALL" ? true : (entry.isValid ? "VALID" : "INVALID") === normalized;
      const busMatch =
        busFilter === "ALL" ? true : normalizeBusLabel(entry.busLabel) === busFilter;
      return statusMatch && busMatch;
    });
  }, [busFilter, filter, logs]);

  const summary = useMemo(() => {
    const valid = logs.filter((entry) => entry.isValid).length;
    const invalid = logs.length - valid;
    const buses = new Set(logs.map((entry) => normalizeBusLabel(entry.busLabel)));
    const validators = new Set(
      logs.map((entry) => normalizeText(entry.validatorDeviceName || entry.validatorDeviceId, "Unknown validator")),
    );

    return {
      total: logs.length,
      valid,
      invalid,
      buses: buses.size,
      validators: validators.size,
    };
  }, [logs]);

  const getExportColumns = () => [
    { key: "createdAt", label: "Time", accessor: (entry) => formatDateTime(entry.createdAt) },
    { key: "timeAgo", label: "When", accessor: (entry) => normalizeText(entry.timeAgo, "-") },
    { key: "busLabel", label: "Bus", accessor: (entry) => normalizeBusLabel(entry.busLabel) },
    {
      key: "status",
      label: "Status",
      accessor: (entry) => (entry.isValid ? "VALID" : "INVALID"),
    },
    { key: "reason", label: "Reason", accessor: (entry) => normalizeReason(entry) },
    {
      key: "validator",
      label: "Validator",
      accessor: (entry) => normalizeText(entry.validatorDeviceName || entry.validatorDeviceId, "Unknown validator"),
    },
    { key: "ticketId", label: "Ticket ID", accessor: (entry) => normalizeText(entry.ticketId, "-") },
    { key: "routeId", label: "Route ID", accessor: (entry) => normalizeText(entry.routeId, "-") },
    { key: "rawPayload", label: "Raw Payload", accessor: (entry) => normalizeText(entry.rawPayload, "-") },
  ];

  const handleCsvExport = () => {
    if (!logsRef.current.length) return;
    downloadCsv({
      filename: "i-metro-validator-logs",
      columns: getExportColumns(),
      rows: logsRef.current,
    });
  };

  const handlePdfExport = () => {
    if (!logsRef.current.length) return;
    printPdf({
      title: "I-Metro Bus Scan Logs",
      subtitle: "Validator scans grouped by bus assignment",
      filename: "i-metro-validator-logs",
      columns: getExportColumns(),
      rows: logsRef.current,
    });
  };

  return (
    <div className="space-y-5">
      {loading && (
        <div className="rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading validator logs...
        </div>
      )}
      {error && (
        <div className="rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}

      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />

      <section className="rounded-3xl bg-surface-container-lowest border border-outline-variant/10 shadow-[0px_10px_30px_rgba(25,28,29,0.06)] overflow-hidden">
        <div className="flex flex-col gap-4 px-6 py-6 md:px-8 md:py-7 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.2em] text-on-surface-variant font-semibold">
              Bus Scan Activity
            </p>
            <h1 className="mt-2 text-3xl md:text-4xl font-bold tracking-tight text-on-surface">
              Validator Logs
            </h1>
            <p className="mt-3 max-w-2xl text-sm md:text-base text-on-surface-variant">
              Track every validator scan by bus, device, and result so the admin team can see
              where passengers boarded.
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <button
              type="button"
              onClick={loadLogs}
              className="inline-flex items-center gap-2 rounded-xl border border-outline-variant/20 bg-surface-container-lowest px-4 py-2.5 text-sm font-semibold text-on-surface hover:bg-surface-container-low transition-colors shadow-sm"
            >
              <span className="material-symbols-outlined text-[18px]">refresh</span>
              Refresh
            </button>
            <div className="rounded-xl bg-surface-container-low px-4 py-2 text-xs text-on-surface-variant">
              Last updated: {lastUpdated || "Waiting..."}
            </div>
          </div>
        </div>

        <div className="px-6 pb-6 md:px-8 md:pb-8">
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
            {[
              { label: "Total scans", value: summary.total },
              { label: "Valid scans", value: summary.valid },
              { label: "Invalid scans", value: summary.invalid },
              { label: "Buses used", value: summary.buses },
              { label: "Validators", value: summary.validators },
            ].map((item) => (
              <div key={item.label} className="rounded-2xl bg-surface-container-low px-4 py-4">
                <p className="text-xs uppercase tracking-[0.18em] text-on-surface-variant font-semibold">
                  {item.label}
                </p>
                <p className="mt-3 text-3xl font-bold tracking-tight text-on-surface">{item.value}</p>
              </div>
            ))}
          </div>

          {logs.length > 0 && (
            <div className="mt-6 rounded-2xl border border-outline-variant/15 bg-surface-container-low px-4 py-4">
              <div className="flex flex-col gap-1 md:flex-row md:items-end md:justify-between">
                <div>
                  <p className="text-xs uppercase tracking-[0.18em] text-on-surface-variant font-semibold">
                    Scan Timeline
                  </p>
                  <p className="mt-1 text-sm text-on-surface-variant">
                    The latest bus validations shown in order, newest first.
                  </p>
                </div>
                <p className="text-xs text-on-surface-variant">
                  Showing the last {Math.min(logs.length, 5)} scans
                </p>
              </div>

              <div className="mt-4 grid gap-3 md:grid-cols-5">
                {logs.slice(0, 5).map((entry) => {
                  const status = entry.isValid ? "VALID" : "INVALID";
                  const badge = statusStyles[status] ?? statusStyles.INVALID;

                  return (
                    <div
                      key={`timeline-${entry.id}`}
                      className="rounded-xl bg-surface-container-lowest px-4 py-3 shadow-sm border border-outline-variant/10"
                    >
                      <div className="flex items-center justify-between gap-2">
                        <span className="text-[10px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                          {normalizeBusLabel(entry.busLabel)}
                        </span>
                        <span
                          className={[
                            "inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.18em]",
                            badge,
                          ].join(" ")}
                        >
                          {status}
                        </span>
                      </div>
                      <p className="mt-3 text-sm font-semibold text-on-surface break-words">
                        {normalizeReason(entry)}
                      </p>
                      <p className="mt-2 text-xs text-on-surface-variant">
                        {entry.timeAgo || formatDateTime(entry.createdAt)}
                      </p>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          <div className="mt-5 flex flex-wrap gap-2">
            {["ALL", "VALID", "INVALID"].map((item) => {
              const active = filter === item;
              return (
                <button
                  key={item}
                  type="button"
                  onClick={() => setFilter(item)}
                  className={[
                    "rounded-full px-4 py-2 text-sm font-semibold transition-colors",
                    active
                      ? "bg-primary text-on-primary"
                      : "bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high",
                  ].join(" ")}
                >
                  {item === "ALL" ? "All" : item === "VALID" ? "Valid" : "Invalid"}
                </button>
              );
            })}
          </div>

          <div className="mt-4 flex flex-col gap-3 rounded-2xl bg-surface-container-low px-4 py-4 md:flex-row md:items-center md:justify-between">
            <div>
              <p className="text-xs uppercase tracking-[0.18em] text-on-surface-variant font-semibold">
                Bus filter
              </p>
              <p className="mt-1 text-sm text-on-surface-variant">
                Narrow the log list to a specific bus assignment.
              </p>
            </div>
            <div className="flex flex-wrap items-center gap-2">
              <select
                className="min-w-56 rounded-xl border border-outline-variant/20 bg-surface-container-lowest px-4 py-2.5 text-sm font-semibold text-on-surface shadow-sm outline-none focus:ring-2 focus:ring-primary"
                value={busFilter}
                onChange={(event) => {
                  const nextBus = event.target.value;
                  setBusFilter(nextBus);
                  setSearchParams((current) => {
                    const nextParams = new URLSearchParams(current);
                    if (nextBus === "ALL") {
                      nextParams.delete("bus");
                    } else {
                      nextParams.set("bus", nextBus);
                    }
                    return nextParams;
                  }, { replace: true });
                }}
              >
                {busOptions.map((bus) => (
                  <option key={bus} value={bus}>
                    {bus === "ALL" ? "All buses" : bus}
                  </option>
                ))}
              </select>
              {(busFilter !== "ALL" || filter !== "ALL") && (
                <button
                  type="button"
                  onClick={() => {
                    setFilter("ALL");
                    setBusFilter("ALL");
                  }}
                  className="rounded-xl border border-outline-variant/20 bg-surface-container-lowest px-4 py-2.5 text-sm font-semibold text-on-surface hover:bg-surface-container-low transition-colors shadow-sm"
                >
                  Clear filters
                </button>
              )}
            </div>
          </div>

          <div className="mt-6 grid gap-4">
            {filteredLogs.length ? (
              filteredLogs.map((entry) => {
                const status = entry.isValid ? "VALID" : "INVALID";
                const badge = statusStyles[status] ?? statusStyles.INVALID;
                const busLabel = normalizeBusLabel(entry.busLabel);
                const validatorName = normalizeText(
                  entry.validatorDeviceName || entry.validatorDeviceId,
                  "Unknown validator",
                );
                const routeLabel = normalizeText(entry.routeId, "-");
                const ticketLabel = normalizeText(entry.ticketId, "-");

                return (
                  <article
                    key={entry.id}
                    className="rounded-2xl border border-outline-variant/15 bg-white px-5 py-4 shadow-sm"
                  >
                    <div className="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
                      <div className="space-y-2">
                        <div className="flex flex-wrap items-center gap-2">
                          <span className="inline-flex items-center rounded-full bg-primary-container/70 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.18em] text-primary">
                            {busLabel}
                          </span>
                          <span className="inline-flex items-center rounded-full bg-surface-container-high px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.18em] text-on-surface-variant">
                            {entry.timeAgo || formatDateTime(entry.createdAt)}
                          </span>
                        </div>
                        <div>
                          <h3 className="text-lg font-bold text-on-surface">
                            {status === "VALID" ? "Access granted" : "Access denied"}
                          </h3>
                          <p className="mt-1 text-sm text-on-surface-variant">
                            {normalizeReason(entry)}
                          </p>
                        </div>
                      </div>

                      <div className="flex items-center gap-2">
                        <span
                          className={[
                            "inline-flex items-center rounded-full px-3 py-1 text-[11px] font-bold uppercase tracking-[0.18em]",
                            badge,
                          ].join(" ")}
                        >
                          {status}
                        </span>
                      </div>
                    </div>

                    <div className="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
                      <div className="rounded-xl bg-surface-container-low px-4 py-3">
                        <p className="text-[10px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                          Validator
                        </p>
                        <p className="mt-1 text-sm font-semibold text-on-surface">{validatorName}</p>
                      </div>
                      <div className="rounded-xl bg-surface-container-low px-4 py-3">
                        <p className="text-[10px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                          Ticket ID
                        </p>
                        <p className="mt-1 font-mono text-sm font-semibold text-on-surface break-all">
                          {ticketLabel}
                        </p>
                      </div>
                      <div className="rounded-xl bg-surface-container-low px-4 py-3">
                        <p className="text-[10px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                          Route
                        </p>
                        <p className="mt-1 text-sm font-semibold text-on-surface">{routeLabel}</p>
                      </div>
                      <div className="rounded-xl bg-surface-container-low px-4 py-3">
                        <p className="text-[10px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                          Raw Payload
                        </p>
                        <p className="mt-1 font-mono text-xs text-on-surface-variant break-all">
                          {normalizeText(entry.rawPayload, "-")}
                        </p>
                      </div>
                    </div>
                  </article>
                );
              })
            ) : (
              <div className="rounded-2xl border border-dashed border-outline-variant/20 bg-surface-container-low px-6 py-10 text-center">
                <p className="text-lg font-semibold text-on-surface">No validator logs yet</p>
                <p className="mt-2 text-sm text-on-surface-variant">
                  {busFilter !== "ALL" || filter !== "ALL"
                    ? "No logs match the selected bus or status filters."
                    : "Once a bus attendant scans a ticket, the validation activity will appear here."}
                </p>
              </div>
            )}
          </div>
        </div>
      </section>
    </div>
  );
}

export default ValidatorLogs;
