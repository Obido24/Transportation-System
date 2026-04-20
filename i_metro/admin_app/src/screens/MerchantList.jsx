import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";

import ExportToolbar from "../components/ExportToolbar";
import HtmlScreen from "./HtmlScreen";
import totalUsersHtml from "./html/total_users.html?raw";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const wrapperClassName = "min-h-screen";

const toInitials = (name) => {
  if (!name) return "M";
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
  return `${parts[0].charAt(0)}${parts[1].charAt(0)}`.toUpperCase();
};

const formatDate = (value) => {
  if (!value) return "-";
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(value));
};

const renderRows = (merchants) =>
  merchants
    .map((merchant) => {
      const contact = merchant.email || merchant.phone || "No contact";
      const statusLabel = merchant.isActive ? "Active" : "Inactive";
      const statusClass = merchant.isActive
        ? "bg-primary-fixed/30 text-on-primary-fixed-variant"
        : "bg-surface-container-highest text-on-surface-variant";
      const dotClass = merchant.isActive ? "bg-primary" : "bg-outline";

      return `
      <tr class="hover:bg-surface-container-low/50 transition-colors group cursor-pointer" data-merchant-id="${merchant.id}">
        <td class="px-8 py-5">
          <div class="flex items-center gap-4">
            <div class="w-10 h-10 rounded-lg bg-surface-container-highest overflow-hidden flex items-center justify-center text-sm font-semibold text-primary">
              ${toInitials(merchant.name)}
            </div>
            <div>
              <p class="font-semibold text-on-surface">${merchant.name}</p>
              <p class="text-xs text-on-surface-variant">${contact}</p>
            </div>
          </div>
        </td>
        <td class="px-8 py-5 text-sm text-on-surface">${contact}</td>
        <td class="px-8 py-5 text-sm text-on-surface-variant">${formatDate(
          merchant.createdAt,
        )}</td>
        <td class="px-8 py-5">
          <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${statusClass}">
            <span class="w-1.5 h-1.5 rounded-full ${dotClass}"></span>
            ${statusLabel}
          </span>
        </td>
        <td class="px-8 py-5 text-right">
          <button class="p-2 hover:bg-surface-container-high rounded-lg text-on-surface-variant transition-all">
            <span class="material-symbols-outlined" data-icon="more_horiz">more_horiz</span>
          </button>
        </td>
      </tr>
    `;
    })
    .join("");

