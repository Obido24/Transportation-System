import { useEffect, useRef, useState } from "react";

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

function AuditActivityLogs() {
  const containerRef = useRef(null);
  const logsRef = useRef([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

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
      try {
        const response = await fetchWithAuth("/admin/audit-logs");
        if (!response.ok) {
          setError("Unable to load audit logs.");
          return;
        }
        const logs = await response.json();
        logsRef.current = logs;
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
