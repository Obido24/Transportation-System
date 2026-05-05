import { useEffect, useMemo, useRef, useState } from "react";
import { Link } from "react-router-dom";

import ExportToolbar from "../components/ExportToolbar";
import HtmlScreen from "./HtmlScreen";
import auditActivityHtml from "./html/audit_activity_logs.html?raw";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const wrapperClassName = "min-h-screen";

const renderRows = (logs) =>
  logs
    .map((log, index) => {
      const date = log.date ?? "-";
      const time = log.time ?? "-";
      const name = log.name ?? "System";
      const role = log.role ?? "-";
      const category = log.category ?? "General";
      const action = log.action ?? "";
      const details = log.details ?? "";
      const ip = log.ipAddress ?? "-";
      const badgeClass =
        category.toLowerCase().includes("security")
          ? "bg-error-container text-on-error-container"
          : category.toLowerCase().includes("data")
          ? "bg-secondary-container text-on-secondary-container"
          : "bg-surface-container-highest text-on-surface-variant";
      const zebra = index % 2 ? "bg-surface-container-low/30" : "";
      return `
      <div class="px-8 py-6 grid grid-cols-12 gap-4 items-center hover:bg-surface-container-low transition-colors group ${zebra}">
        <div class="col-span-2">
          <p class="text-sm font-medium text-on-surface">${date}</p>
          <p class="text-xs text-on-surface-variant">${time}</p>
        </div>
        <div class="col-span-3 flex items-center gap-3">
          <div class="h-9 w-9 rounded-full bg-primary/10 flex items-center justify-center overflow-hidden">
            ${
              log.avatarUrl
                ? `<img alt="Admin portrait" class="h-full w-full object-cover" src="${log.avatarUrl}" />`
                : `<span class="material-symbols-outlined text-primary">shield_person</span>`
            }
          </div>
          <div>
            <p class="text-sm font-semibold text-on-surface">${name}</p>
            <p class="text-xs text-on-surface-variant">${role}</p>
          </div>
        </div>
        <div class="col-span-2">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider ${badgeClass}">
            ${category}
          </span>
        </div>
        <div class="col-span-3 text-sm text-on-surface-variant leading-relaxed">
          <p class="font-semibold text-on-surface">${action}</p>
          <p class="mt-1">${details}</p>
        </div>
        <div class="col-span-2 text-xs font-mono text-on-surface-variant">
          ${ip}
        </div>
      </div>
    `;
    })
    .join("");

const formatScanReason = (entry) => {
  if (entry?.reason) return entry.reason;
  return entry?.isValid ? "Validated successfully" : "Unknown rejection reason";
};

const normalizeBusLabel = (value) => {
  const text = String(value ?? "").trim();
  return text || "Unassigned bus";
};

const normalizeValidatorName = (entry) => {
  const text = String(entry?.validatorDeviceName ?? entry?.validatorDeviceId ?? "").trim();
  return text || "Unknown validator";
};

const mapValidatorLogsToScanCards = (logs) =>
  logs.map((entry) => ({
    id: entry.id,
    title: normalizeValidatorName(entry),
    subtitle: normalizeBusLabel(entry.busLabel),
    status: entry.isValid ? "VALID" : "INVALID",
    reason: formatScanReason(entry),
    ticketId: String(entry.ticketId ?? "-").trim() || "-",
    routeId: String(entry.routeId ?? "-").trim() || "-",
    timeAgo: String(entry.timeAgo ?? "").trim() || "-",
    createdAt: entry.createdAt,
  }));