function MerchantList() {
  const containerRef = useRef(null);
  const merchantsRef = useRef([]);
  const navigate = useNavigate();
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const getExportColumns = () => [
    { key: "name", label: "Merchant", accessor: (merchant) => merchant.name || "-" },
    {
      key: "contact",
      label: "Contact",
      accessor: (merchant) => merchant.email || merchant.phone || "No contact",
    },
    {
      key: "onboarded",
      label: "Onboarded",
      accessor: (merchant) => (merchant.createdAt ? formatDate(merchant.createdAt) : "-"),
    },
    {
      key: "status",
      label: "Status",
      accessor: (merchant) => (merchant.isActive ? "Active" : "Inactive"),
    },
  ];

  const handleCsvExport = () => {
    if (!merchantsRef.current.length) return;
    downloadCsv({
      filename: "i-metro-merchants",
      columns: getExportColumns(),
      rows: merchantsRef.current,
    });
  };

  const handlePdfExport = () => {
    if (!merchantsRef.current.length) return;
    printPdf({
      title: "I-Metro Merchant Management",
      subtitle: "Live merchant directory from the admin backend",
      filename: "i-metro-merchants",
      columns: getExportColumns(),
      rows: merchantsRef.current,
    });
  };

  useEffect(() => {
    let cleanupHandler = null;

    const load = async () => {
      setError("");
      setLoading(true);
      try {
        const response = await fetchWithAuth("/admin/merchants");
        if (!response.ok) {
          setError("Unable to load merchants.");
          return;
        }
        const merchants = await response.json();
        merchantsRef.current = merchants;
        const target = containerRef.current;
        if (!target) return;

        const heading = target.querySelector("h2");
        if (heading) heading.textContent = "Merchants";
        const subtitle = heading?.nextElementSibling;
        if (subtitle) {
          subtitle.textContent =
            "Manage onboarded merchants and their operational status.";
        }

        const directoryHeading = Array.from(target.querySelectorAll("h4")).find(
          (node) => node.textContent?.trim().includes("User Directory"),
        );
        if (directoryHeading) directoryHeading.textContent = "Merchant Directory";

        const ths = Array.from(target.querySelectorAll("table thead th"));
        if (ths.length >= 5) {
          ths[0].textContent = "Merchant";
          ths[1].textContent = "Contact";
          ths[2].textContent = "Onboarded";
          ths[3].textContent = "Status";
          ths[4].textContent = "Actions";
        }

        const tbody = target.querySelector("table tbody");
        if (tbody) {
          if (!merchants.length) {
            tbody.innerHTML = `
              <tr>
                <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="5">
                  No merchants have been onboarded yet.
                </td>
              </tr>
            `;
          } else {
            tbody.innerHTML = renderRows(merchants.slice(0, 10));
          }
          const handler = (event) => {
            const row = event.target.closest("tr[data-merchant-id]");
            if (!row) return;
            const id = row.getAttribute("data-merchant-id");
            if (!id) return;
            localStorage.setItem("i_metro_admin_selected_merchant", id);
            navigate(`/admin/merchant-details?id=${id}`);
          };
          tbody.addEventListener("click", handler);
          cleanupHandler = () => tbody.removeEventListener("click", handler);
        }

        const total = merchants.length;
        const countLabel = Array.from(target.querySelectorAll("p")).find((item) =>
          item.textContent?.includes("Showing"),
        );
        if (countLabel) {
          const showing = Math.min(total, 10);
          countLabel.textContent = total
            ? `Showing 1 to ${showing} of ${total} merchants`
            : "Showing 0 merchants";
        }

        const startOfToday = new Date();
        startOfToday.setHours(0, 0, 0, 0);
        const last24h = Date.now() - 24 * 60 * 60 * 1000;
        const activeMerchants = merchants.filter((item) => item.isActive).length;
        const newToday = merchants.filter(
          (item) => item.createdAt && new Date(item.createdAt) >= startOfToday,
        ).length;
        const newLast24h = merchants.filter(
          (item) => item.createdAt && new Date(item.createdAt) >= last24h,
        ).length;

        const activeLabel = Array.from(target.querySelectorAll("p")).find(
          (node) => node.textContent?.trim() === "Active Users",
        );
        if (activeLabel) {
          activeLabel.textContent = "Active Merchants";
          const card = activeLabel.closest("div");
          const valueNode = card?.querySelector("h3");
          if (valueNode)
            valueNode.textContent = activeMerchants.toLocaleString("en-NG");
          const badge = card?.querySelector("span.text-primary");
          if (badge) badge.textContent = "Live";
        }

        const newTodayLabel = Array.from(target.querySelectorAll("p")).find(
          (node) => node.textContent?.trim() === "New Today",
        );
        if (newTodayLabel) {
          const card = newTodayLabel.closest("div");
          const valueNode = card?.querySelector("h3");
          if (valueNode) valueNode.textContent = newToday.toLocaleString("en-NG");
          const helperText = card?.querySelector("span.text-on-surface-variant");
          if (helperText) helperText.textContent = "created today";
        }

        const healthLabel = Array.from(target.querySelectorAll("p")).find((node) =>
          node.textContent?.trim().includes("Network Health"),
        );
        if (healthLabel) {
          healthLabel.textContent = "Merchant Health";
          const card = healthLabel.closest("div");
          const valueNode = card?.querySelector("h3");
          const percent = total ? (activeMerchants / total) * 100 : 0;
          if (valueNode) {
            valueNode.textContent = total
              ? `${percent.toFixed(1)}% Active`
              : "No merchant data yet";
          }
          const body = card?.querySelector("p.text-sm");
          if (body) {
            body.textContent = total
              ? `${activeMerchants} of ${total} merchants are active.`
              : "No merchants yet to calculate merchant health.";
          }
        }

        const securityTitle = Array.from(target.querySelectorAll("h5")).find(
          (node) => node.textContent?.trim() === "Security Overview",
        );
        if (securityTitle) {
          const card = securityTitle.closest("div");
          const paragraph = card?.querySelector("p");
          const inactiveMerchants = total - activeMerchants;
          if (paragraph) {
            paragraph.textContent = `Active merchants: ${activeMerchants.toLocaleString(
              "en-NG",
            )}. Inactive merchants: ${inactiveMerchants.toLocaleString(
              "en-NG",
            )}. New in last 24 hours: ${newLast24h.toLocaleString("en-NG")}.`;
          }
          const auditLink = card?.querySelector("a");
          if (auditLink) auditLink.setAttribute("href", "/admin/activity");
        }

        const densityTitle = Array.from(target.querySelectorAll("h5")).find(
          (node) => node.textContent?.trim() === "Regional Density",
        );
        if (densityTitle) {
          densityTitle.textContent = "Activation Split";
          const card = densityTitle.closest("div");
          const bar = card?.querySelector("div.h-2 > div");
          const percent = total ? Math.round((activeMerchants / total) * 100) : 0;
          if (bar) bar.style.width = `${Math.min(100, percent)}%`;
          const labels = card?.querySelectorAll("span");
          if (labels && labels.length >= 2) {
            labels[0].textContent = "Active merchants";
            labels[1].textContent = total
              ? `${activeMerchants.toLocaleString("en-NG")} merchants`
              : "No merchants";
          }
        }
      } catch {
        setError("Unable to load merchants.");
      } finally {
        setLoading(false);
      }
    };

    load();
    return () => {
      if (cleanupHandler) cleanupHandler();
    };
  }, [navigate]);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading merchants...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />
      <HtmlScreen
        html={totalUsersHtml}
        title="Merchants"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
    </>
  );
}

export default MerchantList;
