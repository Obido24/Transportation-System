import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";

import HtmlScreen from "./HtmlScreen";
import dashboardMainHtml from "./html/dashboard_main.html?raw";
import { fetchWithAuth } from "../lib/api";

const wrapperClassName = "min-h-screen";

const formatCurrency = (amount, currency = "NGN") => {
  try {
    return new Intl.NumberFormat("en-NG", {
      style: "currency",
      currency,
      maximumFractionDigits: 0,
    }).format(amount);
  } catch {
    return `${currency} ${Number(amount ?? 0).toLocaleString("en-NG")}`;
  }
};

const formatCompactNumber = (value) =>
  new Intl.NumberFormat("en-NG", { notation: "compact" }).format(Number(value ?? 0));

const normalizePassengerLabel = (value) => {
  const label = String(value ?? "").trim();
  if (!label) return "Unnamed rider";
  if (/^(test|demo|sample)(\s+user)?$/i.test(label) || /^test[\s_-]?user$/i.test(label)) {
    return "Unnamed rider";
  }
  return label;
};

const getInitials = (user) => {
  const first = user?.firstName?.trim() ?? "";
  const last = user?.lastName?.trim() ?? "";
  if (first || last) {
    return `${first.charAt(0)}${last.charAt(0)}`.toUpperCase();
  }
  const emailOrPhone = user?.email ?? user?.phone ?? "";
  return emailOrPhone ? emailOrPhone.charAt(0).toUpperCase() : "U";
};

const formatRelativeTime = (value) => {
  if (!value) return "-";
  const now = Date.now();
  const date = new Date(value).getTime();
  const diffMs = Math.max(now - date, 0);
  const minutes = Math.floor(diffMs / 60000);
  if (minutes < 1) return "Just now";
  if (minutes < 60) return `${minutes} mins ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} hrs ago`;
  const days = Math.floor(hours / 24);
  return `${days} days ago`;
};

const statusStyles = {
  SUCCESS: "bg-emerald-100 text-emerald-800",
  PENDING: "bg-amber-100 text-amber-800",
  FAILED: "bg-red-100 text-red-700",
  REFUNDED: "bg-slate-100 text-slate-700",
};

const renderTransactionRows = (payments) =>
  payments
    .map((payment) => {
      const booking = payment.booking;
      const rawPassenger =
        `${booking?.user?.firstName ?? ""} ${booking?.user?.lastName ?? ""}`.trim() ||
        booking?.user?.email ||
        booking?.user?.phone ||
        "Unnamed rider";
      const passenger = normalizePassengerLabel(rawPassenger);
      const bookingId = booking?.id ?? payment.id;
      const shortId = bookingId ? bookingId.replace(/-/g, "").slice(0, 6).toUpperCase() : "IM";
      const route = booking?.route
        ? `${booking.route.fromLocation} -> ${booking.route.toLocation}`
        : "Unknown Route";
      const timeLabel = formatRelativeTime(payment.paidAt ?? payment.createdAt);
      const status = (payment.status ?? "PENDING").toUpperCase();
      const badgeClass = statusStyles[status] ?? statusStyles.PENDING;

      return `
        <tr class="hover:bg-surface-container-low/30 transition-colors">
          <td class="px-6 py-5 font-mono text-sm text-on-surface-variant">#IM-${shortId}</td>
          <td class="px-6 py-5">
            <div class="flex items-center gap-3">
              <div class="w-8 h-8 rounded-full bg-secondary-container flex items-center justify-center text-secondary font-bold text-xs">
                ${getInitials(booking?.user)}
              </div>
              <span class="text-sm font-medium">${passenger}</span>
            </div>
          </td>
          <td class="px-6 py-5">
            <span class="text-xs font-bold px-2 py-1 bg-primary-fixed-dim/20 text-primary rounded">${route}</span>
          </td>
          <td class="px-6 py-5 text-sm text-on-surface-variant">${timeLabel}</td>
          <td class="px-6 py-5 text-right">
            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold ${badgeClass}">
              ${status}
            </span>
          </td>
        </tr>
      `;
    })
    .join("");

