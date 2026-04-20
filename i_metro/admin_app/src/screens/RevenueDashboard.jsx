import { useEffect, useRef, useState } from "react";

import ExportToolbar from "../components/ExportToolbar";
import HtmlScreen from "./HtmlScreen";
import revenueDashboardHtml from "./html/transaction_revenue_dashboard.html?raw";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const wrapperClassName = "min-h-screen";

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

const formatDateTime = (value) => {
  if (!value) return "-";
  const date = new Date(value);
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
};

const statusStyles = {
  SUCCESS: "bg-secondary-container text-on-secondary-fixed-variant",
  PENDING: "bg-amber-100 text-amber-800",
  FAILED: "bg-error-container text-on-error-container",
  REFUNDED: "bg-surface-container-high text-on-surface-variant",
};

const methodLabel = (provider) => {
  switch (provider) {
    case "MONNIFY":
      return "Monnify";
    case "PAYSTACK":
      return "Paystack";
    case "USSD":
      return "USSD";
    default:
      return "Unknown";
  }
};

const normalizePassengerLabel = (value) => {
  const label = String(value ?? "").trim();
  if (!label) return "Unnamed rider";
  if (/^(test|demo|sample)(\s+user)?$/i.test(label) || /^test[\s_-]?user$/i.test(label)) {
    return "Unnamed rider";
  }
  return label;
};

const escapeHtml = (value) =>
  String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");

const renderRows = (payments) =>
  payments
    .map((payment) => {
      const route = payment.booking?.route
        ? `${payment.booking.route.fromLocation} -> ${payment.booking.route.toLocation}`
        : "Route unavailable";
      const rawUser = payment.booking?.user
        ? `${payment.booking.user.firstName ?? ""} ${payment.booking.user.lastName ?? ""}`.trim() ||
          payment.booking.user.email ||
          payment.booking.user.phone ||
          "Unnamed rider"
        : "Unnamed rider";
      const user = normalizePassengerLabel(rawUser);
      const id = payment.id.replace(/-/g, "").slice(0, 6).toUpperCase();
      const status = payment.status ?? "PENDING";
      const badge = statusStyles[status] ?? statusStyles.PENDING;
      return `
      <tr class="hover:bg-surface-container-low transition-colors cursor-pointer" data-payment-id="${payment.id}">
        <td class="px-6 py-4 font-mono text-sm text-on-surface">#IM-${id}</td>
        <td class="px-6 py-4 text-sm text-on-surface-variant">${formatDateTime(
          payment.paidAt ?? payment.createdAt,
        )}</td>
        <td class="px-6 py-4 text-sm font-medium">
          <div class="flex flex-col">
            <span>${route}</span>
            <span class="text-[11px] text-on-surface-variant">${user}</span>
          </div>
        </td>
        <td class="px-6 py-4">
          <span class="flex items-center gap-2 text-sm text-on-surface-variant">
            <span class="material-symbols-outlined text-sm">contactless</span>
            ${methodLabel(payment.provider)}
          </span>
        </td>
        <td class="px-6 py-4 font-bold">${formatCurrency(
          payment.amount,
          payment.currency ?? "NGN",
        )}</td>
        <td class="px-6 py-4">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold ${badge}">
            ${status}
          </span>
        </td>
        <td class="px-6 py-4 text-right">
          <button class="material-symbols-outlined text-on-surface-variant hover:text-primary" data-action="view" title="View payment details">more_vert</button>
        </td>
      </tr>
    `;
    })
    .join("");