function AuditActivityLogs() {
  const containerRef = useRef(null);
  const logsRef = useRef([]);
  const validatorLogsRef = useRef([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [validatorLogs, setValidatorLogs] = useState([]);
  const [validatorError, setValidatorError] = useState("");

  const validatorStats = useMemo(() => {
    const valid = validatorLogs.filter((entry) => entry.isValid).length;
    const invalid = validatorLogs.length - valid;
    const buses = new Set(validatorLogs.map((entry) => normalizeBusLabel(entry.busLabel)));
    const validators = new Set(
      validatorLogs.map((entry) => normalizeValidatorName(entry)),
    );

    return {
      total: validatorLogs.length,
      valid,
      invalid,
      buses: buses.size,
      validators: validators.size,
    };
  }, [validatorLogs]);

  const getExportColumns = () => [
    { key: "date", label: "Date", accessor: (log) => log.date ?? "-" },
    { key: "time", label: "Time", accessor: (log) => log.time ?? "-" },
    { key: "name", label: "Name", accessor: (log) => log.name ?? "System" },
    { key: "role", label: "Role", accessor: (log) => log.role ?? "-" },
    { key: "category", label: "Category", accessor: (log) => log.category ?? "General" },
    { key: "action", label: "Action", accessor: (log) => log.action ?? "-" },
    { key: "details", label: "Details", accessor: (log) => log.details ?? "-" },
    { key: "ipAddress", label: "IP Address", accessor: (log) => log.ipAddress ?? "-" },
  ];

  const handleCsvExport = () => {
    if (!logsRef.current.length) return;
    downloadCsv({
      filename: "i-metro-audit-logs",
      columns: getExportColumns(),
      rows: logsRef.current,
    });
  };

  const handlePdfExport = () => {
    if (!logsRef.current.length) return;
    printPdf({
      title: "I-Metro Audit Activity Logs",
      subtitle: "Live admin audit trail from the backend",
      filename: "i-metro-audit-logs",
      columns: getExportColumns(),
      rows: logsRef.current,
    });
  };

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      setError("");
      setValidatorError("");
      try {
        const [auditResponse, validatorResponse] = await Promise.all([
          fetchWithAuth("/admin/audit-logs"),
          fetchWithAuth("/admin/validator/logs"),
        ]);

        if (!auditResponse.ok) {
          setError("Unable to load audit logs.");
        }

        if (!validatorResponse.ok) {
          setValidatorError("Unable to load validator scan events.");
        }

        const logs = auditResponse.ok ? await auditResponse.json() : [];
        const validatorPayload = validatorResponse.ok ? await validatorResponse.json() : [];

        logsRef.current = logs;
        validatorLogsRef.current = Array.isArray(validatorPayload) ? validatorPayload : [];
        setValidatorLogs(validatorLogsRef.current);

        const container = containerRef.current;
        if (!container) return;

        const list = container.querySelector("div.divide-y-0");
        if (list) {
          list.innerHTML = logs.length
            ? renderRows(logs)
            : `
              <div class="px-8 py-6 text-sm text-on-surface-variant">
                No audit activity has been recorded yet.
              </div>
            `;
        }

        const footer = Array.from(container.querySelectorAll("p")).find((node) =>
          node.textContent?.includes("Showing"),
        );
        if (footer) {
          footer.textContent = logs.length
            ? `Showing 1 to ${Math.min(logs.length, 10)} of ${logs.length} entries`
            : "Showing 0 entries";
        }
      } catch {
        setError("Unable to load audit logs.");
      } finally {
        setLoading(false);
      }
    };

    load();
  }, []);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading audit logs...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />
      <section className="mb-6 rounded-3xl border border-outline-variant/10 bg-surface-container-lowest shadow-[0px_10px_30px_rgba(25,28,29,0.06)] overflow-hidden">
        <div className="flex flex-col gap-4 px-6 py-6 md:px-8 md:py-7 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.2em] text-on-surface-variant font-semibold">
              Scan Events
            </p>
            <h2 className="mt-2 text-2xl md:text-3xl font-bold tracking-tight text-on-surface">
              Validator scans at a glance
            </h2>
            <p className="mt-3 max-w-2xl text-sm md:text-base text-on-surface-variant">
              These are the live bus scan events recorded by the backend, so admins can see
              which validator handled each ticket and whether it was accepted or rejected.
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <Link
              to="/admin/validator-logs"
              className="inline-flex items-center gap-2 rounded-xl border border-outline-variant/20 bg-primary px-4 py-2.5 text-sm font-semibold text-on-primary hover:opacity-90 transition-opacity shadow-sm"
            >
              <span className="material-symbols-outlined text-[18px]">qr_code_scanner</span>
              Open Bus Logs
            </Link>
          </div>
        </div>

        <div className="px-6 pb-6 md:px-8 md:pb-8">
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
            {[
              { label: "Total scans", value: validatorStats.total },
              { label: "Valid scans", value: validatorStats.valid },
              { label: "Invalid scans", value: validatorStats.invalid },
              { label: "Buses used", value: validatorStats.buses },
              { label: "Validators", value: validatorStats.validators },
            ].map((item) => (
              <div key={item.label} className="rounded-2xl bg-surface-container-low px-4 py-4">
                <p className="text-xs uppercase tracking-[0.18em] text-on-surface-variant font-semibold">
                  {item.label}
                </p>
                <p className="mt-3 text-3xl font-bold tracking-tight text-on-surface">{item.value}</p>
              </div>
            ))}
          </div>

          {validatorError ? (
            <div className="mt-5 rounded-2xl bg-error-container text-on-error-container px-4 py-3 text-sm">
              {validatorError}
            </div>
          ) : validatorLogs.length > 0 ? (
            <div className="mt-5 grid gap-3 lg:grid-cols-2">
              {mapValidatorLogsToScanCards(validatorLogs.slice(0, 6)).map((entry) => {
                const isValid = entry.status === "VALID";
                const badgeClass = isValid
                  ? "bg-secondary-container text-on-secondary-container"
                  : "bg-error-container text-on-error-container";

                return (
                  <article
                    key={entry.id}
                    className="rounded-2xl border border-outline-variant/10 bg-surface-container-lowest px-4 py-4 shadow-sm"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <p className="text-xs uppercase tracking-[0.18em] text-on-surface-variant font-semibold">
                          {entry.subtitle}
                        </p>
                        <h3 className="mt-2 text-lg font-bold text-on-surface">{entry.title}</h3>
                      </div>
                      <span
                        className={[
                          "inline-flex items-center rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-[0.18em]",
                          badgeClass,
                        ].join(" ")}
                      >
                        {entry.status}
                      </span>
                    </div>

                    <p className="mt-3 text-sm text-on-surface-variant leading-relaxed">
                      {entry.reason}
                    </p>

                    <div className="mt-4 grid gap-2 sm:grid-cols-3 text-xs">
                      <div className="rounded-xl bg-surface-container-low px-3 py-2">
                        <p className="text-[10px] uppercase tracking-[0.18em] text-on-surface-variant">
                          Ticket
                        </p>
                        <p className="mt-1 font-mono text-on-surface break-all">{entry.ticketId}</p>
                      </div>
                      <div className="rounded-xl bg-surface-container-low px-3 py-2">
                        <p className="text-[10px] uppercase tracking-[0.18em] text-on-surface-variant">
                          Route
                        </p>
                        <p className="mt-1 font-mono text-on-surface break-all">{entry.routeId}</p>
                      </div>
                      <div className="rounded-xl bg-surface-container-low px-3 py-2">
                        <p className="text-[10px] uppercase tracking-[0.18em] text-on-surface-variant">
                          Time
                        </p>
                        <p className="mt-1 text-on-surface">{entry.timeAgo}</p>
                      </div>
                    </div>
                  </article>
                );
              })}
            </div>
          ) : (
            <div className="mt-5 rounded-2xl border border-dashed border-outline-variant/20 bg-surface-container-low px-4 py-5 text-sm text-on-surface-variant">
              No validator scan events have been recorded yet.
            </div>
          )}
        </div>
      </section>
      <HtmlScreen
        html={auditActivityHtml}
        title="Audit Activity Logs"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
    </>
  );
}

export default AuditActivityLogs;