function DashboardMain() {
  const containerRef = useRef(null);
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let cleanupFilter = null;
    let routeRefreshHandler = null;

    const load = async () => {
      setLoading(true);
      setError("");

      try {
        const [response, validatorLogsResponse] = await Promise.all([
          fetchWithAuth("/admin/dashboard/summary"),
          fetchWithAuth("/admin/validator/logs"),
        ]);

        if (!response.ok) {
          setError("Unable to load dashboard metrics.");
          return;
        }

        const summary = await response.json();
        const metrics = summary?.metrics ?? {};
        const paymentTotals = summary?.paymentTotals ?? {
          total: 0,
          PENDING: 0,
          SUCCESS: 0,
          FAILED: 0,
          REFUNDED: 0,
          revenue: 0,
        };
        const normalizedBookings = Array.isArray(summary?.bookings) ? summary.bookings : [];
        const normalizedPayments = Array.isArray(summary?.payments)
          ? summary.payments
          : Array.isArray(summary?.recentPayments)
            ? summary.recentPayments
            : [];
        const validatorLogs = validatorLogsResponse.ok ? await validatorLogsResponse.json() : [];
        const activeUsers = Number(metrics.activeUsers ?? 0);
        const totalBookings = Number(metrics.totalBookings ?? normalizedBookings.length);
        const activeRoutes = Number(metrics.activeRoutes ?? 0);
        const bookingsLast24h = Number(metrics.bookingsLast24h ?? 0);

        const container = containerRef.current;
        if (!container) return;

        const setText = (selector, value) => {
          const node = container.querySelector(selector);
          if (node) {
            node.textContent = value;
          }
        };

        setText("[data-dashboard-value='active-users']", formatCompactNumber(activeUsers));
        setText("[data-dashboard-value='bookings']", formatCompactNumber(totalBookings));
        setText("[data-dashboard-value='revenue']", formatCurrency(paymentTotals.revenue, "NGN"));
        setText("[data-dashboard-value='routes']", formatCompactNumber(activeRoutes));
        setText("[data-dashboard-label='revenue']", "Ticket Sales (NGN)");
        setText("[data-dashboard-status-count='PENDING']", formatCompactNumber(paymentTotals.PENDING));
        setText("[data-dashboard-status-count='SUCCESS']", formatCompactNumber(paymentTotals.SUCCESS));
        setText("[data-dashboard-status-count='FAILED']", formatCompactNumber(paymentTotals.FAILED));

        const activeRoutesNode = container.querySelector("[data-metric='active-routes']");
        if (activeRoutesNode) {
          activeRoutesNode.textContent = activeRoutes.toLocaleString("en-NG");
        }

        const bookingsNode = container.querySelector("[data-metric='bookings-24h']");
        if (bookingsNode) {
          bookingsNode.textContent = bookingsLast24h.toLocaleString("en-NG");
        }

        const snapshotNode = container.querySelector('[data-dashboard-snapshot]');
        if (snapshotNode) {
          snapshotNode.textContent =
            formatCompactNumber(activeUsers) +
            " active users, " +
            formatCompactNumber(totalBookings) +
            " bookings, " +
            formatCurrency(paymentTotals.revenue, "NGN") +
            " revenue";
        }

        const operationsButton = container.querySelector("[data-operation-snapshot-action]");
        if (operationsButton) {
          operationsButton.onclick = () => navigate("/admin/routes");
        }

        const latestValidatorLog = Array.isArray(validatorLogs) && validatorLogs.length ? validatorLogs[0] : null;
        const validatorCard = container.querySelector("[data-validator-snapshot-card]");
        if (validatorCard) {
          const statusNode = validatorCard.querySelector("[data-validator-snapshot-status]");
          const busNode = validatorCard.querySelector("[data-validator-snapshot-bus]");
          const busCountNode = validatorCard.querySelector("[data-validator-snapshot-bus-count]");
          const summaryNode = validatorCard.querySelector("[data-validator-snapshot-summary]");
          const validatorNode = validatorCard.querySelector("[data-validator-snapshot-validator]");
          const ticketNode = validatorCard.querySelector("[data-validator-snapshot-ticket]");
          const routeNode = validatorCard.querySelector("[data-validator-snapshot-route]");
          const timeNode = validatorCard.querySelector("[data-validator-snapshot-time]");
          const titleNode = validatorCard.querySelector("[data-validator-snapshot-title]");
          const actionButton = validatorCard.querySelector("[data-validator-snapshot-action]");
          const busCount = new Set(
            (Array.isArray(validatorLogs) ? validatorLogs : [])
              .map((entry) => String(entry?.busLabel ?? "").trim() || "Unassigned bus"),
          ).size;

          if (latestValidatorLog) {
            const valid = latestValidatorLog.isValid ? "VALID" : "INVALID";
            const routeLabel =
              latestValidatorLog.routeId ?? latestValidatorLog.ticketId ?? "No route recorded";
            const validatorLabel =
              latestValidatorLog.validatorDeviceName ??
              latestValidatorLog.validatorDeviceId ??
              "Unknown validator";
            const busLabel = latestValidatorLog.busLabel ?? "Unassigned bus";

            if (statusNode) statusNode.textContent = valid;
            if (busNode) busNode.textContent = busLabel;
            if (busCountNode) {
              busCountNode.textContent = `${busCount} bus${busCount === 1 ? "" : "es"} tracked`;
            }
            if (summaryNode) {
              summaryNode.textContent = latestValidatorLog.isValid
                ? `Last scan was approved on ${busLabel}.`
                : `Last scan was rejected on ${busLabel}.`;
            }
            if (validatorNode) validatorNode.textContent = validatorLabel;
            if (ticketNode) ticketNode.textContent = latestValidatorLog.ticketId ?? "-";
            if (routeNode) routeNode.textContent = routeLabel;
            if (timeNode) timeNode.textContent = latestValidatorLog.timeAgo ?? "-";
            if (titleNode) {
              titleNode.textContent = latestValidatorLog.isValid
                ? "Latest successful validator scan"
                : "Latest validator scan";
            }
            if (actionButton) {
              actionButton.onclick = () =>
                navigate(
                  `/admin/validator-logs?bus=${encodeURIComponent(busLabel)}`,
                );
            }
          } else {
            if (statusNode) statusNode.textContent = "Waiting";
            if (busNode) busNode.textContent = "Unassigned bus";
            if (busCountNode) busCountNode.textContent = "0 buses tracked";
            if (summaryNode) {
              summaryNode.textContent =
                "Validator activity will appear here once a bus attendant scans a ticket.";
            }
            if (validatorNode) validatorNode.textContent = "-";
            if (ticketNode) ticketNode.textContent = "-";
            if (routeNode) routeNode.textContent = "-";
            if (timeNode) timeNode.textContent = "-";
            if (titleNode) titleNode.textContent = "Latest validator scan";
            if (actionButton) {
              actionButton.onclick = () => navigate("/admin/validator-logs");
            }
          }
        }

        const chartContainer = container.querySelector(".h-64");
        if (chartContainer) {
          const bars = Array.from(chartContainer.children).filter((node) => node.tagName === "DIV");
          const now = new Date();
          now.setHours(0, 0, 0, 0);
          const dailyCounts = Array.from({ length: 7 }).map((_, index) => {
            const dayStart = new Date(now);
            dayStart.setDate(now.getDate() - (6 - index));
            const dayEnd = new Date(dayStart);
            dayEnd.setDate(dayStart.getDate() + 1);
            return normalizedBookings.filter((booking) => {
              if (!booking.createdAt) return false;
              const created = new Date(booking.createdAt);
              return created >= dayStart && created < dayEnd;
            }).length;
          });

          const max = Math.max(...dailyCounts, 1);
          bars.forEach((bar, index) => {
            const value = dailyCounts[index % dailyCounts.length];
            const height = Math.max(10, Math.round((value / max) * 100));
            bar.style.height = `${height}%`;
          });
        }

        const tbody = container.querySelector("table tbody");
        const filterGroup = container.querySelector("[data-filter-group='dashboard-payment-status']");
        const filterButtons = filterGroup ? Array.from(filterGroup.querySelectorAll("button[data-filter]")) : [];

        const applyFilter = (filter) => {
          if (!tbody) return;
          const normalized = (filter ?? "ALL").toUpperCase();
          const filtered =
            normalized === "ALL"
              ? normalizedPayments
              : normalizedPayments.filter((payment) => (payment.status ?? "PENDING").toUpperCase() === normalized);
          const rows = renderTransactionRows(filtered.slice(0, 6));
          tbody.innerHTML =
            rows ||
            `
            <tr>
              <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="5">
                No transactions found for this status.
              </td>
            </tr>
          `;

          const title = container.querySelector("[data-recent-transactions-title]");
          if (title) {
            const countLabel =
              normalized === "ALL"
                ? `${formatCompactNumber(filtered.length)} shown`
                : `${formatCompactNumber(filtered.length)} ${normalized.toLowerCase()}`;            title.textContent = `Recent Transactions ? ${countLabel}`;
          }
        };

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
        } else if (tbody) {
          const rows = renderTransactionRows(normalizedPayments.slice(0, 6));
          tbody.innerHTML =
            rows ||
            `
            <tr>
              <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="5">
                No transactions found yet.
              </td>
            </tr>
          `;
        }
      } catch {
        setError("Unable to load dashboard metrics.");
      } finally {
        setLoading(false);
      }
    };

    load();

    routeRefreshHandler = () => {
      void load();
    };
    window.addEventListener("i-metro:routes-updated", routeRefreshHandler);

    return () => {
      if (cleanupFilter) cleanupFilter();
      if (routeRefreshHandler) {
        window.removeEventListener("i-metro:routes-updated", routeRefreshHandler);
      }
    };
  }, [navigate]);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading dashboard metrics...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      <HtmlScreen
        html={dashboardMainHtml}
        title="Dashboard"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
    </>
  );
}

export default DashboardMain;