function RevenueDashboard() {
  const containerRef = useRef(null);
  const paymentsRef = useRef([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [selectedPayment, setSelectedPayment] = useState(null);
  const closePayment = () => setSelectedPayment(null);

  const getExportColumns = () => [
    {
      key: "id",
      label: "Transaction ID",
      accessor: (payment) => `#IM-${payment.id.replace(/-/g, "").slice(0, 6).toUpperCase()}`,
    },
    {
      key: "paidAt",
      label: "Date & Time",
      accessor: (payment) => formatDateTime(payment.paidAt ?? payment.createdAt),
    },
    {
      key: "route",
      label: "Route",
      accessor: (payment) =>
        payment.booking?.route
          ? `${payment.booking.route.fromLocation} -> ${payment.booking.route.toLocation}`
          : "Route unavailable",
    },
    {
      key: "passenger",
      label: "Passenger",
      accessor: (payment) =>
        normalizePassengerLabel(
          payment.booking?.user
            ? `${payment.booking.user.firstName ?? ""} ${payment.booking.user.lastName ?? ""}`.trim() ||
                payment.booking.user.email ||
                payment.booking.user.phone ||
                "Unnamed rider"
            : "Unnamed rider",
        ),
    },
    {
      key: "provider",
      label: "Provider",
      accessor: (payment) => methodLabel(payment.provider),
    },
    {
      key: "amount",
      label: "Amount",
      accessor: (payment) => formatCurrency(payment.amount, payment.currency ?? "NGN"),
    },
    {
      key: "status",
      label: "Status",
      accessor: (payment) => payment.status ?? "PENDING",
    },
  ];

  const handleCsvExport = () => {
    if (!paymentsRef.current.length) return;
    downloadCsv({
      filename: "i-metro-revenue",
      columns: getExportColumns(),
      rows: paymentsRef.current,
    });
  };

  const handlePdfExport = () => {
    if (!paymentsRef.current.length) return;
    printPdf({
      title: "I-Metro Revenue Dashboard",
      subtitle: "Live payment records from the admin backend",
      filename: "i-metro-revenue",
      columns: getExportColumns(),
      rows: paymentsRef.current,
    });
  };

  useEffect(() => {
    let cleanupFilter = null;
    let cleanupRows = null;
    let cleanupViewAll = null;

    const load = async () => {
      setLoading(true);
      setError("");
      try {
        const [paymentsRes, routesRes] = await Promise.all([
          fetchWithAuth("/admin/payments"),
          fetchWithAuth("/admin/routes"),
        ]);

        if (!paymentsRes.ok) {
          setError("Unable to load revenue data.");
          return;
        }

        const payments = await paymentsRes.json();
        paymentsRef.current = payments;
        const routes = routesRes.ok ? await routesRes.json() : [];

        const successfulPayments = payments.filter(
          (payment) => payment.status === "SUCCESS",
        );
        const totalRevenue = successfulPayments
          .reduce((sum, payment) => sum + (payment.amount ?? 0), 0);
        const averageFare = successfulPayments.length
          ? totalRevenue / successfulPayments.length
          : 0;
        const refundRate = payments.length
          ? (payments.filter((payment) => payment.status === "REFUNDED").length /
              payments.length) *
            100
          : 0;

        const container = containerRef.current;
        if (!container) return;

        const totalLabel = Array.from(container.querySelectorAll("p")).find(
          (node) => node.textContent?.includes("Total Revenue"),
        );
        if (totalLabel) {
          const card = totalLabel.closest("div");
          totalLabel.textContent = "Total Revenue (NGN)";
          const value = card?.querySelector("p.text-3xl");
          if (value) value.textContent = formatCurrency(totalRevenue);
          const badge = card?.querySelector("span.text-primary-fixed-variant");
          if (badge) badge.textContent = "Live";
        }

        const avgLabel = Array.from(container.querySelectorAll("p")).find((node) =>
          node.textContent?.includes("Average Fare"),
        );
        if (avgLabel) {
          const card = avgLabel.closest("div");
          const value = card?.querySelector("p.text-3xl");
          if (value) value.textContent = formatCurrency(averageFare);
        }

        const refundLabel = Array.from(container.querySelectorAll("p")).find(
          (node) => node.textContent?.includes("Refund Rate"),
        );
        if (refundLabel) {
          const card = refundLabel.closest("div");
          const value = card?.querySelector("p.text-3xl");
          if (value) value.textContent = `${refundRate.toFixed(2)}%`;
        }

        const promoLabel = Array.from(container.querySelectorAll("p")).find((node) =>
          node.textContent?.includes("Active Promos"),
        );
        if (promoLabel) {
          const card = promoLabel.closest("div");
          const value = card?.querySelector("p.text-3xl");
          if (value) value.textContent = "0";
          const badge = card?.querySelector("span.text-on-surface-variant");
          if (badge) badge.textContent = "No promos";
        }

        const chart = container.querySelector("div.p-6.h-80");
        if (chart) {
          const bars = Array.from(chart.children).filter((child) =>
            child.classList.contains("bg-primary/20"),
          );
          const now = new Date();
          now.setHours(0, 0, 0, 0);
          const dailyTotals = Array.from({ length: 7 }).map((_, index) => {
            const dayStart = new Date(now);
            dayStart.setDate(now.getDate() - (6 - index));
            const dayEnd = new Date(dayStart);
            dayEnd.setDate(dayStart.getDate() + 1);
            return successfulPayments
              .filter((payment) => {
                const date = new Date(payment.createdAt);
                return date >= dayStart && date < dayEnd;
              })
              .reduce((sum, payment) => sum + (payment.amount ?? 0), 0);
          });
          const max = Math.max(...dailyTotals, 1);
          bars.forEach((bar, index) => {
            const height = Math.max(10, Math.round((dailyTotals[index] / max) * 100));
            bar.style.height = `${height}%`;
            const inner = bar.querySelector("div");
            if (inner) inner.style.height = `${Math.max(10, height / 2)}%`;
          });
        }

        const distribution = Array.from(container.querySelectorAll("h3")).find(
          (node) => node.textContent?.trim() === "Route Distribution",
        );
        if (distribution) {
          const card = distribution.closest("div");
          const routeTotals = routes
            .map((route) => {
              const routePayments = successfulPayments.filter(
                (payment) => payment.booking?.route?.id === route.id,
              );
              const total = routePayments.reduce((sum, payment) => sum + (payment.amount ?? 0), 0);
              return {
                name: `${route.fromLocation} -> ${route.toLocation}`,
                total,
                trips: routePayments.length,
              };
            })
            .filter((item) => item.trips > 0 || item.total > 0)
            .sort((a, b) => b.total - a.total || b.trips - a.trips)
            .slice(0, 4);
          const totalAmount = routeTotals.reduce((sum, item) => sum + item.total, 0);
          const totalTrips = routeTotals.reduce((sum, item) => sum + item.trips, 0);

          const blocks = card?.querySelector("div.p-6.space-y-6");
          if (blocks) {
            if (!routeTotals.length) {
              blocks.innerHTML = `
                <div class="rounded-xl bg-surface-container-low px-4 py-4 text-sm text-on-surface-variant">
                  No successful payments yet to build route distribution.
                </div>
              `;
            } else {
              blocks.innerHTML =
                routeTotals
                  .map((route, index) => {
                    const percent = totalAmount
                      ? Math.round((route.total / totalAmount) * 100)
                      : 0;
                    const barClass =
                      index === 0
                        ? "bg-primary"
                        : index === 1
                          ? "bg-primary-container"
                          : index === 2
                            ? "bg-secondary"
                            : "bg-outline";
                    return `
                      <div class="space-y-2">
                        <div class="flex flex-wrap items-center justify-between gap-2 text-sm font-bold">
                          <span>${escapeHtml(route.name)}</span>
                          <span>${route.trips} trips · ${formatCurrency(route.total)}</span>
                        </div>
                        <div class="w-full bg-surface-container-high h-2 rounded-full overflow-hidden">
                          <div class="${barClass} h-full" style="width: ${percent}%"></div>
                        </div>
                      </div>
                    `;
                  })
                  .join("") +
                `
                  <div class="pt-6 border-t border-outline-variant/20">
                    <p class="text-xs font-bold text-on-surface-variant uppercase tracking-widest mb-2">Route Summary</p>
                    <p class="text-sm text-on-surface-variant">
                      ${totalTrips} successful trips across ${routeTotals.length} active routes, totaling ${formatCurrency(totalAmount)}.
                    </p>
                  </div>
                `;
            }
          }
        }

        const tableBody = container.querySelector("table tbody");
        const filterGroup = container.querySelector("[data-filter-group='payment-status']");
        const filterButtons = filterGroup
          ? Array.from(filterGroup.querySelectorAll("button[data-filter]"))
          : [];
        const viewAllButton = Array.from(container.querySelectorAll("button")).find((button) =>
          button.textContent?.trim() === "View All",
        );
        const openPayment = (paymentId) => {
          const payment = paymentsRef.current.find((item) => item.id === paymentId);
          if (payment) setSelectedPayment(payment);
        };
        const rowClickHandler = (event) => {
          const row = event.target.closest("tr[data-payment-id]");
          if (!row) return;
          const paymentId = row.getAttribute("data-payment-id");
          if (!paymentId) return;
          openPayment(paymentId);
        };
        const applyFilter = (filter) => {
          if (!tableBody) return;
          const normalized = (filter ?? "ALL").toUpperCase();
          const filtered =
            normalized === "ALL"
              ? payments
              : payments.filter(
                  (payment) => (payment.status ?? "PENDING").toUpperCase() === normalized,
                );
          if (!filtered.length) {
            tableBody.innerHTML = `
              <tr>
                <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="7">
                  No ${normalized.toLowerCase()} payment records found. Use View All to return to the full revenue list.
                </td>
              </tr>
            `;
          } else {
            tableBody.innerHTML = renderRows(filtered.slice(0, 8));
          }
        };

        if (tableBody) {
          tableBody.addEventListener("click", rowClickHandler);
          cleanupRows = () => tableBody.removeEventListener("click", rowClickHandler);
        }

        if (filterButtons.length) {
          const setActive = (filter) => {
            filterButtons.forEach((button) => {
              const isActive = button.dataset.filter === filter;
              button.classList.toggle("bg-primary", isActive);
              button.classList.toggle("text-on-primary", isActive);
              button.classList.toggle("text-on-surface-variant", !isActive);
              button.classList.toggle("hover:bg-surface-container-low", !isActive);
            });
          };
          const handler = (event) => {
            const button = event.target.closest("button[data-filter]");
            if (!button) return;
            const filter = button.dataset.filter ?? "ALL";
            setActive(filter);
            applyFilter(filter);
          };
          filterGroup.addEventListener("click", handler);
          cleanupFilter = () => filterGroup.removeEventListener("click", handler);
          setActive("ALL");
          applyFilter("ALL");
        } else if (tableBody) {
          if (!payments.length) {
            tableBody.innerHTML = `
              <tr>
                <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="7">
                  No payments have been recorded yet.
                </td>
              </tr>
            `;
          } else {
            tableBody.innerHTML = renderRows(payments.slice(0, 8));
          }
        }

        if (viewAllButton) {
          const handler = () => {
            if (!tableBody) return;
            if (filterButtons.length) {
              filterButtons.forEach((button) => {
                const isActive = button.dataset.filter === "ALL";
                button.classList.toggle("bg-primary", isActive);
                button.classList.toggle("text-on-primary", isActive);
                button.classList.toggle("text-on-surface-variant", !isActive);
                button.classList.toggle("hover:bg-surface-container-low", !isActive);
              });
            }
            applyFilter("ALL");
          };
          viewAllButton.addEventListener("click", handler);
          cleanupViewAll = () => viewAllButton.removeEventListener("click", handler);
        }
      } catch {
        setError("Unable to load revenue data.");
      } finally {
        setLoading(false);
      }
    };

    load();

    return () => {
      if (cleanupFilter) cleanupFilter();
      if (cleanupRows) cleanupRows();
      if (typeof cleanupViewAll === "function") cleanupViewAll();
    };
  }, []);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading revenue dashboard...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />
      <HtmlScreen
        html={revenueDashboardHtml}
        title="Revenue Dashboard"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
      {selectedPayment && (
        <div
          className="fixed inset-0 z-[60] flex items-center justify-center bg-black/50 px-4 py-8"
          onClick={() => setSelectedPayment(null)}
          role="presentation"
        >
          <div
            className="w-full max-w-3xl rounded-3xl bg-surface-container-lowest shadow-2xl border border-outline-variant/20 overflow-hidden"
            onClick={(event) => event.stopPropagation()}
            role="presentation"
          >
            <div className="flex items-start justify-between gap-4 border-b border-outline-variant/10 px-6 py-5">
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.2em] text-on-surface-variant">
                  Payment Details
                </p>
                <h3 className="mt-1 text-2xl font-bold text-on-surface">
                  #{selectedPayment.id.slice(0, 8).toUpperCase()}
                </h3>
                <p className="mt-1 text-sm text-on-surface-variant">
                  {selectedPayment.booking?.route
                    ? `${selectedPayment.booking.route.fromLocation} -> ${selectedPayment.booking.route.toLocation}`
                    : "Route unavailable"}
                </p>
              </div>
              <button
                className="rounded-full p-2 text-on-surface-variant hover:bg-surface-container-low"
                onClick={closePayment}
                type="button"
              >
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            <div className="grid gap-6 px-6 py-6 lg:grid-cols-[1.1fr_0.9fr]">
              <div className="space-y-4">
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                      Amount
                    </p>
                    <p className="mt-1 text-lg font-semibold text-on-surface">
                      {formatCurrency(selectedPayment.amount, selectedPayment.currency ?? "NGN")}
                    </p>
                  </div>
                  <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                      Status
                    </p>
                    <p className="mt-1 text-lg font-semibold text-on-surface">
                      {selectedPayment.status ?? "PENDING"}
                    </p>
                  </div>
                  <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                      Provider
                    </p>
                    <p className="mt-1 text-lg font-semibold text-on-surface">
                      {methodLabel(selectedPayment.provider)}
                    </p>
                  </div>
                  <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                      Paid At
                    </p>
                    <p className="mt-1 text-lg font-semibold text-on-surface">
                      {formatDateTime(selectedPayment.paidAt ?? selectedPayment.createdAt)}
                    </p>
                  </div>
                </div>

                <div className="rounded-2xl border border-outline-variant/15 bg-white px-4 py-4">
                  <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                    Transaction Metadata
                  </p>
                  <div className="mt-3 space-y-3 text-sm">
                    <div className="flex items-center justify-between gap-4">
                      <span className="text-on-surface-variant">Payment reference</span>
                      <span className="font-mono font-semibold text-on-surface">
                        {selectedPayment.providerRef || "Not available"}
                      </span>
                    </div>
                    <div className="flex items-center justify-between gap-4">
                      <span className="text-on-surface-variant">Booking ID</span>
                      <span className="font-mono font-semibold text-on-surface">
                        {selectedPayment.bookingId}
                      </span>
                    </div>
                    <div className="flex items-center justify-between gap-4">
                      <span className="text-on-surface-variant">Route</span>
                      <span className="font-semibold text-on-surface">
                        {selectedPayment.booking?.route
                          ? `${selectedPayment.booking.route.fromLocation} -> ${selectedPayment.booking.route.toLocation}`
                          : "Unknown route"}
                      </span>
                    </div>
                    <div className="flex items-center justify-between gap-4">
                      <span className="text-on-surface-variant">Passenger</span>
                      <span className="font-semibold text-on-surface">
                        {selectedPayment.booking?.user
                          ? `${selectedPayment.booking.user.firstName ?? ""} ${selectedPayment.booking.user.lastName ?? ""}`.trim() ||
                            selectedPayment.booking.user.email ||
                            selectedPayment.booking.user.phone ||
                            "Rider unavailable"
                          : "Rider unavailable"}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <div className="space-y-4">
                <div className="rounded-2xl bg-primary/5 px-4 py-4 border border-primary/10">
                  <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-primary">
                    Quick Snapshot
                  </p>
                  <p className="mt-2 text-sm text-on-surface-variant">
                    Use this panel to inspect the exact payment behind a revenue row.
                  </p>
                  <div className="mt-4 grid gap-3">
                    <div className="rounded-xl bg-white px-4 py-3 border border-outline-variant/10">
                      <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                        Created
                      </p>
                      <p className="mt-1 text-sm font-semibold text-on-surface">
                        {formatDateTime(selectedPayment.createdAt)}
                      </p>
                    </div>
                    <div className="rounded-xl bg-white px-4 py-3 border border-outline-variant/10">
                      <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                        Currency
                      </p>
                      <p className="mt-1 text-sm font-semibold text-on-surface">
                        {selectedPayment.currency ?? "NGN"}
                      </p>
                    </div>
                  </div>
                </div>
                <button
                  className="w-full rounded-xl bg-primary px-4 py-3 text-sm font-semibold text-on-primary hover:opacity-95"
                  onClick={closePayment}
                  type="button"
                >
                  Close Details
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

export default RevenueDashboard;
