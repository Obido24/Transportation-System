import { useEffect, useMemo, useRef, useState } from "react";
import { useLocation } from "react-router-dom";

import ExportToolbar from "../components/ExportToolbar";
import HtmlScreen from "./HtmlScreen";
import userDetailsHtml from "./html/user_details.html?raw";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const wrapperClassName = "min-h-screen";

const formatCurrency = (amount, currency = "NGN") => {
  if (amount === null || amount === undefined) return "-";
  try {
    return new Intl.NumberFormat("en-NG", {
      style: "currency",
      currency,
      maximumFractionDigits: 0,
    }).format(amount);
  } catch {
    return `${currency} ${Number(amount).toLocaleString("en-NG")}`;
  }
};

const formatDate = (value) => {
  if (!value) return "-";
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(value));
};

const formatTime = (value) => {
  if (!value) return "-";
  return new Intl.DateTimeFormat("en-GB", {
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(value));
};

const formatAccountAge = (createdAt) => {
  if (!createdAt) return "-";
  const created = new Date(createdAt);
  const now = new Date();
  const diffMs = Math.max(now - created, 0);
  const diffDays = diffMs / (1000 * 60 * 60 * 24);
  if (diffDays < 30) {
    return `${Math.max(1, Math.round(diffDays))}d`;
  }
  const diffMonths = diffDays / 30;
  if (diffMonths < 12) {
    return `${diffMonths.toFixed(1)}m`;
  }
  const diffYears = diffMonths / 12;
  return `${diffYears.toFixed(1)}y`;
};

const getUserId = (location) => {
  const params = new URLSearchParams(location.search);
  return (
    params.get("id") || localStorage.getItem("i_metro_admin_selected_user")
  );
};

const statusClassMap = {
  CONFIRMED: "bg-emerald-100 text-emerald-800",
  PENDING: "bg-amber-100 text-amber-800",
  CANCELLED: "bg-slate-200 text-slate-700",
};

const renderBookingRows = (bookings) =>
  bookings
    .map((booking) => {
      const bookingId = booking.id ?? "IM";
      const shortId = bookingId.replace(/-/g, "").slice(0, 6).toUpperCase();
      const route = booking.route
        ? `${booking.route.fromLocation} -> ${booking.route.toLocation}`
        : "Unknown route";
      const amount = booking.payment?.amount ?? booking.route?.price ?? 0;
      const status = booking.status ?? "PENDING";
      const badgeClass = statusClassMap[status] ?? statusClassMap.PENDING;
      return `
      <tr class="hover:bg-surface-container-low/30 transition-colors">
        <td class="px-8 py-5">
          <span class="font-mono text-xs font-semibold text-primary">#IM-${shortId}</span>
        </td>
        <td class="px-6 py-5">
          <div class="text-sm font-medium">${formatDate(booking.createdAt)}</div>
          <div class="text-[11px] text-on-surface-variant">${formatTime(
            booking.createdAt,
          )}</div>
        </td>
        <td class="px-6 py-5">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded bg-primary-container/20 flex items-center justify-center text-primary">
              <span class="material-symbols-outlined text-sm" data-icon="directions_subway">directions_subway</span>
            </div>
            <div>
              <div class="text-sm font-semibold">${route}</div>
              <div class="text-[11px] text-on-surface-variant">${
                booking.route?.fromLocation ?? "-"
              } -> ${booking.route?.toLocation ?? "-"}</div>
            </div>
          </div>
        </td>
        <td class="px-6 py-5 text-sm text-on-surface-variant">--</td>
        <td class="px-6 py-5 text-sm font-bold">${formatCurrency(amount)}</td>
        <td class="px-6 py-5">
          <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full ${badgeClass} text-[10px] font-bold uppercase">
            <span class="w-1.5 h-1.5 rounded-full"></span>
            ${status}
          </span>
        </td>
        <td class="px-8 py-5 text-right">
          <button class="text-on-surface-variant hover:text-primary transition-colors">
            <span class="material-symbols-outlined text-xl" data-icon="more_vert">more_vert</span>
          </button>
        </td>
      </tr>
    `;
    })
    .join("");

function UserDetails() {
  const containerRef = useRef(null);
  const location = useLocation();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [user, setUser] = useState(null);

  const userId = useMemo(() => getUserId(location), [location]);

  const getExportColumns = () => [
    {
      key: "bookingId",
      label: "Booking ID",
      accessor: (booking) => `#IM-${(booking.id ?? "IM").replace(/-/g, "").slice(0, 6).toUpperCase()}`,
    },
    {
      key: "date",
      label: "Date",
      accessor: (booking) => formatDate(booking.createdAt),
    },
    {
      key: "time",
      label: "Time",
      accessor: (booking) => formatTime(booking.createdAt),
    },
    {
      key: "route",
      label: "Route",
      accessor: (booking) =>
        booking.route
          ? `${booking.route.fromLocation} -> ${booking.route.toLocation}`
          : "Unknown route",
    },
    {
      key: "amount",
      label: "Amount",
      accessor: (booking) => formatCurrency(booking.payment?.amount ?? booking.route?.price ?? 0),
    },
    {
      key: "status",
      label: "Status",
      accessor: (booking) => booking.status ?? "PENDING",
    },
  ];

  const handleCsvExport = () => {
    if (!user?.bookings?.length) return;
    downloadCsv({
      filename: `i-metro-user-${user.id ?? "details"}`,
      columns: getExportColumns(),
      rows: user.bookings,
    });
  };

  const handlePdfExport = () => {
    if (!user?.bookings?.length) return;
    printPdf({
      title: "I-Metro User Details",
      subtitle: `${`${user.firstName ?? ""} ${user.lastName ?? ""}`.trim() || user.email || user.phone || "User record"} booking history`,
      filename: `i-metro-user-${user.id ?? "details"}`,
      columns: getExportColumns(),
      rows: user.bookings,
    });
  };

  useEffect(() => {
    const load = async () => {
      if (!userId) {
        setError("Select a user from User Management first.");
        return;
      }
      setLoading(true);
      setError("");
      try {
        const response = await fetchWithAuth(`/admin/users/${userId}`);
        if (!response.ok) {
          setError("Unable to load user details.");
          return;
        }
        const data = await response.json();
        setUser(data);
      } catch {
        setError("Unable to load user details.");
      } finally {
        setLoading(false);
      }
    };

    load();
  }, [userId]);

  useEffect(() => {
    if (!user) return;
    const container = containerRef.current;
    if (!container) return;

    const name = `${user.firstName ?? ""} ${user.lastName ?? ""}`.trim() ||
      user.email ||
      user.phone ||
      "Unknown";
    const nameNode = container.querySelector("h1");
    if (nameNode) nameNode.textContent = name;

    const statusBadge = nameNode?.parentElement?.querySelector("span");
    if (statusBadge) {
      if (user.isActive) {
        statusBadge.textContent = "Active Member";
        statusBadge.classList.remove("bg-error/20", "text-error");
        statusBadge.classList.add("bg-primary/10", "text-primary");
      } else {
        statusBadge.textContent = "Blocked";
        statusBadge.classList.remove("bg-primary/10", "text-primary");
        statusBadge.classList.add("bg-error/20", "text-error");
      }
    }

    const emailNode = container.querySelector("[data-icon='alternate_email']")?.closest("p");
    if (emailNode) {
      const icon = emailNode.querySelector("[data-icon='alternate_email']");
      const iconHtml = icon ? icon.outerHTML : "";
      const email = user.email || user.phone || "Not provided";
      emailNode.innerHTML = `${iconHtml} ${email}`;
    }

    const updateDetail = (label, value) => {
      const labelNode = Array.from(container.querySelectorAll("p")).find(
        (node) => node.textContent?.trim() === label,
      );
      const valueNode = labelNode?.nextElementSibling;
      if (valueNode) {
        valueNode.textContent = value;
      }
    };

    updateDetail("Mobile Number", user.phone || "Not provided");
    updateDetail("Primary Address", "Not provided");
    updateDetail("Payment Method", "Not provided");

    const updateMetric = (label, value) => {
      const labelNode = Array.from(container.querySelectorAll("p")).find(
        (node) => node.textContent?.trim() === label,
      );
      const card = labelNode?.closest("div");
      const valueNode = card?.querySelector("span.text-2xl");
      if (valueNode) valueNode.textContent = value;
    };

    const bookingCount = user.bookings?.length ?? 0;
    updateMetric("Total Trips", bookingCount.toLocaleString("en-NG"));
    updateMetric("Loyalty Points", "0");
    updateMetric("Account Age", formatAccountAge(user.createdAt));

    const tbody = container.querySelector("table tbody");
    if (tbody) {
      const rows = renderBookingRows((user.bookings ?? []).slice(0, 10));
      tbody.innerHTML =
        rows ||
        `
        <tr>
          <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="7">
            No bookings yet.
          </td>
        </tr>
      `;
    }

    const totalTrips = user.bookings?.length ?? 0;
    const countLabel = Array.from(container.querySelectorAll("p")).find((node) =>
      node.textContent?.includes("Showing"),
    );
    if (countLabel) {
      const showing = Math.min(totalTrips, 10);
      countLabel.textContent = `Showing 1-${showing} of ${totalTrips} trips`;
    }

    const blockButton = Array.from(container.querySelectorAll("button")).find(
      (btn) =>
        btn.textContent?.includes("Block User") ||
        btn.textContent?.includes("Unblock User"),
    );

    if (blockButton) {
      blockButton.dataset.active = user.isActive ? "true" : "false";
      if (user.isActive) {
        blockButton.textContent = "Block User";
        blockButton.classList.remove("bg-primary", "text-on-primary");
        blockButton.classList.add("bg-error", "text-white");
      } else {
        blockButton.textContent = "Unblock User";
        blockButton.classList.remove("bg-error", "text-white");
        blockButton.classList.add("bg-primary", "text-on-primary");
      }

      if (!blockButton.dataset.bound) {
        blockButton.dataset.bound = "true";
        blockButton.addEventListener("click", async (event) => {
          event.preventDefault();
          try {
            const currentActive = blockButton.dataset.active === "true";
            const response = await fetchWithAuth(`/admin/users/${user.id}/status`, {
              method: "PATCH",
              body: JSON.stringify({ isActive: !currentActive }),
            });
            if (response.ok) {
              const updated = await response.json();
              setUser((prev) => (prev ? { ...prev, ...updated } : prev));
            }
          } catch {
            setError("Unable to update user status.");
          }
        });
      }
    }
  }, [user]);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading user details...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />
      <HtmlScreen
        html={userDetailsHtml}
        title="User Details"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
    </>
  );
}

export default UserDetails;
