const escapeCsvValue = (value) => {
  const text = String(value ?? "");
  if (/[",\n]/.test(text)) {
    return `"${text.replace(/"/g, '""')}"`;
  }
  return text;
};

const escapeHtml = (value) =>
  String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");

const buildRows = (columns, rows) =>
  rows
    .map((row) =>
      columns
        .map((column) => {
          const value =
            typeof column.accessor === "function" ? column.accessor(row) : row[column.key];
          return escapeCsvValue(column.format ? column.format(value, row) : value);
        })
        .join(","),
    )
    .join("\n");

export const downloadCsv = ({ filename, columns = [], rows = [] }) => {
  const header = columns.map((column) => escapeCsvValue(column.label)).join(",");
  const body = buildRows(columns, rows);
  const blob = new Blob([`\uFEFF${header}\n${body}`], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename.endsWith(".csv") ? filename : `${filename}.csv`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
};

export const printPdf = ({ title, subtitle, filename, columns = [], rows = [] }) => {
  const now = new Date().toLocaleString();
  const tableHead = columns.map((column) => `<th>${escapeHtml(column.label)}</th>`).join("");
  const tableBody = rows
    .map(
      (row) => `<tr>${columns
        .map((column) => {
          const value =
            typeof column.accessor === "function" ? column.accessor(row) : row[column.key];
          return `<td>${escapeHtml(column.format ? column.format(value, row) : value)}</td>`;
        })
        .join("")}</tr>`,
    )
    .join("");

  const iframe = document.createElement("iframe");
  iframe.setAttribute("aria-hidden", "true");
  iframe.style.position = "fixed";
  iframe.style.right = "0";
  iframe.style.bottom = "0";
  iframe.style.width = "0";
  iframe.style.height = "0";
  iframe.style.border = "0";
  iframe.style.opacity = "0";
  document.body.appendChild(iframe);

  const cleanup = () => {
    setTimeout(() => {
      iframe.remove();
    }, 500);
  };

  const doc = iframe.contentWindow?.document;
  if (!doc) {
    cleanup();
    window.alert("PDF export failed to start. Please try again.");
    return;
  }

  doc.open();
  doc.write(`<!doctype html>
    <html>
      <head>
        <meta charset="utf-8" />
        <title>${escapeHtml(filename)}</title>
        <style>
          @page { size: A4; margin: 18mm; }
          body { font-family: Arial, sans-serif; color: #1f2937; }
          h1 { margin: 0 0 8px; font-size: 20px; }
          p { margin: 0 0 18px; color: #6b7280; font-size: 12px; }
          table { width: 100%; border-collapse: collapse; font-size: 12px; }
          th, td { border-bottom: 1px solid #e5e7eb; padding: 10px 8px; text-align: left; vertical-align: top; }
          th { background: #f9fafb; font-size: 11px; text-transform: uppercase; letter-spacing: .04em; }
        </style>
      </head>
      <body>
        <h1>${escapeHtml(title)}</h1>
        <p>${escapeHtml(subtitle || "")} - Generated ${escapeHtml(now)}</p>
        <table>
          <thead><tr>${tableHead}</tr></thead>
          <tbody>${tableBody || `<tr><td colspan="${columns.length}">No records available.</td></tr>`}</tbody>
        </table>
      </body>
    </html>`);
  doc.close();

  const printAndCleanup = () => {
    try {
      iframe.contentWindow?.focus();
      iframe.contentWindow?.print();
    } finally {
      cleanup();
    }
  };

  if (iframe.contentWindow?.document.readyState === "complete") {
    setTimeout(printAndCleanup, 200);
  } else {
    iframe.onload = () => setTimeout(printAndCleanup, 200);
  }
};
