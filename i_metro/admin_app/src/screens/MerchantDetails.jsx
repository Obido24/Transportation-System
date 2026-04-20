import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useLocation } from "react-router-dom";

import ExportToolbar from "../components/ExportToolbar";
import HtmlScreen from "./HtmlScreen";
import merchantDetailsHtml from "./html/merchant_details.html?raw";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const wrapperClassName = "min-h-screen";

const formatMonthYear = (value) => {
  if (!value) return "-";
  return new Intl.DateTimeFormat("en-GB", {
    month: "short",
    year: "numeric",
  }).format(new Date(value));
};

const formatCurrency = (value, currency = "NGN") => {
  if (value === null || value === undefined) return "-";
  try {
    return new Intl.NumberFormat("en-NG", {
      style: "currency",
      currency,
      maximumFractionDigits: 0,
    }).format(value);
  } catch {
    return `${currency} ${Number(value).toLocaleString("en-NG")}`;
  }
};

const getMerchantId = (location) => {
  const params = new URLSearchParams(location.search);
  return (
    params.get("id") || localStorage.getItem("i_metro_admin_selected_merchant")
  );
};

function MerchantDetails() {
  const containerRef = useRef(null);
  const location = useLocation();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [merchant, setMerchant] = useState(null);
  const [statusLoading, setStatusLoading] = useState(false);

  const merchantId = useMemo(() => getMerchantId(location), [location]);

  const getExportColumns = useCallback(() => [
    { key: "name", label: "Merchant", accessor: () => merchant?.name || "Merchant record" },
    {
      key: "email",
      label: "Email",
      accessor: () => merchant?.email || "Not provided",
    },
    {
      key: "phone",
      label: "Phone",
      accessor: () => merchant?.phone || "Not provided",
    },
    {
      key: "status",
      label: "Status",
      accessor: () => (merchant?.isActive ? "Active" : "Inactive"),
    },
    {
      key: "onboarded",
      label: "Onboarded",
      accessor: () => formatMonthYear(merchant?.createdAt),
    },
    {
      key: "risk",
      label: "Risk",
      accessor: () => (merchant?.isActive ? "Normal" : "Review"),
    },
  ], [merchant]);

  const handleCsvExport = useCallback(() => {
    if (!merchant) return;
    downloadCsv({
      filename: `i-metro-merchant-${merchant.id ?? "details"}`,
      columns: getExportColumns(),
      rows: [merchant],
    });
  }, [getExportColumns, merchant]);

  const handlePdfExport = useCallback(() => {
    if (!merchant) return;
    printPdf({
      title: "I-Metro Merchant Details",
      subtitle: `${merchant.name || "Merchant record"} profile summary`,
      filename: `i-metro-merchant-${merchant.id ?? "details"}`,
      columns: getExportColumns(),
      rows: [merchant],
    });
  }, [getExportColumns, merchant]);

  useEffect(() => {
    const load = async () => {
      if (!merchantId) {
        setError("Select a merchant from Merchant Management first.");
        return;
      }
      setLoading(true);
      setError("");
      try {
        const response = await fetchWithAuth(`/admin/merchants/${merchantId}`);
        if (!response.ok) {
          setError("Unable to load merchant details.");
          return;
        }
        const data = await response.json();
        setMerchant(data);
      } catch {
        setError("Unable to load merchant details.");
      } finally {
        setLoading(false);
      }
    };

    load();
  }, [merchantId]);

  useEffect(() => {
    if (!merchant) return;
    const container = containerRef.current;
    if (!container) return;

    const heading = container.querySelector("h2");
    if (heading) heading.textContent = merchant.name || "Merchant";

    const badge = container.querySelector("span.bg-primary\\/90");
    if (badge) {
      if (merchant.isActive) {
        badge.textContent = "Verified Merchant";
      } else {
        badge.textContent = "Inactive Merchant";
      }
    }

    const updateDetail = (label, value) => {
      const labelNode = Array.from(container.querySelectorAll("p")).find(
        (node) => node.textContent?.trim() === label,
      );
      const valueNode = labelNode?.nextElementSibling;
      if (valueNode) valueNode.textContent = value;
    };

    updateDetail("Email Address", merchant.email || "Not provided");
    updateDetail("Direct Line", merchant.phone || "Not provided");
    updateDetail("Office Address", "Not provided");

    const updateBusiness = (label, value) => {
      const labelNode = Array.from(container.querySelectorAll("p")).find(
        (node) => node.textContent?.trim() === label,
      );
      const valueNode = labelNode?.nextElementSibling;
      if (valueNode) valueNode.textContent = value;
    };

    updateBusiness("Merchant ID", merchant.id);
    updateBusiness("Onboarding", formatMonthYear(merchant.createdAt));
    updateBusiness("Category", "Not set");

    const riskLabel = Array.from(container.querySelectorAll("p")).find(
      (node) => node.textContent?.trim() === "Risk Tier",
    );
    if (riskLabel) {
      const riskValue = riskLabel.parentElement?.querySelector("p.text-sm");
      if (riskValue) riskValue.textContent = merchant.isActive ? "Normal" : "Review";
    }

    const routeList = container.querySelector("section:nth-of-type(2) .space-y-3");
    if (routeList) {
      routeList.innerHTML = `
        <div class="text-sm text-on-surface-variant">No associated routes yet.</div>
      `;
    }

    const statCards = Array.from(container.querySelectorAll("div.bg-surface-container-lowest"));
    statCards.forEach((card) => {
      const label = card.querySelector("p");
      const value = card.querySelector("h4");
      if (!label || !value) return;
      if (label.textContent?.includes("Monthly Volume")) {
        value.textContent = formatCurrency(0);
      }
      if (label.textContent?.includes("Avg Transaction")) {
        value.textContent = formatCurrency(0);
      }
      if (label.textContent?.includes("Commission Rate")) {
        value.textContent = "0%";
      }
    });

    const txnTable = container.querySelector("section table tbody");
    if (txnTable) {
      txnTable.innerHTML = `
        <tr>
          <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="6">
            No transactions yet.
          </td>
        </tr>
      `;
    }

    const deviceCard = Array.from(container.querySelectorAll("h3")).find((node) =>
      node.textContent?.trim().includes("Device Distribution"),
    );
    if (deviceCard) {
      const card = deviceCard.closest("div");
      const centerLabel = card?.querySelector("span.text-lg");
      if (centerLabel) centerLabel.textContent = "0%";
      const splits = card?.querySelectorAll("span.text-xs.text-on-surface-variant");
      if (splits && splits.length) {
        splits.forEach((span) => (span.textContent = "0%"));
      }
    }

    const reportButton = Array.from(container.querySelectorAll("button")).find((button) =>
      button.textContent?.includes("Generate Report"),
    );
    if (reportButton) {
      reportButton.style.display = "none";
      reportButton.setAttribute("aria-hidden", "true");
    }

    const downloadButton = Array.from(container.querySelectorAll("button")).find((button) =>
      button.querySelector("[data-icon='download']"),
    );
    if (downloadButton) {
      downloadButton.style.display = "none";
      downloadButton.setAttribute("aria-hidden", "true");
    }
  }, [merchant, handleCsvExport, handlePdfExport]);

  const updateMerchantStatus = async (isActive) => {
    if (!merchant) return;
    setStatusLoading(true);
    setError("");
    try {
      const response = await fetchWithAuth(`/admin/merchants/${merchant.id}/status`, {
        method: "PATCH",
        body: JSON.stringify({ isActive }),
      });
      if (!response.ok) {
        setError("Unable to update merchant status.");
        return;
      }
      const updated = await response.json();
      setMerchant((current) => (current ? { ...current, isActive: updated.isActive } : current));
    } catch {
      setError("Unable to update merchant status.");
    } finally {
      setStatusLoading(false);
    }
  };

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading merchant details...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      {merchant && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-3 text-sm flex items-center justify-between gap-4">
          <span>
            Merchant status:{" "}
            <strong className="text-on-surface">{merchant.isActive ? "Active" : "Inactive"}</strong>
          </span>
          <button
            className={`rounded-full px-4 py-2 text-sm font-semibold ${
              merchant.isActive
                ? "bg-error text-white"
                : "bg-primary text-on-primary"
            } disabled:opacity-60`}
            disabled={statusLoading}
            onClick={() => updateMerchantStatus(!merchant.isActive)}
            type="button"
          >
            {statusLoading
              ? "Updating..."
              : merchant.isActive
                ? "Deactivate Merchant"
                : "Activate Merchant"}
          </button>
        </div>
      )}
      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />
      <HtmlScreen
        html={merchantDetailsHtml}
        title="Merchant Details"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
    </>
  );
}

export default MerchantDetails;
